#include "systeme/reinforcemnt_system/reinforcement_config.as"

// ReinforcementStore:
// Zentrale Laufzeitdaten fuer Reservisten, Penalty-Countdown und Recapture-Zeitstempel.
class ReinforcementStore {
	protected array<int> m_reserves;
	// Kumulativ verbrauchte Reservisten durch Tode (pro Tod +RS_DEATH_COST im Tracker).
	protected array<int> m_lostReservists;
	protected array<float> m_emptyCountdowns;
	protected array<dictionary@> m_baseLostTimestamps;
	protected bool m_initialized = false;

	ReinforcementStore(int factionCount = 0) {
		ensureFactionCount(factionCount);
	}

	void ensureFactionCount(int count) {
		if (count < 0) count = 0;
		while (int(m_reserves.size()) < count) {
			m_reserves.insertLast(RS_BASE_POOL);
			m_lostReservists.insertLast(0);
			m_emptyCountdowns.insertLast(-1.0f);
			dictionary@ perFactionLost = dictionary();
			m_baseLostTimestamps.insertLast(perFactionLost);
		}
	}

	int getFactionCount() const {
		return int(m_reserves.size());
	}

	bool isInitialized() const {
		return m_initialized;
	}

	void initializeStartReserves(const array<int>@ baseCounts, int leaderBases) {
		if (baseCounts is null) return;
		ensureFactionCount(int(baseCounts.size()));
		for (uint i = 0; i < baseCounts.size(); ++i) {
			int deficit = leaderBases - baseCounts[i];
			if (deficit < 0) deficit = 0;
			m_reserves[i] = RS_BASE_POOL + deficit * RS_UNDERDOG_BONUS_PER_BASE;
			m_lostReservists[i] = 0;
			m_emptyCountdowns[i] = -1.0f;
			m_baseLostTimestamps[i].deleteAll();
		}
		m_initialized = true;
	}

	int getReserves(int factionId) const {
		if (factionId < 0 || factionId >= int(m_reserves.size())) return 0;
		return m_reserves[factionId];
	}

	void setReserves(int factionId, int value) {
		if (factionId < 0 || factionId >= int(m_reserves.size())) return;
		if (value < 0) value = 0;
		m_reserves[factionId] = value;
	}

	int addReserves(int factionId, int delta) {
		if (factionId < 0 || factionId >= int(m_reserves.size())) return 0;
		int next = m_reserves[factionId] + delta;
		if (next < 0) next = 0;
		m_reserves[factionId] = next;
		return next;
	}

	int getLostReservists(int factionId) const {
		if (factionId < 0 || factionId >= int(m_lostReservists.size())) return 0;
		return m_lostReservists[factionId];
	}

	void addLostReservists(int factionId, int delta) {
		if (factionId < 0 || factionId >= int(m_lostReservists.size())) return;
		if (delta <= 0) return;
		m_lostReservists[factionId] += delta;
	}

	float getEmptyCountdown(int factionId) const {
		if (factionId < 0 || factionId >= int(m_emptyCountdowns.size())) return -1.0f;
		return m_emptyCountdowns[factionId];
	}

	bool isPenaltyActive(int factionId) const {
		return getEmptyCountdown(factionId) > 0.0f;
	}

	void startEmptyCountdownIfNeeded(int factionId) {
		if (factionId < 0 || factionId >= int(m_emptyCountdowns.size())) return;
		if (m_emptyCountdowns[factionId] > 0.0f) return;
		m_emptyCountdowns[factionId] = RS_EMPTY_COUNTDOWN_SECONDS;
	}

	void clearEmptyCountdown(int factionId) {
		if (factionId < 0 || factionId >= int(m_emptyCountdowns.size())) return;
		m_emptyCountdowns[factionId] = -1.0f;
	}

	bool tickEmptyCountdown(int factionId, float timeStep) {
		if (factionId < 0 || factionId >= int(m_emptyCountdowns.size())) return false;
		if (m_emptyCountdowns[factionId] <= 0.0f) return false;
		m_emptyCountdowns[factionId] -= timeStep;
		if (m_emptyCountdowns[factionId] <= 0.0f) {
			m_emptyCountdowns[factionId] = -1.0f;
			return true;
		}
		return false;
	}

	void markBaseLost(int factionId, int baseId, float now) {
		if (factionId < 0 || factionId >= int(m_baseLostTimestamps.size())) return;
		if (baseId < 0) return;
		m_baseLostTimestamps[factionId].set("b" + baseId, now);
	}

	bool hasLostTimestamp(int factionId, int baseId) const {
		if (factionId < 0 || factionId >= int(m_baseLostTimestamps.size())) return false;
		if (baseId < 0) return false;
		return m_baseLostTimestamps[factionId].exists("b" + baseId);
	}

	float getLostTimestamp(int factionId, int baseId) const {
		if (!hasLostTimestamp(factionId, baseId)) return -1.0f;
		float t = -1.0f;
		m_baseLostTimestamps[factionId].get("b" + baseId, t);
		return t;
	}

	void clearLostTimestamp(int factionId, int baseId) {
		if (factionId < 0 || factionId >= int(m_baseLostTimestamps.size())) return;
		if (baseId < 0) return;
		m_baseLostTimestamps[factionId].delete("b" + baseId);
	}
}
