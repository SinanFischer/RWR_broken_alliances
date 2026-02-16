#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/faction_points_store.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_interface.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event1_support_squad.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event2_company_attack.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event3_defense_response.as"

class FactionPointsPendingExecution {
	FactionPointsEvent@ m_event;
	int m_playerId = -1;
	int m_factionId = -1;
	int m_cost = 0;
	float m_remainingSeconds = 0.0f;
}

// Event-Registry (Registry = zentrale Event-Verwaltung und Lookup).
class FactionPointsEventRegistry {
	protected Metagame@ m_metagame;
	protected FactionPointsStore@ m_store;
	protected FactionPointsEvent1SupportSquad@ m_event1;
	protected FactionPointsEvent2CompanyAttack@ m_event2;
	protected FactionPointsEvent3DefenseResponse@ m_event3;
	protected array<FactionPointsPendingExecution@> m_pendingExecutions;

	FactionPointsEventRegistry(Metagame@ metagame, FactionPointsStore@ store) {
		@m_metagame = @metagame;
		@m_store = @store;
		@m_event1 = FactionPointsEvent1SupportSquad(m_metagame);
		@m_event2 = FactionPointsEvent2CompanyAttack(m_metagame);
		@m_event3 = FactionPointsEvent3DefenseResponse(m_metagame);
	}

	bool isEventCommandToken(const string &in token) const {
		if (token == m_event1.getCommandToken()) return true;
		if (token == m_event2.getCommandToken()) return true;
		if (token == m_event3.getCommandToken()) return true;
		return false;
	}

	bool isSimulationCommandToken(const string &in token) const {
		return token == FP_EVENT3_SIM_TOKEN;
	}

	bool isPlayerEventToken(const string &in token) const {
		FactionPointsEvent@ ev = getEventByToken(token);
		if (ev is null) return false;
		return ev.isPlayerEvent();
	}

	string getUsage() const {
		return "Events: /event1 (cost " + m_event1.getCost() + "), /event2 (cost " + m_event2.getCost() +
			"), /event3 (cost " + m_event3.getCost() + "), /event3_sim (simulation)";
	}

	void update(float time) {
		if (m_pendingExecutions.size() == 0) return;
		if (time <= 0.0f) return;

		for (int i = int(m_pendingExecutions.size()) - 1; i >= 0; --i) {
			FactionPointsPendingExecution@ pending = m_pendingExecutions[i];
			if (pending is null || pending.m_event is null) {
				m_pendingExecutions.removeAt(i);
				continue;
			}

			pending.m_remainingSeconds -= time;
			if (pending.m_remainingSeconds > 0.0f) continue;

			string ignoredResponse;
			executeQueuedEvent(pending, ignoredResponse);
			m_pendingExecutions.removeAt(i);
		}
	}

	int getCostByToken(const string &in token) const {
		FactionPointsEvent@ ev = getEventByToken(token);
		if (ev is null) return -1;
		return ev.getCost();
	}

	bool tryExecute(const string &in token, int playerId, string &out response) {
		if (m_store is null) {
			response = "FP-Store nicht verfuegbar.";
			return false;
		}

		FactionPointsEvent@ ev = getEventByToken(token);
		if (ev is null) {
			response = "Unbekanntes Event.";
			return false;
		}

		const XmlElement@ playerInfo = getPlayerInfo(m_metagame, playerId);
		if (playerInfo is null) {
			response = "Player nicht gefunden.";
			return false;
		}
		int factionId = playerInfo.getIntAttribute("faction_id");
		if (factionId < 0) {
			response = "Ungueltige Fraktion.";
			return false;
		}

		if (ev.isPlayerEvent()) {
			return tryExecuteEvent(ev, playerId, factionId, response);
		}

		// AI-Event aus Player-Kontext: Fraktion aus Sender ableiten, Player-Kontext ignorieren.
		return tryExecuteForFaction(token, factionId, response);
	}

	bool tryExecuteSimulation(const string &in token, int playerId, string &out response) {
		if (!isSimulationCommandToken(token)) {
			response = "Unbekannter Simulation-Command.";
			return false;
		}

		const XmlElement@ playerInfo = getPlayerInfo(m_metagame, playerId);
		if (playerInfo is null) {
			response = "Player nicht gefunden.";
			return false;
		}
		int factionId = playerInfo.getIntAttribute("faction_id");
		if (factionId < 0) {
			response = "Ungueltige Fraktion.";
			return false;
		}

		return m_event3.simulateAtFriendlyBase(factionId, response);
	}

	bool tryExecuteForFaction(const string &in token, int factionId, string &out response) {
		if (m_store is null) {
			response = "FP-Store nicht verfuegbar.";
			return false;
		}

		FactionPointsEvent@ ev = getEventByToken(token);
		if (ev is null) {
			response = "Unbekanntes Event.";
			return false;
		}
		if (ev.isPlayerEvent()) {
			response = ev.getDisplayName() + " ist ein Player-Event und benoetigt player_id.";
			return false;
		}
		if (factionId < 0) {
			response = "Ungueltige Fraktion.";
			return false;
		}

		return tryExecuteEvent(ev, -1, factionId, response);
	}

	protected bool tryExecuteEvent(FactionPointsEvent@ ev, int playerId, int factionId, string &out response) {
		ensureFactionCountFromWorld();
		if (factionId >= m_store.getFactionCount()) {
			response = "Fraktionsindex ausserhalb des FP-Stores.";
			return false;
		}

		string reason;
		if (!ev.canExecute(playerId, factionId, reason)) {
			response = ev.getDisplayName() + " nicht ausgefuehrt: " + reason;
			return false;
		}

		int cost = ev.getCost();
		if (!m_store.canSpend(factionId, cost)) {
			response = "Zu wenig FP fuer " + ev.getDisplayName() + " (cost " + cost + ", current " + m_store.get(factionId) + ").";
			return false;
		}

		m_store.spend(factionId, cost, true);
		sendFriendlyAnnouncement(ev, factionId, cost);
		sendEnemyAnnouncement(ev, factionId, cost);

		float delay = ev.getAnnouncementDelaySeconds();
		if (delay < 0.0f) delay = 0.0f;

		if (delay > 0.0f) {
			queueExecution(ev, playerId, factionId, cost, delay);
			response = ev.getDisplayName() + " scheduled in " + int(delay) + "s " + formatCostSuffix(cost) + " (remaining " + m_store.get(factionId) + ").";
			return true;
		}

		string immediateResponse;
		bool ok = executeImmediateEvent(ev, playerId, factionId, cost, immediateResponse);
		if (!ok) {
			m_store.add(factionId, cost, true);
			response = ev.getDisplayName() + " aborted: " + immediateResponse + " (refund +" + cost + " FP).";
			return false;
		}

		response = immediateResponse + " " + formatCostSuffix(cost) + " (remaining " + m_store.get(factionId) + ").";
		return true;
	}

	protected void queueExecution(FactionPointsEvent@ ev, int playerId, int factionId, int cost, float delaySeconds) {
		FactionPointsPendingExecution@ pending = FactionPointsPendingExecution();
		@pending.m_event = @ev;
		pending.m_playerId = playerId;
		pending.m_factionId = factionId;
		pending.m_cost = cost;
		pending.m_remainingSeconds = delaySeconds;
		m_pendingExecutions.insertLast(pending);
	}

	protected bool executeImmediateEvent(FactionPointsEvent@ ev, int playerId, int factionId, int cost, string &out response) {
		string result;
		if (!ev.execute(playerId, factionId, result)) {
			response = result;
			return false;
		}

		sendFriendlyExecution(ev, factionId, cost);
		sendEnemyExecution(ev, factionId, cost);
		response = result;
		return true;
	}

	protected void executeQueuedEvent(FactionPointsPendingExecution@ pending, string &out response) {
		response = "queued event handled";
		if (pending is null || pending.m_event is null) return;

		string executionResponse;
		bool ok = executeImmediateEvent(
			pending.m_event,
			pending.m_playerId,
			pending.m_factionId,
			pending.m_cost,
			executionResponse
		);
		if (ok) {
			response = executionResponse;
			return;
		}

		// Defensive refund if world changed during countdown.
		if (m_store !is null && pending.m_factionId >= 0) {
			m_store.add(pending.m_factionId, pending.m_cost, true);
		}
		sendFactionMessage(m_metagame, pending.m_factionId, "Commander: Operation aborted, budget refunded (+" + pending.m_cost + " FP).");
		response = executionResponse;
	}

	protected void sendFriendlyAnnouncement(FactionPointsEvent@ ev, int factionId, int cost) {
		if (ev is null) return;
		string txt = ev.getFriendlyAnnouncementText();
		sendFactionMessageIfText(factionId, "Commander: ", txt, cost);
	}

	protected void sendFriendlyExecution(FactionPointsEvent@ ev, int factionId, int cost) {
		if (ev is null) return;
		string txt = ev.getFriendlyExecutionText();
		sendFactionMessageIfText(factionId, "Commander: ", txt, cost);
	}

	protected void sendEnemyAnnouncement(FactionPointsEvent@ ev, int sourceFactionId, int cost) {
		if (ev is null) return;
		string txt = ev.getEnemyAnnouncementText();
		sendEnemyFactionMessagesIfText(sourceFactionId, "Enemy Commander: ", txt, cost);
	}

	protected void sendEnemyExecution(FactionPointsEvent@ ev, int sourceFactionId, int cost) {
		if (ev is null) return;
		string txt = ev.getEnemyExecutionText();
		sendEnemyFactionMessagesIfText(sourceFactionId, "Enemy Commander: ", txt, cost);
	}

	protected void sendFactionMessageIfText(int factionId, const string &in prefix, const string &in text, int cost) {
		if (text.length() == 0) return;
		sendFactionMessage(m_metagame, factionId, prefix + text + " " + formatCostSuffix(cost));
	}

	protected void sendEnemyFactionMessagesIfText(int sourceFactionId, const string &in prefix, const string &in text, int cost) {
		if (text.length() == 0) return;
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;
		for (uint i = 0; i < factions.size(); ++i) {
			int factionId = int(i);
			if (factionId == sourceFactionId) continue;
			sendFactionMessage(m_metagame, factionId, prefix + text + " " + formatCostSuffix(cost));
		}
	}

	protected string formatCostSuffix(int cost) const {
		if (cost < 0) cost = 0;
		return "(-" + cost + " FP)";
	}

	protected FactionPointsEvent@ getEventByToken(const string &in token) const {
		if (token == m_event1.getCommandToken()) return m_event1;
		if (token == m_event2.getCommandToken()) return m_event2;
		if (token == m_event3.getCommandToken()) return m_event3;
		return null;
	}

	protected void ensureFactionCountFromWorld() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;
		m_store.ensureFactionCount(int(factions.size()));
	}
}

