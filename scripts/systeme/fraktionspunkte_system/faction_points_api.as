#include "metagame.as"
#include "query_helpers.as"

#include "trackers/faction_alive_hud_tracker.as"
#include "systeme/fraktionspunkte_system/faction_points_store.as"
#include "systeme/fraktionspunkte_system/faction_points_tracker.as"
#include "systeme/fraktionspunkte_system/faction_points_hud_tracker.as"
#include "systeme/fraktionspunkte_system/faction_points_debug_command_tracker.as"
#include "systeme/fraktionspunkte_system/ai/faction_points_ai_tracker.as"

// API (Fassade = stabiler Einstiegspunkt) fuer das Fraktionspunkte-System.
class FactionPointsApi {
	protected Metagame@ m_metagame;
	protected FactionPointsPersistenceAdapter@ m_persistence;
	protected FactionPointsStore@ m_store;

	protected FactionPointsTracker@ m_coreTracker;
	protected FactionPointsAiTracker@ m_aiTracker;
	protected FactionPointsHudTracker@ m_hudTracker;
	protected FactionPointsDebugCommandTracker@ m_debugTracker;

	protected bool m_coreInstalled = false;
	protected bool m_hudInstalled = false;
	protected bool m_debugInstalled = false;
	protected bool m_aiInstalled = false;

	FactionPointsApi(Metagame@ metagame) {
		@m_metagame = @metagame;

		@m_persistence = FactionPointsPersistenceAdapter(m_metagame);
		int factionCount = 0;
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions !is null) factionCount = int(factions.size());
		@m_store = FactionPointsStore(factionCount, m_persistence);
		m_store.load();
	}

	void installCore(bool enabled = true) {
		if (!enabled) return;
		if (m_coreInstalled) return;

		@m_coreTracker = FactionPointsTracker(m_metagame, m_store);
		m_metagame.addTracker(m_coreTracker);
		m_coreInstalled = true;

		installAi(FP_AI_ENABLED_BY_DEFAULT);
	}

	void installHud(bool enabled = true) {
		if (!enabled) return;
		if (m_hudInstalled) return;
		if (!m_coreInstalled) installCore(true);

		@m_hudTracker = FactionPointsHudTracker(m_metagame, m_store);
		m_metagame.addTracker(m_hudTracker);
		m_hudInstalled = true;
	}

	void installDebugCommands(bool enabled = true, bool adminOnly = true, FactionAliveHudTracker@ aliveHudTracker = null) {
		if (!enabled) return;
		if (m_debugInstalled) return;
		if (!m_coreInstalled) installCore(true);

		@m_debugTracker = FactionPointsDebugCommandTracker(m_metagame, m_store, m_aiTracker, adminOnly, m_hudTracker, aliveHudTracker);
		m_metagame.addTracker(m_debugTracker);
		m_debugInstalled = true;
	}

	void installAi(bool enabled = true) {
		if (!enabled) return;
		if (m_aiInstalled) return;
		if (!m_coreInstalled) return;

		@m_aiTracker = FactionPointsAiTracker(m_metagame, m_store);
		m_metagame.addTracker(m_aiTracker);
		m_aiInstalled = true;
	}

	FactionPointsStore@ getStore() { return m_store; }
	FactionPointsHudTracker@ getHudTracker() { return m_hudTracker; }
	bool hasCoreInstalled() const { return m_coreInstalled; }
	bool hasAiInstalled() const { return m_aiInstalled; }
	bool hasHudInstalled() const { return m_hudInstalled; }
	bool hasDebugInstalled() const { return m_debugInstalled; }
}

