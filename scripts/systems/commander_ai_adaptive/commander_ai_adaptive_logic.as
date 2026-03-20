// Adaptive Commander AI - Reine Logik (kein State, keine Engine-Calls).
// Entscheidet ob ein Event getriggert werden soll.

#include "systems/commander_ai_adaptive/commander_ai_adaptive_config.as"
#include "systems/commander_ai_adaptive/commander_ai_native_defaults.as"

// Liefert defense-Werte fuer ein aktives Event.
void getEventDefenseValues(int eventId, float &out baseDef, float &out borderDef) {
	if (eventId == AI_EVENT_DEFENSIVE_PAUSE) {
		baseDef   = AI_BASE_DEF_DEFENSIVE_PAUSE;
		borderDef = AI_BORDER_DEF_DEFENSIVE_PAUSE;
		return;
	}
	if (eventId == AI_EVENT_GRAND_ASSAULT) {
		baseDef   = AI_BASE_DEF_GRAND_ASSAULT;
		borderDef = AI_BORDER_DEF_GRAND_ASSAULT;
		return;
	}
	// IDLE: Aufrufer soll native Werte nutzen
	baseDef   = AI_NATIVE_FALLBACK_BASE;
	borderDef = AI_NATIVE_FALLBACK_BORDER;
}

// Prueft ob DEFENSIVE_PAUSE ausgeloest werden soll.
bool shouldTriggerDefensivePause(float ratio) {
	return ratio < AI_TRIGGER_DEFENSIVE;
}

// Prueft ob GRAND_ASSAULT ausgeloest werden soll (inkl. Zufallschance).
// randomValue: gleichverteilter Wert 0.0–1.0 (vom Aufrufer generiert).
bool shouldTriggerGrandAssault(float ratio, float randomValue) {
	return ratio > AI_TRIGGER_ASSAULT && randomValue < AI_ASSAULT_CHANCE;
}

// Gibt lesbares Label fuer Event-ID zurueck (fuer Status-Reports).
string getEventLabel(int eventId) {
	string result = "IDLE";
	if (eventId == AI_EVENT_DEFENSIVE_PAUSE) result = "DEFENSIVE_PAUSE";
	if (eventId == AI_EVENT_GRAND_ASSAULT)   result = "GRAND_ASSAULT";
	return result;
}
