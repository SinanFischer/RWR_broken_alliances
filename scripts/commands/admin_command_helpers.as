// Gemeinsame Helfer für Admin-Commands (Unit-Spawn bei Spieler, etc.).
// Enthält nur Logik – keine Tracker. Wird von einzelnen Command-Trackern inkludiert.
#include "query_helpers.as"
#include "helpers.as"

/** Spawnt eine Einheit (soldier) bei der Spielerposition. Fraktion = Spielerfraktion.
 *  @return true bei Erfolg, false wenn Spieler/Character nicht gefunden (Nachricht wurde bereits gesendet). */
bool spawnUnitAtPlayer(Metagame@ m_metagame, int senderId, const string &in soldierKey, float offsetMeters, const string &in successMessage) {
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

	int factionId = playerInfo.getIntAttribute("faction_id");
	string cmd = "<command class='create_instance' instance_class='soldier' instance_key='" + soldierKey +
		"' position='" + pos.toString() + "' faction_id='" + factionId + "' />";
	m_metagame.getComms().send(cmd);
	sendPrivateMessage(m_metagame, senderId, successMessage);
	return true;
}
