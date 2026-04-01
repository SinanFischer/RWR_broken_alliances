#include "metagame.as"
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"
#include "systeme/reinforcemnt_system/reinforcement_config.as"
#include "systeme/reinforcemnt_system/reinforcement_store.as"
#include "systeme/reinforcemnt_system/reinforcement_compensator.as"

// ReinforcementTracker:
// Verwaltet Reservisten-Werte, Capture/Recapture-Bonus, passives Einkommen
// und Empty-Reserve-Penalty inklusive Spawn-Delay-Anpassung.
class ReinforcementTracker : Tracker {
	protected Metagame@ m_metagame;
	protected ReinforcementStore@ m_store;
	protected ReinforcementCompensator@ m_compensator;
	protected float m_timeAccum = 0.0f;
	protected float m_passiveAccum = 0.0f;
	protected float m_applyAccum = 0.0f;

	ReinforcementTracker(Metagame@ metagame, ReinforcementStore@ store) {
		@m_metagame = @metagame;
		@m_store = @store;
		@m_compensator = ReinforcementCompensator(m_metagame);
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_die' enabled='1' />");
		m_metagame.getComms().send("<command class='set_metagame_event' name='base_owner_change_event' enabled='1' />");
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void start() {
		initializeStartState();
		applySpawnIntervals();
	}

	void update(float time) {
		m_timeAccum += time;
		m_compensator.update(time);
		m_store.ensureFactionCount(getFactionCount());

		if (!m_store.isInitialized()) initializeStartState();

		for (int i = 0; i < m_store.getFactionCount(); ++i) {
			if (m_store.tickEmptyCountdown(i, time)) {
				m_store.setReserves(i, RS_BASE_POOL);
				_log("Reinforcement: faction " + i + " penalty countdown complete, reserves reset to " + RS_BASE_POOL, 0);
			}
		}

		m_passiveAccum += time;
		if (m_passiveAccum >= RS_PASSIVE_INCOME_INTERVAL) {
			m_passiveAccum = 0.0f;
			applyPassiveIncome();
		}

		m_applyAccum += time;
		if (m_applyAccum >= RS_APPLY_INTERVAL) {
			m_applyAccum = 0.0f;
			applySpawnIntervals();
		}
	}

	ReinforcementStore@ getStore() { return m_store; }

	protected void handleCharacterDieEvent(const XmlElement@ event) {
		const XmlElement@ character = event.getFirstElementByTagName("character");
		const XmlElement@ target = character is null ? event.getFirstElementByTagName("target") : character;
		if (target is null) return;

		int factionId = target.getIntAttribute("faction_id");
		if (factionId < 0) return;

		m_store.ensureFactionCount(getFactionCount());
		if (factionId >= m_store.getFactionCount()) return;

		// Always track losses for statistics, even during penalty.
		m_store.addLostReservists(factionId, RS_DEATH_COST);

		// No deduction while penalty countdown is active - faction is already at 0.
		if (m_store.isPenaltyActive(factionId)) return;

		int reserves = m_store.addReserves(factionId, -RS_DEATH_COST);
		if (reserves <= 0) {
			m_store.startEmptyCountdownIfNeeded(factionId);
		}
	}

	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		if (event is null) return;

		int baseId = event.getIntAttribute("base_id");
		if (baseId < 0) baseId = event.getIntAttribute("id");

		int previousOwnerId = event.getIntAttribute("previous_owner_id");
		int newOwnerId = event.getIntAttribute("owner_id");
		if (newOwnerId < 0) return;
		if (newOwnerId == previousOwnerId) return;

		m_store.ensureFactionCount(getFactionCount());

		if (previousOwnerId >= 0 && previousOwnerId < m_store.getFactionCount() && baseId >= 0) {
			m_store.markBaseLost(previousOwnerId, baseId, m_timeAccum);
		}

		if (newOwnerId < 0 || newOwnerId >= m_store.getFactionCount()) return;

		int captureBonus = computeCaptureBonus(newOwnerId, baseId);
		if (captureBonus > 0) {
			m_store.addReserves(newOwnerId, captureBonus);
		}
		m_store.clearLostTimestamp(newOwnerId, baseId);
	}

	protected int computeCaptureBonus(int factionId, int baseId) const {
		if (baseId < 0) return RS_CAPTURE_BONUS;
		if (!m_store.hasLostTimestamp(factionId, baseId)) return RS_CAPTURE_BONUS;

		float lostAt = m_store.getLostTimestamp(factionId, baseId);
		if (lostAt < 0.0f) return RS_CAPTURE_BONUS;

		float elapsed = m_timeAccum - lostAt;
		if (elapsed < 0.0f) elapsed = 0.0f;
		float ratio = elapsed / RS_RECAPTURE_TIMER_SECONDS;
		if (ratio < 0.0f) ratio = 0.0f;
		if (ratio > 1.0f) ratio = 1.0f;
		return int(float(RS_CAPTURE_BONUS) * ratio);
	}

	protected void initializeStartState() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;

		array<const XmlElement@>@ bases = getBases(m_metagame);
		array<int> baseCounts;
		baseCounts.resize(factions.size());
		int leaderBases = 0;

		for (uint i = 0; i < factions.size(); ++i) {
			int count = 0;
			if (bases !is null) {
				for (uint b = 0; b < bases.size(); ++b) {
					if (bases[b].getIntAttribute("owner_id") == int(i)) ++count;
				}
			}
			baseCounts[i] = count;
			if (count > leaderBases) leaderBases = count;
		}

		m_store.initializeStartReserves(baseCounts, leaderBases);
	}

	protected void applyPassiveIncome() {
		int factionCount = getFactionCount();
		for (int factionId = 0; factionId < factionCount; ++factionId) {
			int ownedBases = getBasesForFaction(m_metagame, factionId);
			if (ownedBases <= 0) continue;
			int amount = ownedBases * RS_PASSIVE_INCOME_PER_BASE;
			if (amount <= 0) continue;
			m_store.addReserves(factionId, amount);
		}
	}

	protected void applySpawnIntervals() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;

		XmlElement command("command");
		command.setStringAttribute("class", "change_game_settings");
		for (uint i = 0; i < factions.size(); ++i) {
			float spawnInterval = m_store.isPenaltyActive(int(i))
				? RS_PENALTY_SPAWN_INTERVAL
				: RS_NORMAL_SPAWN_INTERVAL;

			XmlElement faction("faction");
			faction.setFloatAttribute("capacity_multiplier", m_compensator.getCapacityMultiplier(int(i)));
			faction.setFloatAttribute("spawn_interval", spawnInterval);
			command.appendChild(faction);
		}
		m_metagame.getComms().send(command);
	}

	protected int getFactionCount() const {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		return (factions is null) ? 0 : int(factions.size());
	}
}
