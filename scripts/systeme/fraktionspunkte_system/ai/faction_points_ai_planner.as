#include "log.as"
#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/faction_points_store.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_registry.as"
#include "systeme/fraktionspunkte_system/ai/faction_points_ai_config.as"
#include "systeme/fraktionspunkte_system/ai/faction_points_ai_decision_context.as"
#include "systeme/fraktionspunkte_system/ai/faction_points_ai_scorer.as"

// Planner (Planner = bewertet Optionen und waehlt die naechste Aktion).
class FactionPointsAiPlanner {
	protected Metagame@ m_metagame;
	protected FactionPointsStore@ m_store;
	protected FactionPointsEventRegistry@ m_eventRegistry;
	protected FactionPointsAiScorer m_scorer;

	FactionPointsAiPlanner(Metagame@ metagame, FactionPointsStore@ store, FactionPointsEventRegistry@ eventRegistry) {
		@m_metagame = @metagame;
		@m_store = @store;
		@m_eventRegistry = @eventRegistry;
	}

	bool tick(string &out summary) {
		summary = "AI: no action";
		if (m_store is null || m_eventRegistry is null) {
			summary = "AI: store/registry missing";
			return false;
		}

		ensureFactionCountFromWorld();
		int factionCount = m_store.getFactionCount();
		for (int factionId = 0; factionId < factionCount; ++factionId) {
			FactionPointsAiDecisionContext ctx;
			buildContext(factionId, ctx);

			string token;
			float utility = 0.0f;
			if (!selectBestEvent(ctx, token, utility)) continue;

			string response;
			bool isPlayerEvent = m_eventRegistry.isPlayerEventToken(token);
			bool ok = false;
			if (isPlayerEvent) {
				if (!ctx.m_hasActivePlayer) {
					if (FP_AI_VERBOSE_LOG) {
						_log("FP-AI: faction " + factionId + " skip /" + token + " (Player-Event ohne aktiven Spieler).", 1);
					}
					continue;
				}
				ok = m_eventRegistry.tryExecute(token, ctx.m_seedPlayerId, response);
			} else {
				ok = m_eventRegistry.tryExecuteForFaction(token, factionId, response);
			}
			if (ok) {
				int utilityPct = int(utility * 100.0f);
				summary = "AI: faction " + factionId + " executed /" + token + " (utility " + utilityPct + "%). " + response;
				return true;
			}

			if (FP_AI_VERBOSE_LOG) {
				_log("FP-AI: faction " + factionId + " /" + token + " skipped: " + response, 1);
			}
		}

		return false;
	}

	protected void buildContext(int factionId, FactionPointsAiDecisionContext &out ctx) {
		ctx.m_factionId = factionId;
		ctx.m_currentPoints = m_store.get(factionId);
		ctx.m_basesOwned = getBasesForFaction(m_metagame, factionId);
		ctx.m_seedPlayerId = findActivePlayerForFaction(factionId);
		ctx.m_hasActivePlayer = (ctx.m_seedPlayerId >= 0);
	}

	protected bool selectBestEvent(const FactionPointsAiDecisionContext &in ctx, string &out outToken, float &out outUtility) {
		outToken = "";
		outUtility = 0.0f;

		array<string> candidates = { "event1", "event2" };
		for (uint i = 0; i < candidates.size(); ++i) {
			string token = candidates[i];
			bool isPlayerEvent = m_eventRegistry.isPlayerEventToken(token);
			if (isPlayerEvent && !ctx.m_hasActivePlayer) continue;

			int cost = m_eventRegistry.getCostByToken(token);
			if (cost < 0) continue;
			if (!canSpendByPolicy(ctx.m_currentPoints, cost)) continue;

			float utility = m_scorer.scoreEventToken(token, ctx);
			if (utility < FP_AI_MIN_UTILITY_TO_SPEND) continue;
			if (utility <= outUtility) continue;

			outUtility = utility;
			outToken = token;
		}

		return outToken.length() > 0;
	}

	protected bool canSpendByPolicy(int currentPoints, int cost) const {
		if (cost < 0) return false;
		if (currentPoints < cost) return false;
		int next = currentPoints - cost;
		return next >= FP_AI_MIN_POINTS_RESERVE;
	}

	protected int findActivePlayerForFaction(int factionId) {
		array<const XmlElement@>@ players = getPlayers(m_metagame);
		if (players is null) return -1;
		for (uint i = 0; i < players.size(); ++i) {
			const XmlElement@ p = players[i];
			if (p is null) continue;
			if (p.getIntAttribute("faction_id") != factionId) continue;
			int playerId = p.getIntAttribute("player_id");
			int characterId = p.getIntAttribute("character_id");
			if (playerId < 0 || characterId < 0) continue;
			return playerId;
		}
		return -1;
	}

	protected void ensureFactionCountFromWorld() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;
		m_store.ensureFactionCount(int(factions.size()));
	}
}
