// Spawn-Capacity-API:
// Kleine, stabile Oberflaeche fuer die Einbindung des Spawn-Capacity-Systems.
// Ziel: Aufrufer koppeln nur an diese API, nicht an Tracker-Interna.

#include "trackers/faction_alive_hud_tracker.as"
#include "trackers/respawn_slot_delay_tracker.as"
#include "trackers/stats_command_tracker.as"
#include "trackers/capacity_debug_hud_tracker.as"

class SpawnCapacityApi {
	protected Metagame@ m_metagame;
	protected RespawnSlotDelayTracker@ m_respawnTracker;
	protected StatsCommandTracker@ m_statsTracker;
	protected CapacityDebugHudTracker@ m_debugHudTracker;
	protected FactionAliveHudTracker@ m_aliveHudTracker;
	protected bool m_coreInstalled = false;
	protected bool m_debugHudInstalled = false;

	SpawnCapacityApi(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	// Installiert Slotblock + /stats einmalig.
	void installCoreTrackers() {
		if (m_coreInstalled) return;
		@m_respawnTracker = RespawnSlotDelayTracker(m_metagame);
		m_metagame.addTracker(m_respawnTracker);
		@m_statsTracker = StatsCommandTracker(m_metagame, m_respawnTracker);
		m_metagame.addTracker(m_statsTracker);
		m_coreInstalled = true;
	}

	// Optionales HUD fuer Diagnose (Alive/Capacity). Nur wenn Core aktiv ist.
	void installDebugHud() {
		if (m_debugHudInstalled) return;
		if (!m_coreInstalled) installCoreTrackers();
		@m_debugHudTracker = CapacityDebugHudTracker(m_metagame, m_respawnTracker);
		m_metagame.addTracker(m_debugHudTracker);
		m_debugHudInstalled = true;
	}

	// Alive-HUD: zeigt "alive / effectiveCap (bases)" pro Fraktion in Fraktionsfarbe.
	// Gibt den respawnTracker weiter, damit der HUD-Tracker keine eigenen Queries doppelt macht.
	void installDefaultAliveHud() {
		@m_aliveHudTracker = FactionAliveHudTracker(m_metagame, m_respawnTracker);
		m_metagame.addTracker(m_aliveHudTracker);
	}

	RespawnSlotDelayTracker@ getRespawnTracker() { return m_respawnTracker; }
	FactionAliveHudTracker@ getAliveHudTracker() { return m_aliveHudTracker; }
	bool hasCoreInstalled() const { return m_coreInstalled; }
	bool hasDebugHudInstalled() const { return m_debugHudInstalled; }
}
