// Adaptive Commander AI — Konfiguration. Single Source of Truth.

// --- Event-IDs ---
const int AI_EVENT_IDLE             = 0;  // Kein aktives Event, native AI laeuft
const int AI_EVENT_DEFENSIVE_PAUSE  = 1;  // Zwangsverteidigung (60s), dann Revert
const int AI_EVENT_GRAND_ASSAULT    = 2;  // Grossangriff (90s), dann Revert

// --- Trigger-Thresholds (ratio = effectiveCap / rawCap) ---
const float AI_TRIGGER_DEFENSIVE = 0.40f;  // ratio < 0.40 → DEFENSIVE_PAUSE moeglich
const float AI_TRIGGER_ASSAULT   = 0.85f;  // ratio > 0.85 → GRAND_ASSAULT moeglich

// --- Event-Dauer (s) ---
const float AI_DURATION_DEFENSIVE_PAUSE = 60.0f;
const float AI_DURATION_GRAND_ASSAULT   = 90.0f;

// --- Cooldown nach Event-Ende (s) — verhindert sofortiges Re-Triggern ---
const float AI_COOLDOWN_AFTER_EVENT = 120.0f;

// --- Verzögerter Start (s) — wartet bis Map vollständig geladen ist ---
const float AI_START_DELAY = 15.0f;

// --- Evaluierungs-Intervall (s) ---
// 45s: Angriffe/Verteidigungen haben Zeit sich zu stabilisieren.
const float AI_UPDATE_INTERVAL = 45.0f;

// --- Zufallschance fuer GRAND_ASSAULT pro Check (0.0–1.0) ---
const float AI_ASSAULT_CHANCE = 0.15f;

// --- Defense-Werte fuer Events ---
// DEFENSIVE_PAUSE: maximale Verteidigung, kein Angriff
const float AI_BASE_DEF_DEFENSIVE_PAUSE  = 0.85f;
const float AI_BORDER_DEF_DEFENSIVE_PAUSE = 0.90f;

// GRAND_ASSAULT: aggressiver Push, Mindestverteidigung bleibt
const float AI_BASE_DEF_GRAND_ASSAULT   = 0.25f;
const float AI_BORDER_DEF_GRAND_ASSAULT = 0.15f;

// --- Radio-Nachrichten bei Event-Start ---
const string AI_RADIO_DEFENSIVE_PAUSE = "Command to all — pull back immediately. Defensive positions only. Out.";
const string AI_RADIO_GRAND_ASSAULT   = "All units — full assault. Push every line. For glory. Out.";
const string AI_RADIO_REVERT          = "Command — returning to standard operational posture. Out.";
