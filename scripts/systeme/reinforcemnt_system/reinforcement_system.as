// Reinforcement-System-Facade:
// Zentrale Include-Stelle und API fuer Installation in Gamemodes.

#include "metagame.as"
#include "systeme/reinforcemnt_system/reinforcement_config.as"
#include "systeme/reinforcemnt_system/reinforcement_store.as"
#include "systeme/reinforcemnt_system/reinforcement_tracker.as"
#include "systeme/reinforcemnt_system/reinforcement_hud_tracker.as"

class ReinforcementApi {
	protected Metagame@ m_metagame;
	protected ReinforcementStore@ m_store;
	protected ReinforcementTracker@ m_tracker;
	protected ReinforcementHudTracker@ m_hudTracker;
	protected bool m_coreInstalled = false;
	protected bool m_hudInstalled = false;

	ReinforcementApi(Metagame@ metagame) {
		@m_metagame = @metagame;
		@m_store = ReinforcementStore();
	}

	void installCore() {
		if (m_coreInstalled) return;
		@m_tracker = ReinforcementTracker(m_metagame, m_store);
		m_metagame.addTracker(m_tracker);
		m_coreInstalled = true;
	}

	void installHud() {
		if (m_hudInstalled) return;
		if (!m_coreInstalled) installCore();
		@m_hudTracker = ReinforcementHudTracker(m_metagame, m_store);
		m_metagame.addTracker(m_hudTracker);
		m_hudInstalled = true;
	}

	ReinforcementStore@ getStore() { return m_store; }
	ReinforcementTracker@ getTracker() { return m_tracker; }
	ReinforcementHudTracker@ getHudTracker() { return m_hudTracker; }
	bool hasCoreInstalled() const { return m_coreInstalled; }
	bool hasHudInstalled() const { return m_hudInstalled; }
}
