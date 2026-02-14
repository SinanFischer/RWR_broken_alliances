#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"

//Author: Unit G17
// Integrated into RWR Total Conversion Mod - costume list limited to items present in mod

	// --------------------------------------------
class SquadEquipmentKit : Tracker {
	protected Metagame@ m_metagame;

	// --------------------------------------------
	SquadEquipmentKit(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	// --------------------------------------------
	protected void handleItemDropEvent(const XmlElement@ event) {
		//squad equipment kit key
		string key = "squad_equipment_kit.weapon";

		string itemKey = event.getStringAttribute("item_key");
		int containerId = event.getIntAttribute("target_container_type_id");
		if (key == itemKey && containerId == 2) {
			int characterId = event.getIntAttribute("character_id");
			//Announcing item description when equipping the kit
			sendFactionMessageKeySaidAsCharacter(m_metagame, 0, characterId, "squad_equipment_kit, equip");
		}
	}

	// --------------------------------------------
	protected void handleResultEvent(const XmlElement@ event) {
		string key = "squad_equipment_kit";
		string eventKey = event.getStringAttribute("key");
		if (key == eventKey) {
			int characterId = event.getIntAttribute("character_id");
			sendFactionMessageKeySaidAsCharacter(m_metagame, 0, characterId, "squad_equipment_kit, done");

			int max_soldier_count = 10;
			float range = 30.0;

			array<string> targetKeys = {
				"default",
				"default_ai",
				"medic",
				"sniper"
			};

			// Costumes that may be found in faulty kits (only items that exist in this mod)
			array<string> vestKeys = {
				"costume_werewolf.carry_item",
				"costume_clown.carry_item",
				"costume_santa.carry_item"
			};

			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			if (character !is null) {
				int factionId = character.getIntAttribute("faction_id");
				Vector3 position = stringToVector3(event.getStringAttribute("position"));
				array<const XmlElement@>@ characters = getCharactersNearPosition(m_metagame, position, factionId, range);
				int soldier_count = 0;
				uint total_soldier_count = characters.length();

				for (uint i = 0; i < total_soldier_count; ++i) {
					int k = rand(0, characters.length() - 1);
					int soldierId = characters[k].getIntAttribute("id");
					const XmlElement@ characterInfo = getCharacterInfo2(m_metagame, soldierId);

					string soldierClass = characterInfo.getStringAttribute("soldier_group_name");
					float soldierXp = characterInfo.getFloatAttribute("xp");

					if (targetKeys.find(soldierClass) != -1 && soldierXp >= 0.1) {
						array<const XmlElement@>@ equipment = characterInfo.getElementsByTagName("item");
						if (equipment.size() > 0) {
							int vestAmount = equipment[4].getIntAttribute("amount");
							string vestKey = equipment[4].getStringAttribute("key");

							if (vestAmount == 0 || (vestAmount == 1 &&
							(	vestKey == "vest2_2" ||
								vestKey == "vest2_3" ||
								vestKey == "vest1.carry_item" ||
								vestKey == "vest3_2"||
								vestKey == "vest3_3"||
								vestKey == "vest3_4"||
								vestKey == "vest3_5"||
								vestKey == "vest1_2"))) {
								string newVest = "vest3.carry_item";

								int r = rand(1, 100);
								if (r == 1 && vestKeys.length() > 0) {
									r = rand(0, vestKeys.length() - 1);
									newVest = vestKeys[r];
								}

								XmlElement c("command");
								c.setStringAttribute("class", "update_inventory");
								c.setIntAttribute("character_id", soldierId);
								c.setIntAttribute("container_type_id", 4);
								{
									XmlElement j("item");
									j.setStringAttribute("class", "carry_item");
									j.setStringAttribute("key", newVest);
									c.appendChild(j);
								}
								m_metagame.getComms().send(c);

								soldier_count++;
								if (soldier_count >= max_soldier_count) {
									break;
								}
							}
						}
					}

					characters.removeAt(k);
				}
			}
		}
    }
}
