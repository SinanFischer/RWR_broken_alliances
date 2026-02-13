// Bane Spawn Command Tracker
// /bane_spawn [paradrop] – spawnt 1 Vanguard (vorne) + 1 General bei Spielerposition
// Admin only. Import aus Project Apocalypse.

#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"

const string CMD_BANE_SPAWN = "bane_spawn";
const float SPAWN_OFFSET_FWD = 5.0f;
const float SPAWN_OFFSET_SIDE = 4.0f;
const float PARADROP_HEIGHT = 50.0f;

// --------------------------------------------
class BaneSpawnCommandTracker : Tracker {
	protected Metagame@ m_metagame;
	protected bool m_started = false;

	BaneSpawnCommandTracker(Metagame@ metagame) {
		@m_metagame = metagame;
	}

	void start() {
		m_started = true;
	}

	protected void handleChatEvent(const XmlElement@ event) {
		string message = event.getStringAttribute("message");
		if (!startsWith(message, "/") || !checkCommand(message, CMD_BANE_SPAWN)) return;
		if (!m_metagame.getAdminManager().isAdmin(event.getStringAttribute("player_name"), event.getIntAttribute("player_id"))) return;

		array<string> params = parseParameters(message, CMD_BANE_SPAWN);
		bool paradrop = params.size() > 0 && (params[0] == "paradrop" || params[0] == "para" || params[0] == "1");

		int senderId = event.getIntAttribute("player_id");
		if (!trySpawnBaneSquad(senderId, paradrop)) return;

		sendPrivateMessage(m_metagame, senderId, "Squad gespawnt (1 Vanguard, 1 General)" + (paradrop ? " mit Paradrop" : ""));
	}

	// Liefert false, wenn Spieler/Char nicht gefunden.
	bool trySpawnBaneSquad(int senderId, bool paradrop) {
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

		// Vanguard zuerst vorne (Guard-Position), General dahinter
		sendSpawnSoldier("bane", pos, factionId);
		pos.m_values[0] -= SPAWN_OFFSET_SIDE;
		sendSpawnSoldier("terminator", pos, factionId);

		sendFactionMessage(m_metagame, factionId, "Vanguard + General deployed!", 1.5f);
		_log("BaneSpawnCommandTracker: Squad bei " + pos.toString(), 1);
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
