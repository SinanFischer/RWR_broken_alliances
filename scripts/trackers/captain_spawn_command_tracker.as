// Captain Spawn Command Tracker
// /captain_spawn [paradrop] - spawnt 1 Captain (vorne) + 3 orange_bodyguards bei Spielerposition
// Admin only. Captain-Position wird mit VIP-Ziel-Symbol (atlas 17) auf der Karte angezeigt, nur für eigene Fraktion.
// Logik wie kill_commander: Captain erhält periodisch soldier_objective 'defend' an Spawn-Position (bleibt in Base).
// Bodyguards erhalten soldier_objective 'defend' an Captain-Position → folgen ihm.
// Import aus Project Apocalypse.

#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"

const string CMD_CAPTAIN_SPAWN = "captain_spawn";
const float SPAWN_OFFSET_FWD = 5.0f;
const float SPAWN_OFFSET_SIDE = 4.0f;
const float PARADROP_HEIGHT = 50.0f;
const int MARKER_ID_CAPTAIN = 70001;
const int MARKER_ID_ENEMY_BASE = 70010;   // 70010 + factionId für Feind-Marker (max 10 Fraktionen)
const int MARKER_ATLAS_VIP_OBJECTIVE = 17;
const int MARKER_ATLAS_ENEMY_COMMANDER = 18;
const float OBJECTIVE_INTERVAL = 1.5f;              // Captain neigt zum Weglaufen - häufig setzen (1.5 s) hält ihn besser am Spawn
const float BODYGUARD_SEARCH_RADIUS = 105.0f;       // wie kill_commander: Radius für Bodyguard-Suche
const string SOLDIER_GROUP_BODYGUARD = "orange_bodyguards";

// --------------------------------------------
class CaptainSpawnCommandTracker : Tracker {
	protected Metagame@ m_metagame;
	protected bool m_started = false;
	protected int m_captainId = -1;
	protected int m_captainFactionId = -1;
	protected bool m_captainSpawned = false;
	protected string m_captainSpawnPosition = "";   // Captain soll hier bleiben (defend)
	protected array<int> m_bodyguardIds;
	protected float m_objectiveTimer = 0.0f;
	protected array<int> m_enemyFactionsSpotted;  // Fraktionen, die Cargo-Truck gespottet haben → sehen Captain als Feind

	CaptainSpawnCommandTracker(Metagame@ metagame) {
		@m_metagame = metagame;
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
		m_metagame.getComms().send("<command class='set_metagame_event' name='vehicle_spot_event' enabled='1' />");
	}

	void start() {
		m_started = true;
	}

	void update(float time) {
		if (!m_captainSpawned) return;

		if (m_captainId < 0) {
			findCaptain();
			return;
		}

		const XmlElement@ info = getCharacterInfo2(m_metagame, m_captainId);
		if (info is null) {
			cleanupOnCaptainGone();
			return;
		}
		if (info.getIntAttribute("dead") != 0) {
			cleanupOnCaptainGone();
			return;
		}

		string captainPos = info.getStringAttribute("position");
		addCaptainMarker(captainPos);
		addEnemyMarkers(captainPos);

		// Wie kill_commander: alle OBJECTIVE_INTERVAL Sek. Captain defend an Spawn, Bodyguards defend an Captain
		m_objectiveTimer -= time;
		if (m_objectiveTimer <= 0.0f) {
			m_objectiveTimer = OBJECTIVE_INTERVAL;
			if (m_captainSpawnPosition != "") {
				setCaptainObjective(m_captainSpawnPosition, "defend");
			}
			if (m_bodyguardIds.length() == 0) {
				findBodyguardsNearCaptain(captainPos);
			}
			setBodyguardsOnDefend(captainPos, "defend");
		}
	}

	/** Captain soll an Spawn-Position bleiben (defend) - verhindert Laufen zur Front. */
	void setCaptainObjective(string position, string objective) {
		XmlElement c("command");
		c.setStringAttribute("class", "soldier_objective");
		c.setIntAttribute("character_id", m_captainId);
		c.setStringAttribute("objective", objective);
		c.setStringAttribute("target", position);
		m_metagame.getComms().send(c);
	}

	/** Sucht orange_bodyguards in Reichweite (wie kill_commander 105m). */
	void findBodyguardsNearCaptain(string captainPosition) {
		m_bodyguardIds.resize(0);
		Vector3 pos = stringToVector3(captainPosition);
		array<const XmlElement@>@ chars = getCharactersNearPosition(m_metagame, pos, m_captainFactionId, BODYGUARD_SEARCH_RADIUS);
		if (chars is null) return;
		for (uint i = 0; i < chars.length(); ++i) {
			int charId = chars[i].getIntAttribute("id");
			const XmlElement@ ci = getCharacterInfo(m_metagame, charId);
			if (ci !is null && ci.getStringAttribute("soldier_group_name") == SOLDIER_GROUP_BODYGUARD) {
				m_bodyguardIds.insertLast(charId);
			}
		}
		if (m_bodyguardIds.length() > 0) {
			_log("CaptainSpawnCommandTracker: " + m_bodyguardIds.length() + " Bodyguards gefunden", 1);
		}
	}

	/** Bodyguards defend an Captain-Position (wie kill_commander setBodyguardsOnDefend). Entfernt tote IDs. */
	void setBodyguardsOnDefend(string captainPosition, string objective) {
		for (int i = int(m_bodyguardIds.length()) - 1; i >= 0; --i) {
			int id = m_bodyguardIds[i];
			const XmlElement@ info = getCharacterInfo2(m_metagame, id);
			if (info is null) {
				m_bodyguardIds.removeAt(uint(i));
				continue;
			}
			if (info.getIntAttribute("dead") != 0) {
				m_bodyguardIds.removeAt(uint(i));
				continue;
			}
			XmlElement c("command");
			c.setStringAttribute("class", "soldier_objective");
			c.setIntAttribute("character_id", id);
			c.setStringAttribute("objective", objective);
			c.setStringAttribute("target", captainPosition);
			m_metagame.getComms().send(c);
		}
	}

	/** Marker entfernen, State zurücksetzen - bei Tod oder wenn Captain nicht mehr existiert. */
	void cleanupOnCaptainGone() {
		removeCaptainMarker();
		removeEnemyMarkers();
		m_enemyFactionsSpotted.resize(0);
		m_captainId = -1;
		m_bodyguardIds.resize(0);
		m_captainSpawned = false;
		m_captainSpawnPosition = "";
	}

	protected void handleVehicleSpotEvent(const XmlElement@ event) {
		if (!m_captainSpawned || m_captainFactionId < 0) return;
		string vehicleKey = event.getStringAttribute("vehicle_key");
		if (vehicleKey.findFirst("cargo_truck") < 0) return;
		int ownerId = event.getIntAttribute("owner_id");
		int spotterFactionId = event.getIntAttribute("faction_id");
		if (ownerId != m_captainFactionId) return;  // nicht unser Cargo-Truck
		if (spotterFactionId == m_captainFactionId) return;  // eigene Fraktion spottet nicht
		for (uint i = 0; i < m_enemyFactionsSpotted.length(); ++i) {
			if (m_enemyFactionsSpotted[i] == spotterFactionId) return;  // bereits bekannt
		}
		m_enemyFactionsSpotted.insertLast(spotterFactionId);
		_log("CaptainSpawnCommandTracker: Cargo-Truck von Fraktion " + m_captainFactionId + " von Fraktion " + spotterFactionId + " gespottet - Feind sieht Captain", 1);
	}

	protected void handleCharacterKillEvent(const XmlElement@ event) {
		if (m_captainId < 0) return;
		const XmlElement@ target = event.getFirstElementByTagName("target");
		if (target is null) return;
		if (target.getIntAttribute("id") != m_captainId) return;
		cleanupOnCaptainGone();
		_log("CaptainSpawnCommandTracker: Captain gestorben, Marker entfernt", 1);
	}

	void findCaptain() {
		array<const XmlElement@>@ characters = getCharacters(m_metagame, m_captainFactionId);
		if (characters is null) return;
		for (uint i = 0; i < characters.length(); ++i) {
			int charId = characters[i].getIntAttribute("id");
			const XmlElement@ info = getCharacterInfo(m_metagame, charId);
			if (info !is null && info.getStringAttribute("soldier_group_name") == "captain") {
				m_captainId = charId;
				_log("CaptainSpawnCommandTracker: Captain gefunden, ID " + m_captainId, 1);
				return;
			}
		}
	}

	void addCaptainMarker(string position) {
		XmlElement c("command");
		c.setStringAttribute("class", "set_marker");
		c.setIntAttribute("id", MARKER_ID_CAPTAIN);
		c.setIntAttribute("faction_id", m_captainFactionId);
		c.setIntAttribute("atlas_index", MARKER_ATLAS_VIP_OBJECTIVE);
		c.setFloatAttribute("size", 0.75f);
		c.setFloatAttribute("range", 0.0f);
		c.setIntAttribute("enabled", 1);
		c.setStringAttribute("position", position);
		c.setStringAttribute("text", "Captain");
		c.setStringAttribute("type_key", "default");
		c.setBoolAttribute("show_in_map_view", true);
		c.setBoolAttribute("show_in_game_view", true); 
		c.setBoolAttribute("show_at_screen_edge", false);
		m_metagame.getComms().send(c);
	}

	void removeCaptainMarker() {
		XmlElement c("command");
		c.setStringAttribute("class", "set_marker");
		c.setIntAttribute("id", MARKER_ID_CAPTAIN);
		c.setIntAttribute("enabled", 0);
		c.setIntAttribute("faction_id", m_captainFactionId);
		m_metagame.getComms().send(c);
	}

	void addEnemyMarkers(string captainPosition) {
		for (uint i = 0; i < m_enemyFactionsSpotted.length(); ++i) {
			int fid = m_enemyFactionsSpotted[i];
			int markerId = MARKER_ID_ENEMY_BASE + fid;
			XmlElement c("command");
			c.setStringAttribute("class", "set_marker");
			c.setIntAttribute("id", markerId);
			c.setIntAttribute("faction_id", fid);
			c.setIntAttribute("atlas_index", MARKER_ATLAS_ENEMY_COMMANDER);
			c.setFloatAttribute("size", 0.75f);
			c.setFloatAttribute("range", 0.0f);
			c.setIntAttribute("enabled", 1);
			c.setStringAttribute("position", captainPosition);
			c.setStringAttribute("text", "Enemy Captain");
			c.setStringAttribute("type_key", "default");
			c.setBoolAttribute("show_in_map_view", true);
			c.setBoolAttribute("show_in_game_view", false);
			c.setBoolAttribute("show_at_screen_edge", true);
			m_metagame.getComms().send(c);
		}
	}

	void removeEnemyMarkers() {
		for (uint i = 0; i < m_enemyFactionsSpotted.length(); ++i) {
			int fid = m_enemyFactionsSpotted[i];
			int markerId = MARKER_ID_ENEMY_BASE + fid;
			XmlElement c("command");
			c.setStringAttribute("class", "set_marker");
			c.setIntAttribute("id", markerId);
			c.setIntAttribute("enabled", 0);
			c.setIntAttribute("faction_id", fid);
			m_metagame.getComms().send(c);
		}
	}

	/** Öffentlich: Spawn bei Position (z.B. von VehicleIntervalSpawn bei Cargo-Truck). */
	void spawnCaptainSquadAt(int factionId, const Vector3 &in pos) {
		if (m_captainFactionId >= 0) removeCaptainMarker();
		if (m_enemyFactionsSpotted.length() > 0) {
			removeEnemyMarkers();
			m_enemyFactionsSpotted.resize(0);
		}
		m_captainSpawnPosition = pos.toString();
		Vector3 p = pos;
		sendSpawnSoldier("captain", p, factionId);
		p.m_values[0] -= SPAWN_OFFSET_SIDE;
		sendSpawnSoldier("orange_bodyguards", p, factionId);
		p.m_values[2] += SPAWN_OFFSET_SIDE;
		sendSpawnSoldier("orange_bodyguards", p, factionId);
		p.m_values[2] -= SPAWN_OFFSET_SIDE * 2.0f;
		sendSpawnSoldier("orange_bodyguards", p, factionId);
		m_captainId = -1;
		m_captainFactionId = factionId;
		m_captainSpawned = true;
		m_bodyguardIds.resize(0);
		m_objectiveTimer = 0.0f;
		_log("CaptainSpawnCommandTracker: Squad bei Cargo-Truck " + pos.toString() + " für Fraktion " + factionId, 1);
	}

	protected void handleChatEvent(const XmlElement@ event) {
		string message = event.getStringAttribute("message");
		if (!startsWith(message, "/") || !checkCommand(message, CMD_CAPTAIN_SPAWN)) return;
		if (!m_metagame.getAdminManager().isAdmin(event.getStringAttribute("player_name"), event.getIntAttribute("player_id"))) return;

		array<string> params = parseParameters(message, CMD_CAPTAIN_SPAWN);
		bool paradrop = params.size() > 0 && (params[0] == "paradrop" || params[0] == "para" || params[0] == "1");

		int senderId = event.getIntAttribute("player_id");
		if (!trySpawnCaptainSquad(senderId, paradrop)) return;

		sendPrivateMessage(m_metagame, senderId, "Squad gespawnt (1 Captain, 3 orange_bodyguards)" + (paradrop ? " mit Paradrop" : ""));
	}

	// Liefert false, wenn Spieler/Char nicht gefunden.
	bool trySpawnCaptainSquad(int senderId, bool paradrop) {
		const XmlElement@ player = getPlayerInfo(m_metagame, senderId);
		if (player is null) {
			sendPrivateMessage(m_metagame, senderId, "Spieler nicht gefunden.");
			return false;
		}
		int factionId = player.getIntAttribute("faction_id");
		if (factionId < 0) factionId = 0;

		const XmlElement@ charInfo = getCharacterInfo(m_metagame, player.getIntAttribute("character_id"));
		if (charInfo is null) {
			sendPrivateMessage(m_metagame, senderId, "Kein Charakter (tot/spectating?).");
			return false;
		}

		Vector3 pos = stringToVector3(charInfo.getStringAttribute("position"));
		pos.m_values[0] += SPAWN_OFFSET_FWD;
		if (paradrop) pos.m_values[1] += PARADROP_HEIGHT;

		m_captainSpawnPosition = pos.toString();  // Captain defend an dieser Position (bleibt in Base)

		// Captain zuerst vorne (Guard-Position), 3 orange_bodyguards dahinter
		sendSpawnSoldier("captain", pos, factionId);
		pos.m_values[0] -= SPAWN_OFFSET_SIDE;
		sendSpawnSoldier("orange_bodyguards", pos, factionId);
		pos.m_values[2] += SPAWN_OFFSET_SIDE;
		sendSpawnSoldier("orange_bodyguards", pos, factionId);
		pos.m_values[2] -= SPAWN_OFFSET_SIDE * 2.0f;
		sendSpawnSoldier("orange_bodyguards", pos, factionId);

		sendFactionMessage(m_metagame, factionId, "Captain + 3 orange_bodyguards deployed!", 1.5f);
		_log("CaptainSpawnCommandTracker: Squad bei " + pos.toString(), 1);

		// Marker: alter Captain-Marker entfernen (falls vorheriger Spawn), dann neuen tracken
		if (m_captainFactionId >= 0) {
			removeCaptainMarker();
		}
		m_captainId = -1;
		m_captainFactionId = factionId;
		m_captainSpawned = true;
		m_bodyguardIds.resize(0);
		m_objectiveTimer = 0.0f;  // erste Objectives beim nächsten Update

		return true;
	}

	void sendSpawnSoldier(const string &in soldierKey, const Vector3 &in pos, int factionId) {
		m_metagame.getComms().send(
			"<command class='create_instance' instance_class='soldier' instance_key='" + soldierKey +
			"' position='" + pos.toString() + "' faction_id='" + factionId + "' />");
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return m_started; }
}
