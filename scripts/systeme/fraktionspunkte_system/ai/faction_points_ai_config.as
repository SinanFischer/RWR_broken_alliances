// Zentrale AI-Konfiguration (Utility AI = Entscheidung per Nutzwert-Score).
const bool FP_AI_ENABLED_BY_DEFAULT = true;
const float FP_AI_DECISION_INTERVAL = 25.0f;
const int FP_AI_MIN_POINTS_RESERVE = 150;
const float FP_AI_MIN_UTILITY_TO_SPEND = 0.55f;
const bool FP_AI_VERBOSE_LOG = false;

// Prioritaetsindex (Importance Index = relative strategische Wichtigkeit).
const float FP_AI_EVENT1_IMPORTANCE = 0.60f;
const float FP_AI_EVENT2_IMPORTANCE = 0.90f;
const float FP_AI_EVENT3_IMPORTANCE = 1.00f;

// Sparziel (Save Target = FP-Wert, auf den aktiv hingespart wird).
const int FP_AI_EVENT2_SAVE_TARGET = 1200;
