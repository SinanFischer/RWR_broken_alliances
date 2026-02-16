#include "metagame.as"
#include "query_helpers.as"

#include "systeme/fraktionspunkte_system/faction_points_store.as"
#include "systeme/fraktionspunkte_system/faction_points_tracker.as"
#include "systeme/fraktionspunkte_system/faction_points_hud_tracker.as"
#include "systeme/fraktionspunkte_system/faction_points_debug_command_tracker.as"

// API (Fassade = stabiler Einstiegspunkt) fuer das Fraktionspunkte-System.
class FactionPointsApi {
	protected Metagame@ m_metagame;
	protected FactionPointsPersistenceAdapter@ m_persistence;
	protected FactionPointsStore@ m_store;

	protected FactionPointsTracker@ m_coreTracker;
	protected FactionPointsHudTracker@ m_hudTracker;
	protected FactionPointsDebugCommandTracker@ m_debugTracker;

	protected bool m_coreInstalled = false;
	protected bool m_hudInstalled = false;
	protected bool m_debugInstalled = false;

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
	}

	void installHud(bool enabled = true) {
		if (!enabled) return;
		if (m_hudInstalled) return;
		if (!m_coreInstalled) installCore(true);

		@m_hudTracker = FactionPointsHudTracker(m_metagame, m_store);
		m_metagame.addTracker(m_hudTracker);
		m_hudInstalled = true;
	}

	void installDebugCommands(bool enabled = true, bool adminOnly = true) {
		if (!enabled) return;
		if (m_debugInstalled) return;
		if (!m_coreInstalled) installCore(true);

		@m_debugTracker = FactionPointsDebugCommandTracker(m_metagame, m_store, adminOnly);
		m_metagame.addTracker(m_debugTracker);
		m_debugInstalled = true;
	}

	FactionPointsStore@ getStore() { return m_store; }
	bool hasCoreInstalled() const { return m_coreInstalled; }
	bool hasHudInstalled() const { return m_hudInstalled; }
	bool hasDebugInstalled() const { return m_debugInstalled; }
}

