// /blackops3 – Admin-Command: spawnt vest_blackops3.carry_item bei Spielerposition (zum Testen).
// Weste ist nicht in der Waffenkammer (in_stock=0).

#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"

const string CMD_BLACKOPS3 = "blackops3";
const string VEST_KEY = "vest_blackops3.carry_item";
const float SPAWN_OFFSET = 5.0f;

// --------------------------------------------
class BlackOps3VestCommandTracker : Tracker {
	protected Metagame@ m_metagame;

	BlackOps3VestCommandTracker(Metagame@ metagame) {
		@m_metagame = metagame;
	}

	void start() {}
	void update(float time) {}

	protected void handleChatEvent(const XmlElement@ event) {
		string message = event.getStringAttribute("message");
		if (!startsWith(message, "/") || !checkCommand(message, CMD_BLACKOPS3)) return;
		if (!m_metagame.getAdminManager().isAdmin(event.getStringAttribute("player_name"), event.getIntAttribute("player_id"))) return;

		int senderId = event.getIntAttribute("player_id");
		spawnVestNearPlayer(senderId);
	}

	void spawnVestNearPlayer(int senderId) {
		const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
		if (playerInfo is null) {
			sendPrivateMessage(m_metagame, senderId, "Player not found.");
			return;
		}
		const XmlElement@ characterInfo = getCharacterInfo(m_metagame, playerInfo.getIntAttribute("character_id"));
		if (characterInfo is null) {
			sendPrivateMessage(m_metagame, senderId, "No character (dead/spectating?).");
			return;
		}
		Vector3 pos = stringToVector3(characterInfo.getStringAttribute("position"));
		pos.m_values[0] += SPAWN_OFFSET;

		string c = "<command class='create_instance' instance_class='carry_item' instance_key='" + VEST_KEY +
			"' position='" + pos.toString() + "' faction_id='0' />";
		m_metagame.getComms().send(c);
		sendPrivateMessage(m_metagame, senderId, "Black Ops Vest III spawned.");
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }
}
