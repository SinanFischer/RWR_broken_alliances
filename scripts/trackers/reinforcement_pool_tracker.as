// Reinforcement-Pool-Tracker: Nachschub begrenzt pro Fraktion; bei 0 kein Spawn mehr.
// Eroberungs-Bonus: sofort voll (25/50/100) – kein 5-Min-Puffer mehr (kein „antellig bei schneller Rückeroberung“).
// Verteidiger-Bonus: alle 2 Min +2/+4/+6 pro gehaltener Basis. Verlust: Hälfte des Basis-Bonus abgezogen.
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

const int REINFORCEMENT_POOL_INITIAL = 1000; // fallback value if no capacity is found in factions
const int REINFORCEMENT_POOL_MULTIPLIER = 2;
const float CAPACITY_SUM_TO_MAX_SOLDIERS_RATIO = 1.28f;
const int BASE_BONUS_DEFAULT = 25;
const int BASE_BONUS_MEDIUM = 50;
const int BASE_BONUS_STRONG = 100;
const float BASE_UPDATE_INTERVAL = 1.0f;
// Verteidiger-Bonus: alle 2 Min (120 s) – kürzeres Intervall hilft großer Fraktion unter Druck. Bei 180 s eher „verdient“ wenn Truppen ausgehen.
const float DEFENDER_BONUS_INTERVAL = 180.0f;
const int DEFENDER_BONUS_SIDE = 5;
const int DEFENDER_BONUS_MEDIUM = 6;
const int DEFENDER_BONUS_STRONG = 12;
const float FOLLOWUP_MESSAGE_DELAY = 4.0f;
// Basis-Verlust: Nachschub-Penalty zurfällig nach Kategorie (Side/Medium/Strong = getBaseBonus 25/50/100).
const int LOSS_PENALTY_SIDE_MIN = 10;
const int LOSS_PENALTY_SIDE_MAX = 25;
const int LOSS_PENALTY_MEDIUM_MIN = 25;
const int LOSS_PENALTY_MEDIUM_MAX = 50;
const int LOSS_PENALTY_STRONG_MIN = 50;
const int LOSS_PENALTY_STRONG_MAX = 100;
// Fahrzeug-Verlust: Angreifer (Besitzer) verliet Nachschub – Ausgleich wenn Panzer/APC alles niedermähen.
const int VEHICLE_PENALTY_TANK_BIG = 10;   // tank_1, tank_2: 5–15, hier Mittelwert 10 (Variante: rand(5,15))
const int VEHICLE_PENALTY_TANK = 10;        // tank (ohne _1/_2)
const int VEHICLE_PENALTY_VULCAN = 5;
const int VEHICLE_PENALTY_APC = 4;
const int VEHICLE_PENALTY_WIESEL = 3;
// Savegame: Nachschub-Werte speichern/laden (save_data/saved_data), damit sie bei Rejoin/Continue erhalten bleiben.
const string REINFORCEMENT_POOL_SAVE_FILENAME = "reinforcement_pool.xml";
const string REINFORCEMENT_POOL_SAVE_LOCATION = "savegame";  // "savegame" = pro Savegame; falls nicht unterstützt: "app_data"
const float REINFORCEMENT_POOL_SAVE_INTERVAL = 60.0f;       // alle 60 s speichern
// Marker auf der Karte: Base-Wert (Side/Medium/Strong) an Basis-Position. ID-Bereich 40000+ baseId (Intel nutzt 5000+).
const int BASE_VALUE_MARKER_ID_OFFSET = 40000;
// Score-Anzeige bei Kills throttlen: getCharacters() pro Fraktion ist eine Engine-Query – max. 1×/s.
const float SCORE_DISPLAY_THROTTLE = 1.0f;

// Verzögerte Commander-Anschlussmeldung (4 s nach Hauptmeldung)
class PendingFollowUp {
	float m_delay;
	int m_factionId;
	string m_text;
	PendingFollowUp(float delay, int factionId, const string &in text) {
		m_delay = delay;
		m_factionId = factionId;
		m_text = text;
	}
}

class ReinforcementPoolTracker : Tracker {
	protected Metagame@ m_metagame;
	protected dictionary m_pool;
	protected dictionary m_spawnDisabled;
	protected dictionary m_announcedThresholds;
	protected dictionary m_baseGranted;   // pro Basis: bereits gewährter Bonus (bei Eroberung sofort voll)
	protected dictionary m_baseBonusCache;
	protected dictionary m_deaths;
	protected int m_initialPoolValue = -1;
	protected bool m_initialAnnounceDone = false;
	protected float m_timeAccum = 0.0f;
	protected float m_baseUpdateAccum = 0.0f;
	protected float m_defenderAccum = 0.0f;
	protected array<int> m_thresholds;
	protected array<PendingFollowUp@> m_pendingFollowUps;
	protected float m_saveTimer = 0.0f;
	protected bool m_loadedFromSave = false;
	protected bool m_baseValueMarkersPlaced = false;
	protected bool m_scoreDisplayDirty = false;
	protected float m_scoreDisplayAccum = 0.0f;

	ReinforcementPoolTracker(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_spawn' enabled='1' />");
		m_metagame.getComms().send("<command class='set_metagame_event' name='chat_event' enabled='1' />");
		m_metagame.getComms().send("<command class='set_metagame_event' name='base_owner_change_event' enabled='1' />");
		m_metagame.getComms().send("<command class='set_metagame_event' name='vehicle_destroyed_event' enabled='1' />");
		m_thresholds.insertLast(800);
		m_thresholds.insertLast(600);
		m_thresholds.insertLast(500);
		m_thresholds.insertLast(300);
		m_thresholds.insertLast(100);
		m_thresholds.insertLast(10);
	}

	void start() {
		loadFromSavegame();
		// Neues Spiel: Pool um bereits lebende Charaktere pro Fraktion reduzieren (die „kosten“ schon).
		if (!m_loadedFromSave) {
			int initial = getInitialPoolValue();
			array<const XmlElement@>@ factions = getFactions(m_metagame);
			for (uint i = 0; i < factions.size(); ++i) {
				int fid = int(i);
				int alive = getAliveCountForFaction(fid);
				int pool = initial - alive;
				if (pool < 0) pool = 0;
				setPoolForFaction(fid, pool);
			}
		}
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	// Bonus nach Schwierigkeit (Key lowercase). Ergebnis pro baseId cachen – Basis-Key ändert sich nicht.
	// Reine Key-Logik aus Map-Daten – keine dynamische Anpassung (z. B. "letzte Basis = Strong").
	int getBaseBonus(const XmlElement@ base) {
		if (base is null) return BASE_BONUS_DEFAULT;
		string key = base.getStringAttribute("key").toLowerCase();
		// Schwer/Hauptziel: höchster Bonus
		if (key.findFirst("hq") >= 0 || key.findFirst("main") >= 0 || key.findFirst("capital") >= 0 ||
		    key.findFirst("headquarters") >= 0 || key.findFirst("zentrum") >= 0 || key.findFirst("haupt") >= 0 ||
		    key.findFirst("center") >= 0 || key.findFirst("centre") >= 0 || key.findFirst("command") >= 0) {
			return BASE_BONUS_STRONG;
		}
		// Mittel: Stützpunkt, Outpost, Forward, Festung, Bunker, Trench, Camp etc.
		if (key.findFirst("stützpunkt") >= 0 || key.findFirst("stutzpunkt") >= 0 || key.findFirst("outpost") >= 0 ||
		    key.findFirst("forward") >= 0 || key.findFirst("festung") >= 0 || key.findFirst("fort") >= 0 ||
		    key.findFirst("base") >= 0 || key.findFirst("stütz") >= 0 ||
		    key.findFirst("bunker") >= 0 || key.findFirst("trench") >= 0 || key.findFirst("camp") >= 0 ||
		    key.findFirst("compound") >= 0 || key.findFirst("position") >= 0 || key.findFirst("post") >= 0) {
			return BASE_BONUS_MEDIUM;
		}
		return BASE_BONUS_DEFAULT;
	}

	// Marker-Text: Name (Sidebase/Outpost/HQ) + Leerzeichen + Bonus in Klammern, z. B. "Sidebase (5)".
	string getBaseMarkerText(const XmlElement@ base) {
		int bonus = getBaseBonus(base);
		string name;
		int defenderBonus;
		if (bonus >= BASE_BONUS_STRONG) {
			name = "HQ";
			defenderBonus = DEFENDER_BONUS_STRONG;
		} else if (bonus >= BASE_BONUS_MEDIUM) {
			name = "Outpost";
			defenderBonus = DEFENDER_BONUS_MEDIUM;
		} else {
			name = "Sidebase";
			defenderBonus = DEFENDER_BONUS_SIDE;
		}
		return name + " (" + defenderBonus + ")";
	}

	// Setzt einmalig Marker an jeder Basis-Position. Pro Fraktion eine Kopie (faction_id=0,1,2…), damit jede Fraktion sie sieht.
	// atlas_index und size wie in Vanilla (intel/kill_commander), Placement auch beim Initial-Announce versuchen.
	void placeBaseValueMarkers(array<const XmlElement@>@ bases) {
		if (bases is null || bases.size() == 0) return;
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;
		for (uint i = 0; i < bases.size(); ++i) {
			const XmlElement@ base = bases[i];
			int baseId = base.getIntAttribute("id");
			string key = base.getStringAttribute("key");
			string position = base.getStringAttribute("position");
			string text = getBaseMarkerText(base);
			_log("Base-Wert: key='" + key + "' -> " + text, 1);
			for (uint f = 0; f < factions.size(); ++f) {
				int factionId = int(f);
				XmlElement command("command");
				command.setStringAttribute("class", "set_marker");
				command.setIntAttribute("id", BASE_VALUE_MARKER_ID_OFFSET + baseId * 8 + factionId);
				command.setIntAttribute("faction_id", factionId);
				command.setIntAttribute("atlas_index", 0);
				command.setStringAttribute("position", position);
				command.setStringAttribute("text", text);
				command.setFloatAttribute("size", 0.5f);
				command.setBoolAttribute("enabled", true);
				command.setBoolAttribute("show_in_map_view", true);
				command.setBoolAttribute("show_in_game_view", false);
				command.setBoolAttribute("show_at_screen_edge", false);
				m_metagame.getComms().send(command);
			}
		}
		_log("ReinforcementPool: Base-Wert-Marker gesetzt (" + bases.size() + " Basen, " + factions.size() + " Faktionen).", 0);
	}

	int getBaseBonusCached(int baseId, const XmlElement@ base) {
		string ckey = "bonus_" + baseId;
		if (m_baseBonusCache.exists(ckey)) return int(m_baseBonusCache[ckey]);
		int bonus = getBaseBonus(base);
		m_baseBonusCache[ckey] = bonus;
		return bonus;
	}

	// Verteidiger-Bonus: pro gehaltener Basis jede Minute (Side/Medium/Strong = Konstanten).
	int getDefenderBonusPerMinute(int bonusCategory) {
		if (bonusCategory == BASE_BONUS_STRONG) return DEFENDER_BONUS_STRONG;
		if (bonusCategory == BASE_BONUS_MEDIUM) return DEFENDER_BONUS_MEDIUM;
		return DEFENDER_BONUS_SIDE;
	}

	// Nachschub-Penalty wenn Fahrzeug zerstört wird (Besitzer = Angreifer verliert). Keys einzeln vergleichen (Engine liefert z. B. "tank_2.vehicle").
	int getVehicleDestroyPenalty(const string &in vehicleKey) {
		if (vehicleKey.length() == 0) return 0;
		string key = vehicleKey.toLowerCase();
		// Große Panzer: tank_1, tank_2 (einzeln)
		if (key == "tank_1.vehicle" || key == "tank.vehicle" || key == "tank_2.vehicle")
			return rand(5, 15);
		// Vulcan, Basis-Panzer, Doppelkannonen-Panzer
		if (key == "vulcan_tank.vehicle") return VEHICLE_PENALTY_VULCAN;
		if (key == "tank.vehicle") return VEHICLE_PENALTY_TANK;
		if (key == "doublecannon_tank.vehicle") return VEHICLE_PENALTY_TANK;
		if (key == "radar_tank.vehicle") return VEHICLE_PENALTY_TANK;
		// APC (einzeln)
		if (key == "apc.vehicle" || key == "apc_1.vehicle" || key == "apc_2.vehicle") return VEHICLE_PENALTY_APC;
		// Wiesel
		if (key == "wiesel_tow.vehicle" || key == "wiesel_mk20.vehicle") return VEHICLE_PENALTY_WIESEL;
		return 0;
	}

	// Initialer Pool = max_soldiers * 2. max_soldiers kommt nicht aus der General-Query;
	// die Engine liefert soldier_capacity pro Fraktion, Summe ≈ max_soldiers * CAPACITY_SUM_TO_MAX_SOLDIERS_RATIO.
	// Daher: max_soldiers = sum(soldier_capacity) / RATIO → Pool = sum * 2 / RATIO (z.B. 284*2/1.28 ≈ 444 bei 222 max).
	int getInitialPoolValue() {
		if (m_initialPoolValue >= 0) return m_initialPoolValue;
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions !is null && factions.size() > 0) {
			int sumCapacity = 0;
			for (uint i = 0; i < factions.size(); ++i)
				sumCapacity += factions[i].getIntAttribute("soldier_capacity");
			if (sumCapacity > 0) {
				float maxSoldiers = float(sumCapacity) / CAPACITY_SUM_TO_MAX_SOLDIERS_RATIO;
				m_initialPoolValue = int(maxSoldiers * float(REINFORCEMENT_POOL_MULTIPLIER));
				if (m_initialPoolValue < 1) m_initialPoolValue = 1;
				_log("ReinforcementPool: sum_capacity=" + sumCapacity + " -> max_soldiers~" + int(maxSoldiers) + " -> pool " + m_initialPoolValue, 0);
				return m_initialPoolValue;
			}
		}
		m_initialPoolValue = REINFORCEMENT_POOL_INITIAL;
		_log("ReinforcementPool: keine Kapazität aus Factions, Fallback " + m_initialPoolValue, 0);
		return m_initialPoolValue;
	}

	string baseGrantedKey(int baseId) { return "b" + baseId; }

	float getBaseGranted(int baseId) {
		string key = baseGrantedKey(baseId);
		if (!m_baseGranted.exists(key)) return 0.0f;
		return float(m_baseGranted[key]);
	}

	void setBaseGranted(int baseId, float value) {
		m_baseGranted[baseGrantedKey(baseId)] = value;
	}

	void update(float time) {
		// Verzögerte Anschluss-Meldungen (4 s nach Base lost/captured)
		for (int i = int(m_pendingFollowUps.size()) - 1; i >= 0; --i) {
			PendingFollowUp@ p = m_pendingFollowUps[i];
			p.m_delay -= time;
			if (p.m_delay <= 0.0f) {
				sendFactionMessage(m_metagame, p.m_factionId, p.m_text, 0.9);
				m_pendingFollowUps.removeAt(i);
			}
		}

		// Score-Anzeige (Lebend · Nachschub): bei Kills nur alle 1 s aktualisieren – getCharacters() ist teuer
		m_scoreDisplayAccum += time;
		if (m_scoreDisplayDirty && m_scoreDisplayAccum >= SCORE_DISPLAY_THROTTLE) {
			m_scoreDisplayAccum = 0.0f;
			m_scoreDisplayDirty = false;
			updateScoreDisplay();
		}

		if (!m_initialAnnounceDone) {
			m_timeAccum += time;
			if (m_timeAccum < 3.0f) return;
			m_initialAnnounceDone = true;
			array<const XmlElement@>@ factions = getFactions(m_metagame);
			for (uint i = 0; i < factions.size(); ++i) {
				int factionId = int(i);
				sendFactionMessage(m_metagame, factionId, "Reinforcements: " + getInitialPoolValue() + " remaining.", 0.95);
			}
			updateScoreDisplay();
			// Marker sofort beim Start versuchen (Basen können schon da sein), nicht erst nach 1 s Intervall
			if (!m_baseValueMarkersPlaced) {
				array<const XmlElement@>@ bases = getBases(m_metagame);
				if (bases.size() > 0) {
					placeBaseValueMarkers(bases);
					m_baseValueMarkersPlaced = true;
				}
			}
			return;
		}

		// Nur Verteidiger-Bonus (Eroberungs-Bonus wird beim Eroberungs-Event sofort voll gutgeschrieben, kein 5-Min-Puffer).
		m_baseUpdateAccum += time;
		m_defenderAccum += time;
		if (m_baseUpdateAccum < BASE_UPDATE_INTERVAL) return;
		m_baseUpdateAccum = 0.0f;

		bool poolChanged = false;
		array<const XmlElement@>@ bases = getBases(m_metagame);

		// Einmalig: Marker für Base-Wert (Side/Medium/Strong) auf der Karte setzen
		if (!m_baseValueMarkersPlaced && bases.size() > 0) {
			placeBaseValueMarkers(bases);
			m_baseValueMarkersPlaced = true;
		}

		// Verteidiger-Bonus: alle 2 Min +2/+4/+6 Nachschub pro gehaltener Basis
		if (m_defenderAccum >= DEFENDER_BONUS_INTERVAL) {
			m_defenderAccum = 0.0f;
			for (uint i = 0; i < bases.size(); ++i) {
				const XmlElement@ base = bases[i];
				int baseId = base.getIntAttribute("id");
				int ownerId = base.getIntAttribute("owner_id");
				if (ownerId < 0) continue;
				int bonusCat = getBaseBonusCached(baseId, base);
				int defenderAdd = getDefenderBonusPerMinute(bonusCat);
				if (defenderAdd > 0) {
					int pool = getPoolForFaction(ownerId);
					setPoolForFaction(ownerId, pool + defenderAdd);
					poolChanged = true;
					_log("ReinforcementPool: Verteidiger-Bonus Base " + baseId + " +" + defenderAdd + " -> Faction " + ownerId, 1);
				}
			}
		}
		if (poolChanged) updateScoreDisplay();

		m_saveTimer -= time;
		if (m_saveTimer <= 0.0f) {
			saveToSavegame();
			m_saveTimer = REINFORCEMENT_POOL_SAVE_INTERVAL;
		}
	}

	// Feste Farben pro Slot, damit die Engine sie zuverlässig anzeigt. Slot 0 = Grün (meist eigene Fraktion), 1 = Rot, 2 = Orange.
	// Format: "R G B" 0.0–1.0 (wie in Faction-XML).
	string getScoreDisplayColor(int factionId) {
		if (factionId == 0) return "0.0 0.85 0.2";   // Grün – typisch eigene Fraktion
		if (factionId == 1) return "0.9 0.2 0.2";   // Rot
		if (factionId == 2) return "0.9 0.55 0.1";  // Orange
		return "0.85 0.85 0.85";                     // Grau für weitere
	}

	// Zählt lebende Charaktere einer Fraktion. Die characters-Query liefert keine "dead"-Attribute (→ Log-Warnung), daher: zurückgegebene Anzahl = lebend.
	int getAliveCountForFaction(int factionId) {
		array<const XmlElement@>@ chars = getCharacters(m_metagame, factionId);
		return (chars is null) ? 0 : int(chars.size());
	}

	// Kompakte Score-Anzeige: "Lebend-Nachschub" (z. B. "14-520"). Bindestrich spart Leerzeichen, ASCII-sicher.
	void updateScoreDisplay() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		for (uint i = 0; i < factions.size(); ++i) {
			int factionId = int(i);
			int alive = getAliveCountForFaction(factionId);
			int pool = getPoolForFaction(factionId);
			string text = alive + "-" + pool;
			XmlElement cmd("command");
			cmd.setStringAttribute("class", "update_score_display");
			cmd.setIntAttribute("id", factionId);
			cmd.setStringAttribute("text", text);
			cmd.setStringAttribute("color", getScoreDisplayColor(factionId));
			m_metagame.getComms().send(cmd);
		}
	}

	void saveToSavegame() {
		XmlElement root("reinforcement_pool");
		root.setIntAttribute("initial_pool_value", m_initialPoolValue >= 0 ? m_initialPoolValue : getInitialPoolValue());
		root.setIntAttribute("initial_announce_done", m_initialAnnounceDone ? 1 : 0);
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		for (uint i = 0; i < factions.size(); ++i) {
			int fid = int(i);
			XmlElement fe("faction");
			fe.setIntAttribute("id", fid);
			fe.setIntAttribute("pool", getPoolForFaction(fid));
			fe.setIntAttribute("deaths", getDeathsForFaction(fid));
			fe.setIntAttribute("spawn_disabled", isSpawnDisabled(fid) ? 1 : 0);
			root.appendChild(fe);
		}
		XmlElement command("command");
		command.setStringAttribute("class", "save_data");
		command.setStringAttribute("filename", REINFORCEMENT_POOL_SAVE_FILENAME);
		command.setStringAttribute("location", REINFORCEMENT_POOL_SAVE_LOCATION);
		command.appendChild(root);
		m_metagame.getComms().send(command);
		_log("ReinforcementPool: gespeichert (Pool/Deaths/Spawn pro Faction).", 1);
	}

	void loadFromSavegame() {
		XmlElement@ query = XmlElement(
			makeQuery(m_metagame, array<dictionary> = {
				dictionary = { {"TagName", "data"}, {"class", "saved_data"}, {"filename", REINFORCEMENT_POOL_SAVE_FILENAME}, {"location", REINFORCEMENT_POOL_SAVE_LOCATION} } }));
		const XmlElement@ doc = m_metagame.getComms().query(query);
		if (doc is null) return;
		const XmlElement@ root = doc.getFirstChild();
		if (root is null || root.getName() != "reinforcement_pool") return;
		m_initialPoolValue = root.getIntAttribute("initial_pool_value");
		m_initialAnnounceDone = root.getIntAttribute("initial_announce_done") != 0;
		array<const XmlElement@>@ factionNodes = root.getElementsByTagName("faction");
		for (uint i = 0; i < factionNodes.size(); ++i) {
			const XmlElement@ fe = factionNodes[i];
			int fid = fe.getIntAttribute("id");
			int pool = fe.getIntAttribute("pool");
			int deaths = fe.getIntAttribute("deaths");
			bool spawnOff = fe.getIntAttribute("spawn_disabled") != 0;
			setPoolForFaction(fid, pool);
			m_deaths[factionKey(fid)] = deaths;
			if (spawnOff) m_spawnDisabled[factionKey(fid)] = true;
		}
		m_loadedFromSave = true;
		updateScoreDisplay();
		_log("ReinforcementPool: geladen aus Savegame (Pool/Deaths/Spawn pro Faction).", 0);
	}

	string factionKey(int factionId) { return "" + factionId; }

	int getPoolForFaction(int factionId) {
		string key = factionKey(factionId);
		if (!m_pool.exists(key)) {
			m_pool[key] = getInitialPoolValue();
		}
		return int(m_pool[key]);
	}

	int getDeathsForFaction(int factionId) {
		string key = factionKey(factionId);
		if (!m_deaths.exists(key)) return 0;
		return int(m_deaths[key]);
	}

	void addDeathForFaction(int factionId) {
		string key = factionKey(factionId);
		int v = getDeathsForFaction(factionId);
		m_deaths[key] = v + 1;
	}

	void setPoolForFaction(int factionId, int value) {
		m_pool[factionKey(factionId)] = value;
	}

	bool isSpawnDisabled(int factionId) {
		string key = factionKey(factionId);
		return m_spawnDisabled.exists(key) && bool(m_spawnDisabled[key]);
	}

	void setSpawnDisabled(int factionId) {
		m_spawnDisabled[factionKey(factionId)] = true;
	}

	bool hasAnnouncedThreshold(int factionId, int value) {
		string key = factionKey(factionId) + "_" + value;
		return m_announcedThresholds.exists(key) && bool(m_announcedThresholds[key]);
	}

	void setAnnouncedThreshold(int factionId, int value) {
		m_announcedThresholds[factionKey(factionId) + "_" + value] = true;
	}

	void announceThreshold(int factionId, int pool) {
		if (pool == 0) {
			sendFactionMessage(m_metagame, factionId, "Reinforcements depleted. No more reinforcements.", 1.0);
			return;
		}
		for (uint i = 0; i < m_thresholds.size(); ++i) {
			if (int(m_thresholds[i]) == pool && !hasAnnouncedThreshold(factionId, pool)) {
				sendFactionMessage(m_metagame, factionId, "Reinforcements: " + pool + " remaining.", 0.95);
				setAnnouncedThreshold(factionId, pool);
				break;
			}
		}
	}

	// Bei Besitzerwechsel: Verlierer verliert Hälfte des Basis-Bonus; Eroberer bekommt vollen Bonus sofort. Commander-Meldungen für beide.
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		int baseId = event.getIntAttribute("base_id");
		int newOwnerId = event.getIntAttribute("owner_id");
		int previousOwnerId = event.getIntAttribute("previous_owner_id");

		array<const XmlElement@>@ bases = getBases(m_metagame);
		const XmlElement@ base = getBase(bases, baseId);
		int bonus = getBaseBonusCached(baseId, base);
		string baseName = base !is null ? base.getStringAttribute("name") : "";
		if (baseName.length() == 0 && base !is null) baseName = base.getStringAttribute("key");
		if (baseName.length() == 0) baseName = "sector";

		// Verlierer bestrafen: Nachschub-Verlust zufällig nach Basis-Kategorie (Side -10 bis -25, Medium -25 bis -50, Strong -50 bis -100).
		if (previousOwnerId >= 0) {
			int penalty = 0;
			if (bonus >= BASE_BONUS_STRONG)
				penalty = rand(LOSS_PENALTY_STRONG_MIN, LOSS_PENALTY_STRONG_MAX);
			else if (bonus >= BASE_BONUS_MEDIUM)
				penalty = rand(LOSS_PENALTY_MEDIUM_MIN, LOSS_PENALTY_MEDIUM_MAX);
			else
				penalty = rand(LOSS_PENALTY_SIDE_MIN, LOSS_PENALTY_SIDE_MAX);
			if (penalty > 0) {
				int pool = getPoolForFaction(previousOwnerId);
				int newPool = pool - penalty;
				if (newPool < 0) newPool = 0;
				setPoolForFaction(previousOwnerId, newPool);
				updateScoreDisplay();
				announceThreshold(previousOwnerId, newPool);
				sendFactionMessage(m_metagame, previousOwnerId, "Base lost. -" + penalty + " reinforcements (" + newPool + " remaining).", 0.95);
				// Anschluss-Meldung 4 s später: vollständige Sätze mit Basisname
				array<string> loseVariants;
				loseVariants.insertLast("We have lost " + baseName + ". Hold the line so we don't lose more reinforcements.");
				loseVariants.insertLast("Base " + baseName + " has fallen. Dig in – every position we hold saves our reinforcements.");
				loseVariants.insertLast("We lost " + baseName + ". Stand fast so we don't bleed more reinforcements.");
				string followLose = loseVariants[rand(0, int(loseVariants.size()) - 1)];
				m_pendingFollowUps.insertLast(PendingFollowUp(FOLLOWUP_MESSAGE_DELAY, previousOwnerId, followLose));
				_log("ReinforcementPool: Basis " + baseId + " verloren – Faction " + previousOwnerId + " -" + penalty + " Nachschub (verbleibend " + newPool + ").", 0);
				if (newPool <= 0 && !isSpawnDisabled(previousOwnerId)) {
					disableSpawnForFaction(previousOwnerId);
					setSpawnDisabled(previousOwnerId);
				}
			}
		}

		// Eroberer: vollen Bonus sofort gutschreiben (kein 5-Min-Puffer mehr).
		if (newOwnerId >= 0 && bonus > 0) {
			int pool = getPoolForFaction(newOwnerId);
			setPoolForFaction(newOwnerId, pool + bonus);
			setBaseGranted(baseId, float(bonus));  // verhindert Doppel-Gutschrift
			updateScoreDisplay();
			_log("ReinforcementPool: Base " + baseId + " erobert – Faction " + newOwnerId + " +" + bonus + " sofort.", 0);

			sendFactionMessage(m_metagame, newOwnerId, "Base captured. +" + bonus + " reinforcements.", 0.95);
			array<string> captureVariants;
			captureVariants.insertLast("We have captured " + baseName + ". " + bonus + " reinforcements have joined us.");
			captureVariants.insertLast("Base " + baseName + " is ours. " + bonus + " troops have reinforced our position.");
			captureVariants.insertLast("We took " + baseName + ". " + bonus + " reinforcements are with us.");
			captureVariants.insertLast("Sector " + baseName + " secured. " + bonus + " troops deployed.");
			string followCap = captureVariants[rand(0, int(captureVariants.size()) - 1)];
			m_pendingFollowUps.insertLast(PendingFollowUp(FOLLOWUP_MESSAGE_DELAY, newOwnerId, followCap));
		}

		// Fallback-Siegesbedingung: Wenn die Engine kein match_result sendet (z. B. Quick Match), bei „alle Basen einer Fraktion“ selbst set_match_status senden.
		if (newOwnerId >= 0 && bases !is null) {
			int totalOwned = 0;
			int ownedByWinner = 0;
			for (uint i = 0; i < bases.size(); ++i) {
				int oid = bases[i].getIntAttribute("owner_id");
				if (oid >= 0) {
					totalOwned++;
					if (oid == newOwnerId) ownedByWinner++;
				}
			}
			if (totalOwned > 0 && totalOwned == ownedByWinner) {
				_log("ReinforcementPool: Alle Basen bei Faction " + newOwnerId + " – setze Sieg (set_match_status).", 0);
				array<const XmlElement@>@ factions = getFactions(m_metagame);
				for (uint i = 0; i < factions.size(); ++i) {
					int fid = int(i);
					if (fid != newOwnerId)
						m_metagame.getComms().send("<command class='set_match_status' lose='1' faction_id='" + fid + "' />");
				}
				m_metagame.getComms().send("<command class='set_match_status' win='1' faction_id='" + newOwnerId + "' />");
			}
		}
	}

	// Fahrzeug zerstört: Besitzer (owner_id) verliert Nachschub – Panzer/APC/Wiesel kosten extra.
	protected void handleVehicleDestroyEvent(const XmlElement@ event) {
		int ownerId = event.getIntAttribute("owner_id");
		if (ownerId < 0) return;
		string vehicleKey = event.getStringAttribute("vehicle_key");
		int penalty = getVehicleDestroyPenalty(vehicleKey);
		if (penalty <= 0) return;

		int pool = getPoolForFaction(ownerId);
		int newPool = pool - penalty;
		if (newPool < 0) newPool = 0;
		setPoolForFaction(ownerId, newPool);
		updateScoreDisplay();
		announceThreshold(ownerId, newPool);
		_log("ReinforcementPool: Fahrzeug " + vehicleKey + " zerstört – Faction " + ownerId + " -" + penalty + " Nachschub (verbleibend " + newPool + ").", 0);
		if (newPool <= 0 && !isSpawnDisabled(ownerId)) {
			disableSpawnForFaction(ownerId);
			setSpawnDisabled(ownerId);
		}
	}

	// Nachschub wird bei Spawn abgezogen (handleCharacterSpawnEvent), nicht bei Tod. Hier nur Tote zählen und Anzeige aktualisieren.
	protected void handleCharacterKillEvent(const XmlElement@ event) {
		const XmlElement@ target = event.getFirstElementByTagName("target");
		if (target is null) return;
		int factionId = target.getIntAttribute("faction_id");
		addDeathForFaction(factionId);
		m_scoreDisplayDirty = true;
	}

	// Bei jedem Spawn: Nachschub um 1 verringern. So kostet „Leben“ beim Spawnen, nicht beim Sterben.
	protected void handleCharacterSpawnEvent(const XmlElement@ event) {
		const XmlElement@ character = event.getFirstElementByTagName("character");
		if (character is null) return;
		int factionId = character.getIntAttribute("faction_id");
		int pool = getPoolForFaction(factionId);
		if (pool <= 0) return;
		pool--;
		setPoolForFaction(factionId, pool);
		_log("ReinforcementPool: Spawn Faction " + factionId + " -> " + pool + " verbleibend", 1);
		updateScoreDisplay();
		announceThreshold(factionId, pool);
		if (pool <= 0 && !isSpawnDisabled(factionId)) {
			disableSpawnForFaction(factionId);
			setSpawnDisabled(factionId);
		}
	}

	// Chat-Command /nachschub oder /pool: Ausgabe pro Fraktion = Verbleibend (Nachschub), Tote, Lebende (aktuelle Charakteranzahl).
	protected void handleChatEvent(const XmlElement@ event) {
		string message = event.getStringAttribute("message");
		if (!startsWith(message, "/")) return;
		if (!checkCommand(message, "nachschub") && !checkCommand(message, "pool")) return;

		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions.size() == 0) return;

		string line = "Reinforcements | ";
		for (uint i = 0; i < factions.size(); ++i) {
			int factionId = int(i);
			int pool = getPoolForFaction(factionId);
			int dead = getDeathsForFaction(factionId);
			array<const XmlElement@>@ chars = getCharacters(m_metagame, factionId);
			int alive = int(chars.size());
			if (i > 0) line += " | ";
			line += "F" + factionId + ": " + pool + " left, " + dead + " dead, " + alive + " alive";
		}
		XmlElement cmd("command");
		cmd.setStringAttribute("class", "chat");
		cmd.setStringAttribute("text", line);
		m_metagame.getComms().send(cmd);
	}

	// Setzt capacity_multiplier der betroffenen Fraktion auf 0; andere Fraktionen unverändert lassen.
	void disableSpawnForFaction(int factionId) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		uint count = factions.size();
		if (count == 0) return;

		XmlElement command("command");
		command.setStringAttribute("class", "change_game_settings");
		for (uint i = 0; i < count; ++i) {
			XmlElement faction("faction");
			if (int(i) == factionId) {
				faction.setFloatAttribute("capacity_multiplier", 0.0f);
			}
			command.appendChild(faction);
		}
		m_metagame.getComms().send(command);
		_log("ReinforcementPool: Faction " + factionId + " – Nachschub aufgebraucht, Spawn deaktiviert.", 0);
	}
}
