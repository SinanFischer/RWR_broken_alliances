// Quick-Match-Gamemode: Match läuft bereits (Engine hat Karte geladen).
// Lädt nur den Nachschub-Tracker (1000 Soldaten pro Fraktion) + Basis-Command-Handler.
#include "metagame.as"
#include "log.as"
#include "query_helpers.as"
#include "basic_command_handler.as"
#include "trackers/faction_alive_hud_tracker.as"
// Spawn-Capacity-System (Slotblock + Stats + optionales Debug-HUD) als zentrales Modul.
#include "systems/spawn_capacity/spawn_capacity_system.as"
#include "trackers/vehicle_interval_spawn.as"
#include "events/captain_spawn_command_tracker.as"
#include "events/single_base_vip_tracker.as"
#include "events/intel_manager_quickmatch.as"
#include "commands/blackops3_vest_command_tracker.as"
#include "delivery_unlocks/item_delivery_configurator_quickmatch.as"
// #include "trackers/reinforcement_pool_tracker.as"  // aus: Reinforcement-Pool deaktiviert

// true = HUD zeigt Alive/Capacity (Respawn-Slot-Delay-Debug), false = HUD zeigt nur Alive 200m (normal)
const bool CAPACITY_DEBUG_HUD = false;

// --------------------------------------------
class GameModeQuickMatch : Metagame {
	protected ItemDeliveryOrganizer@ m_itemDeliveryOrganizer;
	protected ItemDeliveryConfiguratorQuickMatch@ m_itemDeliveryConfigurator;
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

		// Laptop/Briefcase-Unlocks: wie Campaign – abgeben → zufälliges Item freischalten (inkl. vest_blackops3)
		@m_itemDeliveryConfigurator = ItemDeliveryConfiguratorQuickMatch(this);
		@m_itemDeliveryOrganizer = ItemDeliveryOrganizer(this, m_itemDeliveryConfigurator);
		m_itemDeliveryOrganizer.init();
		m_itemDeliveryOrganizer.matchStarted();

		addTracker(BlackOps3VestCommandTracker(this));
		addTracker(BasicCommandHandler(this));
		RespawnSlotDelayTracker@ respawnTr = RespawnSlotDelayTracker(this);
		addTracker(respawnTr);
		addTracker(StatsCommandTracker(this, respawnTr)); // /stats für alle, sofort
		if (CAPACITY_DEBUG_HUD) {
			addTracker(CapacityDebugHudTracker(this, respawnTr));
		} else {
			addTracker(FactionAliveHudTracker(this)); // HUD: nur Einheiten in 200m
		}
		CaptainSpawnCommandTracker@ captainTr = CaptainSpawnCommandTracker(this);
		addTracker(captainTr);  // /captain_spawn - 1 Captain + 3 orange_bodyguards; auch bei Cargo-Truck-Spawn
		addTracker(SingleBaseVipTracker(this, captainTr));  // Bei nur 1 Base: VIP + Escort + 60s Hold, dann Release
		VehicleIntervalSpawn@ vehicleSpawnTr = VehicleIntervalSpawn(this, captainTr);
		addTracker(vehicleSpawnTr);  // Fahrzeug-Spawn; bei Cargo-Truck: Captain-Team mit
		addTracker(IntelManagerQuickMatch(this, 100.0, "paratroopers1.call", 0.15f, captainTr));  // Basis-Intel + Captain-Scout-Verknüpfung
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
