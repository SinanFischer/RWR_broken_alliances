// Vehicle interval spawn: Light 2-4 min, Medium 5-8 min, Heavy 12-15 min.
// Per-faction timers; random interval; spawn at random owned base (center + offset).
// Leading faction (most bases) gets no Heavy spawn - timer reset only.
//
// Factions: from getFactions() - no fixed IDs.
// Vehicle keys: configurable above (Simple/Medium/Heavy).
//
// /vehicle, /vehicle_spawn, /fahrzeug: status for own faction only (light/medium/heavy + times).
// Status access only if player has been in faction for at least 3 min (otherwise: private message access denied + time remaining).
// /vehicle test: instant test spawn (admins only).

#include "tracker.as"
#include "helpers.as"
#include "log.as"
#include "query_helpers.as"
#include "admin_manager.as"
#include "events/captain_spawn_command_tracker.as"

// =============================================================================
// CONFIG - vehicle keys per category (index = faction index)
// Light: Humvee, Jeep, ATV, Quad, VFS, Trucks, Wiesel, ...
// Medium: APC, Noxe, Hovercraft, Cargo Truck, Vulcan, SEV90, Radio Jammer, ...
// Heavy: Alt-Tanks, Sheriff (M551), Scorpion, Legion, M528, Croc (Flamethrower tank)
// =============================================================================
const string SIMPLE_VEHICLE_KEYS = "humvee.vehicle,jeep.vehicle,jeep_1.vehicle,jeep_2.vehicle,vfs_sport.vehicle,willys_mb.vehicle,wiesel_tow.vehicle,wiesel_mk20.vehicle,atv_base.vehicle,atv_armory.vehicle,vfs_base.vehicle,truck.vehicle,truck_1.vehicle,truck_2.vehicle";

const string MEDIUM_VEHICLE_KEYS = "humvee.vehicle,wiesel_mk20.vehicle,apc.vehicle,apc_1.vehicle,apc_2.vehicle,vulcan_tank.vehicle,noxe.vehicle,hovercraft.vehicle,cargo_truck.vehicle,sev90.vehicle,radio_jammer.vehicle,m113_tank_acav.vehicle,m113_tank_mortar.vehicle";
const string CARGO_TRUCK_KEY = "cargo_truck.vehicle";
const string HEAVY_VEHICLE_KEYS = "tank_alt.vehicle,tank_1_alt.vehicle,tank_2_alt.vehicle,m551.vehicle,fv101.vehicle,legion.vehicle,m528.vehicle,flamer_tank.vehicle";

// DEBUG: 5 s after start, commander message with next spawn
const bool DEBUG_ANNOUNCE_LOADED = false;  // was for debugging: "Next spawn: ... at ..." per faction; use /vehicle for status
const float DEBUG_ANNOUNCE_DELAY = 5.0f;

// Min time in faction (seconds) to see /vehicle status - prevents faction switch to read intel
const float VEHICLE_INTEL_MIN_FACTION_TIME_SEC = 180.0f;

class VehicleIntervalSpawn : Tracker {
	protected Metagame@ m_metagame;
	protected CaptainSpawnCommandTracker@ m_captainTracker;

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
	// Per player: last known faction and join time = when we first saw them in that faction (set in update(), not on first /vehicle)
	protected dictionary m_vehicleIntelFaction;
	protected dictionary m_vehicleIntelJoinTime;
	protected float m_vehicleIntelSyncAccum = 0.0f;
	protected float VEHICLE_INTEL_SYNC_INTERVAL = 1.0f;

	// Cargo+Captain: Captain+Bodyguards 2 s NACH Cargo Truck spawnen (verhindert Spawn-Kill), Messages gleichzeitig
	protected int m_pendingCargoCaptainFactionId = -1;
	protected float m_pendingCargoCaptainTimer = 0.0f;
	protected float CARGO_CAPTAIN_SPAWN_DELAY = 2.0f;  // Captain 2 s nach Cargo Truck = weniger Spawn-Kills
	protected string m_pendingCargoCaptainPos = "";
	protected int m_pendingCargoCaptainBaseId = -1;
	// Bei Admin-Test (enemy): Private Message mit Feind-Intel an diesen Spieler
	protected int m_pendingCargoCaptainNotifyPlayerId = -1;

	// Leading faction cache (getBases-Queries pro Frame reduzieren)
	protected int m_cachedLeadingFactionId = -1;
	protected float m_cachedLeadingFactionTime = -999.0f;
	protected float LEADING_FACTION_CACHE_SEC = 5.0f;

	VehicleIntervalSpawn(Metagame@ metagame, CaptainSpawnCommandTracker@ captainTracker = null) {
		@m_metagame = @metagame;
		@m_captainTracker = @captainTracker;
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

		// Join-Zeit pro Spieler: sobald wir ihn in einer Fraktion sehen (nicht erst beim ersten /vehicle)
		m_vehicleIntelSyncAccum += time;
		if (m_vehicleIntelSyncAccum >= VEHICLE_INTEL_SYNC_INTERVAL) {
			m_vehicleIntelSyncAccum = 0.0f;
			updateVehicleIntelFactionTimes();
		}

		// Cargo+Captain: Captain+Bodyguards + Messages 2 s nach Cargo Truck (verhindert Spawn-Kill)
		if (m_pendingCargoCaptainFactionId >= 0 && m_pendingCargoCaptainPos.length() > 0) {
			m_pendingCargoCaptainTimer -= time;
			if (m_pendingCargoCaptainTimer <= 0.0f) {
				if (m_captainTracker !is null) {
					Vector3 pos = stringToVector3(m_pendingCargoCaptainPos);
					m_captainTracker.spawnCaptainSquadAt(m_pendingCargoCaptainFactionId, pos, m_pendingCargoCaptainBaseId);
				}
				sendCargoCaptainEventMessages(m_pendingCargoCaptainFactionId, m_pendingCargoCaptainNotifyPlayerId);
				m_pendingCargoCaptainFactionId = -1;
				m_pendingCargoCaptainPos = "";
				m_pendingCargoCaptainBaseId = -1;
				m_pendingCargoCaptainNotifyPlayerId = -1;
			}
		}

		// DEBUG: 5 s after start, commander message
		if (DEBUG_ANNOUNCE_LOADED && !m_debugAnnounced) {
			m_debugAccum += time;
			if (m_debugAccum >= DEBUG_ANNOUNCE_DELAY) {
				m_debugAnnounced = true;
				runDebugAnnounce();
			}
		}

		// Leading faction 1x pro Frame + Cache: Reduziert getBases-Queries (sonst m_numFactions^2 pro Frame)
		int leadingFactionId = getLeadingFactionIdCached();

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
				if (factionId == leadingFactionId) {
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

	// Cached: Refresh every LEADING_FACTION_CACHE_SEC (Basis-Eroberungen sind selten)
	protected int getLeadingFactionIdCached() {
		if (m_metagameTime - m_cachedLeadingFactionTime >= LEADING_FACTION_CACHE_SEC) {
			m_cachedLeadingFactionId = getLeadingFactionId();
			m_cachedLeadingFactionTime = m_metagameTime;
		}
		return m_cachedLeadingFactionId;
	}

	// Setzt Join-Zeit, sobald Spieler in einer Fraktion sichtbar sind (nicht erst beim ersten /vehicle)
	protected void updateVehicleIntelFactionTimes() {
		array<const XmlElement@>@ players = getPlayers(m_metagame);
		if (players is null) return;
		for (uint i = 0; i < players.size(); ++i) {
			int playerId = players[i].getIntAttribute("player_id");
			int factionId = players[i].getIntAttribute("faction_id");
			if (factionId < 0) continue;
			string key = "" + playerId;
			bool hasRecord = m_vehicleIntelFaction.exists(key);
			int storedFaction = hasRecord ? int(m_vehicleIntelFaction[key]) : -1;
			if (!hasRecord || storedFaction != factionId) {
				m_vehicleIntelFaction[key] = factionId;
				m_vehicleIntelJoinTime[key] = m_metagameTime;
			}
		}
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

	// Vehicle key: zufällig aus Kategorie - jede Fraktion hat gleiche Chance auf jedes Fahrzeug
	protected string getVehicleKeyForFaction(int factionId, int category) {
		array<string>@ keys = category == 0 ? m_simpleKeys : (category == 1 ? m_mediumKeys : m_heavyKeys);
		if (keys.size() == 0) return category == 0 ? "jeep.vehicle" : (category == 1 ? "apc.vehicle" : "tank.vehicle");
		uint idx = rand(0, int(keys.size()) - 1);
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

	/** Von außen aufrufbar: Belohnungs-Spawn Medium oder Heavy an gegebener Basis.
	 *  preferHeavy = true → 50% Heavy/50% Medium; false → 50% Medium/50% Heavy. */
	void spawnRewardVehicleAtBase(int factionId, int baseId, bool preferHeavy = true) {
		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (bases is null) return;
		const XmlElement@ base = getBase(m_metagame, baseId);
		if (base is null) return;
		if (base.getIntAttribute("owner_id") != factionId) return;

		string posStr = base.getStringAttribute("position");
		if (posStr.length() == 0) return;

		string baseName = base.getStringAttribute("name");
		if (baseName.length() == 0) baseName = base.getStringAttribute("key");
		if (baseName.length() == 0) baseName = "Base " + base.getIntAttribute("id");

		Vector3 pos = stringToVector3(posStr);
		float angle = float(rand(0, 5)) * 1.047f;
		pos.m_values[0] += OFFSET_XZ * cos(angle);
		pos.m_values[1] += OFFSET_Y;
		pos.m_values[2] += OFFSET_XZ * sin(angle);

		// Medium (1) oder Heavy (2): preferHeavy → 50/50, sonst 50/50
		int category = (preferHeavy && rand(0, 1) == 1) ? 2 : 1;
		string vehicleKey = getVehicleKeyForFaction(factionId, category);
		string vehicleName = getVehicleDisplayName(vehicleKey);

		string cmd = "<command class='create_instance' faction_id='" + factionId +
			"' position='" + pos.toString() +
			"' instance_class='vehicle' instance_key='" + vehicleKey + "' />";
		m_metagame.getComms().send(cmd);

		string msg = "Reinforcement arrived: " + vehicleName + " at " + baseName + " (cargo delivery reward).";
		sendFactionMessage(m_metagame, factionId, msg, 0.95);
		_log("VehicleIntervalSpawn: reward spawn " + vehicleKey + " for faction " + factionId + " at " + baseName, 1);
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

		// Cargo Truck: Captain+Bodyguards 2 s spaeter spawnen (verhindert Spawn-Kill) + Faction-Messages
		if (vehicleKey == CARGO_TRUCK_KEY && m_captainTracker !is null) {
			int baseId = base.getIntAttribute("id");
			m_pendingCargoCaptainFactionId = factionId;
			m_pendingCargoCaptainPos = pos.toString();
			m_pendingCargoCaptainBaseId = baseId;
			m_pendingCargoCaptainTimer = CARGO_CAPTAIN_SPAWN_DELAY;
		}
	}

	// Faction-Namen aus getFactions (name oder key)
	protected string getFactionName(int factionId) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factionId < 0 || uint(factionId) >= factions.size()) return "Faction " + factionId;
		string n = factions[factionId].getStringAttribute("name");
		if (n.length() > 0) return n;
		return factions[factionId].getStringAttribute("key");
	}

	// Nachrichten bei Cargo+Captain-Event: eigene Fraktion + alle Feinde (2 s nach Vehicle-Meldung)
	// notifyPlayerId >= 0: Zusätzlich Private Message mit Feind-Intel (Admin-Test)
	protected void sendCargoCaptainEventMessages(int factionId, int notifyPlayerId = -1) {
		string ownMsg = "[ALERT] Captain arrived with the supply convoy and will defend our position.";
		sendFactionMessage(m_metagame, factionId, ownMsg, 1.5f);

		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;
		string enemyName = getFactionName(factionId);
		string enemyMsg = "[ALERT] Enemy " + enemyName + " Cargo truck reported - escorted by a Captain. Take him out; he's carrying high-value weapons.";
		for (uint i = 0; i < factions.size(); ++i) {
			if (int(i) == factionId) continue;
			sendFactionMessage(m_metagame, int(i), enemyMsg, 1.5f);
		}
		if (notifyPlayerId >= 0)
			sendPrivateMessage(m_metagame, notifyPlayerId, "[Test] Your faction receives: " + enemyMsg);
	}

	/** Admin-Test: Cargo Truck + Captain an zufälliger Basis einer Feind-Fraktion spawnen. Gibt (success, baseName, factionName) zurück. */
	protected bool spawnCargoTruckWithCaptainForEnemy(int playerFactionId, string &out baseName, string &out enemyFactionName) {
		tryInitFactions();
		if (m_numFactions == 0) return false;
		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (bases is null) return false;

		// Feind-Fraktionen mit mindestens einer Basis
		array<int> enemyFactionIds;
		for (uint i = 0; i < m_numFactions; ++i) {
			int fid = int(i);
			if (fid == playerFactionId) continue;
			bool hasBase = false;
			for (uint b = 0; b < bases.size(); ++b) {
				if (bases[b].getIntAttribute("owner_id") == fid) { hasBase = true; break; }
			}
			if (hasBase) enemyFactionIds.insertLast(fid);
		}
		if (enemyFactionIds.size() == 0) return false;

		int enemyId = enemyFactionIds[rand(0, int(enemyFactionIds.size()) - 1)];
		enemyFactionName = getFactionName(enemyId);

		array<int> ownedIndices;
		for (uint i = 0; i < bases.size(); ++i) {
			if (bases[i].getIntAttribute("owner_id") == enemyId)
				ownedIndices.insertLast(int(i));
		}
		if (ownedIndices.size() == 0) return false;

		int idx = rand(0, ownedIndices.size() - 1);
		const XmlElement@ base = bases[ownedIndices[idx]];
		string posStr = base.getStringAttribute("position");
		if (posStr.length() == 0) return false;

		baseName = base.getStringAttribute("name");
		if (baseName.length() == 0) baseName = base.getStringAttribute("key");
		if (baseName.length() == 0) baseName = "Base " + base.getIntAttribute("id");

		Vector3 pos = stringToVector3(posStr);
		float angle = float(idx) * 1.047f;
		pos.m_values[0] += OFFSET_XZ * cos(angle);
		pos.m_values[1] += OFFSET_Y;
		pos.m_values[2] += OFFSET_XZ * sin(angle);

		string cmd = "<command class='create_instance' faction_id='" + enemyId +
			"' position='" + pos.toString() +
			"' instance_class='vehicle' instance_key='" + CARGO_TRUCK_KEY + "' />";
		m_metagame.getComms().send(cmd);

		sendFactionMessage(m_metagame, enemyId, "Reinforcement arrived: Cargo Truck at " + baseName + ".", 0.95);

		if (m_captainTracker !is null) {
			int baseId = base.getIntAttribute("id");
			m_pendingCargoCaptainFactionId = enemyId;
			m_pendingCargoCaptainPos = pos.toString();
			m_pendingCargoCaptainBaseId = baseId;
			m_pendingCargoCaptainTimer = CARGO_CAPTAIN_SPAWN_DELAY;
		}

		_log("VehicleIntervalSpawn: test_enemy_cargo_captain - Cargo + Captain at " + baseName + " for enemy faction " + enemyId, 1);
		return true;
	}

	/** Admin-Test: Cargo Truck + Captain an zufälliger Basis der Spieler-Fraktion spawnen. */
	protected bool spawnCargoTruckWithCaptain(int factionId) {
		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (bases is null) return false;

		array<int> ownedIndices;
		for (uint i = 0; i < bases.size(); ++i) {
			if (bases[i].getIntAttribute("owner_id") == factionId)
				ownedIndices.insertLast(int(i));
		}
		if (ownedIndices.size() == 0) return false;

		int idx = rand(0, ownedIndices.size() - 1);
		const XmlElement@ base = bases[ownedIndices[idx]];
		string posStr = base.getStringAttribute("position");
		if (posStr.length() == 0) return false;

		string baseName = base.getStringAttribute("name");
		if (baseName.length() == 0) baseName = base.getStringAttribute("key");
		if (baseName.length() == 0) baseName = "Base " + base.getIntAttribute("id");

		Vector3 pos = stringToVector3(posStr);
		float angle = float(idx) * 1.047f;
		pos.m_values[0] += OFFSET_XZ * cos(angle);
		pos.m_values[1] += OFFSET_Y;
		pos.m_values[2] += OFFSET_XZ * sin(angle);

		string cmd = "<command class='create_instance' faction_id='" + factionId +
			"' position='" + pos.toString() +
			"' instance_class='vehicle' instance_key='" + CARGO_TRUCK_KEY + "' />";
		m_metagame.getComms().send(cmd);

		sendFactionMessage(m_metagame, factionId, "Reinforcement arrived: Cargo Truck at " + baseName + ".", 0.95);

		if (m_captainTracker !is null) {
			int baseId = base.getIntAttribute("id");
			m_pendingCargoCaptainFactionId = factionId;
			m_pendingCargoCaptainPos = pos.toString();
			m_pendingCargoCaptainBaseId = baseId;
			m_pendingCargoCaptainTimer = CARGO_CAPTAIN_SPAWN_DELAY;
		}

		_log("VehicleIntervalSpawn: cargo_captain_test - Cargo + Captain at " + baseName + " for faction " + factionId, 1);
		return true;
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	// /vehicle or /vehicle_spawn: status + next spawns. /vehicle test: instant spawn. /cargo_captain_test: Cargo+Captain (Admin).
	protected void handleChatEvent(const XmlElement@ event) {
		string message = event.getStringAttribute("message");
		if (!startsWith(message, "/")) return;

		int senderId = event.getIntAttribute("player_id");

		// /cargo_captain_test oder /test_cargo_captain: Admin - Cargo Truck + Captain an zufälliger Basis
		if (checkCommand(message, "cargo_captain_test") || checkCommand(message, "test_cargo_captain")) {
			if (!m_metagame.getAdminManager().isAdmin(event.getStringAttribute("player_name"), event.getIntAttribute("player_id"))) {
				sendPrivateMessage(m_metagame, senderId, "Admin only.");
				return;
			}
			tryInitFactions();
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
			if (spawnCargoTruckWithCaptain(factionId)) {
				sendPrivateMessage(m_metagame, senderId, "Cargo Captain test: Cargo Truck + Captain spawned at random owned base.");
			} else {
				sendPrivateMessage(m_metagame, senderId, "Cargo Captain test failed - faction " + factionId + " has no base.");
			}
			return;
		}

		// /test_enemy_cargo_captain oder /enemy_cargo_captain_test: Admin - Cargo Truck + Captain an Feind-Basis
		// NICHT /cargo_* verwenden - BasicCommandHandler matcht checkCommand("cargo") und spawnt zusätzlich Truck für eigene Fraktion!
		if (checkCommand(message, "test_enemy_cargo_captain") || checkCommand(message, "enemy_cargo_captain_test")) {
			if (!m_metagame.getAdminManager().isAdmin(event.getStringAttribute("player_name"), event.getIntAttribute("player_id"))) {
				sendPrivateMessage(m_metagame, senderId, "Admin only.");
				return;
			}
			const XmlElement@ player = getPlayerInfo(m_metagame, senderId);
			if (player is null) {
				sendPrivateMessage(m_metagame, senderId, "Player not found.");
				return;
			}
			int playerFactionId = player.getIntAttribute("faction_id");
			if (playerFactionId < 0) {
				sendPrivateMessage(m_metagame, senderId, "You have no faction (spectator?).");
				return;
			}
			string baseName, enemyFactionName;
			if (spawnCargoTruckWithCaptainForEnemy(playerFactionId, baseName, enemyFactionName)) {
				m_pendingCargoCaptainNotifyPlayerId = senderId;
				sendPrivateMessage(m_metagame, senderId, "Cargo Captain test (enemy): Spawned at " + baseName + " (" + enemyFactionName + "). In 2 s: faction message and private message with enemy intel.");
			} else {
				sendPrivateMessage(m_metagame, senderId, "Cargo Captain test (enemy) failed - no enemy faction with bases.");
			}
			return;
		}

		// /spawn_enemy_cargo oder /enemy_cargo_spawn: Admin - feindlicher Cargo Truck neben Spielerposition (zum Testen der Cargo-Delivery-Belohnung)
		if (checkCommand(message, "spawn_enemy_cargo") || checkCommand(message, "enemy_cargo_spawn")) {
			if (!m_metagame.getAdminManager().isAdmin(event.getStringAttribute("player_name"), event.getIntAttribute("player_id"))) {
				sendPrivateMessage(m_metagame, senderId, "Admin only.");
				return;
			}
			const XmlElement@ player = getPlayerInfo(m_metagame, senderId);
			if (player is null) {
				sendPrivateMessage(m_metagame, senderId, "Player not found.");
				return;
			}
			int playerFactionId = player.getIntAttribute("faction_id");
			if (playerFactionId < 0) playerFactionId = 0;
			const XmlElement@ charInfo = getCharacterInfo(m_metagame, player.getIntAttribute("character_id"));
			if (charInfo is null) {
				sendPrivateMessage(m_metagame, senderId, "No character (dead/spectating?).");
				return;
			}
			tryInitFactions();
			if (m_numFactions < 2) {
				sendPrivateMessage(m_metagame, senderId, "Need at least 2 factions for enemy cargo truck.");
				return;
			}
			int enemyFactionId = (playerFactionId == 0) ? 1 : 0;
			for (uint i = 0; i < m_numFactions; ++i) {
				if (int(i) != playerFactionId) { enemyFactionId = int(i); break; }
			}
			Vector3 pos = stringToVector3(charInfo.getStringAttribute("position"));
			pos.m_values[0] += 6.0f;  // etwas vor dem Spieler
			pos.m_values[1] += 2.0f;   // Boden
			string cmd = "<command class='create_instance' faction_id='" + enemyFactionId +
				"' position='" + pos.toString() +
				"' instance_class='vehicle' instance_key='" + CARGO_TRUCK_KEY + "' />";
			m_metagame.getComms().send(cmd);
			sendPrivateMessage(m_metagame, senderId, "Enemy cargo truck spawned next to you (faction " + enemyFactionId + "). Deliver to armory for reward.");
			return;
		}

		if (!checkCommand(message, "vehicle") && !checkCommand(message, "vehicle_spawn") && !checkCommand(message, "fahrzeug")) return;

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

		// 3-min check: access only if player has been in this faction for at least 3 min (prevents faction switch to read intel)
		// Join-Zeit wird in update() gesetzt (updateVehicleIntelFactionTimes); hier nur Fallback falls Sync noch nicht gelaufen
		string key = "" + senderId;
		if (!m_vehicleIntelFaction.exists(key) || int(m_vehicleIntelFaction[key]) != factionId) {
			m_vehicleIntelFaction[key] = factionId;
			m_vehicleIntelJoinTime[key] = m_metagameTime;
		}
		float joinTime = float(m_vehicleIntelJoinTime[key]);
		float elapsed = m_metagameTime - joinTime;
		if (elapsed < VEHICLE_INTEL_MIN_FACTION_TIME_SEC) {
			int remaining = int(VEHICLE_INTEL_MIN_FACTION_TIME_SEC - elapsed);
			sendPrivateMessage(m_metagame, senderId, "Negative. Vehicle status is need-to-know. Stay with us another " + formatTimerSeconds(float(remaining)) + " and we'll brief you.");
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
