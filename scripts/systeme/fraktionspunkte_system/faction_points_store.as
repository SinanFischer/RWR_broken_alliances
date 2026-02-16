#include "log.as"
#include "systeme/fraktionspunkte_system/faction_points_persistence_adapter.as"

// Store (Store = zentrale Datenhaltung) fuer FP pro Fraktion.
// Invarianten:
// - FP nie negativ
// - Fraktionsindex muss gueltig sein
class FactionPointsStore {
	protected array<int> m_pointsByFaction;
	protected FactionPointsPersistenceAdapter@ m_persistence;
	protected bool m_loaded = false;

	FactionPointsStore(int factionCount, FactionPointsPersistenceAdapter@ persistence = null) {
		if (factionCount < 0) factionCount = 0;
		m_pointsByFaction.resize(factionCount);
		for (int i = 0; i < factionCount; ++i) {
			m_pointsByFaction[i] = 0;
		}
		@m_persistence = @persistence;
	}

	void ensureFactionCount(int factionCount) {
		if (factionCount < 0) factionCount = 0;
		if (int(m_pointsByFaction.size()) >= factionCount) return;
		int oldSize = int(m_pointsByFaction.size());
		m_pointsByFaction.resize(factionCount);
		for (int i = oldSize; i < factionCount; ++i) {
			m_pointsByFaction[i] = 0;
		}
	}

	int getFactionCount() const {
		return int(m_pointsByFaction.size());
	}

	int get(int factionId) const {
		if (!isValidFactionId(factionId)) return 0;
		return m_pointsByFaction[factionId];
	}

	const array<int>@ getAll() const {
		return m_pointsByFaction;
	}

	int set(int factionId, int value, bool saveAfter = false) {
		if (!isValidFactionId(factionId)) return 0;
		if (value < 0) value = 0;
		m_pointsByFaction[factionId] = value;
		if (saveAfter) save();
		return value;
	}

	int add(int factionId, int delta, bool saveAfter = false) {
		if (!isValidFactionId(factionId)) return 0;
		int nextValue = m_pointsByFaction[factionId] + delta;
		if (nextValue < 0) nextValue = 0;
		m_pointsByFaction[factionId] = nextValue;
		if (saveAfter) save();
		return nextValue;
	}

	bool canSpend(int factionId, int amount) const {
		if (!isValidFactionId(factionId)) return false;
		if (amount < 0) return false;
		return m_pointsByFaction[factionId] >= amount;
	}

	bool spend(int factionId, int amount, bool saveAfter = false) {
		if (!isValidFactionId(factionId)) return false;
		if (amount < 0) return false;
		if (m_pointsByFaction[factionId] < amount) return false;
		m_pointsByFaction[factionId] -= amount;
		if (saveAfter) save();
		return true;
	}

	bool load() {
		if (m_persistence is null) return false;
		array<int> loaded;
		bool ok = m_persistence.load(loaded, int(m_pointsByFaction.size()));
		if (!ok) return false;
		for (uint i = 0; i < m_pointsByFaction.size(); ++i) {
			int value = loaded[i];
			if (value < 0) value = 0;
			m_pointsByFaction[i] = value;
		}
		m_loaded = true;
		return true;
	}

	void save() {
		if (m_persistence is null) return;
		m_persistence.save(m_pointsByFaction);
	}

	bool wasLoadedFromPersistence() const {
		return m_loaded;
	}

	protected bool isValidFactionId(int factionId) const {
		return factionId >= 0 && factionId < int(m_pointsByFaction.size());
	}
}

