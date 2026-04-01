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
const string FP_CMD_AI_STATUS  = "fp_ai";  // intern; wird als /fp ai Sub-Command geparst
const string FP_CMD_AI_TICK    = "fp_ai_tick";
const string FP_CMD_FORCE_EVENT = "fp_event"; // /fp_event <token> - Force-Execute fuer eigene Fraktion

// Debug-Command-Tracker:
// - /fp stats, /fp_status, /fp hud   → fuer alle Spieler (Info / HUD)
// - /event1..5, /event3_sim, /fp_event, /fp_add/set, /fp ai* → nur Admins (Ausfuehrung & Cheats)
class FactionPointsDebugCommandTracker : Tracker {
	protected Metagame@ m_metagame;
	protected FactionPointsStore@ m_store;
	protected FactionPointsEventRegistry@ m_eventRegistry;
	protected FactionPointsAiTracker@ m_aiTracker;
	protected FactionPointsHudTracker@ m_fpHudTracker;
	protected FactionAliveHudTracker@ m_aliveHudTracker;
	// Reserviert (API): frueher globaler Admin-Lock; Berechtigung jetzt ueber requiresAdminForCommand().
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
		bool isEventCmd = (m_eventRegistry !is null) && m_eventRegistry.isEventCommandToken(commandToken);
		bool isSimulationCmd = (m_eventRegistry !is null) && m_eventRegistry.isSimulationCommandToken(commandToken);
		if (!isFpCommandToken(commandToken) && !isEventCmd && !isSimulationCmd) return;

		int senderId = event.getIntAttribute("player_id");
		string senderName = event.getStringAttribute("player_name");
		bool isAdmin = m_metagame.getAdminManager().isAdmin(senderName, senderId);

		if (requiresAdminForCommand(commandToken, isEventCmd, isSimulationCmd) && !isAdmin) {
			sendPrivateMessage(m_metagame, senderId, "FP: this command is admin only.");
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
			if (tokens.size() >= 2) {
				string sub = tokens[1].toLowerCase();
				if (sub == "hud") {
					handleHudCommand(tokens, senderId);
					return;
				}
				if (sub == "stats") {
					handleStatsCommand(senderId);
					return;
				}
				// /fp ai [tick] → Admin-only Sub-Command
				if (sub == "ai") {
					if (!isAdmin) {
						sendPrivateMessage(m_metagame, senderId, "FP: this command is admin only.");
						return;
					}
					if (tokens.size() >= 3 && tokens[2].toLowerCase() == "tick") {
						handleAiTick(senderId);
					} else {
						handleAiStatus(senderId);
					}
					return;
				}
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

	// Direkte Event-Ausfuehrung (/event1..), Force, Simulation und FP-Cheats: nur Admin.
	// /fp, /fp_status, /fp hud bleiben fuer alle (ohne Admin).
	protected bool requiresAdminForCommand(
		const string &in commandToken,
		bool isEventCmd,
		bool isSimulationCmd
	) const {
		if (isEventCmd || isSimulationCmd) return true;
		if (commandToken == FP_CMD_FORCE_EVENT) return true;
		if (commandToken == FP_CMD_ADD || commandToken == FP_CMD_SET) return true;
		if (commandToken == FP_CMD_AI_STATUS || commandToken == FP_CMD_AI_TICK) return true;
		return false;
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

	// /fp stats: zeigt FP nur fuer Fraktionen mit mind. 1 lebendem Soldaten.
	protected void handleStatsCommand(int playerId) {
		if (m_store is null) return;

		array<const XmlElement@>@ factions = getFactions(m_metagame);
		int factionCount = (factions is null) ? 0 : int(factions.size());
		if (factionCount > m_store.getFactionCount()) {
			m_store.ensureFactionCount(factionCount);
		}

		string msg = "=== FP Stats ===\n";
		bool anyAlive = false;
		for (int i = 0; i < factionCount; ++i) {
			// Fraktion gilt als "im Spiel" wenn mind. 1 Soldat lebt
			array<const XmlElement@>@ chars = getCharacters(m_metagame, i);
			int alive = (chars is null) ? 0 : int(chars.size());
			if (alive == 0) continue;

			anyAlive = true;
			string shortName = getFactionShortName(factions[i], i);
			msg += shortName + ": " + m_store.get(i) + " FP\n";
		}
		if (!anyAlive) msg += "(no active factions found)";

		sendPrivateMessage(m_metagame, playerId, msg);
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
		string usage = "/fp stats - FP der lebenden Fraktionen\n"
			+ "/fp hud on|off - FP-HUD umschalten\n"
			+ "(admin) /fp_event <token> - Event erzwingen (kein FP-Check)\n"
			+ "(admin) /fp_add <fid> <n> - FP addieren\n"
			+ "(admin) /fp_set <fid> <n> - FP setzen\n"
			+ "(admin) /fp ai - AI-Status\n"
			+ "(admin) /fp ai tick - AI-Tick jetzt ausloesen";
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

		string plannerStatus = m_aiTracker.getPlannerStatus();
		string lastEvent = m_aiTracker.getLastSummary();
		sendPrivateMessage(m_metagame, playerId, plannerStatus + "\nLast event: " + lastEvent);
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

