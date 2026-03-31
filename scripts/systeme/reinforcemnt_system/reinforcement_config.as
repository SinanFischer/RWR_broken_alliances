// Reinforcement-System-Konfiguration:
// Alle Spielregeln zentral als Konstanten (keine Magic Numbers im Code).

const int   RS_BASE_POOL                 = 500;    // Basiswert pro Fraktion
const int   RS_UNDERDOG_BONUS_PER_BASE   = 50;     // Startbonus pro Basis-Rueckstand
const int   RS_PASSIVE_INCOME_PER_BASE   = 3;      // passiver Ertrag pro gehaltener Basis
const float RS_PASSIVE_INCOME_INTERVAL   = 60.0f;  // Intervall fuer passiven Ertrag
const int   RS_DEATH_COST                = 1;      // Reservisten-Kosten pro Tod
const int   RS_CAPTURE_BONUS             = 50;     // Capture-Bonus (Recapture wird damit skaliert)
const float RS_RECAPTURE_TIMER_SECONDS   = 300.0f; // Zeitfenster fuer vollen Recapture-Bonus
const float RS_EMPTY_COUNTDOWN_SECONDS   = 120.0f; // Countdown bei 0 Reservisten
const float RS_PENALTY_SPAWN_INTERVAL    = 10.0f;  // Spawn-Delay waehrend Empty-Penalty
const float RS_NORMAL_SPAWN_INTERVAL     = 0.5f;   // Spawn-Delay im Normalzustand
const float RS_APPLY_INTERVAL            = 1.0f;   // Intervall fuer Engine-Settings-Apply
const float RS_HUD_UPDATE_INTERVAL       = 1.0f;   // HUD-Update fuer Countdown-Anzeige
