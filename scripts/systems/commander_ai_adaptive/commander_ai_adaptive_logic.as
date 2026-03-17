// Adaptive Commander AI — Reine Logik (kein State, keine Engine).
// computeAiState(ratio) + getAiBaseDef/getAiBorderDef/getAiRadioMessage.

#include "systems/commander_ai_adaptive/commander_ai_adaptive_config.as"

// Liefert State 0..4 aus Capacity-Ratio. Kein Basen-Override (Comeback immer moeglich).
int computeAiState(float ratio) {
	if (ratio > AI_THRESHOLD_DOMINANT)  return AI_STATE_DOMINANT;
	if (ratio > AI_THRESHOLD_ATTACK)    return AI_STATE_ATTACK;
	if (ratio > AI_THRESHOLD_BALANCED)  return AI_STATE_BALANCED;
	if (ratio > AI_THRESHOLD_DEFENSIVE) return AI_STATE_DEFENSIVE;
	return AI_STATE_CRITICAL;
}

float getAiBaseDef(int state) {
	switch (state) {
		case AI_STATE_DOMINANT:  return AI_BASE_DEF_DOMINANT;
		case AI_STATE_ATTACK:    return AI_BASE_DEF_ATTACK;
		case AI_STATE_BALANCED:  return AI_BASE_DEF_BALANCED;
		case AI_STATE_DEFENSIVE: return AI_BASE_DEF_DEFENSIVE;
		case AI_STATE_CRITICAL:  return AI_BASE_DEF_CRITICAL;
		default:                 return AI_BASE_DEF_BALANCED;
	}
}

float getAiBorderDef(int state) {
	switch (state) {
		case AI_STATE_DOMINANT:  return AI_BORDER_DEF_DOMINANT;
		case AI_STATE_ATTACK:    return AI_BORDER_DEF_ATTACK;
		case AI_STATE_BALANCED:  return AI_BORDER_DEF_BALANCED;
		case AI_STATE_DEFENSIVE: return AI_BORDER_DEF_DEFENSIVE;
		case AI_STATE_CRITICAL:  return AI_BORDER_DEF_CRITICAL;
		default:                 return AI_BORDER_DEF_BALANCED;
	}
}

string getAiRadioMessage(int state) {
	switch (state) {
		case AI_STATE_DOMINANT:  return AI_RADIO_DOMINANT;
		case AI_STATE_ATTACK:    return AI_RADIO_ATTACK;
		case AI_STATE_BALANCED:  return AI_RADIO_BALANCED;
		case AI_STATE_DEFENSIVE: return AI_RADIO_DEFENSIVE;
		case AI_STATE_CRITICAL:  return AI_RADIO_CRITICAL;
		default:                 return AI_RADIO_BALANCED;
	}
}
