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
		string itemKey = event.getStringAttribute("item_key");
		int containerId = event.getIntAttribute("target_container_type_id");
		if (containerId == 2) {
			int characterId = event.getIntAttribute("character_id");
			if (itemKey == "squad_equipment_kit.weapon") {
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, characterId, "squad_equipment_kit, equip");
			} else if (itemKey == "eod_vest_squad_kit.weapon") {
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, characterId, "eod_vest_squad_kit, equip");
			}
		}
	}

	// --------------------------------------------
	protected void handleResultEvent(const XmlElement@ event) {
		string eventKey = event.getStringAttribute("key");
		string vestToGive = "";
		string doneMessageKey = "";

		if (eventKey == "squad_equipment_kit") {
			vestToGive = "vest3.carry_item";
			doneMessageKey = "squad_equipment_kit, done";
		} else if (eventKey == "eod_vest_squad_kit") {
			vestToGive = "eodvest_ai.carry_item";
			doneMessageKey = "eod_vest_squad_kit, done";
		}

		if (vestToGive.length() > 0) {
			int characterId = event.getIntAttribute("character_id");
			sendFactionMessageKeySaidAsCharacter(m_metagame, 0, characterId, doneMessageKey);

			int max_soldier_count = 10;
			float range = 30.0;

			array<string> targetKeys = {
				"default",
				"default_ai",
				"medic",
				"sniper"
			};

			array<string> vestKeys = {};
			if (eventKey == "squad_equipment_kit") {
				vestKeys = {
					"costume_werewolf.carry_item",
					"costume_clown.carry_item",
					"costume_santa.carry_item"
				};
			}

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
						// Alle tragen mindestens Default-Weste; Upgrade zu 100% wenn Slot 4 existiert
						if (equipment.size() > 4) {
							string newVest = vestToGive;

							if (eventKey == "squad_equipment_kit") {
								int r = rand(1, 100);
								if (r == 1 && vestKeys.length() > 0) {
									r = rand(0, vestKeys.length() - 1);
									newVest = vestKeys[r];
								}
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

					characters.removeAt(k);
				}
			}
		}
    }
}
