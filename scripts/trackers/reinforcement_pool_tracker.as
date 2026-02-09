// Reinforcement-Pool-Tracker: Pro Fraktion begrenzter Nachschub (z. B. 1000).
// Jeder Tod verringert den Pool; bei 0 wird Spawn deaktiviert.
// Eroberungs-Bonus: pro Basis über 5 Min 25/50/100 (leicht/mittel/groß). Verteidiger-Bonus: jede Minute +2/+4/+6 pro gehaltener Basis.
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

const int REINFORCEMENT_POOL_INITIAL = 1000;   // Fallback wenn keine Faction-Kapazität
const int REINFORCEMENT_POOL_MULTIPLIER = 2;   // Nachschub = max_soldiers * MULTIPLIER
// Engine liefert soldier_capacity pro Fraktion; Summe ≈ max_soldiers * dieses Faktors (Variance/Modell).
// Rückrechnung: max_soldiers = sum_capacity / RATIO → Pool = (sum_capacity / RATIO) * 2.
const float CAPACITY_SUM_TO_MAX_SOLDIERS_RATIO = 1.28f;
const int BASE_BONUS_DEFAULT = 25;            // leichte/Side-Basis (Eroberungs-Bonus über 5 Min)
const int BASE_BONUS_MEDIUM = 50;             // mittlere Basis
const int BASE_BONUS_STRONG = 100;            // große/Haupt-Basis
const float BASE_FILL_TIME = 300.0f;         // Sekunden bis Counter voll (5 Min)
const float BASE_UPDATE_INTERVAL = 1.0f;      // Basis-Bonus-Loop nur alle N Sekunden (weniger getBases-Queries)
const float DEFENDER_BONUS_INTERVAL = 180.0f; // alle 3 Min Verteidiger-Bonus pro gehaltener Basis
const int DEFENDER_BONUS_SIDE = 2;            // leichte/Side-Basis: +2 Nachschub pro Intervall
const int DEFENDER_BONUS_MEDIUM = 4;          // mittlere Basis: +4 pro Intervall
const int DEFENDER_BONUS_STRONG = 6;          // große Basis: +6 pro Intervall

class ReinforcementPoolTracker : Tracker {
	protected Metagame@ m_metagame;
	protected dictionary m_pool;
	protected dictionary m_spawnDisabled;
	protected dictionary m_announcedThresholds;
	protected dictionary m_baseGranted;       // pro Basis: bereits gewährter Bonus (wird bei Besitzerwechsel zurückgesetzt)
	protected dictionary m_baseBonusCache;    // baseId -> Bonus (30/40/50), vermeidet wiederholte String-Checks
	protected dictionary m_deaths;            // pro Fraktion: Anzahl gefallener Soldaten (für /nachschub "tot")
	protected int m_initialPoolValue = -1;   // einmalig aus Factions-Query (soldier_capacity)*2 gelesen
	protected bool m_initialAnnounceDone = false;
	protected float m_timeAccum = 0.0f;
	protected float m_baseUpdateAccum = 0.0f; // Throttle: getBases nur alle BASE_UPDATE_INTERVAL Sekunden
	protected float m_defenderAccum = 0.0f;  // Verteidiger-Bonus: alle 60 s +2/+4/+6 pro gehaltener Basis
	// Schwellen für Commander-Meldungen: 800, 600, 500, 300, 100, 10
	protected array<int> m_thresholds;

	ReinforcementPoolTracker(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
		m_metagame.getComms().send("<command class='set_metagame_event' name='chat_event' enabled='1' />");
		m_metagame.getComms().send("<command class='set_metagame_event' name='base_owner_change_event' enabled='1' />");
		m_thresholds.insertLast(800);
		m_thresholds.insertLast(600);
		m_thresholds.insertLast(500);
		m_thresholds.insertLast(300);
		m_thresholds.insertLast(100);
		m_thresholds.insertLast(10);
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	// Bonus nach Schwierigkeit (Key lowercase). Ergebnis pro baseId cachen – Basis-Key ändert sich nicht.
	int getBaseBonus(const XmlElement@ base) {
		if (base is null) return BASE_BONUS_DEFAULT;
		string key = base.getStringAttribute("key").toLowerCase();
		// Schwer/Hauptziel: höchster Bonus
		if (key.findFirst("hq") >= 0 || key.findFirst("main") >= 0 || key.findFirst("capital") >= 0 ||
		    key.findFirst("headquarters") >= 0 || key.findFirst("zentrum") >= 0 || key.findFirst("haupt") >= 0) {
			return BASE_BONUS_STRONG;
		}
		// Mittel: Stützpunkt, Outpost, Forward, Festung etc.
		if (key.findFirst("stützpunkt") >= 0 || key.findFirst("stutzpunkt") >= 0 || key.findFirst("outpost") >= 0 ||
		    key.findFirst("forward") >= 0 || key.findFirst("festung") >= 0 || key.findFirst("fort") >= 0 ||
		    key.findFirst("base") >= 0 || key.findFirst("stütz") >= 0) {
			return BASE_BONUS_MEDIUM;
		}
		return BASE_BONUS_DEFAULT;
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
		if (!m_initialAnnounceDone) {
			m_timeAccum += time;
			if (m_timeAccum < 3.0f) return;
			m_initialAnnounceDone = true;
			array<const XmlElement@>@ factions = getFactions(m_metagame);
			for (uint i = 0; i < factions.size(); ++i) {
				int factionId = int(i);
				sendFactionMessage(m_metagame, factionId, "Nachschub: " + getInitialPoolValue() + " verbleibend.", 0.95);
			}
			updateScoreDisplay();
			return;
		}

		// Basis-Bonus: getBases nur alle BASE_UPDATE_INTERVAL Sekunden aufrufen (teure Query).
		m_baseUpdateAccum += time;
		m_defenderAccum += time;
		if (m_baseUpdateAccum < BASE_UPDATE_INTERVAL) return;
		float delta = m_baseUpdateAccum;
		if (delta > BASE_UPDATE_INTERVAL * 2.0f) delta = BASE_UPDATE_INTERVAL * 2.0f; // Catch-up begrenzen
		m_baseUpdateAccum = 0.0f;

		bool poolChanged = false;
		array<const XmlElement@>@ bases = getBases(m_metagame);

		// 1) Eroberungs-Bonus: über 5 Min füllt sich pro Basis (25/50/100)
		for (uint i = 0; i < bases.size(); ++i) {
			const XmlElement@ base = bases[i];
			int baseId = base.getIntAttribute("id");
			int ownerId = base.getIntAttribute("owner_id");
			if (ownerId < 0) continue;
			int bonusMax = getBaseBonusCached(baseId, base);
			float granted = getBaseGranted(baseId);
			if (granted >= float(bonusMax)) continue;
			float rate = float(bonusMax) / BASE_FILL_TIME;
			float add = rate * delta;
			if (granted + add > float(bonusMax)) add = float(bonusMax) - granted;
			setBaseGranted(baseId, granted + add);
			int addInt = int(add);
			if (addInt > 0) {
				int pool = getPoolForFaction(ownerId);
				setPoolForFaction(ownerId, pool + addInt);
				poolChanged = true;
				_log("ReinforcementPool: Base " + baseId + " +" + addInt + " -> Faction " + ownerId + " Pool " + (pool + addInt), 1);
			}
		}

		// 2) Verteidiger-Bonus: alle 3 Min +2/+4/+6 Nachschub pro gehaltener Basis (DEFENDER_BONUS_*)
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
	}

	// Feste Farben pro Slot, damit die Engine sie zuverlässig anzeigt. Slot 0 = Grün (meist eigene Fraktion), 1 = Rot, 2 = Orange.
	// Format: "R G B" 0.0–1.0 (wie in Faction-XML).
	string getScoreDisplayColor(int factionId) {
		if (factionId == 0) return "0.0 0.85 0.2";   // Grün – typisch eigene Fraktion
		if (factionId == 1) return "0.9 0.2 0.2";   // Rot
		if (factionId == 2) return "0.9 0.55 0.1";  // Orange
		return "0.85 0.85 0.85";                     // Grau für weitere
	}

	// Nutzt das gleiche UI wie Minimodes (Score-Anzeige oben). Nur die Zahl pro Fraktion, feste Farbe pro Slot.
	void updateScoreDisplay() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		for (uint i = 0; i < factions.size(); ++i) {
			int factionId = int(i);
			int pool = getPoolForFaction(factionId);
			XmlElement cmd("command");
			cmd.setStringAttribute("class", "update_score_display");
			cmd.setIntAttribute("id", factionId);
			cmd.setStringAttribute("text", "" + pool);
			cmd.setStringAttribute("color", getScoreDisplayColor(factionId));
			m_metagame.getComms().send(cmd);
		}
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
			sendFactionMessage(m_metagame, factionId, "Nachschub aufgebraucht. Keine Verstärkung mehr.", 1.0);
			return;
		}
		for (uint i = 0; i < m_thresholds.size(); ++i) {
			if (int(m_thresholds[i]) == pool && !hasAnnouncedThreshold(factionId, pool)) {
				sendFactionMessage(m_metagame, factionId, "Nachschub: " + pool + " verbleibend.", 0.95);
				setAnnouncedThreshold(factionId, pool);
				break;
			}
		}
	}

	// Bei Besitzerwechsel: Counter für diese Basis auf 0 – neuer Besitzer bekommt über 5 Min den vollen Bonus.
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		int baseId = event.getIntAttribute("base_id");
		setBaseGranted(baseId, 0.0f);
		_log("ReinforcementPool: Base " + baseId + " Besitzerwechsel – Counter zurückgesetzt.", 1);
	}

	protected void handleCharacterKillEvent(const XmlElement@ event) {
		const XmlElement@ target = event.getFirstElementByTagName("target");
		if (target is null) return;

		int factionId = target.getIntAttribute("faction_id");
		int pool = getPoolForFaction(factionId);
		if (pool <= 0) return;  // bereits aufgebraucht, nichts tun

		addDeathForFaction(factionId);
		pool--;
		setPoolForFaction(factionId, pool);
		_log("ReinforcementPool: Faction " + factionId + " -> " + pool + " verbleibend", 1);

		updateScoreDisplay();

		// Commander-Meldung bei Schwellen (800, 600, 500, 300, 100, 10) und bei aufgebraucht
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

		string line = "Nachschub | ";
		for (uint i = 0; i < factions.size(); ++i) {
			int factionId = int(i);
			int pool = getPoolForFaction(factionId);
			int dead = getDeathsForFaction(factionId);
			array<const XmlElement@>@ chars = getCharacters(m_metagame, factionId);
			int alive = int(chars.size());
			if (i > 0) line += " | ";
			line += "F" + factionId + ": " + pool + " verbl., " + dead + " tot, " + alive + " lebend";
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
