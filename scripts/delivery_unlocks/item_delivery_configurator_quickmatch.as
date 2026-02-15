// Item-Delivery-Unlocks für Quick Match (Laptop, Briefcase) – Broken Alliances.
// Nutzt dieselbe Logik wie Campaign: Laptop/Briefcase in Waffenkammer → zufälliges Item freischalten.
// Kein GameModeInvasion nötig – funktioniert mit plain Metagame.
#include "item_delivery_organizer.as"

// No-op UnlockListener: Quick Match hat keine Map-Rotation, daher keine Persistenz nötig.
class NoOpUnlockListener : UnlockListener {
	void itemUnlocked(const Resource@ resource) {}
}

// ------------------------------------------------------------------------------------------------
class ItemDeliveryConfiguratorQuickMatch : ItemDeliveryConfigurator {
	protected Metagame@ m_metagame;
	protected ItemDeliveryOrganizer@ m_itemDeliveryOrganizer;
	protected NoOpUnlockListener m_noOpListener;

	// ------------------------------------------------------------------------------------------------
	ItemDeliveryConfiguratorQuickMatch(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	// --------------------------------------------
	void setup(ItemDeliveryOrganizer@ organizer) {
		@m_itemDeliveryOrganizer = @organizer;
		setupLaptopUnlocks();
		setupBriefcaseUnlocks();
	}

	// --------------------------------------------
	void refresh() {
		// Quick Match: keine Enemy-Weapon-Delivery-Objectives
	}

	// --------------------------------------------
	protected void setupLaptopUnlocks() {
		_log("adding laptop unlocks (Quick Match)", 1);
		array<Resource@> deliveryList;
		deliveryList.insertLast(Resource("laptop.carry_item", "carry_item"));

		dictionary unlockList;
		array<Resource@> list;
		list.push_back(MultiGroupResource("vest_blackops.carry_item", "carry_item", array<string> = {"default", "supply"}));
		list.push_back(MultiGroupResource("vest_blackops3.carry_item", "carry_item", array<string> = {"default", "supply"}));
		list.push_back(MultiGroupResource("mk23.weapon", "weapon", array<string> = {"default", "supply"}));
		unlockList.set("laptop.carry_item", list);

		string thanks = "item objective thanks";
		ResourceUnlocker unlocker(m_metagame, 0, unlockList, @m_noOpListener, "", thanks);

		string instructions = "item objective instruction";
		string mapText = "item objective map text";

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, unlocker, instructions, mapText, "", "", -1 /* loop */)
		);
	}

	// --------------------------------------------
	protected void setupBriefcaseUnlocks() {
		_log("adding briefcase unlocks (Quick Match)", 1);
		array<Resource@> deliveryList;
		deliveryList.insertLast(Resource("suitcase.carry_item", "carry_item"));

		dictionary unlockList;
		array<Resource@> list;
		list.push_back(Resource("mg42.weapon", "weapon"));
		list.push_back(Resource("aa-12.weapon", "weapon"));
		list.push_back(Resource("smaw.weapon", "weapon"));
		list.push_back(Resource("pecheneg_bullpup.weapon", "weapon"));
		list.push_back(Resource("musket.weapon", "weapon"));
		list.push_back(Resource("desert_eagle.weapon", "weapon"));
		list.push_back(Resource("m712.weapon", "weapon"));
		list.push_back(Resource("m79.weapon", "weapon"));
		list.push_back(MultiGroupResource("vest_blackops3.carry_item", "carry_item", array<string> = {"default", "supply"}));
		unlockList.set("suitcase.carry_item", list);

		string thanks = "item objective thanks";
		ResourceUnlocker unlocker(m_metagame, 0, unlockList, @m_noOpListener, "", thanks);

		string instructions = "item objective instruction";
		string mapText = "item objective map text";

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, unlocker, instructions, mapText, "", "", -1 /* loop */)
		);
	}
}
