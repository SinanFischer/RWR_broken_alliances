#include "tracker.as"
#include "metagame.as"
#include "helpers.as"
#include "admin_manager.as"
#include "query_helpers.as"
#include "log.as"
#include "systeme/fraktionspunkte_system/faction_points_store.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_registry.as"
#include "systeme/fraktionspunkte_system/ai/faction_points_ai_tracker.as"

const string FP_CMD_SHOW = "fp";
const string FP_CMD_ADD = "fp_add";
const string FP_CMD_SET = "fp_set";
const string FP_CMD_AI_STATUS = "fp_ai";
const string FP_CMD_AI_TICK = "fp_ai_tick";

// Debug-Command-Tracker:
// - /fp
// - /fp_add <faction_id> <amount>
// - /fp_set <faction_id> <amount>
class FactionPointsDebugCommandTracker : Tracker {
	protected Metagame@ m_metagame;
	protected FactionPointsStore@ m_store;
	protected FactionPointsEventRegistry@ m_eventRegistry;
	protected FactionPointsAiTracker@ m_aiTracker;
	protected bool m_adminOnly = true;

	FactionPointsDebugCommandTracker(Metagame@ metagame, FactionPointsStore@ store, FactionPointsAiTracker@ aiTracker = null, bool adminOnly = true) {
		@m_metagame = @metagame;
		@m_store = @store;
		@m_aiTracker = @aiTracker;
		@m_eventRegistry = FactionPointsEventRegistry(m_metagame, m_store);
		m_adminOnly = adminOnly;
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	protected void handleChatEvent(const XmlElement@ event) {
		if (event is null || m_store is null) return;

		string message = event.getStringAttribute("message");
		if (!startsWith(message, "/")) return;
		array<string>@ tokens = tokenize(message);
		if (tokens.size() == 0) return;
		string commandToken = normalizeCommandToken(tokens[0]);
		bool isFpCmd = isFpCommandToken(commandToken);
		bool isEventCmd = (m_eventRegistry !is null) && m_eventRegistry.isEventCommandToken(commandToken);
		if (!isFpCmd && !isEventCmd) return;

		int senderId = event.getIntAttribute("player_id");
		string senderName = event.getStringAttribute("player_name");

		if (m_adminOnly && !m_metagame.getAdminManager().isAdmin(senderName, senderId)) {
			sendPrivateMessage(m_metagame, senderId, "FP command locked: admin only.");
			return;
		}

		if (isEventCmd) {
			string eventResponse;
			m_eventRegistry.tryExecute(commandToken, senderId, eventResponse);
			sendPrivateMessage(m_metagame, senderId, eventResponse);
			return;
		}

		if (commandToken == FP_CMD_SHOW) {
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
		if (token == FP_CMD_ADD) return true;
		if (token == FP_CMD_SET) return true;
		if (token == FP_CMD_AI_STATUS) return true;
		if (token == FP_CMD_AI_TICK) return true;
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

		string msg = "FP | ";
		for (int i = 0; i < m_store.getFactionCount(); ++i) {
			if (i > 0) msg += " | ";
			msg += "F" + i + ": " + m_store.get(i);
		}
		sendPrivateMessage(m_metagame, playerId, msg);
	}

	protected void sendUsage(int playerId) {
		string usage = "Usage: /fp | /fp_add <faction_id> <amount> | /fp_set <faction_id> <amount> | /fp_ai | /fp_ai_tick";
		if (m_eventRegistry !is null) usage += " | " + m_eventRegistry.getUsage();
		sendPrivateMessage(m_metagame, playerId, usage);
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

