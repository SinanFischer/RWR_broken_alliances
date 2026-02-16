#include "gamemode_campaign.as"
#include "my_stage_configurator.as"
#include "delivery_unlocks/item_delivery_configurator.as"
#include "delivery_unlocks/vehicle_delivery_configurator.as"
#include "trackers/defender_tank_help.as"
#include "trackers/vehicle_interval_spawn.as"
#include "trackers/captain_spawn_command_tracker.as"
// #include "trackers/reinforcement_pool_tracker.as"  // aus: Reinforcement-Pool deaktiviert

// --------------------------------------------
class MyGameMode : GameModeCampaign {
	// --------------------------------------------
	MyGameMode(UserSettings@ settings) {
		super(settings);
	}

	// --------------------------------------------
	void postBeginMatch() {
		GameModeCampaign::postBeginMatch();
		addTracker(DefenderTankHelp(this));
		CaptainSpawnCommandTracker@ captainTr = CaptainSpawnCommandTracker(this);
		addTracker(captainTr);  // /captain_spawn, Cargo-Truck+Captain-Event
		addTracker(VehicleIntervalSpawn(this, captainTr)); // Fahrzeug-Spawn; bei Cargo-Truck: Captain+Bodyguards
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
