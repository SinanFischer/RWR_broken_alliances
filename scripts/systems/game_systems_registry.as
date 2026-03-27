// Global Systems Registry:
// Zentrale Verwaltung eigener, mode-uebergreifender Systeme.
// Ziel: Pro Modus nur eine Einbindung + klarer Installationspunkt.

#include "systems/spawn_capacity/spawn_capacity_system.as"
// AUS: Commander-AI-Adaptive (Ordner systems/commander_ai_adaptive/) — kein Compile/Einbau
// #include "systems/commander_ai_adaptive/commander_ai_adaptive_system.as"
#include "systems/platoon_spawn/platoon_spawn_system.as"
#include "events/captain_spawn_command_tracker.as"
#include "events/single_base_vip_tracker.as"
#include "events/intel_manager_quickmatch.as"
#include "trackers/vehicle_interval_spawn.as"
#include "commands/blackops3_vest_command_tracker.as"
#include "commands/mrl_spawn_command.as"
// AUS: Legacy /ai_fifty, /ai_normal (scripts/commands/commander_ai_command_tracker.as)
// #include "commands/commander_ai_command_tracker.as"
#include "commands/fov_command_tracker.as"
#include "delivery_unlocks/item_delivery_configurator_quickmatch.as"
#include "systeme/fraktionspunkte_system/faction_points_system.as"

class GameSystemsRegistry {
	protected Metagame@ m_metagame;
	protected SpawnCapacityApi@ m_spawnCapacityApi;
	// protected CommanderAiAdaptiveApi@ m_commanderAiAdaptiveApi;
	protected PlatoonSpawnApi@ m_platoonSpawnApi;
	protected CaptainSpawnCommandTracker@ m_quickMatchCaptainTracker;
	protected SingleBaseVipTracker@ m_quickMatchSingleBaseVipTracker;
	protected VehicleIntervalSpawn@ m_quickMatchVehicleSpawnTracker;
	protected IntelManagerQuickMatch@ m_quickMatchIntelTracker;
	protected bool m_quickMatchEventSystemsInstalled = false;
	protected BlackOps3VestCommandTracker@ m_blackOps3VestTracker;
	protected MrlSpawnCommandTracker@ m_mrlSpawnTracker;
	// protected CommanderAiCommandTracker@ m_commanderAiTracker;
	protected FovCommandTracker@ m_fovCommandTracker;
	protected ItemDeliveryConfiguratorQuickMatch@ m_sharedItemDeliveryConfigurator;
	protected ItemDeliveryOrganizer@ m_sharedItemDeliveryOrganizer;
	protected bool m_sharedCommandDeliverySystemsInstalled = false;
	protected FactionPointsApi@ m_factionPointsApi;
	protected bool m_factionPointsSystemInstalled = false;

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

	// Adaptive Commander-AI: deaktiviert (commander_ai_adaptive_* nicht eingebunden).
	// void installCommanderAiAdaptiveSystem(bool enabled) {
	// 	if (!enabled) return;
	// 	if (m_spawnCapacityApi is null || !m_spawnCapacityApi.hasCoreInstalled()) return;
	// 	@m_commanderAiAdaptiveApi = CommanderAiAdaptiveApi(m_metagame);
	// 	m_commanderAiAdaptiveApi.installTracker(m_spawnCapacityApi.getRespawnTracker());
	// }
	void installCommanderAiAdaptiveSystem(bool enabled) {}

	// Installiert QuickMatch-Events zentral ueber die Registry:
	// - Captain-Command (/captain_spawn)
	// - Single-Base-VIP (default AUS: Captain/Escort nur noch ueber Cargo-Truck-Event)
	// - VehicleIntervalSpawn (inkl. Captain-Integration bei Cargo-Truck)
	// - IntelManagerQuickMatch
	void installQuickMatchEventSystems(bool enabled, float intelReward = 100.0f, const string &in intelRequiredCall = "paratroopers1.call", float intelRequiredXP = 0.15f, bool enableSingleBaseVip = false) {
		if (!enabled) return;
		if (m_quickMatchEventSystemsInstalled) return;

		@m_quickMatchCaptainTracker = CaptainSpawnCommandTracker(m_metagame);
		m_metagame.addTracker(m_quickMatchCaptainTracker);

		if (enableSingleBaseVip) {
			@m_quickMatchSingleBaseVipTracker = SingleBaseVipTracker(m_metagame, m_quickMatchCaptainTracker);
			m_metagame.addTracker(m_quickMatchSingleBaseVipTracker);
		}

		@m_quickMatchVehicleSpawnTracker = VehicleIntervalSpawn(m_metagame, m_quickMatchCaptainTracker);
		m_metagame.addTracker(m_quickMatchVehicleSpawnTracker);

		@m_quickMatchIntelTracker = IntelManagerQuickMatch(
			m_metagame,
			intelReward,
			intelRequiredCall,
			intelRequiredXP,
			m_quickMatchCaptainTracker
		);
		m_metagame.addTracker(m_quickMatchIntelTracker);

		m_quickMatchEventSystemsInstalled = true;
	}

	// Globale Shared-Systeme aus commands/, delivery_unlocks und systems/platoon_spawn.
	// Achtung: ItemDeliveryConfiguratorQuickMatch wird bewusst mode-uebergreifend aktiviert.
	void installSharedCommandAndDeliverySystems(bool enabled, bool enableBlackOps3VestCommand = true, bool enableQuickmatchStyleDelivery = true, bool enablePlatoonSpawnCommand = true, bool platoonAdminOnly = true) {
		if (!enabled) return;
		if (m_sharedCommandDeliverySystemsInstalled) return;

		if (enableBlackOps3VestCommand) {
			@m_blackOps3VestTracker = BlackOps3VestCommandTracker(m_metagame);
			m_metagame.addTracker(m_blackOps3VestTracker);
		}

		// MRL Command (immer aktiv, analog zu vest)
		@m_mrlSpawnTracker = MrlSpawnCommandTracker(m_metagame);
		m_metagame.addTracker(m_mrlSpawnTracker);

		// Commander-AI-Commands AUS (commander_ai_command_tracker + adaptive)
		// @m_commanderAiTracker = CommanderAiCommandTracker(m_metagame);
		// m_metagame.addTracker(m_commanderAiTracker);

		// FOV-Command (/fov true|false) – FOV Visualization zur Laufzeit
		@m_fovCommandTracker = FovCommandTracker(m_metagame);
		m_metagame.addTracker(m_fovCommandTracker);

		if (enableQuickmatchStyleDelivery) {
			@m_sharedItemDeliveryConfigurator = ItemDeliveryConfiguratorQuickMatch(m_metagame);
			@m_sharedItemDeliveryOrganizer = ItemDeliveryOrganizer(m_metagame, m_sharedItemDeliveryConfigurator);
			m_sharedItemDeliveryOrganizer.init();
			m_sharedItemDeliveryOrganizer.matchStarted();
		}

		@m_platoonSpawnApi = PlatoonSpawnApi(m_metagame);
		m_platoonSpawnApi.installCommand(enablePlatoonSpawnCommand, platoonAdminOnly);

		m_sharedCommandDeliverySystemsInstalled = true;
	}

	// Installiert das Fraktionspunkte-System (FP = gemeinsame Team-Punkte je Fraktion).
	// - core: Event/Tick-Verarbeitung + Persistenz
	// - hud: Anzeige unten per update_score_display
	// - debugCommands: /fp-Commands (aktuell Scaffold)
	void installFactionPointsSystem(bool enabled, bool installHud = true, bool installDebugCommands = false, bool debugCommandsAdminOnly = true) {
		if (!enabled) return;
		if (m_factionPointsSystemInstalled) return;

		FactionAliveHudTracker@ aliveHud = (m_spawnCapacityApi !is null)
			? m_spawnCapacityApi.getAliveHudTracker()
			: null;

		@m_factionPointsApi = FactionPointsApi(m_metagame);
		m_factionPointsApi.installCore(true);
		m_factionPointsApi.installHud(installHud);
		m_factionPointsApi.installDebugCommands(installDebugCommands, debugCommandsAdminOnly, aliveHud);

		// HUD-Mutex: AliveHud bekommt FP-HUD-Referenz, um es beim Einschalten auszuschalten.
		if (aliveHud !is null && installHud) {
			aliveHud.setFpHudTracker(m_factionPointsApi.getHudTracker());
		}

		m_factionPointsSystemInstalled = true;
	}

	SpawnCapacityApi@ getSpawnCapacityApi() { return m_spawnCapacityApi; }
	// CommanderAiAdaptiveApi@ getCommanderAiAdaptiveApi() { return m_commanderAiAdaptiveApi; }
	PlatoonSpawnApi@ getPlatoonSpawnApi() { return m_platoonSpawnApi; }
	CaptainSpawnCommandTracker@ getQuickMatchCaptainTracker() { return m_quickMatchCaptainTracker; }
	FactionPointsApi@ getFactionPointsApi() { return m_factionPointsApi; }
}
