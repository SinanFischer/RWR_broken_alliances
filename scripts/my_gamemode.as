#include "gamemode_campaign.as"
#include "my_stage_configurator.as"
#include "delivery_unlocks/item_delivery_configurator.as"
#include "delivery_unlocks/my_vehicle_delivery_configurator.as"
#include "trackers/defender_tank_help.as"
#include "systems/game_systems.as"
// #include "trackers/reinforcement_pool_tracker.as"  // aus: Reinforcement-Pool deaktiviert

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
		@m_gameSystemsRegistry = GameSystemsRegistry(this);
		m_gameSystemsRegistry.installSharedCommandAndDeliverySystems(true, true, true);
		m_gameSystemsRegistry.installQuickMatchEventSystems(true, 100.0f, "paratroopers1.call", 0.15f);
		addTracker(DefenderTankHelp(this));
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
