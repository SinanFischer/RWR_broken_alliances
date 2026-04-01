// =============================================================================
// RWR Broken Alliances - Mod Configuration
// =============================================================================
// Central toggle file for all switchable systems.
// Changes take effect on the next game start.
//
// THIS is the only file you need to edit to enable/disable systems.
// =============================================================================



// -----------------------------------------------------------------------------
// REINFORCEMENT SYSTEM 
// -----------------------------------------------------------------------------
// Commands:
//   /rs                -> help/status hint
//   /rs hud            -> HUD status
//   /rs hud on         -> enable reinforcement HUD (admin only)
//   /rs hud off        -> disable reinforcement HUD (admin only)
//   /rs debug          -> toggle debug HUD: "A/C R:X (Ys)" (admin only; mutex mit rs hud)

// NEVER ENABLE TOGETHER WITH THE "SPAWN CAPACITY SYSTEM"!!!!!!
// -----------------------------------------------------------------------------
const bool CFG_REINFORCEMENT_SYSTEM = true;

// -----------------------------------------------------------------------------
// FACTION POINTS SYSTEM
// -----------------------------------------------------------------------------
// Team points system: factions earn shared points through kills, base captures
// etc. Points trigger events (support squads, vehicle waves, reinforcements).
// Has its own HUD in the score display.
// -----------------------------------------------------------------------------
const bool CFG_FACTION_POINTS_SYSTEM = true;



// -----------------------------------------------------------------------------
// **OUTDATED - DONT USE** SPAWN CAPACITY SYSTEM (Respawn Slot Delay)
// -----------------------------------------------------------------------------
// Enables the spawn throttle mechanic: after each death, respawn slots are
// blocked for a short time. Stronger factions are throttled harder.
// Weaker factions receive a temporary capacity boost (balance compensator).
//
// When disabled: no slot blocking, no balance compensator.
// The Alive HUD will then show the native soldier_capacity from the engine.

// NEVER ENABLE TOGETHER WITH "REINFORCEMENT SYSTEM"!!!!!!
// -----------------------------------------------------------------------------
const bool CFG_SPAWN_CAPACITY_SYSTEM = false;

// -----------------------------------------------------------------------------
// **OUTDATED - DONT USE ** FACTION ALIVE HUD
// -----------------------------------------------------------------------------
// Shows "alive / cap" per faction in faction color in the score display.
// Runs independently of the Spawn Capacity System:
//   - With system enabled:  shows effective capacity (after slot throttle)
//   - With system disabled: shows native soldier_capacity from the engine
// Commands:
//   /alive                -> status
//   /alive hud on         -> HUD einschalten (admin only)
//   /alive hud off        -> HUD ausschalten (admin only)
//   /alive hud bases      -> Basen-Anzeige togglen (admin only)
// -----------------------------------------------------------------------------
const bool CFG_FACTION_ALIVE_HUD = true;