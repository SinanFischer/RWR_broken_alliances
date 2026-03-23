#include "tracker.as"
#include "metagame.as"
#include "log.as"
#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/faction_points_store.as"
#include "systeme/fraktionspunkte_system/events/faction_points_defense_state.as"
#include "systeme/fraktionspunkte_system/faction_points_kill_rank.as"
#include "events/character_death_helpers.as"

const float FP_AUTOSAVE_INTERVAL = 30.0f;
const float FP_HOLD_TICK_INTERVAL = 20.0f;
const int FP_CAPTURE_REWARD = 120;
const int FP_HOLD_REWARD_PER_BASE = 5;
const bool FP_KILL_REWARD_AI = true; // false = nur Kills durch Spieler zaehlen
const bool FP_VERBOSE_HOLD_LOG = false;

// Core-Tracker (Core = zentraler Laufzeitprozess).
// FP-Quellen: Base-Capture, Base-Hold, character_kill (Friendly-Fire ausgeschlossen).
class FactionPointsTracker : Tracker {
	protected Metagame@ m_metagame;
	protected FactionPointsStore@ m_store;
	protected float m_saveTimer = 0.0f;
	protected float m_holdTimer = 0.0f;
	protected float m_killRankTimer = 0.0f; // 0 = beim ersten Update sofort neu berechnen
	protected array<int> m_killFpByFaction;

	FactionPointsTracker(Metagame@ metagame, FactionPointsStore@ store) {
		@m_metagame = @metagame;
		@m_store = @store;
		m_saveTimer = FP_AUTOSAVE_INTERVAL;
		m_holdTimer = FP_HOLD_TICK_INTERVAL;
		m_killRankTimer = 0.0f;

		// Event-Driven: Capture-Vergabe ueber Base-Owner-Events.
		m_metagame.getComms().send("<command class='set_metagame_event' name='base_owner_change_event' enabled='1' />");
		// Kill-Vergabe: gleiches Event wie Stats/Reinforcement (doppelt aktivieren ist harmlos).
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void update(float time) {
		if (m_store is null) return;

		int fc = getDynamicFactionCount();
		m_store.ensureFactionCount(fc);

		m_killRankTimer -= time;
		if (m_killRankTimer <= 0.0f) {
			refreshKillFpByBaseRanking(fc);
			m_killRankTimer = FP_KILL_RANK_REFRESH_INTERVAL;
		}

		m_holdTimer -= time;
		if (m_holdTimer <= 0.0f) {
			applyHoldRewards();
			m_holdTimer = FP_HOLD_TICK_INTERVAL;
		}

		m_saveTimer -= time;
		if (m_saveTimer <= 0.0f) {
			m_store.save();
			m_saveTimer = FP_AUTOSAVE_INTERVAL;
		}
	}

	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		if (event is null) return;

		int newOwnerId = event.getIntAttribute("owner_id");
		int previousOwnerId = event.getIntAttribute("previous_owner_id");
		int baseId = event.getIntAttribute("base_id");
		if (baseId < 0) baseId = event.getIntAttribute("id");
		if (newOwnerId < 0) return;
		if (newOwnerId == previousOwnerId) return;

		m_store.ensureFactionCount(getDynamicFactionCount());
		if (newOwnerId >= m_store.getFactionCount()) return;

		// deltaPoints = Aenderungswert der FP-Bilanz durch dieses Event.
		int deltaPoints = FP_CAPTURE_REWARD;
		int nextPoints = m_store.add(newOwnerId, deltaPoints, false);

		if (previousOwnerId >= 0 && baseId >= 0) fpDefenseMarkBaseLost(previousOwnerId, baseId);

		_log("FactionPoints: base capture -> faction " + newOwnerId + " +" + deltaPoints + " FP (total " + nextPoints + ").", 0);
	}

	// FP fuer gueltige Kills der Killer-Fraktion; kein Friendly-Fire (Opfer = target/character).
	protected void handleCharacterKillEvent(const XmlElement@ event) {
		if (event is null || m_store is null) return;

		const XmlElement@ killer = event.getFirstElementByTagName("killer");
		if (killer is null) return;

		int factionId = killer.getIntAttribute("faction_id");
		if (factionId < 0) return;

		if (!FP_KILL_REWARD_AI && killer.getIntAttribute("player_id") == -1) return;

		const XmlElement@ victim = getDeadCharacterFromDeathEvent(event);
		if (victim !is null && victim.getIntAttribute("faction_id") == factionId) return;

		m_store.ensureFactionCount(getDynamicFactionCount());
		if (factionId >= m_store.getFactionCount()) return;

		int killFp = getKillFpForFaction(factionId);
		m_store.add(factionId, killFp, false);
	}

	protected void refreshKillFpByBaseRanking(int factionCount) {
		fpComputeKillFpByBaseRanking(m_metagame, factionCount, m_killFpByFaction);
	}

	// Nutzt Cache aus refreshKillFpByBaseRanking (alle FP_KILL_RANK_REFRESH_INTERVAL Sekunden).
	protected int getKillFpForFaction(int factionId) const {
		if (factionId < 0 || factionId >= int(m_killFpByFaction.size())) return FP_KILL_RANK_PLACE_2;
		return m_killFpByFaction[factionId];
	}

	protected void applyHoldRewards() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;

		m_store.ensureFactionCount(int(factions.size()));

		for (uint i = 0; i < factions.size(); ++i) {
			int factionId = int(i);
			int ownedBases = getBasesForFaction(m_metagame, factionId);
			if (ownedBases <= 0) continue;

			// deltaPoints = Aenderungswert der FP-Bilanz pro Hold-Tick.
			int deltaPoints = ownedBases * FP_HOLD_REWARD_PER_BASE;
			if (deltaPoints <= 0) continue;

			int nextPoints = m_store.add(factionId, deltaPoints, false);
			if (FP_VERBOSE_HOLD_LOG) {
				_log("FactionPoints: hold tick -> faction " + factionId + " +" + deltaPoints + " FP (" + ownedBases + " bases, total " + nextPoints + ").", 1);
			}
		}
	}

	protected int getDynamicFactionCount() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return 0;
		return int(factions.size());
	}
}

