// Item-Delivery-Unlocks für Quick Match (Laptop, Briefcase) – Broken Alliances.
// Nutzt dieselbe Logik wie Campaign: Laptop/Briefcase in Waffenkammer → zufälliges Item freischalten.
// Kein GameModeInvasion nötig – funktioniert mit plain Metagame.
#include "item_delivery_organizer.as"

// UnlockListener der die Freischaltungs-Meldung garantiert anzeigt.
// Vanilla ResourceUnlocker sendet "resource added in stock" nur wenn getResourceName() != "" –
// bei Mod-Items liefert das oft leer. Dieser Listener ergänzt die Meldung mit Fallback.
class NotifyingUnlockListener : UnlockListener {
	Metagame@ m_metagame;
	int m_factionId;

	NotifyingUnlockListener(Metagame@ mg, int factionId) {
		@m_metagame = mg;
		m_factionId = factionId;
	}

	void itemUnlocked(const Resource@ resource) {
		string name = getResourceName(m_metagame, resource.m_key, resource.m_type);
		if (name == "") {
			// Fallback: Resource-Key ohne Extension (z.B. "vest_blackops3.carry_item" -> "vest_blackops3")
			name = resource.m_key;
			int dot = name.findLast(".weapon");
			if (dot < 0) dot = name.findLast(".carry_item");
			if (dot < 0) dot = name.findLast(".grenade");
			if (dot >= 0) name = name.substr(0, dot);
			// Vanilla hat die Faction-Message übersprungen (getResourceName leer) – hier nachholen
			dictionary fa;
			fa["%resource_name"] = name;
			sendFactionMessageKey(m_metagame, m_factionId, "resource added in stock, default", fa, 1.0);
		}
		// Immer als Privatnachricht – garantiert sichtbar (Faction-Message wird in Quick Match oft übersehen)
		dictionary a;
		a["%resource_name"] = name;
		array<const XmlElement@>@ players = getPlayers(m_metagame);
		for (uint i = 0; i < players.size(); ++i) {
			int pid = players[i].getIntAttribute("player_id");
			if (pid >= 0)
				sendPrivateMessageKey(m_metagame, pid, "resource added in stock, default", a);
		}
	}
}

// ------------------------------------------------------------------------------------------------
class ItemDeliveryConfiguratorQuickMatch : ItemDeliveryConfigurator {
	protected Metagame@ m_metagame;
	protected ItemDeliveryOrganizer@ m_itemDeliveryOrganizer;
	protected NotifyingUnlockListener@ m_unlockListener;
	// Member-Arrays persistent halten (AngelScript: lokale Arrays würden nach setup() ungültig)
	protected array<Resource@> m_laptopUnlockList;
	protected array<Resource@> m_briefcaseUnlockList;

	// ------------------------------------------------------------------------------------------------
	ItemDeliveryConfiguratorQuickMatch(Metagame@ metagame) {
		@m_metagame = @metagame;
		@m_unlockListener = NotifyingUnlockListener(metagame, 0);
		buildUnlockLists();
	}

	// --------------------------------------------
	void buildUnlockLists() {
		// Laptop: Items die in Quick Match oft noch nicht in der Fraktion sind
		m_laptopUnlockList.push_back(MultiGroupResource("vest_blackops3.carry_item", "carry_item", array<string> = {"default", "supply"}));
		m_laptopUnlockList.push_back(MultiGroupResource("mk23.weapon", "weapon", array<string> = {"default", "supply"}));
		m_laptopUnlockList.push_back(Resource("xm25.weapon", "weapon"));
		m_laptopUnlockList.push_back(Resource("ares_shrike.weapon", "weapon"));

		m_briefcaseUnlockList.push_back(Resource("mg42.weapon", "weapon"));
		m_briefcaseUnlockList.push_back(Resource("aa-12.weapon", "weapon"));
		m_briefcaseUnlockList.push_back(Resource("musket.weapon", "weapon"));
		m_briefcaseUnlockList.push_back(Resource("desert_eagle.weapon", "weapon"));
		m_briefcaseUnlockList.push_back(Resource("m712.weapon", "weapon"));
		m_briefcaseUnlockList.push_back(MultiGroupResource("vest_blackops3.carry_item", "carry_item", array<string> = {"default", "supply"}));
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
		unlockList.set("laptop.carry_item", @m_laptopUnlockList);

		string thanks = "item objective thanks";
		ResourceUnlocker unlocker(m_metagame, 0, unlockList, @m_unlockListener, "", thanks);

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
		unlockList.set("suitcase.carry_item", @m_briefcaseUnlockList);

		string thanks = "item objective thanks";
		ResourceUnlocker unlocker(m_metagame, 0, unlockList, @m_unlockListener, "", thanks);

		string instructions = "item objective instruction";
		string mapText = "item objective map text";

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, unlocker, instructions, mapText, "", "", -1 /* loop */)
		);
	}
}
