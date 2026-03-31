// Reinforcement-System-Konfiguration:
// Alle Spielregeln zentral als Konstanten (keine Magic Numbers im Code).

const int   RS_BASE_POOL                 = 150;    // Basiswert pro Fraktion
const int   RS_UNDERDOG_BONUS_PER_BASE   = 50;     // Startbonus pro Basis-Rueckstand
const int   RS_PASSIVE_INCOME_PER_BASE   = 1;      // passiver Ertrag pro gehaltener Basis
const float RS_PASSIVE_INCOME_INTERVAL   = 90.0f;  // Intervall fuer passiven Ertrag
const int   RS_DEATH_COST                = 1;      // Reservisten-Kosten pro Tod
const int   RS_CAPTURE_BONUS             = 50;     // Capture-Bonus (Recapture wird damit skaliert)
const float RS_RECAPTURE_TIMER_SECONDS   = 300.0f; // Zeitfenster fuer vollen Recapture-Bonus
const float RS_EMPTY_COUNTDOWN_SECONDS   = 180.0f; // Countdown bei 0 Reservisten
const float RS_PENALTY_SPAWN_INTERVAL    = 6.5f;  // Spawn-Delay waehrend Empty-Penalty
const float RS_NORMAL_SPAWN_INTERVAL     = 0.5f;   // Spawn-Delay im Normalzustand
const float RS_APPLY_INTERVAL            = 1.0f;   // Intervall fuer Engine-Settings-Apply
const float RS_HUD_UPDATE_INTERVAL       = 1.0f;   // HUD-Update fuer Countdown-Anzeige

// Underdog-Kompensator (Sturmangriff): capacity_multiplier fuer eine Underdog-Fraktion
const float RS_COMP_EVAL_DELAY_SECONDS   = 20.0f;  // einmalige Eval nach Map-Start
const int   RS_COMP_DOMINANT_MIN_BASES   = 6;       // >5 Basen = mindestens diese Anzahl
const float RS_COMP_MULT_BASE            = 1.0f;   // neutral / Ende
const float RS_COMP_MULT_PHASE1          = 3.0f;   // Ziel Sturmangriff
const float RS_COMP_MULT_PHASE2          = 1.5f;   // Ziel Abklingen
const float RS_COMP_LERP_SECONDS         = 60.0f;  // lineare Rampen Start/Wechsel/Ende
const float RS_COMP_PHASE1_HOLD_SECONDS  = 120.0f; // Hold auf Phase1 (3 min)
const float RS_COMP_PHASE2_HOLD_SECONDS  = 100.0f; // Hold auf Phase2 (2 min)

// Segment-Reihenfolge (nur fuer Lesbarkeit; Logik in reinforcement_compensator.as)
const int RS_COMP_SEG_RAMP_UP            = 0;
const int RS_COMP_SEG_HOLD1              = 1;
const int RS_COMP_SEG_RAMP_4_TO_2        = 2;
const int RS_COMP_SEG_HOLD2              = 3;
const int RS_COMP_SEG_RAMP_2_TO_1        = 4;

// Commander-Funk (Early-Game-Texte wie Slot-Delay-Balance; verzoegerte Zweitnachricht)
const float RS_COMP_MSG_DELAY_SECONDS    = 10.0f;
const float RS_COMP_MSG_PRIORITY         = 0.95f;
