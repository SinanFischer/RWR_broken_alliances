// AI-Konfiguration (Utility AI vereinfacht auf Chance-Rolls und Save-Goals).
const bool  FP_AI_ENABLED_BY_DEFAULT = true;
const float FP_AI_DECISION_INTERVAL  = 10.0f; // Haupt-Taktgeber: alle 10s pruefen
const bool  FP_AI_VERBOSE_LOG        = false;

// Event 1 (Support Squad): alle 60s, 5% Chance pro Fraktion
const float FP_AI_EVENT1_INTERVAL = 60.0f;
const float FP_AI_EVENT1_CHANCE   = 0.05f;

// Event 3 (Defense Response): bei Basierverlust, 25% Chance
const float FP_AI_EVENT3_CHANCE = 0.25f;

// Spare Events (2, 4, 5) + Saving: gewichteter Zufalls-Roll fuer das naechste Sparziel
// "save" = Null-Event: Fraktion spart frei fuer 2 Minuten, dann neuer Roll.
// Bedingung fuer "save": mehr als 2 Basen (Fraktion ist stabil genug zum Sparen).
const float FP_AI_EVENT2_WEIGHT      = 0.2f;
const float FP_AI_EVENT4_WEIGHT      = 0.6f;
const float FP_AI_EVENT5_WEIGHT      = 0.5f;
const float FP_AI_SAVE_EVENT_WEIGHT  = 0.3f;  // Chance dass Fraktion einfach spart (kein Kauf)
const float FP_AI_SAVE_DURATION      = 120.0f; // Spar-Phase dauert 2 Minuten, dann neuer Roll

// Reserve nach Spare-Event-Kauf: zufaellig zwischen MIN und MAX
const int FP_AI_RESERVE_MIN = 0;
const int FP_AI_RESERVE_MAX = 450;
