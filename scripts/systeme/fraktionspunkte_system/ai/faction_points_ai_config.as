// =============================================================================
// FP AI - Konfiguration
// =============================================================================
const bool  FP_AI_ENABLED_BY_DEFAULT = true;
const float FP_AI_DECISION_INTERVAL  = 10.0f;  // Haupt-Taktgeber: alle 10s pruefen
const bool  FP_AI_VERBOSE_LOG        = false;

// -----------------------------------------------------------------------------
// Periodic - Event1 (Support Squad)
// Loest alle FP_AI_EVENT1_INTERVAL Sekunden mit FP_AI_EVENT1_CHANCE Wahrscheinlichkeit aus.
const float FP_AI_EVENT1_INTERVAL = 60.0f;
const float FP_AI_EVENT1_CHANCE   = 0.05f;  // 5%

// -----------------------------------------------------------------------------
// Reactive - Event3 (Defense Response)
// Loest bei Basisverlust mit FP_AI_EVENT3_CHANCE Wahrscheinlichkeit aus.
const float FP_AI_EVENT3_CHANCE = 0.25f;  // 25%

// -----------------------------------------------------------------------------
// Strategic - Spare-Event-Pool
//
// Jede Fraktion wuerfelt ein Sparziel aus dieser Tabelle.
// Sobald FP >= Kosten + Reserve wird das Event ausgefuehrt, dann neuer Roll.
//
// "save" = Null-Eintrag: Fraktion spart passiv fuer FP_AI_SAVE_DURATION Sekunden.
//          Nur waehlbar wenn Fraktion > 2 Basen haelt (stabile Lage).
//
// Um ein Event hinzuzufuegen oder zu entfernen: Zeile eintragen / loeschen.
// Gewichte sind relativ zueinander (kein Maximum von 1.0 noetig).
//
//   Token     Gewicht   Bedeutung
//   --------  -------   -----------------------------------------
//   event2    0.2       Company Attack  - grosse Offensive
//   event4    0.6       Base Reinforcement - Fallschirmjaeger
//   event5    0.5       Vehicle Support - mittleres Fahrzeug
//   event6    0.3       Heavy Armour - schweres Fahrzeug (nur bei > 3 Basen)
//   event7    0.4       Armoured Wave - 3x Medium Vehicle
//   save      0.3       Spar-Phase (kein Kauf, 2 Minuten warten)
//
// ACHTUNG: Token-Strings muessen mit den Event-Konstanten (FP_EVENTx_TOKEN) uebereinstimmen.
//
const int   FP_AI_SPARE_POOL_SIZE = 6;  // Anzahl Eintraege in den Arrays unten (muss stimmen)

// Token-Name und Gewicht pro Eintrag - Suffix = Event-Nummer, _SAVE = Spar-Phase.
const string FP_AI_SPARE_TOKEN_EVENT2 = "event2";
const string FP_AI_SPARE_TOKEN_EVENT4 = "event4";
const string FP_AI_SPARE_TOKEN_EVENT5 = "event5";
const string FP_AI_SPARE_TOKEN_EVENT6 = "event6";
const string FP_AI_SPARE_TOKEN_EVENT7 = "event7";
const string FP_AI_SPARE_TOKEN_SAVE   = "save";

const float FP_AI_SPARE_WEIGHT_EVENT2 = 0.2f;
const float FP_AI_SPARE_WEIGHT_EVENT4 = 0.4f;
const float FP_AI_SPARE_WEIGHT_EVENT5 = 0.5f;
const float FP_AI_SPARE_WEIGHT_EVENT6 = 0.35f;
const float FP_AI_SPARE_WEIGHT_EVENT7 = 0.15f;
const float FP_AI_SPARE_WEIGHT_SAVE   = 0.3f;

const float FP_AI_SAVE_DURATION = 120.0f;  // Spar-Phase: 2 Minuten, dann neuer Roll

// Reserve nach Spare-Event-Kauf: zufaellig zwischen MIN und MAX.
// Verhindert vorhersehbares Kaufverhalten bei festem Schwellwert.
const int FP_AI_RESERVE_MIN = 0;
const int FP_AI_RESERVE_MAX = 450;
