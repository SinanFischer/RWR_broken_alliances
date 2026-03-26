// Adaptive Commander AI - System-Einstieg.
// Einzige Include-Stelle; Tracker inkludiert Config + Logik.

#include "systems/commander_ai_adaptive/commander_ai_adaptive_tracker.as"

class CommanderAiAdaptiveApi {
	protected Metagame@ m_metagame;
	protected CommanderAiAdaptiveTracker@ m_tracker;
	protected bool m_installed = false;

	CommanderAiAdaptiveApi(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	void installTracker(RespawnSlotDelayTracker@ respawnTracker) {
		if (m_installed) return;
		if (respawnTracker is null) return;
		@m_tracker = CommanderAiAdaptiveTracker(m_metagame, respawnTracker);
		m_metagame.addTracker(m_tracker);
		m_installed = true;
	}

	bool isInstalled() const { return m_installed; }
}
