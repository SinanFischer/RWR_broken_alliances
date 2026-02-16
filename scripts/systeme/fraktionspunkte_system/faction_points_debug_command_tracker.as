#include "tracker.as"
#include "metagame.as"
#include "systeme/fraktionspunkte_system/faction_points_store.as"

// Debug-Command-Tracker:
// Schritt 3 Scaffold, damit API/Installation vollstaendig ist.
// Fachliche Command-Logik (/fp, /fp_add, /fp_set) folgt in Schritt 7.
class FactionPointsDebugCommandTracker : Tracker {
	protected Metagame@ m_metagame;
	protected FactionPointsStore@ m_store;
	protected bool m_adminOnly = true;

	FactionPointsDebugCommandTracker(Metagame@ metagame, FactionPointsStore@ store, bool adminOnly = true) {
		@m_metagame = @metagame;
		@m_store = @store;
		m_adminOnly = adminOnly;
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void update(float time) {
		// no-op bis Schritt 7
	}
}

