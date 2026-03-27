// Quick-Match-Gamemode: Match läuft bereits (Engine hat Karte geladen).
// Lädt nur den Nachschub-Tracker (1000 Soldaten pro Fraktion) + Basis-Command-Handler.
#include "metagame.as"
#include "log.as"
#include "query_helpers.as"
#include "basic_command_handler.as"
// Globales Bundle fuer mode-uebergreifende eigene Systeme.
#include "systems/game_systems.as"
// #include "trackers/reinforcement_pool_tracker.as"  // aus: Reinforcement-Pool deaktiviert

/* TEST: /testcap <fraktion> <multiplier>
// Fraktion: 0/1/2 oder Namenskuerzel (eu/gc/bp, green/grey/brown)
// Multiplier: 0.0 - 2.0 (z.B. 0.2 = 20% Kapazitaet, 1.0 = voll)
// Beispiel: /testcap 0 0.2   /testcap eu 0.5   /testcap 2 1.0
class CapacityToggleTestTracker : Tracker {
	protected Metagame@ m_metagame;
	// Aktuell gesetzte Multiplier pro Fraktion (default 1.0)
	protected array<float> m_mults;

	CapacityToggleTestTracker(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_metagame.getComms().send("<command class='set_metagame_event' name='chat_event' enabled='1' />");
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }
	void update(float time) {}

	// Loest Fraktionsname/-kuerzel zu Index auf. -1 = unbekannt.
	int resolveFactionId(const string &in token) {
		if (token == "0") return 0;
		if (token == "1") return 1;
		if (token == "2") return 2;
		string t = token.toLowerCase();
		if (t == "eu" || t == "green" || t == "gb" || t == "greenbelts") return 0;
		if (t == "gc" || t == "grey" || t == "gray" || t == "greycollars") return 1;
		if (t == "bp" || t == "brown" || t == "brownpants") return 2;
		return -1;
	}

	void sendMultipliers() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;

		// Sicherstellen dass m_mults gross genug ist
		while (int(m_mults.size()) < int(factions.size())) m_mults.insertLast(1.0f);

		XmlElement cmd("command");
		cmd.setStringAttribute("class", "change_game_settings");
		string info = "";
		for (uint i = 0; i < factions.size(); ++i) {
			XmlElement f("faction");
			float m = m_mults[i];
			if (m < 0.00001f) m = 0.00001f; // Engine-Minimum
			f.setFloatAttribute("capacity_multiplier", m);
			cmd.appendChild(f);
			if (i > 0) info += "  ";
			info += "F" + i + "=" + m;
		}
		m_metagame.getComms().send(cmd);

		XmlElement chat("command");
		chat.setStringAttribute("class", "chat");
		chat.setStringAttribute("text", "[TestCap] " + info);
		m_metagame.getComms().send(chat);
		_log("CapacityToggleTest: " + info, 0);
	}

	protected void handleChatEvent(const XmlElement@ event) {
		string msg = event.getStringAttribute("message");
		if (!startsWith(msg, "/testcap")) return;

		// Tokenize: "/testcap eu 0.2" → ["eu", "0.2"]
		array<string> parts = msg.split(" ");
		// parts[0] = "/testcap"
		if (parts.size() < 3) {
			XmlElement chat("command");
			chat.setStringAttribute("class", "chat");
			chat.setStringAttribute("text", "[TestCap] Syntax: /testcap <fraktion> <mult>  z.B. /testcap eu 0.2  oder /testcap 1 0.5");
			m_metagame.getComms().send(chat);
			return;
		}

		int fid = resolveFactionId(parts[1]);
		if (fid < 0) {
			XmlElement chat("command");
			chat.setStringAttribute("class", "chat");
			chat.setStringAttribute("text", "[TestCap] Unbekannte Fraktion '" + parts[1] + "'. Nutze: 0/1/2 oder eu/gc/bp");
			m_metagame.getComms().send(chat);
			return;
		}

		float mult = parseFloat(parts[2]);
		if (mult < 0.0f) mult = 0.0f;
		if (mult > 4.0f) mult = 4.0f;

		while (int(m_mults.size()) <= fid) m_mults.insertLast(1.0f);
		m_mults[fid] = mult;
		sendMultipliers();
	}
} // END CapacityToggleTestTracker */

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
			true // Alive-HUD: zeigt "alive / cap (bases)" in Fraktionsfarbe
		);
		if (!ENABLE_SPAWN_CAPACITY_SYSTEM) {
			addTracker(FactionAliveHudTracker(this, null)); // cap = native soldier_capacity
		}
		// addTracker(CapacityToggleTestTracker(this)); // TEST: /testcap-Command (Klasse oben auskommentiert)
		// Commander-AI-Adaptive + Legacy-Chat-Commands AUS (game_systems_registry.as)
		// m_systemsRegistry.installCommanderAiAdaptiveSystem(ENABLE_COMMANDER_AI_ADAPTIVE);
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
