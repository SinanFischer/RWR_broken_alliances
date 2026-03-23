#include "tracker.as"
#include "metagame.as"
#include "helpers.as"
#include "admin_manager.as"
#include "query_helpers.as"
#include "log.as"
#include "systeme/fraktionspunkte_system/faction_points_store.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_registry.as"
#include "systeme/fraktionspunkte_system/ai/faction_points_ai_tracker.as"

const string FP_CMD_SHOW       = "fp";
const string FP_CMD_STATUS     = "fp_status";
const string FP_CMD_ADD        = "fp_add";
const string FP_CMD_SET        = "fp_set";
const string FP_CMD_AI_STATUS  = "fp_ai";
const string FP_CMD_AI_TICK    = "fp_ai_tick";
const string FP_CMD_FORCE_EVENT = "fp_event"; // /fp_event <token> - Force-Execute fuer eigene Fraktion

// Debug-Command-Tracker:
// - /fp                              → Befehlsübersicht
// - /fp_status                       → Punkte aller Fraktionen
// - /fp hud on|off                   → FP-HUD umschalten (AliveHud wird Mutex)
// - /fp_add <faction_id> <amount>    → FP hinzufügen
// - /fp_set <faction_id> <amount>    → FP setzen
// - /fp_ai                           → AI-Status
// - /fp_ai_tick                      → AI sofort auslösen
// - /fp_event <token>                → Event erzwingen (ohne FP-Prüfung), eigene Fraktion
// - /event1..5                       → Event mit FP-Prüfung auslösen
class FactionPointsDebugCommandTracker : Tracker {
	protected Metagame@ m_metagame;
	protected FactionPointsStore@ m_store;
	protected FactionPointsEventRegistry@ m_eventRegistry;
	protected FactionPointsAiTracker@ m_aiTracker;
	protected FactionPointsHudTracker@ m_fpHudTracker;
	protected FactionAliveHudTracker@ m_aliveHudTracker;
	protected bool m_adminOnly = true;

	FactionPointsDebugCommandTracker(
		Metagame@ metagame,
		FactionPointsStore@ store,
		FactionPointsAiTracker@ aiTracker = null,
		bool adminOnly = true,
		FactionPointsHudTracker@ fpHudTracker = null,
		FactionAliveHudTracker@ aliveHudTracker = null
	) {
		@m_metagame = @metagame;
		@m_store = @store;
		@m_aiTracker = @aiTracker;
		@m_fpHudTracker = @fpHudTracker;
		@m_aliveHudTracker = @aliveHudTracker;
		@m_eventRegistry = FactionPointsEventRegistry(m_metagame, m_store);
		m_adminOnly = adminOnly;
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void update(float time) {
		if (m_eventRegistry is null) return;
		m_eventRegistry.update(time);
	}

	protected void handleChatEvent(const XmlElement@ event) {
		if (event is null || m_store is null) return;

		string message = event.getStringAttribute("message");
		if (!startsWith(message, "/")) return;
		array<string>@ tokens = tokenize(message);
		if (tokens.size() == 0) return;
		string commandToken = normalizeCommandToken(tokens[0]);
		bool isFpCmd = isFpCommandToken(commandToken);
		bool isEventCmd = (m_eventRegistry !is null) && m_eventRegistry.isEventCommandToken(commandToken);
		bool isSimulationCmd = (m_eventRegistry !is null) && m_eventRegistry.isSimulationCommandToken(commandToken);
		if (!isFpCmd && !isEventCmd && !isSimulationCmd) return;

		int senderId = event.getIntAttribute("player_id");
		string senderName = event.getStringAttribute("player_name");

		if (m_adminOnly && !m_metagame.getAdminManager().isAdmin(senderName, senderId)) {
			sendPrivateMessage(m_metagame, senderId, "FP command locked: admin only.");
			return;
		}

		if (commandToken == FP_CMD_FORCE_EVENT) {
			handleForceEvent(tokens, senderId);
			return;
		}

		if (isEventCmd) {
			string eventResponse;
			m_eventRegistry.tryExecute(commandToken, senderId, eventResponse);
			sendPrivateMessage(m_metagame, senderId, eventResponse);
			return;
		}
		if (isSimulationCmd) {
			string simulationResponse;
			m_eventRegistry.tryExecuteSimulation(commandToken, senderId, simulationResponse);
			sendPrivateMessage(m_metagame, senderId, simulationResponse);
			return;
		}

		if (commandToken == FP_CMD_SHOW) {
			if (tokens.size() >= 2 && tokens[1].toLowerCase() == "hud") {
				handleHudCommand(tokens, senderId);
				return;
			}
			sendUsage(senderId);
			return;
		}
		if (commandToken == FP_CMD_STATUS) {
			handleShow(senderId);
			return;
		}
		if (commandToken == FP_CMD_AI_STATUS) {
			handleAiStatus(senderId);
			return;
		}
		if (commandToken == FP_CMD_AI_TICK) {
			handleAiTick(senderId);
			return;
		}

		if (tokens.size() < 3) {
			sendUsage(senderId);
			return;
		}

		int factionId;
		int amount;
		if (!tryParseInt(tokens[1], factionId) || !tryParseInt(tokens[2], amount)) {
			sendPrivateMessage(m_metagame, senderId, "Invalid args. Use integers: /fp_add <faction_id> <amount>.");
			return;
		}

		if (factionId < 0 || factionId >= m_store.getFactionCount()) {
			sendPrivateMessage(m_metagame, senderId, "Invalid faction_id.");
			return;
		}

		if (commandToken == FP_CMD_ADD) {
			int nextValue = m_store.add(factionId, amount, true);
			sendPrivateMessage(m_metagame, senderId, "FP updated: faction " + factionId + " = " + nextValue + ".");
			return;
		}

		if (commandToken == FP_CMD_SET) {
			int nextValue = m_store.set(factionId, amount, true);
			sendPrivateMessage(m_metagame, senderId, "FP set: faction " + factionId + " = " + nextValue + ".");
		}
	}

	protected bool isFpCommandToken(const string &in token) const {
		if (token == FP_CMD_SHOW) return true;
		if (token == FP_CMD_STATUS) return true;
		if (token == FP_CMD_ADD) return true;
		if (token == FP_CMD_SET) return true;
		if (token == FP_CMD_AI_STATUS) return true;
		if (token == FP_CMD_AI_TICK) return true;
		if (token == FP_CMD_FORCE_EVENT) return true;
		return false;
	}

	protected string normalizeCommandToken(const string &in rawToken) const {
		if (rawToken.length() == 0) return "";
		string token = rawToken.toLowerCase();
		if (startsWith(token, "/")) token = token.substr(1);
		return token;
	}

	protected void handleShow(int playerId) {
		if (m_store is null) return;

		array<const XmlElement@>@ factions = getFactions(m_metagame);
		int factionCount = (factions is null) ? 0 : int(factions.size());
		if (factionCount > m_store.getFactionCount()) {
			m_store.ensureFactionCount(factionCount);
		}

		string msg = "FP: ";
		for (int i = 0; i < m_store.getFactionCount(); ++i) {
			if (i > 0) msg += " | ";
			string shortName = getFactionShortName((factions !is null && i < factionCount) ? factions[i] : null, i);
			msg += shortName + ": " + m_store.get(i);
			float cd = (m_eventRegistry !is null) ? m_eventRegistry.getCooldownRemaining(i) : 0.0f;
			if (cd > 0.0f) msg += " [cd " + int(cd + 1.0f) + "s]";
		}
		sendPrivateMessage(m_metagame, playerId, msg);
		sendUsage(playerId);
	}

	// Identical to StatsCommandTracker.getFactionShortName - first 2 chars of key or name.
	protected string getFactionShortName(const XmlElement@ faction, int factionId) {
		if (faction is null) return "F" + factionId;
		string key = faction.getStringAttribute("key");
		if (key.length() >= 2) return key.substr(0, 2);
		string name = faction.getStringAttribute("name");
		if (name.length() >= 2) return name.substr(0, 2);
		return "F" + factionId;
	}

	protected void sendUsage(int playerId) {
		string usage = "/fp_status - show FP per faction\n"
			+ "/fp hud on|off - toggle FP HUD\n"
			+ "/fp_event <token> - force-execute event (no FP check)\n"
			+ "/fp_add <fid> <n> - add FP\n"
			+ "/fp_set <fid> <n> - set FP\n"
			+ "/fp_ai - AI status\n"
			+ "/fp_ai_tick - trigger AI tick now";
		if (m_eventRegistry !is null) usage += "\n" + m_eventRegistry.getUsage();
		sendPrivateMessage(m_metagame, playerId, usage);
	}

	// /fp hud on|off: schaltet FP-HUD, deaktiviert gegenseitig das andere HUD (Mutex).
	protected void handleHudCommand(array<string>@ tokens, int playerId) {
		if (m_fpHudTracker is null) {
			sendPrivateMessage(m_metagame, playerId, "[FP-HUD] Not installed.");
			return;
		}
		string sub = (tokens.size() >= 3) ? tokens[2].toLowerCase() : "";
		if (sub == "on") {
			m_fpHudTracker.setEnabled(true);
			if (m_aliveHudTracker !is null && m_aliveHudTracker.isEnabled()) {
				m_aliveHudTracker.setEnabled(false);
				sendPrivateMessage(m_metagame, playerId, "[FP-HUD] ON. Alive-HUD automatically disabled.");
			} else {
				sendPrivateMessage(m_metagame, playerId, "[FP-HUD] ON.");
			}
		} else if (sub == "off") {
			m_fpHudTracker.setEnabled(false);
			sendPrivateMessage(m_metagame, playerId, "[FP-HUD] OFF.");
		} else {
			string fpState    = (m_fpHudTracker !is null && m_fpHudTracker.isEnabled()) ? "ON" : "OFF";
			string aliveState = (m_aliveHudTracker !is null && m_aliveHudTracker.isEnabled()) ? "ON" : "OFF";
			sendPrivateMessage(m_metagame, playerId,
				"[HUD] FP-HUD: " + fpState + " | Alive-HUD: " + aliveState +
				" | /fp hud on  /fp hud off");
		}
	}

	protected void handleForceEvent(array<string>@ tokens, int playerId) {
		if (m_eventRegistry is null) {
			sendPrivateMessage(m_metagame, playerId, "Event registry not available.");
			return;
		}
		if (tokens.size() < 2) {
			sendPrivateMessage(m_metagame, playerId, "Usage: /fp_event <token>  e.g. /fp_event event4");
			return;
		}
		string token = tokens[1].toLowerCase();
		const XmlElement@ playerInfo = getPlayerInfo(m_metagame, playerId);
		if (playerInfo is null) {
			sendPrivateMessage(m_metagame, playerId, "Player not found.");
			return;
		}
		int factionId = playerInfo.getIntAttribute("faction_id");
		if (factionId < 0) {
			sendPrivateMessage(m_metagame, playerId, "Invalid faction.");
			return;
		}
		string response;
		m_eventRegistry.tryForceExecuteFaction(token, factionId, response);
		sendPrivateMessage(m_metagame, playerId, "[Force] " + response);
	}

	protected void handleAiStatus(int playerId) {
		if (m_aiTracker is null) {
			sendPrivateMessage(m_metagame, playerId, "FP-AI: not installed.");
			return;
		}

		float secs = m_aiTracker.getSecondsUntilNextTick();
		int secsRounded = int(secs + 0.5f);
		string msg = "FP-AI: next tick in " + secsRounded + "s | last: " + m_aiTracker.getLastSummary();
		sendPrivateMessage(m_metagame, playerId, msg);
	}

	protected void handleAiTick(int playerId) {
		if (m_aiTracker is null) {
			sendPrivateMessage(m_metagame, playerId, "FP-AI: not installed.");
			return;
		}

		string result;
		m_aiTracker.forceTick(result);
		sendPrivateMessage(m_metagame, playerId, "FP-AI tick: " + result);
	}

	protected bool tryParseInt(const string &in s, int &out value) {
		if (s.length() == 0) return false;
		for (uint i = 0; i < s.length(); ++i) {
			string c = s.substr(i, 1);
			if (i == 0 && c == "-") continue;
			if (c < "0" || c > "9") return false;
		}
		value = parseInt(s);
		return true;
	}

	protected array<string>@ tokenize(const string &in input) {
		array<string>@ raw = input.split(" ");
		array<string>@ cleaned = array<string>();
		for (uint i = 0; i < raw.size(); ++i) {
			string t = raw[i];
			if (t.length() == 0) continue;
			cleaned.insertLast(t);
		}
		return cleaned;
	}
}

