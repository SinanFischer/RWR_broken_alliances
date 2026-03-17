// Legacy-Preset-Commands (manuelle Overrides, admin-only):
// /ai_fifty   – Ausgeglichen:  base_defense=0.5, border_defense=0.5
// /ai_normal  – Vanilla-Nähe: base_defense=0.1, border_defense=0.2
//
// HINWEIS: /ai_status, /ai_attack, /ai_defend werden jetzt vom
// CommanderAiAdaptiveTracker (commander_ai_adaptive_tracker.as) behandelt.

#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"

// Hinweis: CMD_AI_STATUS, CMD_AI_DEFEND, CMD_AI_ATTACK sind in commander_ai_adaptive_tracker.as definiert.
// Dieser Tracker behandelt nur noch die verbleibenden manuellen Preset-Commands.
const string CMD_AI_LEGACY_FIFTY  = "ai_fifty";
const string CMD_AI_LEGACY_NORMAL = "ai_normal";

const float DEFAULT_BASE_DEFENSE   = 0.1f;
const float DEFAULT_BORDER_DEFENSE = 0.2f;

// Interne Zustandsspeicherung – da die Engine keine Getter für commander_ai bietet,
// tracken wir die zuletzt gesetzten Werte selbst.
array<float> g_baseDef   = { DEFAULT_BASE_DEFENSE, DEFAULT_BASE_DEFENSE, DEFAULT_BASE_DEFENSE, DEFAULT_BASE_DEFENSE };
array<float> g_borderDef = { DEFAULT_BORDER_DEFENSE, DEFAULT_BORDER_DEFENSE, DEFAULT_BORDER_DEFENSE, DEFAULT_BORDER_DEFENSE };
string g_modeName        = "init_match default";

// --------------------------------------------
class CommanderAiCommandTracker : Tracker {
	protected Metagame@ m_metagame;

	CommanderAiCommandTracker(Metagame@ metagame) {
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

		if      (checkCommand(msg, CMD_AI_LEGACY_FIFTY))  { handleFifty(playerId);  }
		else if (checkCommand(msg, CMD_AI_LEGACY_NORMAL)) { handleNormal(playerId); }
	}

	// --------------------------------------------
	// /ai_fifty – base=0.5 border=0.5 (ausgeglichen)
	private void handleFifty(int playerId) {
		applyToAllFactions(0.5f, 0.5f);
		g_modeName = "FIFTY-FIFTY (ai_fifty)";
		string feedback = "[AI] Modus gesetzt: " + g_modeName;
		_log(feedback);
		sendPrivateMessage(m_metagame, playerId, feedback);
	}

	// --------------------------------------------
	// /ai_normal – base=0.1 border=0.2 (dein gewünschter Normalzustand)
	private void handleNormal(int playerId) {
		applyToAllFactions(DEFAULT_BASE_DEFENSE, DEFAULT_BORDER_DEFENSE);
		g_modeName = "NORMAL (ai_normal)";
		string feedback = "[AI] Modus gesetzt: " + g_modeName;
		_log(feedback);
		sendPrivateMessage(m_metagame, playerId, feedback);
	}

	// --------------------------------------------
	// Sendet commander_ai-Command für alle aktiven Fraktionen und aktualisiert den lokalen State.
	private void applyToAllFactions(float baseDef, float borderDef) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		for (uint i = 0; i < factions.size(); i++) {
			int fId = factions[i].getIntAttribute("id");

			string cmd = "<command class='commander_ai'"
				+ " faction='" + fId + "'"
				+ " base_defense='" + formatFloat(baseDef, "", 0, 2) + "'"
				+ " border_defense='" + formatFloat(borderDef, "", 0, 2) + "'"
				+ " />";
			m_metagame.getComms().send(cmd);

			// Lokalen State aktualisieren (Engine hat keinen Getter)
			if (fId >= 0 && fId < 4) {
				g_baseDef[fId]   = baseDef;
				g_borderDef[fId] = borderDef;
			}
		}
	}
}
