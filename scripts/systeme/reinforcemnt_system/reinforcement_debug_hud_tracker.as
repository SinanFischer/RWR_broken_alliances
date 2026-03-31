#include "metagame.as"
#include "tracker.as"
#include "query_helpers.as"
#include "helpers.as"
#include "admin_manager.as"
#include "systeme/reinforcemnt_system/reinforcement_config.as"
#include "systeme/reinforcemnt_system/reinforcement_store.as"
#include "systeme/reinforcemnt_system/hud_mutex_interface.as"

// ReinforcementDebugHudTracker:
// Kombiniertes Debug-HUD: "A/C R:X (Ys)" pro Fraktion.
// Toggle via /rs debug (Admin). Startet standardmaessig DEAKTIVIERT.
// Mutex mit ReinforcementHudTracker: nie beide gleichzeitig aktiv.
class ReinforcementDebugHudTracker : Tracker, IToggleableHud {
	protected Metagame@ m_metagame;
	protected ReinforcementStore@ m_store;
	protected IToggleableHud@ m_mutexHud;  // RS-HUD; von API nach Installation gesetzt
	protected bool m_enabled = false;
	protected float m_updateAccum = 0.0f;

	ReinforcementDebugHudTracker(Metagame@ metagame, ReinforcementStore@ store) {
		@m_metagame = @metagame;
		@m_store = @store;
		m_metagame.getComms().send("<command class='set_metagame_event' name='chat_event' enabled='1' />");
	}

	void setMutexHud(IToggleableHud@ other) { @m_mutexHud = @other; }

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void setEnabled(bool enabled) {
		m_enabled = enabled;
		if (!enabled) clearDisplay();
	}

	bool isEnabled() const { return m_enabled; }

	void update(float time) {
		if (!m_enabled) return;

		m_updateAccum += time;
		if (m_updateAccum < RS_HUD_UPDATE_INTERVAL) return;
		m_updateAccum = 0.0f;

		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;

		for (uint i = 0; i < factions.size(); ++i) {
			int fid = int(i);
			string text = buildDebugText(factions[fid], fid);
			string color = getScoreDisplayColor(factions[fid], fid);

			XmlElement cmd("command");
			cmd.setStringAttribute("class", "update_score_display");
			cmd.setIntAttribute("id", fid);
			cmd.setStringAttribute("text", text);
			cmd.setStringAttribute("color", color);
			m_metagame.getComms().send(cmd);
		}
	}

	protected void handleChatEvent(const XmlElement@ event) {
		string msg = event.getStringAttribute("message");
		if (!checkCommand(msg, "rs")) return;

		array<string> params = parseParameters(msg, "rs");
		if (params.size() == 0 || params[0].toLowerCase() != "debug") return;

		int playerId = event.getIntAttribute("player_id");
		string playerName = event.getStringAttribute("player_name");

		if (!m_metagame.getAdminManager().isAdmin(playerName, playerId)) {
			sendPrivateMessage(m_metagame, playerId, "[RS] Admin only.");
			return;
		}

		bool newState = !m_enabled;
		setEnabled(newState);

		if (newState) {
			if (m_mutexHud !is null && m_mutexHud.isEnabled()) {
				m_mutexHud.setEnabled(false);
				sendPrivateMessage(m_metagame, playerId, "[RS] Debug-HUD ON. RS-HUD disabled.");
			} else {
				sendPrivateMessage(m_metagame, playerId, "[RS] Debug-HUD ON.");
			}
		} else {
			sendPrivateMessage(m_metagame, playerId, "[RS] Debug-HUD OFF.");
		}
	}

	// Format: "A/C R:X" oder "A/C R:X (Ys)" wenn Cooldown aktiv
	private string buildDebugText(const XmlElement@ faction, int fid) const {
		array<const XmlElement@>@ chars = getCharacters(m_metagame, fid);
		int alive = (chars is null) ? 0 : int(chars.size());
		int cap   = (faction !is null) ? faction.getIntAttribute("soldier_capacity") : 0;
		int res   = m_store.getReserves(fid);
		float cd  = m_store.getEmptyCountdown(fid);

		string text = "" + alive + "/" + cap + " R:" + res;
		if (cd > 0.0f) text += " (" + int(cd) + "s)";
		return text;
	}

	private void clearDisplay() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;
		for (uint i = 0; i < factions.size(); ++i) {
			XmlElement cmd("command");
			cmd.setStringAttribute("class", "update_score_display");
			cmd.setIntAttribute("id", int(i));
			cmd.setStringAttribute("text", "");
			cmd.setStringAttribute("color", "0 0 0");
			m_metagame.getComms().send(cmd);
		}
	}

	string getScoreDisplayColor(const XmlElement@ faction, int factionId) const {
		if (faction !is null) {
			string color = faction.getStringAttribute("color");
			if (color.length() > 0) return color;
			string name = faction.getStringAttribute("name").toLowerCase();
			string key  = faction.getStringAttribute("key").toLowerCase();
			if (name.findFirst("green") >= 0 || key.findFirst("green") >= 0 || name.findFirst("united states") >= 0) return "0.0 0.5 0.1";
			if (name.findFirst("grey") >= 0 || name.findFirst("gray") >= 0 || key.findFirst("grey") >= 0 || key.findFirst("gray") >= 0 || name.findFirst("european") >= 0) return "0.3 0.3 0.3";
			if (name.findFirst("brown") >= 0 || key.findFirst("brown") >= 0 || name.findFirst("russian") >= 0) return "0.5 0.35 0.1";
		}
		if (factionId == 0) return "0.0 0.5 0.1";
		if (factionId == 1) return "0.3 0.3 0.3";
		if (factionId == 2) return "0.5 0.35 0.1";
		return "0.5 0.5 0.5";
	}
}
