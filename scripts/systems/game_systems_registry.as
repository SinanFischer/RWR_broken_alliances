// Global Systems Registry:
// Zentrale Verwaltung eigener, mode-uebergreifender Systeme.
// Ziel: Pro Modus nur eine Einbindung + klarer Installationspunkt.

#include "spawn_capacity/spawn_capacity_system.as"

class GameSystemsRegistry {
	protected Metagame@ m_metagame;
	protected SpawnCapacityApi@ m_spawnCapacityApi;

	GameSystemsRegistry(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	// Installiert Spawn-Capacity-System optional.
	// - enabled: true = Slotblock + /stats aktiv
	// - debugHud: true = Capacity-Debug-HUD statt Standard-Alive-HUD
	// - defaultAliveHudWhenNoDebug: true = Fallback-HUD fuer Normalbetrieb
	void installSpawnCapacitySystem(bool enabled, bool debugHud = false, bool defaultAliveHudWhenNoDebug = true) {
		if (!enabled) return;
		@m_spawnCapacityApi = SpawnCapacityApi(m_metagame);
		m_spawnCapacityApi.installCoreTrackers();
		if (debugHud) {
			m_spawnCapacityApi.installDebugHud();
		} else if (defaultAliveHudWhenNoDebug) {
			m_spawnCapacityApi.installDefaultAliveHud();
		}
	}

	SpawnCapacityApi@ getSpawnCapacityApi() { return m_spawnCapacityApi; }
}
