// /mrl – Admin-Command: spawnt mrl.vehicle bei Spielerposition.

#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "commands/admin_command_helpers.as"

const string CMD_MRL = "mrl";
const string MRL_KEY = "m120_heavy_mortar_deploy.weapon";
const string MRL_CLASS = "weapon";
const float SPAWN_OFFSET_MRL = 1.0f; // Näher, da Item kleiner

// --------------------------------------------
class MrlSpawnCommandTracker : Tracker {
	protected Metagame@ m_metagame;

	MrlSpawnCommandTracker(Metagame@ metagame) {
		@m_metagame = metagame;
	}

	void start() {}
	void update(float time) {}

	protected void handleChatEvent(const XmlElement@ event) {
		string message = event.getStringAttribute("message");
		if (!startsWith(message, "/") || !checkCommand(message, CMD_MRL)) return;
		if (!m_metagame.getAdminManager().isAdmin(event.getStringAttribute("player_name"), event.getIntAttribute("player_id"))) return;

		int senderId = event.getIntAttribute("player_id");
		// Spawne das Item (Weapon) anstatt das Vehicle direkt
		spawnInstanceAtPlayer(m_metagame, senderId, MRL_CLASS, MRL_KEY, SPAWN_OFFSET_MRL, "MRL Artillery Weapon spawned.");
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }
}
