#include "log.as"
#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/faction_points_store.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_registry.as"
#include "systeme/fraktionspunkte_system/ai/faction_points_ai_config.as"

// Planner: einfache Chance-Roll-Logik + Save-Goal-System fuer Spare Events.
class FactionPointsAiPlanner {
	protected Metagame@ m_metagame;
	protected FactionPointsStore@ m_store;
	protected FactionPointsEventRegistry@ m_eventRegistry;

	// Per-Faction-State (Indizes = faction_id)
	protected array<int>    m_prevBasesOwned; // Basisanzahl letzter Tick → Verlust-Erkennung
	protected array<string> m_saveTarget;     // aktuelles Sparziel: "event2"|"event4"|"event5"
	protected array<int>    m_minReserve;     // zufaelliger FP-Puffer nach Spare-Kauf (0..450)

	protected float m_event1Accum  = 0.0f;  // Zeit-Akkumulator fuer Event-1-Intervall
	protected bool  m_initialized  = false; // Baseline einmalig setzen beim ersten Tick

	FactionPointsAiPlanner(Metagame@ metagame, FactionPointsStore@ store, FactionPointsEventRegistry@ eventRegistry) {
		@m_metagame      = @metagame;
		@m_store         = @store;
		@m_eventRegistry = @eventRegistry;
	}

	// Haupt-Tick — wird vom AiTracker alle FP_AI_DECISION_INTERVAL Sekunden aufgerufen.
	bool tick(float time, string &out summary) {
		summary = "AI: no action";
		if (m_store is null || m_eventRegistry is null) {
			summary = "AI: store/registry missing";
			return false;
		}

		ensureFactionCount();

		bool isBaseline = !m_initialized;
		m_initialized = true;
		bool anyExecuted = false;

		// ── Event 1 (Support Squad): alle 60s, 5% Chance ─────────────────────────
		m_event1Accum += time;
		if (m_event1Accum >= FP_AI_EVENT1_INTERVAL) {
			m_event1Accum -= FP_AI_EVENT1_INTERVAL;
			for (int fid = 0; fid < m_store.getFactionCount(); ++fid) {
				if (!canAfford(fid, "event1")) continue;
				if (!rollChance(FP_AI_EVENT1_CHANCE)) continue;
				string response;
				bool ok = tryExecuteEvent("event1", fid, response);
				if (ok) {
					summary = "AI: faction " + fid + " executed /event1. " + response;
					anyExecuted = true;
				}
			}
		}

		// ── Event 3 (Defense Response): bei Basisverlust, 25% Chance ─────────────
		for (int fid = 0; fid < m_store.getFactionCount(); ++fid) {
			int currentBases = getBasesForFaction(m_metagame, fid);
			bool baseLost = !isBaseline && (currentBases < m_prevBasesOwned[fid]);
			m_prevBasesOwned[fid] = currentBases;

			if (!baseLost) continue;
			if (!canAfford(fid, "event3")) continue;
			if (!rollChance(FP_AI_EVENT3_CHANCE)) continue;

			string response;
			bool ok = tryExecuteEvent("event3", fid, response);
			if (ok) {
				summary = "AI: faction " + fid + " executed /event3 (base lost). " + response;
				anyExecuted = true;
			}
		}

		// ── Spare Events (2, 4, 5): auf Sparziel hinsparen ───────────────────────
		for (int fid = 0; fid < m_store.getFactionCount(); ++fid) {
			if (m_saveTarget[fid] == "") {
				rollSaveTarget(fid);
				rollReserve(fid);
			}

			string token    = m_saveTarget[fid];
			int    cost     = m_eventRegistry.getCostByToken(token);
			int    reserve  = m_minReserve[fid];
			int    fp       = m_store.get(fid);

			if (cost < 0 || fp < cost + reserve) continue;

			string response;
			bool ok = tryExecuteEvent(token, fid, response);
			if (ok) {
				summary = "AI: faction " + fid + " executed /" + token + " (save goal). " + response;
				anyExecuted = true;
				rollSaveTarget(fid); // neues Ziel nach Kauf
				rollReserve(fid);    // neuer Puffer nach Kauf
			}
		}

		return anyExecuted;
	}

	// ── Helpers ──────────────────────────────────────────────────────────────────

	// Einheitlicher Execute-Dispatch: erkennt Player-Events und sucht passenden Spieler.
	protected bool tryExecuteEvent(const string &in token, int factionId, string &out response) {
		if (m_eventRegistry.isPlayerEventToken(token)) {
			int playerId = findActivePlayerForFaction(factionId);
			if (playerId < 0) {
				response = "no active player for faction " + factionId;
				return false;
			}
			return m_eventRegistry.tryExecute(token, playerId, response);
		}
		return m_eventRegistry.tryExecuteForFaction(token, factionId, response);
	}

	protected bool canAfford(int factionId, const string &in token) const {
		int cost = m_eventRegistry.getCostByToken(token);
		if (cost < 0) return false;
		return m_store.get(factionId) >= cost;
	}

	// Gibt true zurueck wenn ein Zufallswurf 0..1 unter 'chance' landet.
	protected bool rollChance(float chance) const {
		return rand(0.0f, 1.0f) < chance;
	}

	// Gewichteter Zufalls-Roll: waehlt naechstes Sparziel gemaess den Gewichten in der Config.
	protected void rollSaveTarget(int fid) {
		float totalWeight = FP_AI_EVENT2_WEIGHT + FP_AI_EVENT4_WEIGHT + FP_AI_EVENT5_WEIGHT;
		float roll = rand(0.0f, totalWeight);
		string chosen;
		if (roll < FP_AI_EVENT2_WEIGHT) {
			chosen = "event2";
		} else if (roll < FP_AI_EVENT2_WEIGHT + FP_AI_EVENT4_WEIGHT) {
			chosen = "event4";
		} else {
			chosen = "event5";
		}
		m_saveTarget[fid] = chosen;
		if (FP_AI_VERBOSE_LOG) _log("FP-AI: faction " + fid + " save target = /" + chosen, 1);
	}

	// Reserve-Roll: zufaelliger FP-Puffer 0..FP_AI_RESERVE_MAX der nach Kauf verbleiben muss.
	protected void rollReserve(int fid) {
		m_minReserve[fid] = rand(FP_AI_RESERVE_MIN, FP_AI_RESERVE_MAX);
		if (FP_AI_VERBOSE_LOG) _log("FP-AI: faction " + fid + " reserve = " + m_minReserve[fid], 1);
	}

	protected int findActivePlayerForFaction(int factionId) {
		array<const XmlElement@>@ players = getPlayers(m_metagame);
		if (players is null) return -1;
		for (uint i = 0; i < players.size(); ++i) {
			const XmlElement@ p = players[i];
			if (p is null) continue;
			if (p.getIntAttribute("faction_id") != factionId) continue;
			int playerId    = p.getIntAttribute("player_id");
			int characterId = p.getIntAttribute("character_id");
			if (playerId < 0 || characterId < 0) continue;
			return playerId;
		}
		return -1;
	}

	// Stellt sicher dass per-Faction-Arrays mit dem Store synchron sind.
	protected void ensureFactionCount() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;
		int count = int(factions.size());
		m_store.ensureFactionCount(count);
		while (int(m_prevBasesOwned.size()) < count) m_prevBasesOwned.insertLast(0);
		while (int(m_saveTarget.size()) < count)     m_saveTarget.insertLast("");
		while (int(m_minReserve.size()) < count)     m_minReserve.insertLast(FP_AI_RESERVE_MIN);
	}
}
