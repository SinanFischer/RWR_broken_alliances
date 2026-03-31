// =============================================================================
// RWR Broken Alliances - Mod Configuration
// =============================================================================
// Central toggle file for all switchable systems.
// Changes take effect on the next game start.
//
// THIS is the only file you need to edit to enable/disable systems.
// =============================================================================

// -----------------------------------------------------------------------------
// SPAWN CAPACITY SYSTEM (Respawn Slot Delay)
// -----------------------------------------------------------------------------
// Enables the spawn throttle mechanic: after each death, respawn slots are
// blocked for a short time. Stronger factions are throttled harder.
// Weaker factions receive a temporary capacity boost (balance compensator).
//
// When disabled: no slot blocking, no balance compensator.
// The Alive HUD will then show the native soldier_capacity from the engine.
// -----------------------------------------------------------------------------
const bool CFG_SPAWN_CAPACITY_SYSTEM = true;

// -----------------------------------------------------------------------------
// FACTION ALIVE HUD
// -----------------------------------------------------------------------------
// Shows "alive / cap" per faction in faction color in the score display.
// Runs independently of the Spawn Capacity System:
//   - With system enabled:  shows effective capacity (after slot throttle)
//   - With system disabled: shows native soldier_capacity from the engine
// Can be toggled at runtime via /hud on|off|bases (admin only).
// -----------------------------------------------------------------------------
const bool CFG_FACTION_ALIVE_HUD = true;

// -----------------------------------------------------------------------------
// FACTION POINTS SYSTEM
// -----------------------------------------------------------------------------
// Team points system: factions earn shared points through kills, base captures
// etc. Points trigger events (support squads, vehicle waves, reinforcements).
// Has its own HUD in the score display.
// HUD mutex: if Alive HUD is on, FP HUD is automatically disabled.
// -----------------------------------------------------------------------------
const bool CFG_FACTION_POINTS_SYSTEM = true;
