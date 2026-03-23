#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/faction_points_store.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_interface.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event1_support_squad.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event2_company_attack.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event3_defense_response.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event4_base_reinforcement.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event5_vehicle_support.as"

class FactionPointsPendingExecution {
	FactionPointsEvent@ m_event;
	int m_playerId = -1;
	int m_factionId = -1;
	int m_cost = 0;
	float m_remainingSeconds = 0.0f;
	string m_location = "";
}

// Event-Registry (Registry = zentrale Event-Verwaltung und Lookup).
class FactionPointsEventRegistry {
	protected Metagame@ m_metagame;
	protected FactionPointsStore@ m_store;
	protected FactionPointsEvent1SupportSquad@ m_event1;
	protected FactionPointsEvent2CompanyAttack@ m_event2;
	protected FactionPointsEvent3DefenseResponse@ m_event3;
	protected FactionPointsEvent4BaseReinforcement@ m_event4;
	protected FactionPointsEvent5VehicleSupport@ m_event5;
	protected array<FactionPointsPendingExecution@> m_pendingExecutions;

	FactionPointsEventRegistry(Metagame@ metagame, FactionPointsStore@ store) {
		@m_metagame = @metagame;
		@m_store = @store;
		@m_event1 = FactionPointsEvent1SupportSquad(m_metagame);
		@m_event2 = FactionPointsEvent2CompanyAttack(m_metagame);
		@m_event3 = FactionPointsEvent3DefenseResponse(m_metagame);
		@m_event4 = FactionPointsEvent4BaseReinforcement(m_metagame);
		@m_event5 = FactionPointsEvent5VehicleSupport(m_metagame);
	}

	bool isEventCommandToken(const string &in token) const {
		if (token == m_event1.getCommandToken()) return true;
		if (token == m_event2.getCommandToken()) return true;
		if (token == m_event3.getCommandToken()) return true;
		if (token == m_event4.getCommandToken()) return true;
		if (token == m_event5.getCommandToken()) return true;
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
			"), /event3 (cost " + m_event3.getCost() + "), /event3_sim (simulation)" +
			", /event4 (cost " + m_event4.getCost() + "), /event5 (cost " + m_event5.getCost() + ")";
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
			response = "FP store not available.";
			return false;
		}

		FactionPointsEvent@ ev = getEventByToken(token);
		if (ev is null) {
			response = "Unknown event.";
			return false;
		}

		const XmlElement@ playerInfo = getPlayerInfo(m_metagame, playerId);
		if (playerInfo is null) {
			response = "Player not found.";
			return false;
		}
		int factionId = playerInfo.getIntAttribute("faction_id");
		if (factionId < 0) {
			response = "Invalid faction.";
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
			response = "Unknown simulation command.";
			return false;
		}

		const XmlElement@ playerInfo = getPlayerInfo(m_metagame, playerId);
		if (playerInfo is null) {
			response = "Player not found.";
			return false;
		}
		int factionId = playerInfo.getIntAttribute("faction_id");
		if (factionId < 0) {
			response = "Invalid faction.";
			return false;
		}

		return m_event3.simulateAtFriendlyBase(factionId, response);
	}

	// Force-Execute: überspringt FP-Check und FP-Abzug. Nur für Admin-Debug-Commands.
	bool tryForceExecuteFaction(const string &in token, int factionId, string &out response) {
		FactionPointsEvent@ ev = getEventByToken(token);
		if (ev is null) {
			response = "Unknown event: " + token;
			return false;
		}
		ensureFactionCountFromWorld();
		string reason;
		if (!ev.canExecute(-1, factionId, reason)) {
			response = ev.getDisplayName() + " cannot execute: " + reason;
			return false;
		}
		string location = resolveLocationForEvent(ev, factionId);
		string executionResponse;
		bool ok = executeImmediateEvent(ev, -1, factionId, 0, location, executionResponse);
		response = ok
			? "[Force] " + executionResponse + " (no FP deducted)"
			: "[Force] Error: " + executionResponse;
		return ok;
	}

	bool tryExecuteForFaction(const string &in token, int factionId, string &out response) {
		if (m_store is null) {
			response = "FP store not available.";
			return false;
		}

		FactionPointsEvent@ ev = getEventByToken(token);
		if (ev is null) {
			response = "Unknown event.";
			return false;
		}
		if (ev.isPlayerEvent()) {
			response = ev.getDisplayName() + " is a player event and requires player_id.";
			return false;
		}
		if (factionId < 0) {
			response = "Invalid faction.";
			return false;
		}

		return tryExecuteEvent(ev, -1, factionId, response);
	}

	protected bool tryExecuteEvent(FactionPointsEvent@ ev, int playerId, int factionId, string &out response) {
		ensureFactionCountFromWorld();
		if (factionId >= m_store.getFactionCount()) {
			response = "Faction index out of FP store range.";
			return false;
		}

		string reason;
		if (!ev.canExecute(playerId, factionId, reason)) {
			response = ev.getDisplayName() + " not executed: " + reason;
			return false;
		}

		int cost = ev.getCost();
		if (!m_store.canSpend(factionId, cost)) {
			response = "Not enough FP for " + ev.getDisplayName() + " (cost " + cost + ", current " + m_store.get(factionId) + ").";
			return false;
		}

		string location = resolveLocationForEvent(ev, factionId);
		m_store.spend(factionId, cost, true);
		sendFriendlyAnnouncement(ev, factionId, cost, location);
		sendEnemyAnnouncement(ev, factionId, cost, location);

		float delay = ev.getAnnouncementDelaySeconds();
		if (delay < 0.0f) delay = 0.0f;

		if (delay > 0.0f) {
			queueExecution(ev, playerId, factionId, cost, delay, location);
			response = ev.getDisplayName() + " scheduled in " + int(delay) + "s " + formatCostSuffix(cost) + " (remaining " + m_store.get(factionId) + ").";
			return true;
		}

		string immediateResponse;
		bool ok = executeImmediateEvent(ev, playerId, factionId, cost, location, immediateResponse);
		if (!ok) {
			m_store.add(factionId, cost, true);
			response = ev.getDisplayName() + " aborted: " + immediateResponse + " (refund +" + cost + " FP).";
			return false;
		}

		response = immediateResponse + " " + formatCostSuffix(cost) + " (remaining " + m_store.get(factionId) + ").";
		return true;
	}

	protected void queueExecution(FactionPointsEvent@ ev, int playerId, int factionId, int cost, float delaySeconds, const string &in location) {
		FactionPointsPendingExecution@ pending = FactionPointsPendingExecution();
		@pending.m_event = @ev;
		pending.m_playerId = playerId;
		pending.m_factionId = factionId;
		pending.m_cost = cost;
		pending.m_remainingSeconds = delaySeconds;
		pending.m_location = location;
		m_pendingExecutions.insertLast(pending);
	}

	protected bool executeImmediateEvent(FactionPointsEvent@ ev, int playerId, int factionId, int cost, const string &in location, string &out response) {
		string result;
		if (!ev.execute(playerId, factionId, result)) {
			response = result;
			return false;
		}

		sendFriendlyExecution(ev, factionId, cost, location);
		sendEnemyExecution(ev, factionId, cost, location);
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
			pending.m_location,
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

	protected void sendFriendlyAnnouncement(FactionPointsEvent@ ev, int factionId, int cost, const string &in location) {
		if (ev is null) return;
		string txt = ev.getFriendlyAnnouncementText();
		sendFactionMessageIfText(factionId, "Commander: ", txt, cost, location);
	}

	protected void sendFriendlyExecution(FactionPointsEvent@ ev, int factionId, int cost, const string &in location) {
		if (ev is null) return;
		string txt = ev.getFriendlyExecutionText();
		sendFactionMessageIfText(factionId, "Commander: ", txt, cost, location);
	}

	protected void sendEnemyAnnouncement(FactionPointsEvent@ ev, int sourceFactionId, int cost, const string &in location) {
		if (ev is null) return;
		string txt = ev.getEnemyAnnouncementText();
		sendEnemyFactionMessagesIfText(sourceFactionId, "Enemy Commander: ", txt, cost, location);
	}

	protected void sendEnemyExecution(FactionPointsEvent@ ev, int sourceFactionId, int cost, const string &in location) {
		if (ev is null) return;
		string txt = ev.getEnemyExecutionText();
		sendEnemyFactionMessagesIfText(sourceFactionId, "Enemy Commander: ", txt, cost, location);
	}

	protected void sendFactionMessageIfText(int factionId, const string &in prefix, const string &in text, int cost, const string &in location) {
		if (text.length() == 0) return;
		sendFactionMessage(m_metagame, factionId, prefix + appendLocationIfAny(text, location) + " " + formatCostSuffix(cost));
	}

	protected void sendEnemyFactionMessagesIfText(int sourceFactionId, const string &in prefix, const string &in text, int cost, const string &in location) {
		if (text.length() == 0) return;
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;
		for (uint i = 0; i < factions.size(); ++i) {
			int factionId = int(i);
			if (factionId == sourceFactionId) continue;
			sendFactionMessage(m_metagame, factionId, prefix + appendLocationIfAny(text, location) + " " + formatCostSuffix(cost));
		}
	}

	protected string resolveLocationForEvent(FactionPointsEvent@ ev, int factionId) {
		if (ev is null) return "";
		if (ev.getCommandToken() == FP_EVENT2_TOKEN) {
			string baseName;
			if (m_event2.tryGetTargetBaseName(factionId, baseName)) return baseName;
		}
		if (ev.getCommandToken() == FP_EVENT3_TOKEN) {
			string baseName;
			if (m_event3.tryGetLostBaseName(factionId, baseName)) return baseName;
		}
		if (ev.getCommandToken() == FP_EVENT4_TOKEN) {
			string baseName;
			if (m_event4.tryGetTargetBaseName(factionId, baseName)) return baseName;
		}
		if (ev.getCommandToken() == FP_EVENT5_TOKEN) {
			string baseName;
			if (m_event5.tryGetTargetBaseName(factionId, baseName)) return baseName;
		}
		return "";
	}

	protected string appendLocationIfAny(const string &in text, const string &in location) const {
		if (location.length() == 0) return text;
		return text + " At base " + location + ".";
	}

	protected string formatCostSuffix(int cost) const {
		if (cost < 0) cost = 0;
		return "(-" + cost + " FP)";
	}

	protected FactionPointsEvent@ getEventByToken(const string &in token) const {
		if (token == m_event1.getCommandToken()) return m_event1;
		if (token == m_event2.getCommandToken()) return m_event2;
		if (token == m_event3.getCommandToken()) return m_event3;
		if (token == m_event4.getCommandToken()) return m_event4;
		if (token == m_event5.getCommandToken()) return m_event5;
		return null;
	}

	protected void ensureFactionCountFromWorld() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;
		m_store.ensureFactionCount(int(factions.size()));
	}
}

