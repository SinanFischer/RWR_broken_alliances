// Reinforcement-Pool-Tracker: Nachschub begrenzt pro Fraktion; bei 0 kein Spawn mehr.
// Eroberungs-Bonus: sofort voll (25/50/100) – kein 5-Min-Puffer mehr (kein „antellig bei schneller Rückeroberung“).
// Verteidiger-Bonus: alle 3 Min +2/+4/+6 pro gehaltener Basis. Verlust: Hälfte des Basis-Bonus abgezogen.
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

const int REINFORCEMENT_POOL_INITIAL = 1000;
const int REINFORCEMENT_POOL_MULTIPLIER = 2;
const float CAPACITY_SUM_TO_MAX_SOLDIERS_RATIO = 1.28f;
const int BASE_BONUS_DEFAULT = 25;
const int BASE_BONUS_MEDIUM = 50;
const int BASE_BONUS_STRONG = 100;
const float BASE_UPDATE_INTERVAL = 1.0f;
const float DEFENDER_BONUS_INTERVAL = 180.0f;
const int DEFENDER_BONUS_SIDE = 2;
const int DEFENDER_BONUS_MEDIUM = 4;
const int DEFENDER_BONUS_STRONG = 6;
const float FOLLOWUP_MESSAGE_DELAY = 4.0f;
// Fahrzeug-Verlust: Angreifer (Besitzer) verliert Nachschub – Ausgleich wenn Panzer/APC alles niedermähen.
const int VEHICLE_PENALTY_TANK_BIG = 10;   // tank_1, tank_2: 5–15, hier Mittelwert 10 (Variante: rand(5,15))
const int VEHICLE_PENALTY_TANK = 7;        // tank (ohne _1/_2)
const int VEHICLE_PENALTY_VULCAN = 5;
const int VEHICLE_PENALTY_APC = 4;
const int VEHICLE_PENALTY_WIESEL = 3;

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

	ReinforcementPoolTracker(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
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

	// Nachschub-Penalty wenn Fahrzeug zerstört wird (Besitzer = Angreifer verliert). Key z. B. "vulcan_tank.vehicle".
	int getVehicleDestroyPenalty(const string &in vehicleKey) {
		if (vehicleKey.length() == 0) return 0;
		string key = vehicleKey.toLowerCase();
		// Reihenfolge wichtig: spezifische Keys zuerst
		if (key.findFirst("tank_1") >= 0 || key.findFirst("tank_2") >= 0)
			return rand(5, 15);
		if (key.findFirst("vulcan") >= 0) return VEHICLE_PENALTY_VULCAN;
		if (key.findFirst("apc") >= 0) return VEHICLE_PENALTY_APC;
		if (key.findFirst("wiesel") >= 0) return VEHICLE_PENALTY_WIESEL;
		// Basis-Panzer "tank.vehicle" (nicht tank_1/tank_2/vulcan_tank)
		if (key.findFirst("tank.vehicle") >= 0) return VEHICLE_PENALTY_TANK;
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
			return;
		}

		// Nur Verteidiger-Bonus (Eroberungs-Bonus wird beim Eroberungs-Event sofort voll gutgeschrieben, kein 5-Min-Puffer).
		m_baseUpdateAccum += time;
		m_defenderAccum += time;
		if (m_baseUpdateAccum < BASE_UPDATE_INTERVAL) return;
		m_baseUpdateAccum = 0.0f;

		bool poolChanged = false;
		array<const XmlElement@>@ bases = getBases(m_metagame);

		// Verteidiger-Bonus: alle 3 Min +2/+4/+6 Nachschub pro gehaltener Basis
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

		// Verlierer bestrafen + Commander-Meldung: Nachschub um die Hälfte des Eroberungs-Bonus verringern.
		if (previousOwnerId >= 0) {
			int penalty = bonus / 2;
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
