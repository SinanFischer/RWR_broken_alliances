// Gemeinsame Helfer für Admin-Commands (Unit-Spawn bei Spieler, etc.).
// Enthält nur Logik – keine Tracker. Wird von einzelnen Command-Trackern inkludiert.
#include "query_helpers.as"
#include "helpers.as"

/** Spawnt eine generische Instanz (soldier, vehicle, weapon, carry_item) bei der Spielerposition.
 *  @return true bei Erfolg, false wenn Spieler/Character nicht gefunden. */
bool spawnInstanceAtPlayer(Metagame@ m_metagame, int senderId, const string &in instanceClass, const string &in instanceKey, float offsetMeters, const string &in successMessage) {
	const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
	if (playerInfo is null) {
		sendPrivateMessage(m_metagame, senderId, "Player not found.");
		return false;
	}
	const XmlElement@ characterInfo = getCharacterInfo(m_metagame, playerInfo.getIntAttribute("character_id"));
	if (characterInfo is null) {
		sendPrivateMessage(m_metagame, senderId, "No character (dead/spectating?).");
		return false;
	}
	Vector3 pos = stringToVector3(characterInfo.getStringAttribute("position"));
	pos.m_values[0] += offsetMeters;
	
	// FIX: Höher spawnen, um Bodenkollision zu vermeiden (analog zu basic_command_handler: +50 bei Skydive, hier +5.0)
	pos.m_values[1] += 5.0; 

	// Fraktion des Spielers nutzen (für Fahrzeuge/Soldaten relevant, für Waffen meist egal aber ok)
	int factionId = playerInfo.getIntAttribute("faction_id");
	string cmd = "<command class='create_instance' instance_class='" + instanceClass + "' instance_key='" + instanceKey +
		"' position='" + pos.toString() + "' faction_id='" + factionId + "' />";
	m_metagame.getComms().send(cmd);
	sendPrivateMessage(m_metagame, senderId, successMessage);
	return true;
}

/** Wrapper für Soldier-Spawn */
bool spawnUnitAtPlayer(Metagame@ m_metagame, int senderId, const string &in soldierKey, float offsetMeters, const string &in successMessage) {
	return spawnInstanceAtPlayer(m_metagame, senderId, "soldier", soldierKey, offsetMeters, successMessage);
}

/** Wrapper für Vehicle-Spawn */
bool spawnVehicleAtPlayer(Metagame@ m_metagame, int senderId, const string &in vehicleKey, float offsetMeters, const string &in successMessage) {
	return spawnInstanceAtPlayer(m_metagame, senderId, "vehicle", vehicleKey, offsetMeters, successMessage);
}
