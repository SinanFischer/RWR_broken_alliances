// Reinforcement system configuration:
// All game rules as central constants 

const int   RS_BASE_POOL                 = 150;    // base pool per faction
const int   RS_UNDERDOG_BONUS_PER_BASE   = 50;     // starting bonus per base deficit
const int   RS_PASSIVE_INCOME_PER_BASE   = 1;      // passive income per held base
const float RS_PASSIVE_INCOME_INTERVAL   = 60.0f;  // interval for passive income
const int   RS_DEATH_COST                = 1;      // reinforcement cost per death
const int   RS_CAPTURE_BONUS             = 50;     // capture bonus (recapture scales from this)
const float RS_RECAPTURE_TIMER_SECONDS   = 300.0f; // time window for full recapture bonus
const float RS_EMPTY_COUNTDOWN_SECONDS   = 180.0f; // countdown when reinforcements reach 0
const float RS_PENALTY_SPAWN_INTERVAL    = 6.5f;   // spawn delay during empty penalty
const float RS_NORMAL_SPAWN_INTERVAL     = 0.5f;   // spawn delay in normal state
const float RS_APPLY_INTERVAL            = 1.0f;   // interval for engine settings apply
const float RS_HUD_UPDATE_INTERVAL       = 1.0f;   // HUD update interval for countdown display

// Underdog compensator (assault surge): capacity_multiplier for an underdog faction
const float RS_COMP_EVAL_DELAY_SECONDS   = 20.0f;  // one-time eval after map start
const int   RS_COMP_DOMINANT_MIN_BASES   = 5;       // >4 bases = dominant threshold
const float RS_COMP_MULT_BASE            = 1.0f;   // neutral / end state
const float RS_COMP_MULT_PHASE1          = 3.0f;   // target assault surge
const float RS_COMP_MULT_PHASE2          = 1.5f;   // target decay phase
const float RS_COMP_LERP_SECONDS         = 60.0f;  // linear ramp duration (start/switch/end)
const float RS_COMP_PHASE1_HOLD_SECONDS  = 120.0f; // hold at phase 1 (3 min)
const float RS_COMP_PHASE2_HOLD_SECONDS  = 100.0f; // hold at phase 2 (2 min)

// Segment order (readability only; logic in reinforcement_compensator.as)
const int RS_COMP_SEG_RAMP_UP            = 0;
const int RS_COMP_SEG_HOLD1              = 1;
const int RS_COMP_SEG_RAMP_4_TO_2        = 2;
const int RS_COMP_SEG_HOLD2              = 3;
const int RS_COMP_SEG_RAMP_2_TO_1        = 4;

// Commander radio (early-game messages e.g. slot-delay balance; delayed second message)
const float RS_COMP_MSG_DELAY_SECONDS    = 10.0f;
const float RS_COMP_MSG_PRIORITY         = 0.95f;
