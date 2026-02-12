// Fahrzeug-Intervall-Spawn: Einfache Fahrzeuge alle 2–4 min, mittlere alle 5–8 min.
// Pro Fraktion eigener Timer; zufälliges Intervall; Spawn an zufälliger Basis im Basenmittelpunkt + Offset.
// Hinweis: "Basis unter Beschuss" ist in der RWR-API nicht abfragbar – Spawn erfolgt unabhängig davon.
//
// Fraktionen: dynamisch aus getFactions() (wie faction_alive_hud_tracker) – keine festen IDs.
// Fahrzeug-Keys: oben konfigurierbar (Simple/Medium/Heavy).
//
// /vehicle, /vehicle_spawn, /fahrzeug: Status + nächste Spawns pro Fraktion.
// /vehicle test: sofort Test-Spawn für deine Fraktion (Commander-Meldung prüfen).

#include "tracker.as"
#include "helpers.as"
#include "log.as"
#include "query_helpers.as"

// =============================================================================
// KONFIGURATION – Fahrzeug-Keys pro Kategorie (Index = Fraktions-Index)
// Leicht: Humvee, Jeep-Varianten
// Mittel: APC, Wiesel, leichtes Landfahrzeug
// Schwer: Panzer
// =============================================================================
const string SIMPLE_VEHICLE_KEYS = "humvee.vehicle,jeep.vehicle,jeep_1.vehicle,jeep_2.vehicle,vfs_sport.vehicle,willys_mb.vehicle,wiesel_tow.vehicle,wiesel_mk20.vehicle";
const string MEDIUM_VEHICLE_KEYS = "apc.vehicle,apc_1.vehicle,apc_2.vehicle";
const string HEAVY_VEHICLE_KEYS = "tank.vehicle,tank_1.vehicle,tank_2.vehicle,vulcan_tank.vehicle";

// DEBUG: 5 s nach Start Commander-Meldung mit nächstem Spawn
const bool DEBUG_ANNOUNCE_LOADED = true;
const float DEBUG_ANNOUNCE_DELAY = 5.0f;

class VehicleIntervalSpawn : Tracker {
	protected Metagame@ m_metagame;

	// Intervall-Range (Sekunden): 2–4 min = 120–240, 5–8 min = 300–480
	protected int SIMPLE_INTERVAL_MIN = 120;
	protected int SIMPLE_INTERVAL_MAX = 240;
	protected int MEDIUM_INTERVAL_MIN = 300;
	protected int MEDIUM_INTERVAL_MAX = 480;

	// Spawn-Offset vom Basenmittelpunkt (m): X/Z damit nicht übereinander, Y für Boden
	protected float OFFSET_XZ = 8.0f;
	protected float OFFSET_Y = 5.0f;

	// Fahrzeug-Keys pro Kategorie (aus Config-Strings geparst)
	protected array<string> m_simpleKeys;
	protected array<string> m_mediumKeys;
	protected array<string> m_heavyKeys;

	// Pro Fraktion: Timer und nächste Spawn-Zeit (Index = Fraktions-Index aus getFactions)
	protected array<float> m_simpleTimer;
	protected array<float> m_mediumTimer;

	// Anzahl Fraktionen (dynamisch)
	protected uint m_numFactions = 0;

	// DEBUG: Einmalige Meldung 5 s nach Start
	protected float m_debugAccum = 0.0f;
	protected bool m_debugAnnounced = false;

	VehicleIntervalSpawn(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_simpleKeys = parseKeys(SIMPLE_VEHICLE_KEYS);
		m_mediumKeys = parseKeys(MEDIUM_VEHICLE_KEYS);
		m_heavyKeys = parseKeys(HEAVY_VEHICLE_KEYS);
		m_metagame.getComms().send("<command class='set_metagame_event' name='chat_event' enabled='1' />");
	}

	// Komma-separierte Keys parsen
	protected array<string> parseKeys(const string &in csv) {
		array<string> result;
		int start = 0;
		for (uint i = 0; i <= csv.length(); ++i) {
			if (i == csv.length() || csv.substr(i, 1) == ",") {
				string part = csv.substr(start, int(i) - start);
				if (part.length() > 0) result.insertLast(part);
				start = int(i) + 1;
			}
		}
		return result;
	}

	void start() {
		tryInitFactions();
	}

	// Lazy-Init: wie faction_alive_hud_tracker – getFactions() kann bei Quick Match erst später Daten liefern
	protected void tryInitFactions() {
		if (m_numFactions > 0) return;
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;

		m_numFactions = factions.size();
		m_simpleTimer.resize(m_numFactions);
		m_mediumTimer.resize(m_numFactions);
		for (uint i = 0; i < m_numFactions; ++i) {
			m_simpleTimer[i] = float(rand(SIMPLE_INTERVAL_MIN, SIMPLE_INTERVAL_MAX));
			m_mediumTimer[i] = float(rand(MEDIUM_INTERVAL_MIN, MEDIUM_INTERVAL_MAX));
		}
		_log("VehicleIntervalSpawn: Gestartet mit " + m_numFactions + " Fraktionen.", 1);
	}

	void update(float time) {
		tryInitFactions(); // Lazy-Init falls start() zu früh war (Quick Match)
		if (m_numFactions == 0) return;

		// DEBUG: 5 s nach Start Commander-Meldung
		if (DEBUG_ANNOUNCE_LOADED && !m_debugAnnounced) {
			m_debugAccum += time;
			if (m_debugAccum >= DEBUG_ANNOUNCE_DELAY) {
				m_debugAnnounced = true;
				runDebugAnnounce();
			}
		}

		for (uint i = 0; i < m_numFactions; ++i) {
			int factionId = int(i);

			m_simpleTimer[i] -= time;
			if (m_simpleTimer[i] <= 0.0f) {
				spawnVehicle(factionId, true);
				m_simpleTimer[i] = float(rand(SIMPLE_INTERVAL_MIN, SIMPLE_INTERVAL_MAX));
			}

			m_mediumTimer[i] -= time;
			if (m_mediumTimer[i] <= 0.0f) {
				spawnVehicle(factionId, false);
				m_mediumTimer[i] = float(rand(MEDIUM_INTERVAL_MIN, MEDIUM_INTERVAL_MAX));
			}
		}
	}

	// DEBUG: Skript geladen + nächster Spawn pro Fraktion (Sekunden, Basis-Name)
	protected void runDebugAnnounce() {
		string msg = "VehicleIntervalSpawn: Script loaded.";
		sendFactionMessage(m_metagame, 0, msg, 0.95);

		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (bases is null) return;

		for (uint i = 0; i < m_numFactions; ++i) {
			int factionId = int(i);

			// Nächste Spawns: Simple oder Medium (wenn Timer kleiner)
			bool simple = m_simpleTimer[i] <= m_mediumTimer[i];
			float nextSec = simple ? m_simpleTimer[i] : m_mediumTimer[i];
			string vehicleKey = simple ? getVehicleKeyForFaction(factionId, true) : getVehicleKeyForFaction(factionId, false);
			string vehicleName = getVehicleDisplayName(vehicleKey);

			// Basis-Name: wo wird gespawnt? (Predict: nächste Basis, die Fraktion gehört)
			array<int> ownedIndices;
			for (uint b = 0; b < bases.size(); ++b) {
				if (bases[b].getIntAttribute("owner_id") == factionId)
					ownedIndices.insertLast(int(b));
			}
			string baseName = "unknown";
			if (ownedIndices.size() > 0) {
				int idx = rand(0, ownedIndices.size() - 1);
				const XmlElement@ base = bases[ownedIndices[idx]];
				baseName = base.getStringAttribute("name");
				if (baseName.length() == 0) baseName = base.getStringAttribute("key");
				if (baseName.length() == 0) baseName = "Base " + base.getIntAttribute("id");
			}

			msg = "Next spawn: " + vehicleName + " in " + int(nextSec) + "s at " + baseName + ".";
			sendFactionMessage(m_metagame, factionId, msg, 0.95);
		}
	}

	// Fahrzeug-Key je Fraktion (Index in m_simpleKeys/m_mediumKeys)
	protected string getVehicleKeyForFaction(int factionId, bool simple) {
		array<string>@ keys = simple ? m_simpleKeys : m_mediumKeys;
		if (keys.size() == 0) return simple ? "jeep.vehicle" : "apc.vehicle";
		uint idx = uint(factionId) % keys.size();
		return keys[idx];
	}

	// Anzeigename aus Vehicle-Definition (name-Attribut) – z. B. "Humvee", "SIK-AP APC", "Leopold II Tank"
	protected string getVehicleDisplayName(const string &in vehicleKey) {
		if (vehicleKey.length() == 0) return "vehicle";
		string name = getResourceName(m_metagame, vehicleKey, "vehicle");
		if (name.length() > 0) return name;
		// Fallback: Key ohne .vehicle
		int dot = vehicleKey.findFirst(".vehicle");
		string base = (dot >= 0) ? vehicleKey.substr(0, dot) : vehicleKey;
		return base.length() > 0 ? base : "vehicle";
	}

	protected void spawnVehicle(int factionId, bool simple) {
		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (bases is null) return;

		array<int> ownedIndices;
		for (uint i = 0; i < bases.size(); ++i) {
			if (bases[i].getIntAttribute("owner_id") == factionId) {
				ownedIndices.insertLast(int(i));
			}
		}
		if (ownedIndices.size() == 0) {
			_log("VehicleIntervalSpawn: Fraktion " + factionId + " hat keine Basis – kein Spawn", 1);
			return;
		}

		// Zufällige Basis wählen
		int idx = rand(0, ownedIndices.size() - 1);
		const XmlElement@ base = bases[ownedIndices[idx]];
		string posStr = base.getStringAttribute("position");
		if (posStr.length() == 0) return;

		string baseName = base.getStringAttribute("name");
		if (baseName.length() == 0) baseName = base.getStringAttribute("key");
		if (baseName.length() == 0) baseName = "Base " + base.getIntAttribute("id");

		Vector3 pos = stringToVector3(posStr);
		float angle = float(idx) * 1.047f;
		pos.m_values[0] += OFFSET_XZ * cos(angle);
		pos.m_values[1] += OFFSET_Y;
		pos.m_values[2] += OFFSET_XZ * sin(angle);

		string vehicleKey = getVehicleKeyForFaction(factionId, simple);
		string vehicleName = getVehicleDisplayName(vehicleKey);

		string cmd = "<command class='create_instance' faction_id='" + factionId +
			"' position='" + pos.toString() +
			"' instance_class='vehicle' instance_key='" + vehicleKey + "' />";
		m_metagame.getComms().send(cmd);

		// Commander-Meldung: Verstärkung, Basis-Name, Fahrzeug-Name
		string msg = "Reinforcement arrived: " + vehicleName + " at " + baseName + ".";
		sendFactionMessage(m_metagame, factionId, msg, 0.95);

		_log("VehicleIntervalSpawn: " + vehicleKey + " für Fraktion " + factionId + " an " + baseName + " (" + pos.toString() + ")", 1);
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	// /vehicle oder /vehicle_spawn: Status + nächste Spawns. /vehicle test: sofort Spawn für deine Fraktion.
	protected void handleChatEvent(const XmlElement@ event) {
		string message = event.getStringAttribute("message");
		if (!startsWith(message, "/")) return;
		if (!checkCommand(message, "vehicle") && !checkCommand(message, "vehicle_spawn") && !checkCommand(message, "fahrzeug")) return;

		int senderId = event.getIntAttribute("player_id");

		// /vehicle test oder /vehicle_spawn test: sofort Spawn für Spieler-Fraktion
		int space = message.findFirst(" ");
		string arg = "";
		if (space >= 0 && space + 1 < int(message.length()))
			arg = message.substr(space + 1, message.length() - space - 1);
		if (arg.length() > 0 && arg.toLowerCase() == "test") {
				const XmlElement@ player = getPlayerInfo(m_metagame, senderId);
				if (player is null) {
					sendPrivateMessage(m_metagame, senderId, "Player nicht gefunden.");
					return;
				}
				int factionId = player.getIntAttribute("faction_id");
				if (factionId < 0) {
					sendPrivateMessage(m_metagame, senderId, "Du hast keine Fraktion (Beobachter?).");
					return;
				}
				spawnVehicle(factionId, true); // Simple spawn
				sendPrivateMessage(m_metagame, senderId, "Test-Spawn: Simple-Fahrzeug für Fraktion " + factionId + " gespawnt. Commander-Meldung sollte erscheinen.");
				return;
		}

		// Status-Ausgabe – Lazy-Init falls noch nicht (Quick Match, wie faction_alive_hud_tracker)
		tryInitFactions();
		if (m_numFactions == 0) {
			sendPrivateMessage(m_metagame, senderId, "VehicleIntervalSpawn: Noch keine Fraktionen. Warte auf Match-Start, dann /vehicle erneut.");
			return;
		}

		array<const XmlElement@>@ factions = getFactions(m_metagame);
		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (factions is null || factions.size() == 0) return;

		string block = "VehicleIntervalSpawn | " + m_numFactions + " Fraktionen | Simple 2-4min, Medium 5-8min\n";

		for (uint i = 0; i < m_numFactions; ++i) {
			int fid = int(i);
			string fName = (factions !is null && uint(fid) < factions.size()) ? factions[fid].getStringAttribute("key") : "F" + fid;
			if (fName.length() < 2) fName = "F" + fid;

			float nextSec = (m_simpleTimer[i] <= m_mediumTimer[i]) ? m_simpleTimer[i] : m_mediumTimer[i];
			string vehicleKey = (m_simpleTimer[i] <= m_mediumTimer[i]) ? getVehicleKeyForFaction(fid, true) : getVehicleKeyForFaction(fid, false);
			string vehicleName = getVehicleDisplayName(vehicleKey);

			string baseName = "?";
			if (bases !is null) {
				for (uint b = 0; b < bases.size(); ++b) {
					if (bases[b].getIntAttribute("owner_id") == fid) {
						baseName = bases[b].getStringAttribute("name");
						if (baseName.length() == 0) baseName = bases[b].getStringAttribute("key");
						break;
					}
				}
			}

			block += fName + ": " + vehicleName + " in " + int(nextSec) + "s @ " + baseName + "\n";
		}
		block += "--- /vehicle test = sofort Spawn deiner Fraktion ---";
		sendPrivateMessage(m_metagame, senderId, block);
	}
}
