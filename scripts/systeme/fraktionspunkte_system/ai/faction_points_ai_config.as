// Zentrale AI-Konfiguration (Utility AI = Entscheidung per Nutzwert-Score).
const bool FP_AI_ENABLED_BY_DEFAULT = true;
const float FP_AI_DECISION_INTERVAL = 10.0f; // Decider-Takt: alle 10s pruefen ob Sparziel erreicht
const int FP_AI_MIN_POINTS_RESERVE = 150;
const float FP_AI_MIN_UTILITY_TO_SPEND = 0.55f;
const bool FP_AI_VERBOSE_LOG = false;

// Prioritaetsindex (Importance Index = relative strategische Wichtigkeit).
const float FP_AI_EVENT1_IMPORTANCE = 0.60f;
const float FP_AI_EVENT2_IMPORTANCE = 0.90f;
const float FP_AI_EVENT3_IMPORTANCE = 1.00f;
const float FP_AI_EVENT4_IMPORTANCE = 0.70f; // Basis-Verstaerkung: Verteidigung hat mittlere Prio
const float FP_AI_EVENT5_IMPORTANCE = 0.65f; // Fahrzeug-Unterstuetzung: nützlich mit mehreren Basen

// Sparziele (Save Target = FP-Wert, auf den aktiv hingespart wird).
const int FP_AI_EVENT2_SAVE_TARGET = 1200;
const int FP_AI_EVENT4_SAVE_TARGET = 350;
const int FP_AI_EVENT5_SAVE_TARGET = 500;
