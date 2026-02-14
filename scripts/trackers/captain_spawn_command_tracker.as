// Captain Spawn Command Tracker
// /captain_spawn [paradrop] – spawnt 1 Captain (vorne) + 3 orange_bodyguards bei Spielerposition
// Admin only. Captain-Position wird mit VIP-Ziel-Symbol (atlas 17) auf der Karte angezeigt, nur für eigene Fraktion.
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

// --------------------------------------------
class CaptainSpawnCommandTracker : Tracker {
	protected Metagame@ m_metagame;
	protected bool m_started = false;
	protected int m_captainId = -1;
	protected int m_captainFactionId = -1;
	protected bool m_captainSpawned = false;

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
			m_captainSpawned = false;
			return;
		}

		string pos = info.getStringAttribute("position");
		addCaptainMarker(pos);
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
		c.setBoolAttribute("show_at_screen_edge", true);
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
