// Vehicle-Delivery-Unlocks (Cargo Truck) – Broken Alliances.
// Cargo Truck an Waffenkammer abliefern → zufälliges Item freischalten (inkl. vest_blackops3).
#include "vehicle_delivery_configurator_invasion.as"

// ------------------------------------------------------------------------------------------------
class MyVehicleDeliveryConfigurator : VehicleDeliveryConfiguratorInvasion {
	// ------------------------------------------------------------------------------------------------
	MyVehicleDeliveryConfigurator(GameModeInvasion@ metagame) {
		super(metagame);
	}

	// --------------------------------------------
	// Cargo Truck → Unlocks
	protected array<Resource@>@ getUnlockItemList() const {
		array<Resource@> list;

		list.push_back(Resource("l85a2.weapon", "weapon"));
		list.push_back(Resource("famasg1.weapon", "weapon"));
		list.push_back(Resource("sg552.weapon", "weapon"));
		list.push_back(Resource("tow_resource.weapon", "weapon"));
		list.push_back(Resource("m202_flash.weapon", "weapon"));
		list.push_back(Resource("milkor_mgl.weapon", "weapon"));
		list.push_back(Resource("xm25.weapon", "weapon"));
		list.push_back(Resource("chain_saw.weapon", "weapon"));
		list.push_back(MultiGroupResource("vest_blackops3.carry_item", "carry_item", array<string> = {"default", "supply"}));

		return list;
	}
}
