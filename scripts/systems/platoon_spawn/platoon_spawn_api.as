// Platoon-Spawn-API:
// Kleine oeffentliche Oberflaeche zum Installieren des /platoon-Commands.

#include "metagame.as"
#include "systems/platoon_spawn/platoon_spawn_command_tracker.as"

class PlatoonSpawnApi {
	protected Metagame@ m_metagame;
	protected PlatoonSpawnCommandTracker@ m_commandTracker;
	protected bool m_commandInstalled = false;

	PlatoonSpawnApi(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	void installCommand(bool enabled, bool adminOnly = true) {
		if (!enabled) return;
		if (m_commandInstalled) return;
		@m_commandTracker = PlatoonSpawnCommandTracker(m_metagame, adminOnly);
		m_metagame.addTracker(m_commandTracker);
		m_commandInstalled = true;
	}

	PlatoonSpawnCommandTracker@ getCommandTracker() { return m_commandTracker; }
}
