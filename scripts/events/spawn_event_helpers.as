// spawn_event_helpers.as
// Gemeinsame Logik für Spawn-Events: Soldaten spawnen, Defend-Objective setzen.
// Nutzung: Captain-Tracker, Single-Base-VIP, weitere Event-Tracker.

#include "query_helpers.as"
#include "helpers.as"

/** Spawnt mehrere Soldaten bei Position. Jeder Eintrag = (instance_key, Anzahl).
 *  Position wird pro Spawn leicht versetzt (X/Z), um Überlappung zu vermeiden. */
void spawnSoldiersAt(Metagame@ metagame, const Vector3 &in basePos, int factionId, const array<string> &in soldierKeys) {
	float offsetSide = 4.0f;
	Vector3 p = basePos;
	for (uint i = 0; i < soldierKeys.length(); ++i) {
		string cmd = "<command class='create_instance' instance_class='soldier' instance_key='" + soldierKeys[i] +
			"' position='" + p.toString() + "' faction_id='" + factionId + "' />";
		metagame.getComms().send(cmd);
		// Nächstes Spawn etwas versetzt (Reihe)
		p.m_values[0] -= offsetSide;
		if ((i + 1) % 3 == 0) {
			p.m_values[0] = basePos.m_values[0];
			p.m_values[2] += offsetSide;
		}
	}
}

/** Setzt soldier_objective 'defend' für einen Charakter an einer Zielposition. */
void setDefendObjective(Metagame@ metagame, int characterId, const string &in positionStr) {
	XmlElement c("command");
	c.setStringAttribute("class", "soldier_objective");
	c.setIntAttribute("character_id", characterId);
	c.setStringAttribute("objective", "defend");
	c.setStringAttribute("target", positionStr);
	metagame.getComms().send(c);
}
