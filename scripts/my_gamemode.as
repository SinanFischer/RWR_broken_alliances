#include "gamemode_campaign.as"
#include "my_stage_configurator.as"
#include "my_item_delivery_configurator.as"
#include "my_vehicle_delivery_configurator.as"
#include "trackers/bullet_flyby_effect.as"
#include "trackers/defender_tank_help.as"

// --------------------------------------------
class MyGameMode : GameModeCampaign {
	// --------------------------------------------
	MyGameMode(UserSettings@ settings) {
		super(settings);
	}

	// --------------------------------------------
	void postBeginMatch() {
		GameModeCampaign::postBeginMatch();
		addTracker(BulletFlybyEffect(this));
		addTracker(DefenderTankHelp(this));
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
