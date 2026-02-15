// character_death_helpers.as
// Hilfsfunktionen für Todes-Events (character_kill, character_die).
// Engine kann "target" oder "character" als Kind verwenden – beide abdecken für robuste Erkennung.
// Vorbild: vanilla respawn_slot_delay_tracker, stats_command_tracker (character/target Fallback).

#include "log.as"

// ----------------------------------------------------
// Gibt das Xml-Element des toten Charakters aus dem Event zurück.
// character_kill: in der Regel <target>; character_die: in der Regel <character>.
// Rückgabe null, wenn kein gültiges Element gefunden.
// ----------------------------------------------------
const XmlElement@ getDeadCharacterFromDeathEvent(const XmlElement@ event) {
	if (event is null) return null;
	const XmlElement@ character = event.getFirstElementByTagName("character");
	const XmlElement@ target = event.getFirstElementByTagName("target");
	const XmlElement@ dead = character !is null ? character : target;
	return dead;
}

// ----------------------------------------------------
// Schreibt ein einzeiliges Log mit relevanten Event-Daten (Captain-Tod).
// source: "character_kill" oder "character_die".
// ----------------------------------------------------
void logCaptainDeathEventPayload(const XmlElement@ event, const string &in source, const XmlElement@ deadElement) {
	if (deadElement is null) return;
	string line = "CaptainDeath event=" + source +
		" dead_id=" + deadElement.getIntAttribute("id") +
		" dead_faction_id=" + deadElement.getIntAttribute("faction_id") +
		" soldier_group_name=" + deadElement.getStringAttribute("soldier_group_name");
	if (source == "character_kill") {
		const XmlElement@ killer = event.getFirstElementByTagName("killer");
		if (killer !is null)
			line += " killer_id=" + killer.getIntAttribute("id") + " killer_faction_id=" + killer.getIntAttribute("faction_id") + " killer_player_id=" + killer.getIntAttribute("player_id");
	}
	_log("CaptainSpawnCommandTracker: " + line, 0);
}
