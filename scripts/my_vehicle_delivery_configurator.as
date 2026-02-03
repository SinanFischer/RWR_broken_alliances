#include "vehicle_delivery_configurator_invasion.as"

// ------------------------------------------------------------------------------------------------
class MyVehicleDeliveryConfigurator : VehicleDeliveryConfiguratorInvasion {
	// ------------------------------------------------------------------------------------------------
	MyVehicleDeliveryConfigurator(GameModeInvasion@ metagame) {
		super(metagame);
	}

	// --------------------------------------------
	protected array<Resource@>@ getUnlockItemList() const {
		array<Resource@> list;

		// --------------------------------------------
		// TODO:
		// - replace these with suitable items for cargo truck delivery rewards
		// --------------------------------------------

		list.push_back(Resource("l85a2.weapon", "weapon"));
		list.push_back(Resource("famasg1.weapon", "weapon"));
		list.push_back(Resource("sg552.weapon", "weapon"));
		list.push_back(Resource("tow_resource.weapon", "weapon"));
		list.push_back(Resource("m202_flash.weapon", "weapon"));
        		list.push_back(Resource("milkor_mgl.weapon", "weapon"));
        		list.push_back(Resource("xm25.weapon", "weapon"));
		list.push_back(Resource("chain_saw.weapon", "weapon"));
         
		return list;
	}
}

