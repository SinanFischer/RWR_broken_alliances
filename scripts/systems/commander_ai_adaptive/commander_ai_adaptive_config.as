// Adaptive Commander AI — Konfiguration.
// Alle Gewichtungen als Prozentwerte (Max 1.0). Single Source of Truth.

// --- State-IDs (0..4) ---
const int AI_STATE_DOMINANT  = 0;
const int AI_STATE_ATTACK    = 1;
const int AI_STATE_BALANCED  = 2;
const int AI_STATE_DEFENSIVE = 3;
const int AI_STATE_CRITICAL  = 4;

// --- Capacity-Ratio-Thresholds (ratio = effectiveCap / rawCap) ---
const float AI_THRESHOLD_DOMINANT  = 0.85f;
const float AI_THRESHOLD_ATTACK    = 0.70f;
const float AI_THRESHOLD_BALANCED  = 0.50f;
const float AI_THRESHOLD_DEFENSIVE = 0.30f;

// --- Defense-Werte pro State (base_defense, border_defense) ---
const float AI_BASE_DEF_DOMINANT   = 0.05f;
const float AI_BASE_DEF_ATTACK     = 0.10f;
const float AI_BASE_DEF_BALANCED   = 0.25f;
const float AI_BASE_DEF_DEFENSIVE  = 0.50f;
const float AI_BASE_DEF_CRITICAL   = 0.70f;

const float AI_BORDER_DEF_DOMINANT   = 0.10f;
const float AI_BORDER_DEF_ATTACK     = 0.20f;
const float AI_BORDER_DEF_BALANCED   = 0.35f;
const float AI_BORDER_DEF_DEFENSIVE  = 0.65f;
const float AI_BORDER_DEF_CRITICAL   = 0.90f;

// --- Update-Intervall (s) ---
const float AI_UPDATE_INTERVAL = 10.0f;

// --- Radio-Nachrichten bei Zustandswechsel (Commander-Ton) ---
const string AI_RADIO_DOMINANT   = "All units — push the line. Full offensive. Out.";
const string AI_RADIO_ATTACK     = "Advance on contact. Maintain pressure. Out.";
const string AI_RADIO_BALANCED   = "Hold current positions. Engage on contact only. Out.";
const string AI_RADIO_DEFENSIVE  = "Command to all — fall back to defensive lines. Out.";
const string AI_RADIO_CRITICAL   = "All units, Command — fortify all positions. Do NOT advance. Out.";
