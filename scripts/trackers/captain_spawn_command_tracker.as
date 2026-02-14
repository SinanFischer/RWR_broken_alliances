// Captain Spawn Command Tracker
// /captain_spawn [paradrop] – spawnt 1 Captain (vorne) + 3 orange_bodyguards bei Spielerposition
// Admin only. Captain-Position wird mit VIP-Ziel-Symbol (atlas 17) auf der Karte angezeigt, nur für eigene Fraktion.
// Bodyguards erhalten periodisch soldier_objective 'protect' auf Captain-Position → folgen ihm effektiv.
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
const int MARKER_ATLAS_VIP_OBJECTIVE = 17;
const float BODYGUARD_OBJECTIVE_INTERVAL = 5.0f;   // wie kill_commander: alle 5 s neu setzen
const float BODYGUARD_SEARCH_RADIUS = 50.0f;       // Radius um Captain, in dem Bodyguards gesucht werden
const string SOLDIER_GROUP_BODYGUARD = "orange_bodyguards";

// --------------------------------------------
class CaptainSpawnCommandTracker : Tracker {
	protected Metagame@ m_metagame;
	protected bool m_started = false;
	protected int m_captainId = -1;
	protected int m_captainFactionId = -1;
	protected bool m_captainSpawned = false;
	protected array<int> m_bodyguardIds;
	protected float m_bodyguardObjectiveTimer = 0.0f;

	CaptainSpawnCommandTracker(Metagame@ metagame) {
		@m_metagame = metagame;
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
			removeCaptainMarker();
			m_captainId = -1;
			m_bodyguardIds.resize(0);
			m_captainSpawned = false;
			return;
		}

		string pos = info.getStringAttribute("position");
		addCaptainMarker(pos);

		// Bodyguards periodisch auf Captain-Position ausrichten („Folgen/Schützen“)
		updateBodyguardObjectives(pos, time);
	}

	/** Bodyguards bekommen soldier_objective 'protect' auf aktuelle Captain-Position – alle BODYGUARD_OBJECTIVE_INTERVAL Sek. */
	void updateBodyguardObjectives(string captainPosition, float deltaTime) {
		m_bodyguardObjectiveTimer -= deltaTime;
		if (m_bodyguardObjectiveTimer > 0.0f) return;
		m_bodyguardObjectiveTimer = BODYGUARD_OBJECTIVE_INTERVAL;

		if (m_bodyguardIds.length() == 0) {
			findBodyguardsNearCaptain(captainPosition);
		}
		setBodyguardsToProtectCaptain(captainPosition);
	}

	/** Sucht orange_bodyguards in Reichweite des Captains und speichert deren IDs. */
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

	/** Sendet soldier_objective 'protect' an alle lebenden Bodyguards mit Ziel = Captain-Position. Entfernt tote IDs. */
	void setBodyguardsToProtectCaptain(string captainPosition) {
		for (int i = int(m_bodyguardIds.length()) - 1; i >= 0; --i) {
			int id = m_bodyguardIds[i];
			const XmlElement@ info = getCharacterInfo2(m_metagame, id);
			if (info is null) {
				m_bodyguardIds.removeAt(uint(i));
				continue;
			}
			XmlElement c("command");
			c.setStringAttribute("class", "soldier_objective");
			c.setIntAttribute("character_id", id);
			c.setStringAttribute("objective", "protect");
			c.setStringAttribute("target", captainPosition);
			m_metagame.getComms().send(c);
		}
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
		c.setBoolAttribute("show_in_game_view", false);
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
		m_bodyguardObjectiveTimer = 0.0f;  // erste setBodyguardsToProtectCaptain nach findBodyguards beim ersten Update

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
