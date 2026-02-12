#include "stage_configurator_campaign.as"

// ------------------------------------------------------------------------------------------------
class MyStageConfigurator : StageConfiguratorCampaign {
	// ------------------------------------------------------------------------------------------------
	MyStageConfigurator(GameModeInvasion@ metagame, MapRotatorCampaign@ mapRotator) {
		super(metagame, mapRotator);
	}

	// ------------------------------------------------------------------------------------------------
	// Capacity-Aenderungen nur vom ReinforcementPoolTracker (60/40-Cap); Campaign/Vanilla ueberschreibt nicht.
	protected void addStage(Stage@ stage) {
		stage.m_allowChangeCapacityOnTheFly = false;
		StageConfiguratorCampaign::addStage(stage);
	}

	// ------------------------------------------------------------------------------------------------
	const array<FactionConfig@>@ getAvailableFactionConfigs() const {
		array<FactionConfig@> availableFactionConfigs;

		// --------------------------------
		// TODO: define 3 faction configs here
		// - "green.xml" faction specification filename
		// - "Greenbelts" faction name, usually same as the one in the file
		// - "0.1 0.5 0" color used for faction in the world view
		// - "green_boss.xml" faction specification filename used in the final missions; 
		//   can be same as the regular faction filename
		// --------------------------------

		availableFactionConfigs.push_back(FactionConfig(-1, "green.xml", "Greenbelts", "0.1 0.5 0", "green_boss.xml"));
		availableFactionConfigs.push_back(FactionConfig(-1, "grey.xml", "Graycollars", "0.5 0.5 0.5", "grey_boss.xml"));
		availableFactionConfigs.push_back(FactionConfig(-1, "brown.xml", "Brownpants", "0.5 0.25 0", "brown_boss.xml"));

		return availableFactionConfigs;
	}

	// ------------------------------------------------------------------------------------------------
	// Westen in Waffenkammer: Fraktion bekommt alle Westen als Ressource (enabled), damit sie in der
	// Westen-Kategorie der Waffenkammer angezeigt werden (wie in Project Apocalypse).
	protected array<ResourceChange@> getFriendlyFactionResourceChanges() const {
		array<ResourceChange@> list = StageConfiguratorInvasion::getFriendlyFactionResourceChanges();

		// Alle Westen für Spielerfraktion freischalten → erscheinen in Waffenkammer
		list.push_back(ResourceChange(Resource("vest_default.carry_item", "carry_item"), true));
		list.push_back(ResourceChange(Resource("vest1.carry_item", "carry_item"), true));
		list.push_back(ResourceChange(Resource("vest2.carry_item", "carry_item"), true));
		list.push_back(ResourceChange(Resource("vest3.carry_item", "carry_item"), true));
		list.push_back(ResourceChange(Resource("vest4.carry_item", "carry_item"), true));
		list.push_back(ResourceChange(Resource("eodvest.carry_item", "carry_item"), true));
		list.push_back(ResourceChange(Resource("camouflage_suit.carry_item", "carry_item"), true));
		list.push_back(ResourceChange(Resource("sf_suit.carry_item", "carry_item"), true));
		list.push_back(ResourceChange(Resource("vest_blackops.carry_item", "carry_item"), true));

		return list;
	}

	// NOTE
	// if you need to add certain resources for enemies or friendlies generally in all stages, have a look at
	// vanilla\scripts\gamemodes\invasion\stage_configurator_invasion.as and consider overriding
	// getCommonFactionResourceChanges
	// getCompletionVarianceCommands
}
