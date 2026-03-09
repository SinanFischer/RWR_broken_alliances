// /ai_status  – loggt aktuelle commander_ai-Werte aller Fraktionen
// /ai_defend  – Vollverteidigung: base_defense=1.0, border_defense=1.0
// /ai_fifty   – Ausgeglichen:     base_defense=0.5, border_defense=0.5
// /ai_attack  – Voller Angriff:   base_defense=0.0, border_defense=0.0
// /ai_normal  – Vanilla-Default:  base_defense=0.1, border_defense=0.2
// Nur für Admins. Funktioniert in Quick Match und Campaign.

#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"

const string CMD_AI_STATUS = "ai_status";
const string CMD_AI_DEFEND = "ai_defend";
const string CMD_AI_FIFTY  = "ai_fifty";
const string CMD_AI_ATTACK = "ai_attack";
const string CMD_AI_NORMAL = "ai_normal";

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

		if      (checkCommand(msg, CMD_AI_STATUS)) { handleStatus(playerId); }
		else if (checkCommand(msg, CMD_AI_DEFEND)) { handleDefend(playerId); }
		else if (checkCommand(msg, CMD_AI_FIFTY))  { handleFifty(playerId);  }
		else if (checkCommand(msg, CMD_AI_ATTACK)) { handleAttack(playerId); }
		else if (checkCommand(msg, CMD_AI_NORMAL)) { handleNormal(playerId); }
	}

	// --------------------------------------------
	// /ai_status – gibt die zuletzt gesetzten Werte aller Fraktionen aus
	private void handleStatus(int playerId) {
		string msg_out = "[AI] Aktueller Modus: " + g_modeName + "\n";
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		for (uint i = 0; i < factions.size(); i++) {
			int fId = factions[i].getIntAttribute("id");
			if (fId >= 0 && fId < 4) {
				msg_out += "  Fraktion " + fId
					+ " | base_defense=" + formatFloat(g_baseDef[fId], "", 0, 2)
					+ " | border_defense=" + formatFloat(g_borderDef[fId], "", 0, 2) + "\n";
			}
		}
		_log(msg_out);
		sendPrivateMessage(m_metagame, playerId, msg_out);
	}

	// --------------------------------------------
	// /ai_defend – base=1.0 border=1.0 (alle Fraktionen verteidigen maximal)
	private void handleDefend(int playerId) {
		applyToAllFactions(1.0f, 1.0f);
		g_modeName = "VOLLVERTEIDIGUNG (ai_defend)";
		string feedback = "[AI] Modus gesetzt: " + g_modeName;
		_log(feedback);
		sendPrivateMessage(m_metagame, playerId, feedback);
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
	// /ai_attack – base=0.0 border=0.0 (voller Angriff, keine Verteidigung)
	private void handleAttack(int playerId) {
		applyToAllFactions(0.0f, 0.0f);
		g_modeName = "VOLLER ANGRIFF (ai_attack)";
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
