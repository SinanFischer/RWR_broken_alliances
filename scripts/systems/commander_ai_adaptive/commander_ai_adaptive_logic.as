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
	float result = AI_BASE_DEF_BALANCED;
	switch (state) {
		case AI_STATE_DOMINANT:  result = AI_BASE_DEF_DOMINANT;  break;
		case AI_STATE_ATTACK:    result = AI_BASE_DEF_ATTACK;    break;
		case AI_STATE_BALANCED:  result = AI_BASE_DEF_BALANCED;  break;
		case AI_STATE_DEFENSIVE: result = AI_BASE_DEF_DEFENSIVE; break;
		case AI_STATE_CRITICAL:  result = AI_BASE_DEF_CRITICAL;  break;
	}
	return result;
}

float getAiBorderDef(int state) {
	float result = AI_BORDER_DEF_BALANCED;
	switch (state) {
		case AI_STATE_DOMINANT:  result = AI_BORDER_DEF_DOMINANT;  break;
		case AI_STATE_ATTACK:    result = AI_BORDER_DEF_ATTACK;    break;
		case AI_STATE_BALANCED:  result = AI_BORDER_DEF_BALANCED;  break;
		case AI_STATE_DEFENSIVE: result = AI_BORDER_DEF_DEFENSIVE; break;
		case AI_STATE_CRITICAL:  result = AI_BORDER_DEF_CRITICAL;  break;
	}
	return result;
}

string getAiRadioMessage(int state) {
	string result = AI_RADIO_BALANCED;
	switch (state) {
		case AI_STATE_DOMINANT:  result = AI_RADIO_DOMINANT;  break;
		case AI_STATE_ATTACK:    result = AI_RADIO_ATTACK;    break;
		case AI_STATE_BALANCED:  result = AI_RADIO_BALANCED;  break;
		case AI_STATE_DEFENSIVE: result = AI_RADIO_DEFENSIVE; break;
		case AI_STATE_CRITICAL:  result = AI_RADIO_CRITICAL;  break;
	}
	return result;
}
