// Quick-Match-Gamemode: Match läuft bereits (Engine hat Karte geladen).
// Lädt nur den Nachschub-Tracker (1000 Soldaten pro Fraktion) + Basis-Command-Handler.
#include "metagame.as"
#include "log.as"
#include "query_helpers.as"
#include "basic_command_handler.as"
// Globales Bundle fuer mode-uebergreifende eigene Systeme.
#include "systems/game_systems.as"
// #include "trackers/reinforcement_pool_tracker.as"  // aus: Reinforcement-Pool deaktiviert

// true = HUD zeigt Alive/Capacity (Respawn-Slot-Delay-Debug), false = HUD zeigt nur Alive 200m (normal)
const bool CAPACITY_DEBUG_HUD = false;
const bool ENABLE_SPAWN_CAPACITY_SYSTEM = true;
const bool ENABLE_COMMANDER_AI_ADAPTIVE = true;
const bool ENABLE_QUICKMATCH_EVENT_SYSTEMS = true;
const bool ENABLE_SHARED_COMMAND_DELIVERY_SYSTEMS = true;
const bool ENABLE_FACTION_POINTS_SYSTEM = true;

// --------------------------------------------
class GameModeQuickMatch : Metagame {
	protected GameSystemsRegistry@ m_systemsRegistry;
	protected SpawnCapacityApi@ m_spawnCapacityApi;
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
		// Spawn-Capacity-System ueber globale Registry aufsetzen.
		@m_systemsRegistry = GameSystemsRegistry(this);
		m_systemsRegistry.installSharedCommandAndDeliverySystems(
			ENABLE_SHARED_COMMAND_DELIVERY_SYSTEMS,
			true,
			true
		);
		m_systemsRegistry.installSpawnCapacitySystem(
			ENABLE_SPAWN_CAPACITY_SYSTEM,
			CAPACITY_DEBUG_HUD,
			false // Alive-HUD deaktiviert, da FP-HUD aktiv ist
		);
		m_systemsRegistry.installCommanderAiAdaptiveSystem(ENABLE_COMMANDER_AI_ADAPTIVE);
		m_systemsRegistry.installFactionPointsSystem(
			ENABLE_FACTION_POINTS_SYSTEM,
			true,   // HUD aktiv
			true,   // Debug-Commands aktiv
			true
		);
		@m_spawnCapacityApi = m_systemsRegistry.getSpawnCapacityApi();
		m_systemsRegistry.installQuickMatchEventSystems(
			ENABLE_QUICKMATCH_EVENT_SYSTEMS,
			100.0f,
			"paratroopers1.call",
			0.15f,
			false // Single-Base-VIP global deaktiviert
		);
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
