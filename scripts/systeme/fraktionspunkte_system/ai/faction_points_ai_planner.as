#include "log.as"
#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/faction_points_store.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_registry.as"
#include "systeme/fraktionspunkte_system/ai/faction_points_ai_config.as"

// Entscheidet alle FP_AI_DECISION_INTERVAL Sekunden welche Events die AI ausfuehrt.
//
// Drei unabhaengige Entscheidungs-Pfade pro Tick:
//   1. Periodic  — Event1 (Support Squad) alle 60s mit 5% Chance
//   2. Reactive  — Event3 (Defense Response) bei Basisverlust mit 25% Chance
//   3. Strategic — Spare-Events (2/4/5) oder Spar-Phase ("save") per gewichtetem Roll
class FactionPointsAiPlanner {
	protected Metagame@ m_metagame;
	protected FactionPointsStore@ m_store;
	protected FactionPointsEventRegistry@ m_eventRegistry;

	// Per-Faction-State — Index = faction_id
	protected array<int>    m_prevBasesOwned; // Snapshot der Basisanzahl; Rueckgang = Verlust
	protected array<string> m_saveTarget;     // Aktuelles Sparziel: "event2"|"event4"|"event5"|"save"
	protected array<int>    m_minReserve;     // FP-Puffer der nach einem Kauf mindestens bleiben muss
	protected array<float>  m_saveAccum;      // Verstrichene Zeit im "save"-Modus (zaehlt bis FP_AI_SAVE_DURATION)

	protected float m_event1Accum = 0.0f; // Verstrichene Zeit seit letztem Event1-Fenster
	protected bool  m_initialized = false; // Verhindert false-positive Basisverlust im ersten Tick

	FactionPointsAiPlanner(Metagame@ metagame, FactionPointsStore@ store, FactionPointsEventRegistry@ eventRegistry) {
		@m_metagame      = @metagame;
		@m_store         = @store;
		@m_eventRegistry = @eventRegistry;
	}

	// Einstiegspunkt — wird vom AI-Tracker alle FP_AI_DECISION_INTERVAL Sekunden aufgerufen.
	bool tick(float time, string &out summary) {
		summary = "AI: no action";
		if (m_store is null || m_eventRegistry is null) {
			summary = "AI: store/registry missing";
			return false;
		}
		ensureFactionCount();

		bool isFirstTick = !m_initialized;
		m_initialized = true;
		bool anyExecuted = false;

		tickPeriodic(time, isFirstTick, summary, anyExecuted);
		tickReactive(time, isFirstTick, summary, anyExecuted);
		tickStrategic(time, summary, anyExecuted);

		return anyExecuted;
	}

	// ── Pfad 1: Periodic ─────────────────────────────────────────────────────────
	// Event1 (Support Squad) loest alle 60s mit 5% Chance aus — unabhaengig vom FP-Stand.
	// Kleiner, regelmaessiger Druck der die Frontlinie lebendig haelt.
	protected void tickPeriodic(float time, bool isFirstTick, string &out summary, bool &out anyExecuted) {
		m_event1Accum += time;
		if (m_event1Accum < FP_AI_EVENT1_INTERVAL) return;
		m_event1Accum -= FP_AI_EVENT1_INTERVAL;

		for (int fid = 0; fid < m_store.getFactionCount(); ++fid) {
			if (!canAfford(fid, "event1")) continue;
			if (!rollChance(FP_AI_EVENT1_CHANCE)) continue;
			string response;
			if (tryExecuteEvent("event1", fid, response)) {
				summary = "AI: faction " + fid + " executed /event1. " + response;
				anyExecuted = true;
			}
		}
	}

	// ── Pfad 2: Reactive ─────────────────────────────────────────────────────────
	// Event3 (Defense Response) reagiert auf Basisverlust mit 25% Chance.
	// Gibt der verlierenden Fraktion eine letzte Gegenwehr-Chance.
	protected void tickReactive(float time, bool isFirstTick, string &out summary, bool &out anyExecuted) {
		for (int fid = 0; fid < m_store.getFactionCount(); ++fid) {
			int currentBases = getBasesForFaction(m_metagame, fid);
			bool baseLost = !isFirstTick && (currentBases < m_prevBasesOwned[fid]);
			m_prevBasesOwned[fid] = currentBases;

			if (!baseLost) continue;
			if (!canAfford(fid, "event3")) continue;
			if (!rollChance(FP_AI_EVENT3_CHANCE)) continue;

			string response;
			if (tryExecuteEvent("event3", fid, response)) {
				summary = "AI: faction " + fid + " executed /event3 (base lost). " + response;
				anyExecuted = true;
			}
		}
	}

	// ── Pfad 3: Strategic ────────────────────────────────────────────────────────
	// Jede Fraktion spart auf ein gewuerfeltes Ziel hin (event2/4/5 oder "save"-Phase).
	// Sobald FP >= Kosten + Reserve wird gekauft; danach neues Ziel wuerfeln.
	protected void tickStrategic(float time, string &out summary, bool &out anyExecuted) {
		for (int fid = 0; fid < m_store.getFactionCount(); ++fid) {
			if (m_saveTarget[fid] == "") {
				rollSaveTarget(fid);
				rollReserve(fid);
			}

			string token = m_saveTarget[fid];

			if (token == "save") {
				tickSavePhase(time, fid);
				continue;
			}

			int cost   = m_eventRegistry.getCostByToken(token);
			int fp     = m_store.get(fid);
			int needed = cost + m_minReserve[fid];

			if (cost < 0 || fp < needed) continue;

			string response;
			if (tryExecuteEvent(token, fid, response)) {
				summary = "AI: faction " + fid + " executed /" + token + " (save goal). " + response;
				anyExecuted = true;
				rollSaveTarget(fid);
				rollReserve(fid);
			}
		}
	}

	// Wartet FP_AI_SAVE_DURATION Sekunden, dann neues Sparziel wuerfeln.
	// Kein Kauf, keine Meldung — Fraktion akkumuliert passiv FP.
	protected void tickSavePhase(float time, int fid) {
		m_saveAccum[fid] += time;
		if (m_saveAccum[fid] < FP_AI_SAVE_DURATION) return;

		m_saveAccum[fid] = 0.0f;
		rollSaveTarget(fid);
		rollReserve(fid);
		if (FP_AI_VERBOSE_LOG) _log("FP-AI: faction " + fid + " save phase ended -> new target = " + m_saveTarget[fid], 1);
	}

	// ── Dice Rolls ───────────────────────────────────────────────────────────────

	// Waehlt naechstes Sparziel per gewichtetem Zufalls-Roll.
	// "save" ist nur moeglich wenn Fraktion > 2 Basen haelt (stabile Lage = kein Druck).
	protected void rollSaveTarget(int fid) {
		int bases = getBasesForFaction(m_metagame, fid);
		bool saveAllowed = (bases > 2);

		// Gewichte aufaddieren; "save" nur wenn erlaubt
		float w2    = FP_AI_EVENT2_WEIGHT;
		float w4    = FP_AI_EVENT4_WEIGHT;
		float w5    = FP_AI_EVENT5_WEIGHT;
		float wSave = saveAllowed ? FP_AI_SAVE_EVENT_WEIGHT : 0.0f;
		float total = w2 + w4 + w5 + wSave;

		float roll = rand(0.0f, total);
		string chosen;

		if      (roll < w2)              chosen = "event2";
		else if (roll < w2 + w4)         chosen = "event4";
		else if (roll < w2 + w4 + w5)    chosen = "event5";
		else                             chosen = "save";

		m_saveTarget[fid] = chosen;
		if (FP_AI_VERBOSE_LOG) _log("FP-AI: faction " + fid + " -> save target = " + chosen + " (bases=" + bases + ")", 1);
	}

	// Wuerfelt den FP-Puffer der nach einem Kauf mindestens verbleiben muss.
	// Zufaellig damit die AI nicht vorhersehbar kauft sobald ein fixer Schwellwert erreicht ist.
	protected void rollReserve(int fid) {
		m_minReserve[fid] = rand(FP_AI_RESERVE_MIN, FP_AI_RESERVE_MAX);
		if (FP_AI_VERBOSE_LOG) _log("FP-AI: faction " + fid + " -> reserve = " + m_minReserve[fid], 1);
	}

	protected bool rollChance(float chance) const {
		return rand(0.0f, 1.0f) < chance;
	}

	// ── Execution Helpers ────────────────────────────────────────────────────────

	// Player-Events benoetigen eine echte player_id; AI-Events laufen direkt ueber die Fraktion.
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

	// Gibt den ersten lebenden Spieler einer Fraktion zurueck (-1 = niemand online).
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

	// ── Lifecycle ────────────────────────────────────────────────────────────────

	// Waechst die per-Faction-Arrays auf die aktuelle Fraktionsanzahl.
	// Noetig weil getFactions() beim Start noch leer sein kann (Quick Match Lazy-Init).
	protected void ensureFactionCount() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;
		int count = int(factions.size());
		m_store.ensureFactionCount(count);
		while (int(m_prevBasesOwned.size()) < count) m_prevBasesOwned.insertLast(0);
		while (int(m_saveTarget.size()) < count)     m_saveTarget.insertLast("");
		while (int(m_minReserve.size()) < count)     m_minReserve.insertLast(FP_AI_RESERVE_MIN);
		while (int(m_saveAccum.size()) < count)      m_saveAccum.insertLast(0.0f);
	}
}
