#include "item_delivery_configurator_invasion.as"

// ------------------------------------------------------------------------------------------------
class MyItemDeliveryConfigurator : ItemDeliveryConfiguratorInvasion {
	// ------------------------------------------------------------------------------------------------
	MyItemDeliveryConfigurator(GameModeInvasion@ metagame) {
		super(metagame);
	}

	// --------------------------------------------
	array<Resource@>@ getUnlockWeaponList() const {
		array<Resource@> list;

		// --------------------------------------------
		// TODO:
		// - replace these with suitable items for briefcase delivery rewards
		// --------------------------------------------

		list.push_back(Resource("mg42.weapon", "weapon"));
		list.push_back(Resource("aa-12.weapon", "weapon"));
         		list.push_back(Resource("smaw.weapon", "weapon"));
   		list.push_back(Resource("pecheneg_bullpup.weapon", "weapon"));
		list.push_back(Resource("musket.weapon", "weapon"));
		list.push_back(Resource("desert_eagle.weapon", "weapon"));
    		list.push_back(Resource("m712.weapon", "weapon"));
		list.push_back(Resource("m79.weapon", "weapon"));

		return list;
	}

	// --------------------------------------------
	array<Resource@>@ getUnlockWeaponList2() const {
		array<Resource@> list;

		// --------------------------------------------
		// TODO:
		// - replace these with suitable items for laptop delivery rewards
		// --------------------------------------------

		list.push_back(MultiGroupResource("vest_blackops.carry_item", "carry_item", array<string> = {"default", "supply"}));
		list.push_back(MultiGroupResource("mk23.weapon", "weapon", array<string> = {"default", "supply"}));       
         
		return list;
	}
	
	// --------------------------------------------
	array<Resource@>@ getDeliverablesList() const {
		array<Resource@> list;

		// --------------------------------------------
		// TODO:
		// - replace these with what we want to track as delivered to armory, with intention of unlocking that same item
		// --------------------------------------------

		// green weapons
		list.push_back(Resource("m16a4.weapon", "weapon"));
		list.push_back(Resource("m240.weapon", "weapon"));
		list.push_back(Resource("m24_a2.weapon", "weapon"));
		list.push_back(Resource("mp5sd.weapon", "weapon"));
		list.push_back(Resource("mossberg.weapon", "weapon"));
		list.push_back(Resource("m72_law.weapon", "weapon"));
		list.push_back(Resource("beretta_m9.weapon", "weapon"));
		list.push_back(Resource("mini_uzi.weapon", "weapon"));     

		// grey weapons
		list.push_back(Resource("g36.weapon", "weapon"));
		list.push_back(Resource("imi_negev.weapon", "weapon"));
		list.push_back(Resource("psg90.weapon", "weapon"));
		list.push_back(Resource("scorpion-evo.weapon", "weapon"));
		list.push_back(Resource("spas-12.weapon", "weapon"));
		list.push_back(Resource("m2_carlgustav.weapon", "weapon"));
		list.push_back(Resource("glock17.weapon", "weapon"));
		list.push_back(Resource("steyr_tmp.weapon", "weapon"));     

		// brown weapons
		list.push_back(Resource("ak47.weapon", "weapon"));
		list.push_back(Resource("pkm.weapon", "weapon"));
		list.push_back(Resource("dragunov_svd.weapon", "weapon"));
		list.push_back(Resource("qcw-05.weapon", "weapon"));
		list.push_back(Resource("qbs-09.weapon", "weapon"));
		list.push_back(Resource("rpg-7.weapon", "weapon"));
		list.push_back(Resource("pb.weapon", "weapon")); 
		list.push_back(Resource("aek_919k.weapon", "weapon"));

		// squad equipment kits (from Project Apocalypse)
		list.push_back(Resource("squad_equipment_kit.weapon", "weapon"));
		list.push_back(Resource("squad_equipment_kit_navy.weapon", "weapon"));

		// Westen: in Waffenkammer von Anfang an verfügbar (Weste 1 bis EOD + Default, Tarnanzug, SF)
		list.push_back(Resource("vest_default.carry_item", "carry_item"));
		list.push_back(Resource("vest1.carry_item", "carry_item"));
		list.push_back(Resource("vest2.carry_item", "carry_item"));
		list.push_back(Resource("vest3.carry_item", "carry_item"));
		list.push_back(Resource("vest4.carry_item", "carry_item"));
		list.push_back(Resource("eodvest.carry_item", "carry_item"));
		list.push_back(Resource("camouflage_suit.carry_item", "carry_item"));
		list.push_back(Resource("sf_suit.carry_item", "carry_item"));
		list.push_back(Resource("vest_blackops.carry_item", "carry_item"));

		return list;
	}

	// --------------------------------------------
	// NOTE:
	// also see vanilla\scripts\gamemodes\invasion\item_delivery_configurator_invasion.as:
	// protected void setupGift1()
	// protected void setupGift2()
	// protected void setupGift3()

}
