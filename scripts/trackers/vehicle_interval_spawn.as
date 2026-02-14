// Vehicle interval spawn: Light 2-4 min, Medium 5-8 min, Heavy 12-15 min.
// Per-faction timers; random interval; spawn at random owned base (center + offset).
// Leading faction (most bases) gets no Heavy spawn - timer reset only.
//
// Factions: from getFactions() - no fixed IDs.
// Vehicle keys: configurable above (Simple/Medium/Heavy).
//
// /vehicle, /vehicle_spawn, /fahrzeug: status for own faction only (light/medium/heavy + times).
// Status access only if player has been in faction for at least 4 min (otherwise commander: access denied + time remaining).
// /vehicle test: instant test spawn (admins only).

#include "tracker.as"
#include "helpers.as"
#include "log.as"
#include "query_helpers.as"
#include "admin_manager.as"

// =============================================================================
// CONFIG - vehicle keys per category (index = faction index)
// Light: Humvee, Jeep, ATV, Quad, VFS, Trucks, Wiesel, ...
// Medium: APC, Noxe, Hovercraft, Cargo Truck, Vulcan, SEV90, Radio Jammer, ...
// Heavy: Alt-Tanks, Sheriff (M551), Scorpion, Legion, M528, Croc (Flamethrower tank)
// =============================================================================
const string SIMPLE_VEHICLE_KEYS = "humvee.vehicle,jeep.vehicle,jeep_1.vehicle,jeep_2.vehicle,vfs_sport.vehicle,willys_mb.vehicle,wiesel_tow.vehicle,wiesel_mk20.vehicle,atv_base.vehicle,atv_armory.vehicle,vfs_base.vehicle,truck.vehicle,truck_1.vehicle,truck_2.vehicle";

const string MEDIUM_VEHICLE_KEYS = "humvee.vehicle,wiesel_mk20.vehicle,apc.vehicle,apc_1.vehicle,apc_2.vehicle,vulcan_tank.vehicle,noxe.vehicle,hovercraft.vehicle,cargo_truck.vehicle,sev90.vehicle,radio_jammer.vehicle";
const string HEAVY_VEHICLE_KEYS = "tank_alt.vehicle,tank_1_alt.vehicle,tank_2_alt.vehicle,m551.vehicle,fv101.vehicle,legion.vehicle,m528.vehicle,flamer_tank.vehicle";

// DEBUG: 5 s after start, commander message with next spawn
const bool DEBUG_ANNOUNCE_LOADED = true;
const float DEBUG_ANNOUNCE_DELAY = 5.0f;

// Min time in faction (seconds) to see /vehicle status - prevents faction switch to read intel
const float VEHICLE_INTEL_MIN_FACTION_TIME_SEC = 240.0f;

class VehicleIntervalSpawn : Tracker {
	protected Metagame@ m_metagame;

	// Interval range (seconds): Light 2-4 min, Medium 5-8 min, Heavy 12-15 min
	protected int SIMPLE_INTERVAL_MIN = 120;
	protected int SIMPLE_INTERVAL_MAX = 240;
	protected int MEDIUM_INTERVAL_MIN = 300;
	protected int MEDIUM_INTERVAL_MAX = 480;
	protected int HEAVY_INTERVAL_MIN = 720;
	protected int HEAVY_INTERVAL_MAX = 900;

	// Spawn offset from base center (m): X/Z to spread, Y for ground
	protected float OFFSET_XZ = 8.0f;
	protected float OFFSET_Y = 5.0f;

	// Vehicle keys per category (parsed from config strings)
	protected array<string> m_simpleKeys;
	protected array<string> m_mediumKeys;
	protected array<string> m_heavyKeys;

	// Per faction: timers (index = faction index from getFactions)
	protected array<float> m_simpleTimer;
	protected array<float> m_mediumTimer;
	protected array<float> m_heavyTimer;

	// Number of factions (dynamic)
	protected uint m_numFactions = 0;

	// DEBUG: one-time message 5 s after start
	protected float m_debugAccum = 0.0f;
	protected bool m_debugAnnounced = false;

	// Running game time (seconds) for 4-min check
	protected float m_metagameTime = 0.0f;
	// Per player: last known faction and "join" time (first /vehicle or faction switch)
	protected dictionary m_vehicleIntelFaction;
	protected dictionary m_vehicleIntelJoinTime;

	VehicleIntervalSpawn(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_simpleKeys = parseKeys(SIMPLE_VEHICLE_KEYS);
		m_mediumKeys = parseKeys(MEDIUM_VEHICLE_KEYS);
		m_heavyKeys = parseKeys(HEAVY_VEHICLE_KEYS);
		m_metagame.getComms().send("<command class='set_metagame_event' name='chat_event' enabled='1' />");
	}

	// Parse comma-separated keys
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

	// Lazy-Init: getFactions() may not be ready at start (Quick Match)
	protected void tryInitFactions() {
		if (m_numFactions > 0) return;
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;

		m_numFactions = factions.size();
		m_simpleTimer.resize(m_numFactions);
		m_mediumTimer.resize(m_numFactions);
		m_heavyTimer.resize(m_numFactions);
		for (uint i = 0; i < m_numFactions; ++i) {
			m_simpleTimer[i] = float(rand(SIMPLE_INTERVAL_MIN, SIMPLE_INTERVAL_MAX));
			m_mediumTimer[i] = float(rand(MEDIUM_INTERVAL_MIN, MEDIUM_INTERVAL_MAX));
			m_heavyTimer[i] = float(rand(HEAVY_INTERVAL_MIN, HEAVY_INTERVAL_MAX));
		}
		_log("VehicleIntervalSpawn: Started with " + m_numFactions + " factions (Light/Medium/Heavy).", 1);
	}

	void update(float time) {
		m_metagameTime += time;
		tryInitFactions(); // Lazy-init if start() was too early (Quick Match)
		if (m_numFactions == 0) return;

		// DEBUG: 5 s after start, commander message
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
				spawnVehicle(factionId, 0);
				m_simpleTimer[i] = float(rand(SIMPLE_INTERVAL_MIN, SIMPLE_INTERVAL_MAX));
			}

			m_mediumTimer[i] -= time;
			if (m_mediumTimer[i] <= 0.0f) {
				spawnVehicle(factionId, 1);
				m_mediumTimer[i] = float(rand(MEDIUM_INTERVAL_MIN, MEDIUM_INTERVAL_MAX));
			}

			m_heavyTimer[i] -= time;
			if (m_heavyTimer[i] <= 0.0f) {
				// Leading faction (most bases) gets no Heavy spawn - timer reset only
				if (factionId == getLeadingFactionId()) {
					m_heavyTimer[i] = float(rand(HEAVY_INTERVAL_MIN, HEAVY_INTERVAL_MAX));
				} else {
					spawnVehicle(factionId, 2);
					m_heavyTimer[i] = float(rand(HEAVY_INTERVAL_MIN, HEAVY_INTERVAL_MAX));
				}
			}
		}
	}

	// Leading faction = faction with most bases (tie: lower ID wins)
	protected int getLeadingFactionId() {
		if (m_numFactions == 0) return -1;
		int leadingId = 0;
		int maxBases = getBasesForFaction(m_metagame, 0);
		for (uint i = 1; i < m_numFactions; ++i) {
			int bases = getBasesForFaction(m_metagame, int(i));
			if (bases > maxBases) {
				maxBases = bases;
				leadingId = int(i);
			}
		}
		return leadingId;
	}

	// DEBUG: script loaded + next spawn per faction (seconds, base name)
	protected void runDebugAnnounce() {
		string msg = "VehicleIntervalSpawn: script loaded.";
		sendFactionMessage(m_metagame, 0, msg, 0.95);

		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (bases is null) return;

		for (uint i = 0; i < m_numFactions; ++i) {
			int factionId = int(i);

			// Next spawn: category with smallest timer (0=Light, 1=Medium, 2=Heavy)
			int nextCat = 0;
			float nextSec = m_simpleTimer[i];
			if (m_mediumTimer[i] < nextSec) { nextSec = m_mediumTimer[i]; nextCat = 1; }
			if (m_heavyTimer[i] < nextSec)  { nextSec = m_heavyTimer[i];  nextCat = 2; }
			string vehicleKey = getVehicleKeyForFaction(factionId, nextCat);
			string vehicleName = getVehicleDisplayName(vehicleKey);

			// Base name: where spawn will be (predict: one of faction's bases)
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

	// Vehicle key per faction; category: 0=Light, 1=Medium, 2=Heavy
	protected string getVehicleKeyForFaction(int factionId, int category) {
		array<string>@ keys = category == 0 ? m_simpleKeys : (category == 1 ? m_mediumKeys : m_heavyKeys);
		if (keys.size() == 0) return category == 0 ? "jeep.vehicle" : (category == 1 ? "apc.vehicle" : "tank.vehicle");
		uint idx = uint(factionId) % keys.size();
		return keys[idx];
	}

	// Display name from vehicle definition (name attribute), e.g. "Humvee", "APC", "Tank"
	protected string getVehicleDisplayName(const string &in vehicleKey) {
		if (vehicleKey.length() == 0) return "vehicle";
		string name = getResourceName(m_metagame, vehicleKey, "vehicle");
		if (name.length() > 0) return name;
		// Fallback: Key ohne .vehicle
		int dot = vehicleKey.findFirst(".vehicle");
		string base = (dot >= 0) ? vehicleKey.substr(0, dot) : vehicleKey;
		return base.length() > 0 ? base : "vehicle";
	}

	// Display: >= 60s minutes only ("Xmin"), under 60s seconds ("Xs")
	protected string formatTimerSeconds(float sec) {
		int s = int(sec);
		if (s < 60) return "" + s + "s";
		return "" + (s / 60) + "min";
	}

	// One base name for display (random base faction currently owns). Spawn picks random at spawn time; if base is lost, next /vehicle shows another.
	protected string getOneBaseNameForFaction(int factionId) {
		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (bases is null) return "?";
		array<int> ownedIndices;
		for (uint i = 0; i < bases.size(); ++i) {
			if (bases[i].getIntAttribute("owner_id") == factionId)
				ownedIndices.insertLast(int(i));
		}
		if (ownedIndices.size() == 0) return "?";
		int idx = rand(0, ownedIndices.size() - 1);
		const XmlElement@ base = bases[ownedIndices[idx]];
		string name = base.getStringAttribute("name");
		if (name.length() == 0) name = base.getStringAttribute("key");
		if (name.length() == 0) name = "Base " + base.getIntAttribute("id");
		return name;
	}

	protected void spawnVehicle(int factionId, int category) {
		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (bases is null) return;

		array<int> ownedIndices;
		for (uint i = 0; i < bases.size(); ++i) {
			if (bases[i].getIntAttribute("owner_id") == factionId) {
				ownedIndices.insertLast(int(i));
			}
		}
		if (ownedIndices.size() == 0) {
			_log("VehicleIntervalSpawn: Faction " + factionId + " has no base - no spawn", 1);
			return;
		}

		// Pick random base
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

		string vehicleKey = getVehicleKeyForFaction(factionId, category);
		string vehicleName = getVehicleDisplayName(vehicleKey);

		string cmd = "<command class='create_instance' faction_id='" + factionId +
			"' position='" + pos.toString() +
			"' instance_class='vehicle' instance_key='" + vehicleKey + "' />";
		m_metagame.getComms().send(cmd);

		// Commander message: reinforcement, base name, vehicle name
		string msg = "Reinforcement arrived: " + vehicleName + " at " + baseName + ".";
		sendFactionMessage(m_metagame, factionId, msg, 0.95);

		_log("VehicleIntervalSpawn: " + vehicleKey + " for faction " + factionId + " at " + baseName + " (" + pos.toString() + ")", 1);
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	// /vehicle or /vehicle_spawn: status + next spawns. /vehicle test: instant spawn for your faction.
	protected void handleChatEvent(const XmlElement@ event) {
		string message = event.getStringAttribute("message");
		if (!startsWith(message, "/")) return;
		if (!checkCommand(message, "vehicle") && !checkCommand(message, "vehicle_spawn") && !checkCommand(message, "fahrzeug")) return;

		int senderId = event.getIntAttribute("player_id");

		int space = message.findFirst(" ");
		string arg = "";
		if (space >= 0 && space + 1 < int(message.length()))
			arg = message.substr(space + 1, message.length() - space - 1);

		// /vehicle test: instant spawn - admins only
		if (arg.length() > 0 && arg.toLowerCase() == "test") {
			if (!m_metagame.getAdminManager().isAdmin(event.getStringAttribute("player_name"), event.getIntAttribute("player_id"))) {
				sendPrivateMessage(m_metagame, senderId, "Admin only.");
				return;
			}
			const XmlElement@ player = getPlayerInfo(m_metagame, senderId);
			if (player is null) {
				sendPrivateMessage(m_metagame, senderId, "Player not found.");
				return;
			}
			int factionId = player.getIntAttribute("faction_id");
			if (factionId < 0) {
				sendPrivateMessage(m_metagame, senderId, "You have no faction (spectator?).");
				return;
			}
			spawnVehicle(factionId, 0);
			sendPrivateMessage(m_metagame, senderId, "Test spawn: light vehicle for faction " + factionId + " spawned.");
			return;
		}

		// Status: own faction only - light / medium / heavy (heavy may show "blocked (leading)")
		tryInitFactions();
		if (m_numFactions == 0) {
			sendPrivateMessage(m_metagame, senderId, "No factions yet. Try /vehicle after match start.");
			return;
		}

		const XmlElement@ player = getPlayerInfo(m_metagame, senderId);
		if (player is null) {
			sendPrivateMessage(m_metagame, senderId, "Player not found.");
			return;
		}
		int factionId = player.getIntAttribute("faction_id");
		if (factionId < 0 || uint(factionId) >= m_numFactions) {
			sendPrivateMessage(m_metagame, senderId, "You have no faction (spectator?).");
			return;
		}

		// 4-min check: access only if player has been in this faction for at least 4 min (prevents faction switch to read intel)
		string key = "" + senderId;
		bool hasRecord = m_vehicleIntelFaction.exists(key);
		int storedFaction = hasRecord ? int(m_vehicleIntelFaction[key]) : -1;
		if (!hasRecord || storedFaction != factionId) {
			m_vehicleIntelFaction[key] = factionId;
			m_vehicleIntelJoinTime[key] = m_metagameTime;
		}
		float joinTime = float(m_vehicleIntelJoinTime[key]);
		float elapsed = m_metagameTime - joinTime;
		if (elapsed < VEHICLE_INTEL_MIN_FACTION_TIME_SEC) {
			int remaining = int(VEHICLE_INTEL_MIN_FACTION_TIME_SEC - elapsed);
			string playerName = event.getStringAttribute("player_name");
			if (playerName.length() == 0) playerName = "Player";
			// Only commander message (player sees it as faction member; no separate private message)
			sendFactionMessage(m_metagame, factionId, "Vehicle intel access denied. " + playerName + " must be in faction for 4 min. " + formatTimerSeconds(float(remaining)) + " remaining.", 0.95);
			return;
		}

		// Per line: one currently owned base (random). If a base is lost, next /vehicle shows another owned base.
		string lightStr = "light:  " + formatTimerSeconds(m_simpleTimer[factionId]) + "  at " + getOneBaseNameForFaction(factionId) + " - " + getVehicleDisplayName(getVehicleKeyForFaction(factionId, 0));
		string mediumStr = "medium: " + formatTimerSeconds(m_mediumTimer[factionId]) + "  at " + getOneBaseNameForFaction(factionId) + " - " + getVehicleDisplayName(getVehicleKeyForFaction(factionId, 1));
		string heavyStr;
		if (factionId == getLeadingFactionId())
			heavyStr = "heavy:  blocked (leading faction)";
		else
			heavyStr = "heavy:  " + formatTimerSeconds(m_heavyTimer[factionId]) + "  at " + getOneBaseNameForFaction(factionId) + " - " + getVehicleDisplayName(getVehicleKeyForFaction(factionId, 2));

		string block = "Upcoming vehicle spawns\n" + lightStr + "\n" + mediumStr + "\n" + heavyStr;
		sendPrivateMessage(m_metagame, senderId, block);
	}
}
