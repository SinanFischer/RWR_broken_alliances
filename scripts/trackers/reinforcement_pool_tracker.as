// Reinforcement-Pool-Tracker: Nachschub begrenzt pro Fraktion; bei 0 kein Spawn mehr.
// Pool-Abzug bei jedem Tod (character_die, inkl. Artillerie/Umwelt), nicht bei Spawn.
// Eroberungs-Bonus: sofort voll (25/50/100) – kein 5-Min-Puffer mehr.
// Haltungsbonus: nur während Spawn AUS alle 10 s pro Basis in Akkumulator (Side 0.2, Outpost 0.4, HQ 1.0); beim Öffnen (AUS→AN) in Pool + Commander-Meldung. Pool mit Kommarest (z. B. 15.2 → 15 ausgeben, 0.2 bleibt).
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

const int REINFORCEMENT_POOL_INITIAL = 1000; // fallback value if no capacity is found in factions
const int REINFORCEMENT_POOL_MULTIPLIER = 3;  // Start-Nachschub = 3x Startkapazitaet (max_soldiers)
const int BASE_COUNT_BONUS_PER_BASE_LESS = 50; // Entschaedigung: +50 Nachschub pro Basis weniger als die Fraktion mit den meisten Basen
const float CAPACITY_SUM_TO_MAX_SOLDIERS_RATIO = 2.5f;  // Capacity-Summe = 2.5x max_soldiers (vorher 1.28x)
// Eroberungs-Bonus pro eingenommene Basis (verdoppelt: 50/100/200).
const int BASE_BONUS_DEFAULT = 50;   // Side/leicht (vorher 25)
const int BASE_BONUS_MEDIUM = 100;   // Outpost/mittel (vorher 50)
const int BASE_BONUS_STRONG = 200;   // HQ/gross (vorher 100)
const float BASE_UPDATE_INTERVAL = 1.0f;
// Haltungsbonus nur während Spawn-AUS: alle 10 s pro Basis in Akkumulator; beim Öffnen (AUS→AN) wird Akkumulator in Pool überführt + Commander-Meldung. 2x, dann +1.6x.
const float DEFENDER_TRICKLE_INTERVAL = 10.0f;
const float DEFENDER_TRICKLE_SIDE = 1.6f;   // Sidebase: 1.6 pro 10 s
const float DEFENDER_TRICKLE_MEDIUM = 2.56f; // Outpost: 2.56 pro 10 s
const float DEFENDER_TRICKLE_STRONG = 4.8f;  // HQ: 4.8 pro 10 s
// AUS-Phase direkt nach MajorAttack: 5.6x Trickle (3.5 * 1.6).
const float TRICKLE_MULTIPLIER_AFTER_MAJOR_ATTACK = 5.6f;
// Basis-Verlust: Nachschub-Penalty zufaellig, gleiche Bereiche wie Eroberungs-Bonus (Side 5–10, Medium 10–20, HQ 20–30).
const int LOSS_PENALTY_SIDE_MIN = 5;
const int LOSS_PENALTY_SIDE_MAX = 10;
const int LOSS_PENALTY_MEDIUM_MIN = 10;
const int LOSS_PENALTY_MEDIUM_MAX = 20;
const int LOSS_PENALTY_STRONG_MIN = 20;
const int LOSS_PENALTY_STRONG_MAX = 30;
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
// Score-Anzeige bei Kills throttlen: getCharacters() pro Fraktion ist eine Engine-Query – max. 2×/s, damit Killstreaks schneller sichtbar sind.
const float SCORE_DISPLAY_THROTTLE = 0.5f;
// Alle 60 s: getCharacters() fuer alle Fraktionen, Anzeige neu setzen (Recheck falls Zahl nicht stimmt).
const float SCORE_RECHECK_INTERVAL = 60.0f;
// Spawn-Fenster: 30 s AN (5x Rate). AUS-Dauer abhaengig von Capacity: 200 Soldaten = 90 s, darueber laenger (min 60, max 180 s).
const float SPAWN_WINDOW_OPEN_DURATION = 30.0f;
const float SPAWN_CLOSED_BASE = 102.0f;   // 90 + 12
const int SPAWN_CLOSED_REF_SOLDIERS = 200;
const float SPAWN_CLOSED_FACTOR = 0.5f;
const float SPAWN_CLOSED_MIN = 72.0f;     // 60 + 12
const float SPAWN_CLOSED_MAX = 252.0f;    // 192 + 60 (bei hoher Kapazität +60 s Pause)
const int SPAWN_CLOSED_HIGH_CAPACITY_THRESHOLD = 320;  // maxSoldiers > 320 → +60 s Spawn-Pause
const float SPAWN_CLOSED_HIGH_CAPACITY_BONUS = 60.0f;
// Großangriff: nach 4 normalen Zyklen 30 s Spawn mit verdoppelter Kapazität + Commander-Meldung
const int GROSSANGRIFF_CYCLES = 4;
const float GROSSANGRIFF_CAPACITY_MULTIPLIER = 2.0f;
// Statt 0: minimaler Multiplikator, damit die Engine die Fraktion nicht als „tot“ behandelt (Capture-Timer bleibt gültig).
const float CAPACITY_MULTIPLIER_NEAR_ZERO = 0.00001f;
// Attack-Boost (Surge): pro Spawn-Zyklus 25 % Chance pro Fraktion; 1.2x Capacity, 1.5x Spawn-Rate; Cooldown 1 Zyklus.
const float BOOST_CAPACITY_MULTIPLIER = 1.2f;
const float BOOST_SPAWN_RATE_MULTIPLIER = 1.5f;
const float BOOST_CHANCE_ON_WINDOW_OPEN = 0.25f;
// Capacity-Nerf: Fraktionen mit ueberdurchschnittlicher soldier_capacity (mehr Basen) bekommen Multiplikator < 1, um 7-Basen-200-Truppen vs 1-Basis-40-Truppen abzumildern.
const float CAPACITY_NERF_ABOVE_AVG = 0.8f;
// Status-Marker auf der Karte (rechte obere Ecke): Weltposition "x y z". Typische Map-Groesse 512–1536; bei kleineren Maps Marker evtl. am Rand.
const int STATUS_MARKER_ID_BASE = 45000;
const string STATUS_MARKER_POSITION = "1500 0 50";
class ReinforcementPoolTracker : Tracker {
	protected Metagame@ m_metagame;
	protected dictionary m_pool;
	protected dictionary m_spawnDisabled;
	protected dictionary m_announcedThresholds;
	protected dictionary m_baseGranted;   // pro Basis: bereits gewährter Bonus (bei Eroberung sofort voll)
	protected dictionary m_baseGrantedOwner; // pro Basis: owner_id, dem zuletzt gutgeschrieben wurde (-1 = nach Verlust zurückgesetzt)
	protected dictionary m_baseBonusCache;
	protected dictionary m_deaths;
	protected int m_initialPoolValue = -1;
	protected bool m_initialAnnounceDone = false;
	protected float m_timeAccum = 0.0f;
	protected float m_baseUpdateAccum = 0.0f;
	protected float m_defenderAccum = 0.0f;
	protected array<int> m_thresholds;
	protected float m_saveTimer = 0.0f;
	protected bool m_loadedFromSave = false;
	protected bool m_baseValueMarkersPlaced = false;
	protected bool m_scoreDisplayDirty = false;
	protected float m_scoreDisplayAccum = 0.0f;
	protected float m_recheckAccum = 0.0f;
	protected bool m_initialPoolCorrectedForLiving = false;
	// Position des Status-Markers: aus erster Basis + Offset, damit er immer auf der Karte sichtbar ist (nicht ausserhalb wie 1500 0 50 bei kleinen Maps).
	protected string m_statusMarkerPosition = "";
	// Spawn-Fenster: 30 s an; AUS-Dauer aus Capacity (einmal berechnet, getSpawnClosedDuration).
	protected bool m_spawnWindowOpen = true;
	protected float m_spawnWindowAccum = 0.0f;
	protected bool m_spawnWindowStateApplied = false;
	protected float m_spawnClosedDuration = -1.0f;
	// Großangriff: Zähler (4 → 0), bei 0 nächster Öffnung = Großangriff (30 s, 2x Kapazität)
	protected int m_cyclesUntilGrossangriff = GROSSANGRIFF_CYCLES;
	protected bool m_grossangriffActive = false;
	// Haltungsbonus: während Spawn AUS akkumuliert, beim Öffnen (AUS→AN) in Pool überführt
	protected dictionary m_holdingAccumulator;
	// Attack-Boost: pro Zyklus aktiv; Block für nächsten Zyklus; wer hatte Boost im letzten Zyklus (Cooldown-Aufhebung beim nächsten Öffnen)
	protected dictionary m_factionBoostActive;
	protected dictionary m_factionBoostBlocked;
	protected dictionary m_factionHadBoostLastCycle;
	// Naechste AUS-Phase nach MajorAttack: 3.5x Trickle (Reinforcements in der Nicht-Spawn-Zeit)
	protected bool m_trickleBonusAfterMajorAttack = false;

	ReinforcementPoolTracker(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_die' enabled='1' />");
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
		// Spawn-Fenster (30s an / 30s aus) wird in update() nach Initial-Announce angewendet.
		// Abzug der Lebenden erst beim Initial-Announce (~3 s), da getCharacters() in start() oft noch 0 liefert.
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
		// Mittel (Outpost): Stützpunkt, Outpost, Forward, Town, Festung, Bunker, Trench, Camp etc.
		if (key.findFirst("stützpunkt") >= 0 || key.findFirst("stutzpunkt") >= 0 || key.findFirst("outpost") >= 0 ||
		    key.findFirst("forward") >= 0 || key.findFirst("festung") >= 0 || key.findFirst("fort") >= 0 ||
		    key.findFirst("base") >= 0 || key.findFirst("stütz") >= 0 ||
		    key.findFirst("bunker") >= 0 || key.findFirst("trench") >= 0 || key.findFirst("camp") >= 0 ||
		    key.findFirst("compound") >= 0 || key.findFirst("position") >= 0 || key.findFirst("post") >= 0 ||
		    key.findFirst("town") >= 0) {
			return BASE_BONUS_MEDIUM;
		}
		return BASE_BONUS_DEFAULT;
	}

	// Marker-Text: Name (Sidebase/Outpost/HQ) + Trickle pro 10 s, z. B. "Sidebase (0.2/10s)".
	string getBaseMarkerText(const XmlElement@ base) {
		int bonus = getBaseBonus(base);
		string name;
		float trickle;
		if (bonus >= BASE_BONUS_STRONG) {
			name = "HQ";
			trickle = DEFENDER_TRICKLE_STRONG;
		} else if (bonus >= BASE_BONUS_MEDIUM) {
			name = "Outpost";
			trickle = DEFENDER_TRICKLE_MEDIUM;
		} else {
			name = "Sidebase";
			trickle = DEFENDER_TRICKLE_SIDE;
		}
		return name + " (" + trickle + "/10s)";
	}

	// Setzt einmalig Marker an jeder Basis-Position. Pro Fraktion eine Kopie (faction_id=0,1,2…), damit jede Fraktion sie sieht.
	// atlas_index und size wie in Vanilla (intel/kill_commander), Placement auch beim Initial-Announce versuchen.
	void placeBaseValueMarkers(array<const XmlElement@>@ bases) {
		if (bases is null || bases.size() == 0) return;
		// Status-Marker-Position: Offset von erster Basis, damit auf jeder Map sichtbar (nicht 1500/0/50 ausserhalb).
		if (m_statusMarkerPosition.length() == 0) {
			Vector3 p = stringToVector3(bases[0].getStringAttribute("position"));
			// Weiter oben rechts: +360 x, -360 z (von erster Basis)
			m_statusMarkerPosition = (p.get_opIndex(0) + 360) + " " + p.get_opIndex(1) + " " + (p.get_opIndex(2) - 360);
		}
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

	// Eroberungs-Bonus zufaellig, verdoppelt: Side 10–20, Medium 20–40, HQ 40–60 (Verlust nutzt LOSS_PENALTY_*).
	int getCaptureBonusRandom(int baseId, const XmlElement@ base) {
		int cat = getBaseBonusCached(baseId, base);
		if (cat >= BASE_BONUS_STRONG) return rand(40, 60);
		if (cat >= BASE_BONUS_MEDIUM) return rand(20, 40);
		return rand(10, 20);
	}

	// Haltungsbonus: pro gehaltener Basis alle 10 s (nur während Spawn AUS) – Beitrag zum Akkumulator.
	float getDefenderTricklePer10s(int bonusCategory) {
		if (bonusCategory == BASE_BONUS_STRONG) return DEFENDER_TRICKLE_STRONG;
		if (bonusCategory == BASE_BONUS_MEDIUM) return DEFENDER_TRICKLE_MEDIUM;
		return DEFENDER_TRICKLE_SIDE;
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

	// Kurzer Anzeigename für Fahrzeug-Zerstörungsmeldung (Englisch).
	string getVehicleDisplayName(const string &in vehicleKey) {
		if (vehicleKey.length() == 0) return "vehicle";
		string key = vehicleKey.toLowerCase();
		if (key.findFirst("tank") >= 0) return "tank";
		if (key.findFirst("apc") >= 0) return "APC";
		if (key.findFirst("vulcan") >= 0) return "Vulcan";
		if (key.findFirst("wiesel") >= 0) return "Wiesel";
		// Fallback: .vehicle abstreifen
		int dot = key.findFirst(".vehicle");
		if (dot >= 0) return key.substr(0, dot);
		return key;
	}

	// Initialer Pool = max_soldiers * 2. max_soldiers kommt nicht aus der General-Query;
	// die Engine liefert soldier_capacity pro Fraktion, Summe = max_soldiers * CAPACITY_SUM_TO_MAX_SOLDIERS_RATIO (2.5x).
	// Daher: max_soldiers = sum(soldier_capacity) / RATIO → Pool = sum * 2 / RATIO (z.B. 284*2/2.5 ≈ 227 bei ~114 max).
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

	// Basen pro Fraktion zaehlen (owner_id); max zurueckgeben. Entschaedigung: +50 Nachschub pro Basis weniger.
	int getBaseCountForFaction(array<const XmlElement@>@ bases, int factionId) {
		if (bases is null) return 0;
		int n = 0;
		for (uint i = 0; i < bases.size(); ++i) {
			if (bases[i].getIntAttribute("owner_id") == factionId) ++n;
		}
		return n;
	}

	int getMaxBaseCount(array<const XmlElement@>@ bases, int numFactions) {
		if (bases is null || numFactions <= 0) return 0;
		int maxB = 0;
		for (int fid = 0; fid < numFactions; ++fid) {
			int c = getBaseCountForFaction(bases, fid);
			if (c > maxB) maxB = c;
		}
		return maxB;
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

	int getBaseGrantedOwner(int baseId) {
		string key = baseGrantedKey(baseId) + "_owner";
		if (!m_baseGrantedOwner.exists(key)) return -1;
		return int(m_baseGrantedOwner[key]);
	}

	void setBaseGrantedOwner(int baseId, int ownerId) {
		m_baseGrantedOwner[baseGrantedKey(baseId) + "_owner"] = ownerId;
	}

	// AUS-Dauer aus Capacity: 200 Soldaten = 90 s, +0.5 s pro Soldat darueber, Clamp 60–180 s. Einmal berechnet.
	float getSpawnClosedDuration() {
		if (m_spawnClosedDuration >= 0.0f) return m_spawnClosedDuration;
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) {
			m_spawnClosedDuration = SPAWN_CLOSED_BASE;
			return m_spawnClosedDuration;
		}
		int sumCapacity = 0;
		for (uint i = 0; i < factions.size(); ++i)
			sumCapacity += factions[i].getIntAttribute("soldier_capacity");
		float maxSoldiers = float(sumCapacity) / CAPACITY_SUM_TO_MAX_SOLDIERS_RATIO;
		float d = SPAWN_CLOSED_BASE + (maxSoldiers - float(SPAWN_CLOSED_REF_SOLDIERS)) * SPAWN_CLOSED_FACTOR;
		if (maxSoldiers > float(SPAWN_CLOSED_HIGH_CAPACITY_THRESHOLD))
			d += SPAWN_CLOSED_HIGH_CAPACITY_BONUS;
		if (d < SPAWN_CLOSED_MIN) d = SPAWN_CLOSED_MIN;
		if (d > SPAWN_CLOSED_MAX) d = SPAWN_CLOSED_MAX;
		m_spawnClosedDuration = d;
		_log("ReinforcementPool: max_soldiers~" + int(maxSoldiers) + " -> Spawn AUS " + int(d) + " s", 0);
		return m_spawnClosedDuration;
	}

	void update(float time) {
		// Score-Anzeige (Lebend · Nachschub): bei Kill/Die-Events dirty, dann alle 0,5 s getCharacters() – lebend = immer aktuelle Engine-Abfrage, kein Cache
		m_scoreDisplayAccum += time;
		if (m_scoreDisplayDirty && m_scoreDisplayAccum >= SCORE_DISPLAY_THROTTLE) {
			m_scoreDisplayAccum = 0.0f;
			m_scoreDisplayDirty = false;
			updateScoreDisplay();
		}
		// Alle 60 s: Recheck – getCharacters() fuer alle Fraktionen, Anzeige neu setzen (Zahl kann nachziehen).
		if (m_initialAnnounceDone) {
			m_recheckAccum += time;
			if (m_recheckAccum >= SCORE_RECHECK_INTERVAL) {
				m_recheckAccum = 0.0f;
				updateScoreDisplay();
			}
		}

		if (!m_initialAnnounceDone) {
			m_timeAccum += time;
			if (m_timeAccum < 3.0f) return;
			m_initialAnnounceDone = true;
			array<const XmlElement@>@ factions = getFactions(m_metagame);
			array<const XmlElement@>@ bases = getBases(m_metagame);
			int numFactions = factions !is null ? int(factions.size()) : 0;
			int maxBases = getMaxBaseCount(bases, numFactions);
			// Jetzt sind Charaktere geladen: Pool = (Basis-Nachschub 3x + Entschaedigung 50 pro Basis weniger) minus bereits Lebende (einmalig, nur neues Spiel).
			if (!m_loadedFromSave && !m_initialPoolCorrectedForLiving) {
				int basePool = getInitialPoolValue();
				for (uint i = 0; i < factions.size(); ++i) {
					int fid = int(i);
					int factionBases = getBaseCountForFaction(bases, fid);
					int bonus = (maxBases - factionBases) * BASE_COUNT_BONUS_PER_BASE_LESS;
					if (bonus < 0) bonus = 0;
					int initial = basePool + bonus;
					int alive = getAliveCountForFaction(fid);
					int pool = initial - alive;
					if (pool < 0) pool = 0;
					setPoolForFaction(fid, pool);
					if (bonus > 0)
						_log("ReinforcementPool: Faction " + fid + " " + factionBases + " Basen (max " + maxBases + ") -> +" + bonus + " Start-Nachschub.", 0);
				}
				m_initialPoolCorrectedForLiving = true;
			}
			for (uint i = 0; i < factions.size(); ++i) {
				int factionId = int(i);
				int shown = getPoolForFaction(factionId);
				sendFactionMessage(m_metagame, factionId, "Reinforcements: " + shown + " remaining.", 0.95);
			}
			if (bases !is null && bases.size() > 0 && m_statusMarkerPosition.length() == 0) {
				Vector3 p = stringToVector3(bases[0].getStringAttribute("position"));
				m_statusMarkerPosition = (p.get_opIndex(0) + 360) + " " + p.get_opIndex(1) + " " + (p.get_opIndex(2) - 360);
			}
			updateScoreDisplay();
			if (!m_baseValueMarkersPlaced && bases !is null && bases.size() > 0) {
				placeBaseValueMarkers(bases);
				m_baseValueMarkersPlaced = true;
			}
			return;
		}

		// Spawn-Fenster: 30 s an, dann AUS (72–192 s). Alle 4 Zyklen = Großangriff (30 s mit 2x Kapazität + Commander-Meldung).
		m_spawnWindowAccum += time;
		if (!m_spawnWindowStateApplied) {
			m_spawnWindowStateApplied = true;
			applySpawnWindowState(m_spawnWindowOpen, false);
			m_scoreDisplayDirty = true;
		}
		float currentDuration = m_spawnWindowOpen ? SPAWN_WINDOW_OPEN_DURATION : getSpawnClosedDuration();
		if (m_spawnWindowAccum >= currentDuration) {
			m_spawnWindowAccum = 0.0f;
			bool wasOpen = m_spawnWindowOpen;
			m_spawnWindowOpen = !m_spawnWindowOpen;
			if (wasOpen) {
				// Gerade von AN auf AUS gewechselt → Boost beenden, für Cooldown merken wer Boost hatte
				array<const XmlElement@>@ factionsClose = getFactions(m_metagame);
				if (factionsClose !is null) {
					for (uint j = 0; j < factionsClose.size(); ++j) {
						int fid = int(j);
						if (getBoostActive(fid)) {
							setBoostActive(fid, false);
							setHadBoostLastCycle(fid, true);
						}
					}
				}
				if (m_grossangriffActive) {
					m_trickleBonusAfterMajorAttack = true;  // naechste AUS-Phase: 3.5x Trickle
					m_cyclesUntilGrossangriff = GROSSANGRIFF_CYCLES;
					m_grossangriffActive = false;
				} else if (m_cyclesUntilGrossangriff > 0) {
					m_cyclesUntilGrossangriff--;
				}
				applySpawnWindowState(false, false);
			} else {
				m_trickleBonusAfterMajorAttack = false;  // AUS vorbei, Bonus nur eine Phase
				// Gerade von AUS auf AN gewechselt: Akkumulator in Pool überführen + Commander-Meldung
				array<const XmlElement@>@ factions = getFactions(m_metagame);
				if (factions !is null) {
					for (uint i = 0; i < factions.size(); ++i) {
						int fid = int(i);
						float acc = getHoldingAccumulator(fid);
						if (acc > 0.0f) {
							float pool = getPoolForFactionFloat(fid);
							float newPool = pool + acc;
							setPoolForFaction(fid, newPool);
							int poolBefore = int(pool);
							int poolAfter = int(newPool);
							if (poolBefore <= 0 && poolAfter > 0 && isSpawnDisabled(fid))
								enableSpawnForFaction(fid);
							int added = poolAfter - poolBefore;
							if (added > 0)
								sendFactionMessage(m_metagame, fid, "Reinforcements arrived. +" + added + " added to supply.", 0.95);
							resetHoldingAccumulator(fid);
							_log("ReinforcementPool: Haltungsbonus Faction " + fid + " +" + acc + " -> Pool " + newPool, 0);
						}
					}
				}
				// Attack-Boost: Cooldown aufheben (wer letzten Zyklus Boost hatte, darf wieder würfeln ab übernächstem)
				array<const XmlElement@>@ factionsOpen = getFactions(m_metagame);
				if (factionsOpen !is null) {
					for (uint j = 0; j < factionsOpen.size(); ++j) {
						int fid = int(j);
						if (getHadBoostLastCycle(fid)) {
							setBoostBlocked(fid, false);
							setHadBoostLastCycle(fid, false);
						}
					}
					// 25 % Chance pro berechtigter Fraktion (Pool > 0, nicht blockiert)
					for (uint j = 0; j < factionsOpen.size(); ++j) {
						int fid = int(j);
						if (getPoolForFaction(fid) > 0 && !isBoostBlocked(fid) && rand(1, 100) <= 25) {
							setBoostActive(fid, true);
							setBoostBlocked(fid, true);
							sendFactionMessage(m_metagame, fid, "Reinforcement surge active. Increased capacity and spawn rate this cycle.", 0.95);
							_log("ReinforcementPool: Attack-Boost Faction " + fid + " (25% hit).", 0);
						}
					}
				}
				if (m_cyclesUntilGrossangriff == 0) {
					m_grossangriffActive = true;
					sendGrossangriffMessageToAll();
					applySpawnWindowState(true, true);
				} else {
					applySpawnWindowState(true, false);
				}
			}
			m_scoreDisplayDirty = true;
		}

		// Basis-Update (Marker, Trickle nur während Spawn AUS)
		m_baseUpdateAccum += time;
		if (m_baseUpdateAccum < BASE_UPDATE_INTERVAL) return;
		m_baseUpdateAccum = 0.0f;
		if (!m_spawnWindowOpen) m_scoreDisplayDirty = true;

		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (!m_baseValueMarkersPlaced && bases.size() > 0) {
			placeBaseValueMarkers(bases);
			m_baseValueMarkersPlaced = true;
		}

		// Haltungsbonus: nur während Spawn AUS alle 10 s pro Basis in Akkumulator einzahlen
		if (!m_spawnWindowOpen && bases.size() > 0) {
			m_defenderAccum += time;
			if (m_defenderAccum >= DEFENDER_TRICKLE_INTERVAL) {
				m_defenderAccum = 0.0f;
				bool anyAdded = false;
				for (uint i = 0; i < bases.size(); ++i) {
					const XmlElement@ base = bases[i];
					int baseId = base.getIntAttribute("id");
					int ownerId = base.getIntAttribute("owner_id");
					if (ownerId < 0) continue;
					int bonusCat = getBaseBonusCached(baseId, base);
					float trickle = getDefenderTricklePer10s(bonusCat);
					if (m_trickleBonusAfterMajorAttack) trickle *= TRICKLE_MULTIPLIER_AFTER_MAJOR_ATTACK;
					if (trickle > 0.0f) {
						addHoldingAccumulator(ownerId, trickle);
						anyAdded = true;
						_log("ReinforcementPool: Trickle Base " + baseId + " +" + trickle + " -> Faction " + ownerId, 1);
					}
				}
				if (anyAdded) updateScoreDisplay();
			}
		}

		m_saveTimer -= time;
		if (m_saveTimer <= 0.0f) {
			saveToSavegame();
			m_saveTimer = REINFORCEMENT_POOL_SAVE_INTERVAL;
		}
	}

	// Farbe für Score-Anzeige: 1) Faction-XML color, 2) anhand Name/Key (green/grey/brown) – immer fraktionsbezogen, nie nur Slot.
	string getScoreDisplayColor(const XmlElement@ faction, int factionId) {
		if (faction !is null) {
			string color = faction.getStringAttribute("color");
			if (color.length() > 0) return color;
			string name = faction.getStringAttribute("name").toLowerCase();
			string key = faction.getStringAttribute("key").toLowerCase();
			// Green: green/greenbelt/United States
			if (name.findFirst("green") >= 0 || key.findFirst("green") >= 0 || name.findFirst("greenbelt") >= 0 || name.findFirst("united states") >= 0) return "0.0 0.5 0.1";
			// Grey: grey/gray/European Union/Graycollars
			if (name.findFirst("grey") >= 0 || name.findFirst("gray") >= 0 || key.findFirst("grey") >= 0 || key.findFirst("gray") >= 0 || name.findFirst("european") >= 0 || name.findFirst("graycollar") >= 0) return "0.3 0.3 0.3";
			// Brown: brown/Russian/Brownpants
			if (name.findFirst("brown") >= 0 || key.findFirst("brown") >= 0 || name.findFirst("russian") >= 0 || name.findFirst("brownpants") >= 0) return "0.5 0.35 0.1";
		}
		// Letzter Fallback: Slot (nur wenn weder color noch Name/Key erkennbar)
		if (factionId == 0) return "0.0 0.5 0.1";
		if (factionId == 1) return "0.3 0.3 0.3";
		if (factionId == 2) return "0.5 0.35 0.1";
		return "0.5 0.5 0.5";
	}

	// Anzeigename 100% dynamisch aus Faction-XML: Abkuerzung = erste Buchstaben der Woerter (name), sonst key, sonst F+id.
	string getFactionDisplayName(const XmlElement@ faction, int factionId) {
		if (faction is null) return "F" + factionId;
		string name = faction.getStringAttribute("name");
		if (name.length() > 0) {
			array<string>@ words = name.split(" ");
			string abbr = "";
			for (uint w = 0; w < words.size() && abbr.length() < 3; ++w) {
				string word = words[w];
				if (word.length() > 0) abbr += word.substr(0, 1);
			}
			if (abbr.length() >= 1) return abbr;
		}
		string key = faction.getStringAttribute("key");
		if (key.length() > 0) return key.length() >= 2 ? key.substr(0, 2) : key.substr(0, 1);
		return "F" + factionId;
	}

	// Zählt lebende Charaktere einer Fraktion. Die characters-Query liefert keine "dead"-Attribute (→ Log-Warnung), daher: zurückgegebene Anzahl = lebend.
	int getAliveCountForFaction(int factionId) {
		array<const XmlElement@>@ chars = getCharacters(m_metagame, factionId);
		return (chars is null) ? 0 : int(chars.size());
	}

	// Spawn-Status-Text nur fuer Karten-Marker: Sekunden anzeigen (AN 30s, AUS 90s, Großangriff 30s).
	string getSpawnStatusText() {
		float duration = m_spawnWindowOpen ? SPAWN_WINDOW_OPEN_DURATION : getSpawnClosedDuration();
		int secLeft = int(duration - m_spawnWindowAccum);
		if (secLeft < 0) secLeft = 0;
		if (m_grossangriffActive) return "Spawn: MajorAttack (" + secLeft + "s)";
		if (m_spawnWindowOpen) return "Spawn: AN (" + secLeft + "s)";
		return "Spawn: AUS (" + secLeft + "s)";
	}

	// Kurz fuer HUD: AN (ohne Sekunden) oder AUS + verbleibende Sekunden.
	string getSpawnStatusTextShort() {
		if (m_spawnWindowOpen) return "AN";
		float duration = getSpawnClosedDuration();
		int secLeft = int(duration - m_spawnWindowAccum);
		if (secLeft < 0) secLeft = 0;
		return "AUS " + secLeft + "s";
	}

	// HUD: AN oder AUS (Xs) + pro Slot Fraktionsfarbe + Alive-Zahl (Slot 0 = Spawn + F0 Alive, Slot 1/2 = F1/F2 Alive).
	void updateScoreDisplay() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;
		string markerPos = m_statusMarkerPosition.length() > 0 ? m_statusMarkerPosition : STATUS_MARKER_POSITION;
		string spawnText = getSpawnStatusTextShort();

		for (uint i = 0; i < factions.size(); ++i) {
			int factionId = int(i);
			int alive = getAliveCountForFaction(factionId);
			string lineText = (factionId == 0) ? (spawnText + "  " + alive) : ("" + alive);
			if (getBoostActive(factionId)) lineText += " [Surge]";
			XmlElement cmd("command");
			cmd.setStringAttribute("class", "update_score_display");
			cmd.setIntAttribute("id", factionId);
			cmd.setStringAttribute("text", lineText);
			cmd.setStringAttribute("color", getScoreDisplayColor(factions[factionId], factionId));
			m_metagame.getComms().send(cmd);
		}
		// Karte: ein gemeinsamer Marker mit allen Nachschub-Zahlen (EU, UN, RU).
		string markerText = "";
		for (uint i = 0; i < factions.size(); ++i) {
			if (i > 0) markerText += "  ";
			markerText += getFactionDisplayName(factions[i], int(i)) + ": " + getPoolForFaction(int(i));
		}
		XmlElement m("command");
		m.setStringAttribute("class", "set_marker");
		m.setIntAttribute("id", STATUS_MARKER_ID_BASE);
		m.setIntAttribute("faction_id", 0);
		m.setIntAttribute("atlas_index", 0);
		m.setStringAttribute("position", markerPos);
		m.setStringAttribute("text", markerText);
		m.setStringAttribute("color", getScoreDisplayColor(factions[0], 0));
		m.setFloatAttribute("size", 0.75f);
		m.setBoolAttribute("enabled", true);
		m.setBoolAttribute("show_in_map_view", true);
		m.setBoolAttribute("show_in_game_view", false);
		m.setBoolAttribute("show_at_screen_edge", false);
		m_metagame.getComms().send(m);
	}

	void saveToSavegame() {
		XmlElement root("reinforcement_pool");
		root.setIntAttribute("initial_pool_value", m_initialPoolValue >= 0 ? m_initialPoolValue : getInitialPoolValue());
		root.setIntAttribute("initial_announce_done", m_initialAnnounceDone ? 1 : 0);
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		for (uint i = 0; i < factions.size(); ++i) {
			int fid = int(i);
			float poolF = getPoolForFactionFloat(fid);
			float accF = getHoldingAccumulator(fid);
			XmlElement fe("faction");
			fe.setIntAttribute("id", fid);
			fe.setIntAttribute("pool", int(poolF));
			fe.setIntAttribute("pool_frac", int((poolF - float(int(poolF))) * 100.0f));
			fe.setIntAttribute("acc_x100", int(accF * 100.0f));
			fe.setIntAttribute("deaths", getDeathsForFaction(fid));
			fe.setIntAttribute("spawn_disabled", isSpawnDisabled(fid) ? 1 : 0);
			fe.setIntAttribute("boost_active", getBoostActive(fid) ? 1 : 0);
			fe.setIntAttribute("boost_blocked", isBoostBlocked(fid) ? 1 : 0);
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
			int poolInt = fe.getIntAttribute("pool");
			int poolFrac = 0;
			if (fe.hasAttribute("pool_frac")) poolFrac = fe.getIntAttribute("pool_frac");
			float pool = float(poolInt) + float(poolFrac) / 100.0f;
			setPoolForFaction(fid, pool);
			if (fe.hasAttribute("acc_x100")) {
				float acc = float(fe.getIntAttribute("acc_x100")) / 100.0f;
				if (acc > 0.0f) m_holdingAccumulator[factionKey(fid)] = acc;
			}
			int deaths = fe.getIntAttribute("deaths");
			bool spawnOff = fe.getIntAttribute("spawn_disabled") != 0;
			m_deaths[factionKey(fid)] = deaths;
			if (spawnOff) m_spawnDisabled[factionKey(fid)] = true;
			if (fe.hasAttribute("boost_active") && fe.getIntAttribute("boost_active") != 0)
				setBoostActive(fid, true);
			if (fe.hasAttribute("boost_blocked") && fe.getIntAttribute("boost_blocked") != 0)
				setBoostBlocked(fid, true);
		}
		// Nachschub wieder da nach Load → Spawn-Flag löschen, damit applySpawnWindowState (in update) sie wieder aktiviert
		for (uint i = 0; i < factionNodes.size(); ++i) {
			int fid = factionNodes[i].getIntAttribute("id");
			int pool = getPoolForFaction(fid);
			if (pool > 0 && isSpawnDisabled(fid)) clearSpawnDisabled(fid);
		}
		m_loadedFromSave = true;
		updateScoreDisplay();
		_log("ReinforcementPool: geladen aus Savegame (Pool/Deaths/Spawn pro Faction).", 0);
	}

	string factionKey(int factionId) { return "" + factionId; }

	// Attack-Boost: nur in diesem Spawn-Zyklus aktiv; Block = darf nächsten Zyklus nicht gezogen werden.
	bool getBoostActive(int fid) {
		string key = factionKey(fid);
		if (!m_factionBoostActive.exists(key)) return false;
		return int(m_factionBoostActive[key]) != 0;
	}
	void setBoostActive(int fid, bool on) {
		string key = factionKey(fid);
		if (on) m_factionBoostActive[key] = 1;
		else m_factionBoostActive.delete(key);
	}
	bool isBoostBlocked(int fid) {
		string key = factionKey(fid);
		if (!m_factionBoostBlocked.exists(key)) return false;
		return int(m_factionBoostBlocked[key]) != 0;
	}
	void setBoostBlocked(int fid, bool block) {
		string key = factionKey(fid);
		if (block) m_factionBoostBlocked[key] = 1;
		else m_factionBoostBlocked.delete(key);
	}
	bool getHadBoostLastCycle(int fid) {
		string key = factionKey(fid);
		if (!m_factionHadBoostLastCycle.exists(key)) return false;
		return int(m_factionHadBoostLastCycle[key]) != 0;
	}
	void setHadBoostLastCycle(int fid, bool had) {
		string key = factionKey(fid);
		if (had) m_factionHadBoostLastCycle[key] = 1;
		else m_factionHadBoostLastCycle.delete(key);
	}

	// Pool intern als float (Rest bleibt z. B. 15.2 → 15 Soldaten ausgeben, 0.2 bleibt).
	float getPoolForFactionFloat(int factionId) {
		string key = factionKey(factionId);
		if (!m_pool.exists(key)) {
			m_pool[key] = float(getInitialPoolValue());
		}
		return float(m_pool[key]);
	}

	int getPoolForFaction(int factionId) {
		return int(getPoolForFactionFloat(factionId));
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

	void setPoolForFaction(int factionId, float value) {
		if (value < 0.0f) value = 0.0f;
		m_pool[factionKey(factionId)] = value;
	}

	float getHoldingAccumulator(int factionId) {
		string key = factionKey(factionId);
		if (!m_holdingAccumulator.exists(key)) return 0.0f;
		return float(m_holdingAccumulator[key]);
	}

	void addHoldingAccumulator(int factionId, float amount) {
		string key = factionKey(factionId);
		float v = getHoldingAccumulator(factionId);
		m_holdingAccumulator[key] = v + amount;
	}

	void resetHoldingAccumulator(int factionId) {
		m_holdingAccumulator.delete(factionKey(factionId));
	}

	bool isSpawnDisabled(int factionId) {
		string key = factionKey(factionId);
		return m_spawnDisabled.exists(key) && bool(m_spawnDisabled[key]);
	}

	void setSpawnDisabled(int factionId) {
		m_spawnDisabled[factionKey(factionId)] = true;
	}

	void clearSpawnDisabled(int factionId) {
		m_spawnDisabled.delete(factionKey(factionId));
	}

	// Spawn für Fraktion wieder erlauben (z. B. nach Eroberung bei Pool 0 → Pool > 0).
	void enableSpawnForFaction(int factionId) {
		clearSpawnDisabled(factionId);
		applySpawnWindowState(m_spawnWindowOpen);
	}

	bool hasAnnouncedThreshold(int factionId, int value) {
		string key = factionKey(factionId) + "_" + value;
		return m_announcedThresholds.exists(key) && bool(m_announcedThresholds[key]);
	}

	void setAnnouncedThreshold(int factionId, int value) {
		m_announcedThresholds[factionKey(factionId) + "_" + value] = true;
	}

	void announceThreshold(int factionId, int pool) {
		if (pool == 0) return;  // Kein Commander-Meldung bei 0 („Reinforcements depleted“ entfernt)
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
		int bonusCat = getBaseBonusCached(baseId, base);
		int bonus = getCaptureBonusRandom(baseId, base);
		string baseName = base !is null ? base.getStringAttribute("name") : "";
		if (baseName.length() == 0 && base !is null) baseName = base.getStringAttribute("key");
		if (baseName.length() == 0) baseName = "sector";

		// Verlierer bestrafen: nur einmal pro Besitzerwechsel (verhindert Doppel-Penalty bei mehrfach gefeuertem Event).
		int grantedOwner = getBaseGrantedOwner(baseId);
		if (previousOwnerId >= 0 && (grantedOwner == -1 || grantedOwner == previousOwnerId)) {
			setBaseGrantedOwner(baseId, -1); // Basis „frei“ für Gutschrift an neuen Besitzer
			int penalty = 0;
			if (bonusCat >= BASE_BONUS_STRONG)
				penalty = rand(LOSS_PENALTY_STRONG_MIN, LOSS_PENALTY_STRONG_MAX);
			else if (bonusCat >= BASE_BONUS_MEDIUM)
				penalty = rand(LOSS_PENALTY_MEDIUM_MIN, LOSS_PENALTY_MEDIUM_MAX);
			else
				penalty = rand(LOSS_PENALTY_SIDE_MIN, LOSS_PENALTY_SIDE_MAX);
			if (penalty > 0) {
				float pool = getPoolForFactionFloat(previousOwnerId);
				float newPool = pool - float(penalty);
				if (newPool < 0.0f) newPool = 0.0f;
				setPoolForFaction(previousOwnerId, newPool);
				updateScoreDisplay();
				announceThreshold(previousOwnerId, int(newPool));
				sendFactionMessage(m_metagame, previousOwnerId, "We lost " + baseName + ". -" + penalty + " reinforcements.", 0.95);
				_log("ReinforcementPool: Basis " + baseId + " verloren – Faction " + previousOwnerId + " -" + penalty + " Nachschub (verbleibend " + int(newPool) + ").", 0);
				if (newPool <= 0 && !isSpawnDisabled(previousOwnerId)) {
					disableSpawnForFaction(previousOwnerId);
					setSpawnDisabled(previousOwnerId);
				}
			}
		}

		// Eroberer: vollen Bonus genau einmal pro Besitzerwechsel (Doppel-Gutschrift verhindert).
		if (newOwnerId >= 0 && bonus > 0 && getBaseGrantedOwner(baseId) != newOwnerId) {
			float pool = getPoolForFactionFloat(newOwnerId);
			setPoolForFaction(newOwnerId, pool + float(bonus));
			setBaseGranted(baseId, float(bonus));
			setBaseGrantedOwner(baseId, newOwnerId);
			updateScoreDisplay();
			_log("ReinforcementPool: Base " + baseId + " erobert – Faction " + newOwnerId + " +" + bonus + " sofort.", 0);
			sendFactionMessage(m_metagame, newOwnerId, "We captured " + baseName + ". +" + bonus + " reinforcements.", 0.95);
			// Spawn wieder aktivieren, wenn Fraktion sich von 0 hochspielt
			if (getPoolForFaction(newOwnerId) > 0 && isSpawnDisabled(newOwnerId)) {
				enableSpawnForFaction(newOwnerId);
				_log("ReinforcementPool: Faction " + newOwnerId + " – Spawn wieder aktiviert (Pool > 0 nach Eroberung).", 0);
			}
		}

		// Kein set_match_status: Win/Lose bleibt der Engine oder dem Gamemode überlassen (bei Nachschub 0 überrennt man ohnehin).
	}

	// Fahrzeug zerstört: Besitzer (owner_id) verliert Nachschub. Zerstörer-Fraktion (faction_id) bekommt Meldung „We destroyed X.“ (gleicher Kanal wie Commander/Chat, oft oben rechts).
	protected void handleVehicleDestroyEvent(const XmlElement@ event) {
		int ownerId = event.getIntAttribute("owner_id");
		if (ownerId < 0) return;
		int killerFactionId = event.getIntAttribute("faction_id");  // Fraktion, die das Fahrzeug zerstört hat (bei owner_id != faction_id)
		string vehicleKey = event.getStringAttribute("vehicle_key");
		int penalty = getVehicleDestroyPenalty(vehicleKey);
		if (penalty <= 0) return;

		float pool = getPoolForFactionFloat(ownerId);
		float newPool = pool - float(penalty);
		if (newPool < 0.0f) newPool = 0.0f;
		setPoolForFaction(ownerId, newPool);
		updateScoreDisplay();
		announceThreshold(ownerId, int(newPool));
		_log("ReinforcementPool: Fahrzeug " + vehicleKey + " zerstört – Faction " + ownerId + " -" + penalty + " Nachschub (verbleibend " + int(newPool) + ").", 0);
		if (newPool <= 0 && !isSpawnDisabled(ownerId)) {
			disableSpawnForFaction(ownerId);
			setSpawnDisabled(ownerId);
		}
		// Meldung an Zerstörer-Fraktion (wenn anders als Besitzer): „We destroyed tank.“ – gleiche Anzeige wie „Spiel gespeichert“/Commander (Engine legt Position fest).
		if (killerFactionId >= 0 && killerFactionId != ownerId) {
			string vehicleName = getVehicleDisplayName(vehicleKey);
			sendFactionMessage(m_metagame, killerFactionId, "We destroyed " + vehicleName + ".", 0.9);
		}
	}

	// Nachschub geht bei jedem Tod runter (auch Artillerie/Umwelt). character_die = jeder Tod; character_kill nur fuer Tote-Zaehler.
	// Nur in character_die Pool abziehen, damit bei einem Tod nicht doppelt abgezogen wird (Engine kann beide senden).
	protected void handleCharacterKillEvent(const XmlElement@ event) {
		const XmlElement@ target = event.getFirstElementByTagName("target");
		if (target is null) return;
		addDeathForFaction(target.getIntAttribute("faction_id"));
		m_scoreDisplayDirty = true;
		updateScoreDisplay();
	}

	protected void handleCharacterDieEvent(const XmlElement@ event) {
		const XmlElement@ character = event.getFirstElementByTagName("character");
		const XmlElement@ target = character is null ? event.getFirstElementByTagName("target") : character;
		if (target is null) return;
		int factionId = target.getIntAttribute("faction_id");
		addDeathForFaction(factionId);
		// Pool bei jedem Tod um 1 verringern (inkl. Artillerie, Umwelt, etc.)
		float pool = getPoolForFactionFloat(factionId);
		if (pool >= 1.0f) {
			pool -= 1.0f;
			setPoolForFaction(factionId, pool);
			announceThreshold(factionId, getPoolForFaction(factionId));
			if (getPoolForFaction(factionId) <= 0 && !isSpawnDisabled(factionId)) {
				disableSpawnForFaction(factionId);
				setSpawnDisabled(factionId);
			}
		}
		m_scoreDisplayDirty = true;
		updateScoreDisplay();
	}

	// Spawn: Nachschub wird nicht mehr abgezogen – Abzug nur bei Tod (character_die).
	protected void handleCharacterSpawnEvent(const XmlElement@ event) {
		m_scoreDisplayDirty = true;
		updateScoreDisplay();
	}

	// Chat-Command /nachschub oder /pool: sofort ausfuehren, Pools bei Bedarf initialisieren. Ausgabe mit dynamischen Fraktionskuerzeln.
	protected void handleChatEvent(const XmlElement@ event) {
		string message = event.getStringAttribute("message");
		if (!startsWith(message, "/")) return;
		if (!checkCommand(message, "nachschub") && !checkCommand(message, "pool")) return;

		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) {
			XmlElement cmd("command");
			cmd.setStringAttribute("class", "chat");
			cmd.setStringAttribute("text", "Reinforcements: no faction data yet. Try again in a moment.");
			m_metagame.getComms().send(cmd);
			return;
		}
		// Pools sofort verfuegbar machen (getPoolForFactionFloat initialisiert bei Bedarf)
		getInitialPoolValue();

		string line = "Reinforcements | ";
		for (uint i = 0; i < factions.size(); ++i) {
			int factionId = int(i);
			int pool = getPoolForFaction(factionId);
			int dead = getDeathsForFaction(factionId);
			array<const XmlElement@>@ chars = getCharacters(m_metagame, factionId);
			int alive = (chars is null) ? 0 : int(chars.size());
			if (i > 0) line += " | ";
			line += getFactionDisplayName(factions[factionId], factionId) + ": " + pool + " left, " + dead + " dead, " + alive + " alive";
		}
		XmlElement cmd("command");
		cmd.setStringAttribute("class", "chat");
		cmd.setStringAttribute("text", line);
		m_metagame.getComms().send(cmd);
	}

	// Spawn-Fenster umschalten. grossangriff=true: 30 s mit verdoppelter Kapazität (2x). Attack-Boost (Surge): 1.2x Cap, 1.5x Spawn-Rate.
	// Capacity-Nerf: Fraktionen mit ueberdurchschnittlicher soldier_capacity (mehr Basen) bekommen 0.9x, damit 7 Basen/200 Truppen vs 1 Basis/40 nicht so krass ist.
	void applySpawnWindowState(bool open, bool grossangriff = false) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;
		int sumCapacity = 0;
		for (uint i = 0; i < factions.size(); ++i)
			sumCapacity += factions[i].getIntAttribute("soldier_capacity");
		float avgCapacity = factions.size() > 0 ? float(sumCapacity) / float(factions.size()) : 0.0f;

		XmlElement command("command");
		command.setStringAttribute("class", "change_game_settings");
		for (uint i = 0; i < factions.size(); ++i) {
			int fid = int(i);
			XmlElement faction("faction");
			bool canSpawn = open && getPoolForFaction(fid) > 0 && !isSpawnDisabled(fid);
			float capMultBase = (open && grossangriff) ? GROSSANGRIFF_CAPACITY_MULTIPLIER : 1.0f;
			float capMult = capMultBase;
			float spawnInterval = 0.2f;
			if (canSpawn && getBoostActive(fid)) {
				capMult = capMultBase * BOOST_CAPACITY_MULTIPLIER;
				spawnInterval = 0.2f / BOOST_SPAWN_RATE_MULTIPLIER;
			}
			// Nerf: ueberdurchschnittliche Capacity (mehr Basen) -> 0.9x
			if (canSpawn && avgCapacity > 0.0f && float(factions[i].getIntAttribute("soldier_capacity")) > avgCapacity)
				capMult *= CAPACITY_NERF_ABOVE_AVG;
			faction.setFloatAttribute("capacity_multiplier", canSpawn ? capMult : CAPACITY_MULTIPLIER_NEAR_ZERO);
			if (canSpawn) faction.setFloatAttribute("spawn_interval", spawnInterval);
			command.appendChild(faction);
		}
		m_metagame.getComms().send(command);
		if (grossangriff && open)
			_log("ReinforcementPool: MajorAttack – Spawn 30 s mit 2x Kapazität.", 0);
		else
			_log("ReinforcementPool: Spawn-Fenster " + (open ? "AN (5x)" : "AUS") + ".", 0);
	}

	void sendGrossangriffMessageToAll() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;
		string msg = "All sides are preparing for a major assault.";
		for (uint i = 0; i < factions.size(); ++i)
			sendFactionMessage(m_metagame, int(i), msg, 0.95);
	}

	// Spawn für Fraktion abschalten. Immer vollen Zustand für ALLE Fraktionen senden (wie applySpawnWindowState),
	// damit die Engine keine leeren <faction/>-Elemente bekommt – die können den Basis-Capture-Timer zurücksetzen.
	void disableSpawnForFaction(int factionId) {
		setSpawnDisabled(factionId);
		applySpawnWindowState(m_spawnWindowOpen);
		_log("ReinforcementPool: Faction " + factionId + " – Nachschub aufgebraucht, Spawn deaktiviert.", 0);
	}
}
