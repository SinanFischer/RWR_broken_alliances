// /fov true|false – Admin-Command zur Laufzeit-Steuerung der FOV Visualization.
// Steuert change_game_settings fov (Sichtkegel-Anzeige, Post-Processing).
// Nur für Admins. Kampagne + Quick Match.

#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"

const string CMD_FOV = "fov";

// --------------------------------------------
class FovCommandTracker : Tracker {
	protected Metagame@ m_metagame;

	FovCommandTracker(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	void start() {}
	void update(float time) {}
	bool hasEnded()   const { return false; }
	bool hasStarted() const { return true; }

	// --------------------------------------------
	protected void handleChatEvent(const XmlElement@ event) {
		string msg = event.getStringAttribute("message");
		if (!startsWith(msg, "/")) return;

		string playerName = event.getStringAttribute("player_name");
		int    playerId   = event.getIntAttribute("player_id");

		if (!m_metagame.getAdminManager().isAdmin(playerName, playerId)) return;

		if (!checkCommand(msg, CMD_FOV)) return;

		// Parameter parsen: /fov <true|false|1|0|on|off>
		array<string> params = parseParameters(msg, CMD_FOV);
		string arg = "";
		for (uint i = 0; i < params.size(); ++i) {
			string p = params[i].trim();
			if (p.length() > 0) { arg = p.toLowerCase(); break; }
		}

		bool enable = false;
		bool hasArg = (arg.length() > 0);

		if (!hasArg) {
			sendPrivateMessage(m_metagame, playerId, "Usage: /fov true|false (or 1|0, on|off)");
			return;
		}
		if (arg == "true" || arg == "1" || arg == "on")  enable = true;
		else if (arg == "false" || arg == "0" || arg == "off") enable = false;
		else {
			sendPrivateMessage(m_metagame, playerId, "Usage: /fov true|false (or 1|0, on|off)");
			return;
		}

		string fovVal = enable ? "1" : "0";
		m_metagame.getComms().send("<command class='change_game_settings' fov='" + fovVal + "' />");

		string status = enable ? "ON" : "OFF";
		string feedback = "[FOV] Visualization " + status;
		_log(feedback);
		sendPrivateMessage(m_metagame, playerId, feedback);
	}
}
