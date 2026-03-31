// Reinforcement-System-Facade:
// Zentrale Include-Stelle und API fuer Installation in Gamemodes.

#include "metagame.as"
#include "systeme/reinforcemnt_system/reinforcement_config.as"
#include "systeme/reinforcemnt_system/reinforcement_store.as"
#include "systeme/reinforcemnt_system/reinforcement_tracker.as"
#include "systeme/reinforcemnt_system/reinforcement_hud_tracker.as"
#include "systeme/reinforcemnt_system/reinforcement_debug_hud_tracker.as"
#include "systeme/reinforcemnt_system/reinforcement_stats_command_tracker.as"

class ReinforcementApi {
	protected Metagame@ m_metagame;
	protected ReinforcementStore@ m_store;
	protected ReinforcementTracker@ m_tracker;
	protected ReinforcementStatsCommandTracker@ m_statsCommandTracker;
	protected ReinforcementHudTracker@ m_hudTracker;
	protected ReinforcementDebugHudTracker@ m_debugHudTracker;
	protected bool m_coreInstalled = false;
	protected bool m_hudInstalled = false;
	protected bool m_debugHudInstalled = false;

	ReinforcementApi(Metagame@ metagame) {
		@m_metagame = @metagame;
		@m_store = ReinforcementStore();
	}

	void installCore() {
		if (m_coreInstalled) return;
		@m_tracker = ReinforcementTracker(m_metagame, m_store);
		m_metagame.addTracker(m_tracker);
		@m_statsCommandTracker = ReinforcementStatsCommandTracker(m_metagame, m_store);
		m_metagame.addTracker(m_statsCommandTracker);
		m_coreInstalled = true;
	}

	void installHud() {
		if (m_hudInstalled) return;
		if (!m_coreInstalled) installCore();
		@m_hudTracker = ReinforcementHudTracker(m_metagame, m_store);
		m_metagame.addTracker(m_hudTracker);
		m_hudInstalled = true;
		wireInternalHudMutex();
	}

	void installDebugHud() {
		if (m_debugHudInstalled) return;
		if (!m_coreInstalled) installCore();
		@m_debugHudTracker = ReinforcementDebugHudTracker(m_metagame, m_store);
		m_metagame.addTracker(m_debugHudTracker);
		m_debugHudInstalled = true;
		wireInternalHudMutex();
	}

	ReinforcementStore@ getStore()                    { return m_store; }
	ReinforcementTracker@ getTracker()                { return m_tracker; }
	ReinforcementHudTracker@ getHudTracker()          { return m_hudTracker; }
	ReinforcementDebugHudTracker@ getDebugHudTracker(){ return m_debugHudTracker; }
	bool hasCoreInstalled() const                     { return m_coreInstalled; }
	bool hasHudInstalled() const                      { return m_hudInstalled; }
	bool hasDebugHudInstalled() const                 { return m_debugHudInstalled; }

	// Interner Mutex: RS-HUD ↔ Debug-HUD; nur verdrahten wenn beide existieren.
	private void wireInternalHudMutex() {
		if (m_hudTracker is null || m_debugHudTracker is null) return;
		m_hudTracker.setDebugHud(m_debugHudTracker);
		m_debugHudTracker.setMutexHud(m_hudTracker);
	}
}
