#include "gamemode_campaign.as"
#include "my_stage_configurator.as"
#include "delivery_unlocks/item_delivery_configurator.as"
#include "delivery_unlocks/my_vehicle_delivery_configurator.as"
#include "trackers/defender_tank_help.as"
#include "systems/game_systems.as"
// #include "trackers/reinforcement_pool_tracker.as"  // aus: Reinforcement-Pool deaktiviert

const bool CAMPAIGN_ENABLE_SHARED_COMMAND_DELIVERY_SYSTEMS = true;
const bool CAMPAIGN_ENABLE_EVENT_SYSTEMS = true;
const bool CAMPAIGN_ENABLE_SPAWN_CAPACITY_SYSTEM = true;
const bool CAMPAIGN_CAPACITY_DEBUG_HUD = false;
const bool CAMPAIGN_ENABLE_FACTION_POINTS_SYSTEM = true;

// --------------------------------------------
class MyGameMode : GameModeCampaign {
	protected GameSystemsRegistry@ m_gameSystemsRegistry;

	// --------------------------------------------
	MyGameMode(UserSettings@ settings) {
		super(settings);
	}

	// --------------------------------------------
	void postBeginMatch() {
		GameModeCampaign::postBeginMatch();
		// Redundante Initialisierung entfernt: GameModeInvasion übernimmt dies bereits.
		/*
		@m_gameSystemsRegistry = GameSystemsRegistry(this);
		m_gameSystemsRegistry.installSharedCommandAndDeliverySystems(
			CAMPAIGN_ENABLE_SHARED_COMMAND_DELIVERY_SYSTEMS,
			true,
			true
		);
		m_gameSystemsRegistry.installSpawnCapacitySystem(
			CAMPAIGN_ENABLE_SPAWN_CAPACITY_SYSTEM,
			CAMPAIGN_CAPACITY_DEBUG_HUD,
			false // Alive-HUD deaktiviert, da FP-HUD aktiv ist
		);
		m_gameSystemsRegistry.installFactionPointsSystem(
			CAMPAIGN_ENABLE_FACTION_POINTS_SYSTEM,
			true,   // HUD aktiv
			true,   // Debug-Commands aktiv
			true
		);
		m_gameSystemsRegistry.installQuickMatchEventSystems(
			CAMPAIGN_ENABLE_EVENT_SYSTEMS,
			100.0f,
			"paratroopers1.call",
			0.15f,
			false // Campaign: Single-Base-VIP deaktiviert
		);
		addTracker(DefenderTankHelp(this));
		*/
		// addTracker(ReinforcementPoolTracker(this));  // aus: Reinforcement-Pool deaktiviert
	}

	// --------------------------------------------
	protected void setupMapRotator() {
		MapRotatorCampaign mapRotatorCampaign(this);
		MyStageConfigurator configurator(this, mapRotatorCampaign);
		@m_mapRotator = @mapRotatorCampaign;
	}

	// --------------------------------------------
	protected void setupItemDeliveryOrganizer() {
		MyItemDeliveryConfigurator configurator(this);
		@m_itemDeliveryOrganizer = ItemDeliveryOrganizer(this, configurator);
	}

	// --------------------------------------------
	protected void setupVehicleDeliveryObjectives() {
		MyVehicleDeliveryConfigurator configurator(this);
		configurator.setup();
	}
}
