// Spawn-Capacity-System (Facade):
// Zentrale Include-Stelle fuer Slotblock, Stats und optionale Debug-Anzeige.
// Ziel: Erweiterungen an einem Ort andocken, ohne Gamemode-Includes zu streuen.
//
// Enthaltene Tracker:
// - RespawnSlotDelayTracker: Slotblock/CAP-Multiplier-Logik
// - StatsCommandTracker: /stats-Anzeige fuer Cap/Blocked/Impact
// - CapacityDebugHudTracker: optionale HUD-Diagnose

#include "../../trackers/respawn_slot_delay_tracker.as"
#include "../../trackers/stats_command_tracker.as"
#include "../../trackers/capacity_debug_hud_tracker.as"
