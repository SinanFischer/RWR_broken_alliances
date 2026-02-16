#include "tracker.as"
#include "metagame.as"
#include "systeme/fraktionspunkte_system/faction_points_store.as"

const float FP_AUTOSAVE_INTERVAL = 30.0f;

// Core-Tracker (Core = zentraler Laufzeitprozess).
// MVP Schritt 2/3: nur Persistenz-Takt + Fraktionsgroesse nachziehen.
// Fachliche FP-Quellen (Base Capture/Hold/Kills/Events) folgen in Schritt 4.
class FactionPointsTracker : Tracker {
	protected Metagame@ m_metagame;
	protected FactionPointsStore@ m_store;
	protected float m_saveTimer = 0.0f;

	FactionPointsTracker(Metagame@ metagame, FactionPointsStore@ store) {
		@m_metagame = @metagame;
		@m_store = @store;
		m_saveTimer = FP_AUTOSAVE_INTERVAL;
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void update(float time) {
		if (m_store is null) return;

		m_store.ensureFactionCount(m_metagame.getFactionCount());

		m_saveTimer -= time;
		if (m_saveTimer <= 0.0f) {
			m_store.save();
			m_saveTimer = FP_AUTOSAVE_INTERVAL;
		}
	}
}

