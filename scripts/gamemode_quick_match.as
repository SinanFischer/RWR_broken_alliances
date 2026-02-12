// Quick-Match-Gamemode: Match läuft bereits (Engine hat Karte geladen).
// Lädt nur den Nachschub-Tracker (1000 Soldaten pro Fraktion) + Basis-Command-Handler.
#include "metagame.as"
#include "log.as"
#include "query_helpers.as"
#include "basic_command_handler.as"
#include "trackers/faction_alive_hud_tracker.as"
// Capacity-Debug: HUD zeigt "Alive/Capacity" pro Fraktion. RespawnSlotDelayTracker muss vor capacity_debug_hud eingebunden sein.
#include "trackers/respawn_slot_delay_tracker.as"
#include "trackers/capacity_debug_hud_tracker.as"
#include "trackers/stats_command_tracker.as"
#include "trackers/vehicle_interval_spawn.as"
// #include "trackers/reinforcement_pool_tracker.as"  // aus: Reinforcement-Pool deaktiviert

// true = HUD zeigt Alive/Capacity (Respawn-Slot-Delay-Debug), false = HUD zeigt nur Alive 200m (normal)
const bool CAPACITY_DEBUG_HUD = false;

// --------------------------------------------
class GameModeQuickMatch : Metagame {
	// --------------------------------------------
	GameModeQuickMatch(const XmlElement@ settings) {
		super(settings.getStringAttribute("log_level"));
	}

	// --------------------------------------------
	void init() {
		Metagame::init();
		preBeginMatch();
		postBeginMatch();
	}

	// --------------------------------------------
	void postBeginMatch() {
		Metagame::postBeginMatch();
		addTracker(BasicCommandHandler(this));
		RespawnSlotDelayTracker@ respawnTr = RespawnSlotDelayTracker(this);
		addTracker(respawnTr);
		addTracker(StatsCommandTracker(this, respawnTr)); // /stats für alle, sofort
		if (CAPACITY_DEBUG_HUD) {
			addTracker(CapacityDebugHudTracker(this, respawnTr));
		} else {
			addTracker(FactionAliveHudTracker(this)); // HUD: nur Einheiten in 200m
		}
		addTracker(VehicleIntervalSpawn(this)); // Fahrzeug-Spawn alle 2–4 min (simple) / 5–8 min (medium)
		// addTracker(ReinforcementPoolTracker(this));  // aus: Reinforcement-Pool deaktiviert

		const XmlElement@ player = getPlayerInfo(this, 0);
		if (player !is null) {
			string username = player.getStringAttribute("name");
			if (!getAdminManager().isAdmin(username)) {
				getAdminManager().addAdmin(username);
			}
		}
	}
}
