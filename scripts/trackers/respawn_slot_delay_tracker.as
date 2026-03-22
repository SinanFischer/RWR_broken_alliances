// Respawn-Slot-Delay: Nach Tod bleibt ein Spawn-Slot X Sekunden „besetzt" → capacity_multiplier sinkt.
// Zweiter Hebel: spawn_interval = 60s wenn liveCount >= effectiveCap (Fraktion ist voll/drüber).
// Mechanismus: mult = (nativeCap - reserved) / nativeCap
//   nativeCap  = (xmlCap / sumXmlCap) × peakTotalLive  — stabiler Proxy für max_soldiers-Anteil
//   reserved   = Anzahl noch aktiver Slot-Ablaufzeitstempel nach Toden
//
// Warum peakTotalLive statt liveCount:
//   capacity_multiplier skaliert die Engine-interne Kapazität (xmlCap-proportionaler Anteil an max_soldiers).
//   liveCount sinkt durch Drosselung → würde den Nenner verkleinern → Feedback-Loop → Block hebt sich auf.
//   peakTotalLive = höchster je beobachteter totalLive-Wert, wird nur nach oben aktualisiert.
//   So bleibt der Nenner stabil und mult wirkt tatsächlich als Spawn-Bremse.
//
// Fraktion mit ≤1 Basis: Slotblock immer AUS → mult = 1.0, spawn_interval = SPAWN_INTERVAL_NORMAL.
//
// Timestamps: Gespeichert wird der Ablaufzeitpunkt (expireTime = now + delay), nicht der Todeszeitpunkt.
//
// --- Konfiguration ---
const float RESPAWN_SLOT_DELAY          = 10.0f;   // s, 3+ Basen
const float RESPAWN_SLOT_DELAY_2_BASES  =  5.0f;   // s, 2 Basen
const float RESPAWN_SLOT_DELAY_1_BASE   =  2.0f;   // s, 1 Basis
const float ALIVE_CHECK_INTERVAL        = 15.0f;   // s, Intervall für Alive/Basen-Update
const int   TROOPS_PER_EXTRA_BLOCK      = 25;      // pro 25 Truppen Vorsprung …
const float EXTRA_SECONDS_PER_BLOCK     =  4.0f;   // … +4 s Slot-Delay
const float APPLY_INTERVAL             =  1.0f;   // s, wie oft capacity_multiplier gesendet wird
const float CAPACITY_MULTIPLIER_NEAR_ZERO = 0.00001f; // Engine-Minimum (Fraktion nicht ignorieren)
const float SPAWN_INTERVAL_NORMAL      =  0.2f;   // s, normaler Respawn-Takt (Engine-Default ~0.05–0.2)
const float SPAWN_INTERVAL_BLOCKED     = 60.0f;   // s, Respawn-Takt wenn Slots geblockt sind
// Slots pro Tod: XML-soldier_capacity <70→1, 70–120→2, 121–200→3, 201–250→4, 251–299→5, ≥300→6; Führer +2.
//
// --- BalanceCompensator-Konfiguration ---
// Gleicht extreme Alive-Verhältnisse automatisch aus (z.B. 11 vs 80 = 1:7).
// Greift erst ab BALANCE_RATIO_THRESHOLD. Ziel-Mult wird sanft per Lerp aufgebaut,
// aber sofort auf 1.0 zurückgesetzt wenn das Verhältnis wieder unter den Threshold fällt.
// Funktioniert für 1v1 und 1v1v1: jede Fraktion wird relativ zur stärksten bewertet.
const float BALANCE_RATIO_THRESHOLD = 3.0f;  // ab diesem Verhältnis (stärkste/schwächste) greift der Kompensator
const float BALANCE_MAX_MULT        = 3.0f;  // maximaler capacity_multiplier (Engine-Max ist 4.0)
const float BALANCE_LERP_SPEED      = 0.03f; // pro Sekunde Aufbaugeschwindigkeit (sanft, kein Sprung)

#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

class RespawnSlotDelayTracker : Tracker {
	protected Metagame@ m_metagame;
	protected float m_timeAccum       = 0.0f;
	protected float m_applyAccum      = 0.0f;
	protected float m_aliveCheckAccum = 0.0f;

	// Timestamps: key = factionId, value = "expire1,expire2,..."
	protected dictionary m_slotExpireTimes;
	protected dictionary m_pendingDeaths;
	protected dictionary m_extraDelaySeconds;
	protected int        m_leaderFactionId = -1;
	protected dictionary m_totalSlotSecondsBlocked;
	protected dictionary m_basesPerFaction;

	// Alive-Cache: liveCount pro Fraktion (alle ALIVE_CHECK_INTERVAL s aktualisiert)
	protected dictionary m_liveCount;

	// XML-soldier_capacity: nur für getSlotsPerDeathForCapacity (Größenindikator)
	protected dictionary m_xmlCapacity;

	// Geschätzte native Kapazität pro Fraktion: (xmlCap / sumXmlCap) × totalLive
	// Das ist der echte Nenner für capacity_multiplier-Berechnungen.
	protected dictionary m_nativeCap;
	protected int        m_totalLive = 0;
	protected int        m_sumXmlCap = 0;

	// BalanceCompensator: aktuell angewendeter Kompensations-Multiplikator pro Fraktion (geglättet per Lerp)
	protected dictionary m_balanceMult;
	// Einmal-Flag: key vorhanden = Kompensator für diese Fraktion bereits verbraucht (nie mehr aktivierbar)
	protected dictionary m_balanceBurned;

	RespawnSlotDelayTracker(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_die' enabled='1' />");
	}

	bool hasEnded()  const { return false; }
	bool hasStarted() const { return true; }

	void start() {
		refreshAliveBasedData();
		applyCapacityWithReservedSlots();
	}

	void update(float time) {
		m_timeAccum += time;
		flushPendingDeaths();

		m_aliveCheckAccum += time;
		if (m_aliveCheckAccum >= ALIVE_CHECK_INTERVAL) {
			m_aliveCheckAccum = 0.0f;
			refreshAliveBasedData();
		}

		m_applyAccum += time;
		if (m_applyAccum < APPLY_INTERVAL) return;
		m_applyAccum = 0.0f;
		applyCapacityWithReservedSlots();
	}

	// Aktualisiert liveCount, Basen, Extra-Delay und Leader-Fraktion.
	void refreshAliveBasedData() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;

		array<int> aliveCounts;
		aliveCounts.resize(factions.size());
		int first = 0, second = 0;
		for (uint i = 0; i < factions.size(); ++i) {
			array<const XmlElement@>@ chars = getCharacters(m_metagame, int(i));
			int n = (chars is null) ? 0 : int(chars.size());
			aliveCounts[i] = n;
			if (n >= first) { second = first; first = n; }
			else if (n > second) second = n;
		}
		if (factions.size() == 1) second = first;

		// Summen für nativeCap-Schätzung
		int totalLive = 0;
		int sumXmlCap = 0;
		for (uint i = 0; i < factions.size(); ++i) {
			totalLive += aliveCounts[i];
			sumXmlCap += factions[i].getIntAttribute("soldier_capacity");
		}
		m_totalLive = totalLive;
		m_sumXmlCap = sumXmlCap;

		m_leaderFactionId = -1;
		for (uint i = 0; i < factions.size(); ++i) {
			string key = factionKey(int(i));
			int alive = aliveCounts[i];
			m_liveCount[key] = alive;
			int xmlCap = factions[i].getIntAttribute("soldier_capacity");
			m_xmlCapacity[key] = xmlCap;
			// nativeCap = proportionaler Anteil an totalLive (Schätzung für max_soldiers-Anteil)
			float nativeCap = (sumXmlCap > 0 && totalLive > 0)
				? float(xmlCap) / float(sumXmlCap) * float(totalLive)
				: float(alive);
			m_nativeCap[key] = nativeCap;
			float extra = (alive > second)
				? float((alive - second) / TROOPS_PER_EXTRA_BLOCK) * EXTRA_SECONDS_PER_BLOCK
				: 0.0f;
			m_extraDelaySeconds[key] = extra;
			if (alive == first && m_leaderFactionId < 0) m_leaderFactionId = int(i);
			m_basesPerFaction[key] = getBasesForFaction(m_metagame, int(i));
		}

		// BalanceCompensator: Lerp-Mults nach frischem liveCount aktualisieren
		updateBalanceMults(first);
	}

	int getLiveCount(int factionId) {
		string key = factionKey(factionId);
		if (m_liveCount.exists(key)) return int(m_liveCount[key]);
		// Fallback: direkte Query wenn Cache noch leer
		array<const XmlElement@>@ chars = getCharacters(m_metagame, factionId);
		int n = (chars is null) ? 0 : int(chars.size());
		m_liveCount[key] = n;
		return n;
	}

	int getXmlCapacity(int factionId) {
		string key = factionKey(factionId);
		if (m_xmlCapacity.exists(key)) return int(m_xmlCapacity[key]);
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions !is null && factionId >= 0 && uint(factionId) < factions.size()) {
			int cap = factions[factionId].getIntAttribute("soldier_capacity");
			m_xmlCapacity[key] = cap;
			return cap;
		}
		return 0;
	}

	// ---- BalanceCompensator-System ------------------------------------------
	// Ziel-Mult basierend auf Alive-Verhältnis zur stärksten Fraktion.
	float calcBalanceTargetMult(int factionId, int maxAlive) {
		if (maxAlive <= 0) return 1.0f;
		int alive = getLiveCount(factionId);
		if (alive <= 0) return 1.0f;
		float ratio = float(maxAlive) / float(alive);
		if (ratio < BALANCE_RATIO_THRESHOLD) return 1.0f;
		return (ratio > BALANCE_MAX_MULT) ? BALANCE_MAX_MULT : ratio;
	}

	// Lerp-Aufbau wenn ratio > threshold, sofortiger Reset wenn ratio darunter fällt.
	// Einmal-Aktivierung: Sobald der Kompensator für eine Fraktion aktiv war und wieder deaktiviert wird,
	// wird sie in m_balanceBurned eingetragen und reagiert nie wieder auf den Kompensator.
	void updateBalanceMults(int maxAlive) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;
		for (uint i = 0; i < factions.size(); ++i) {
			string key = factionKey(int(i));

			// Einmal-Flag: key vorhanden = bereits verbraucht → dauerhaft deaktiviert
			if (m_balanceBurned.exists(key)) {
				m_balanceMult[key] = 1.0f;
				continue;
			}

			float current = m_balanceMult.exists(key) ? float(m_balanceMult[key]) : 1.0f;
			float target  = calcBalanceTargetMult(int(i), maxAlive);
			float next;
			if (target <= 1.0f) {
				// War der Kompensator aktiv und das Verhältnis normalisiert sich jetzt?
				// → Einmal-Flag setzen: dieser Slot ist für immer verbraucht.
				if (current > 1.01f) {
					m_balanceBurned[key] = 1;
					_log("BalanceComp: fid=" + i + " BURNED – einmalige Aktivierung verbraucht", 1);
				}
				next = 1.0f;
			} else {
				next = current + (target - current) * BALANCE_LERP_SPEED * ALIVE_CHECK_INTERVAL;
			}
			m_balanceMult[key] = next;
			if (target > 1.01f || current > 1.01f)
				_log("BalanceComp: fid=" + i + " alive=" + getLiveCount(int(i)) + " maxAlive=" + maxAlive + " target=" + target + " mult=" + next, 1);
		}
	}

	float getBalanceMult(int factionId) {
		string key = factionKey(factionId);
		return m_balanceMult.exists(key) ? float(m_balanceMult[key]) : 1.0f;
	}
	// -------------------------------------------------------------------------

	// Gibt die geschätzte native Kapazität zurück (proportionaler Anteil an totalLive).
	// Das ist der korrekte Nenner für capacity_multiplier: mult × nativeCap = targetCap.
	float getNativeCap(int factionId) {
		string key = factionKey(factionId);
		if (m_nativeCap.exists(key)) return float(m_nativeCap[key]);
		// Fallback: liveCount wenn Cache noch leer
		return float(getLiveCount(factionId));
	}

	float getEffectiveDelaySeconds(int factionId) {
		int bases = getBasesForFactionCached(factionId);
		float baseDelay = (bases <= 1) ? RESPAWN_SLOT_DELAY_1_BASE
		                : (bases == 2) ? RESPAWN_SLOT_DELAY_2_BASES
		                :                RESPAWN_SLOT_DELAY;
		float extra = 0.0f;
		if (m_extraDelaySeconds.exists(factionKey(factionId)))
			extra = float(m_extraDelaySeconds[factionKey(factionId)]);
		return baseDelay + extra;
	}

	int getBasesForFactionCached(int factionId) {
		string key = factionKey(factionId);
		return m_basesPerFaction.exists(key)
			? int(m_basesPerFaction[key])
			: getBasesForFaction(m_metagame, factionId);
	}

	void addPendingDeath(int factionId) {
		string key = factionKey(factionId);
		int v = m_pendingDeaths.exists(key) ? int(m_pendingDeaths[key]) : 0;
		m_pendingDeaths[key] = v + 1;
	}

	// Slots pro Tod basierend auf XML-soldier_capacity (Größenindikator, nicht Feldstärke).
	int getSlotsPerDeathForCapacity(int xmlCap) {
		if (xmlCap >= 300) return 6;
		if (xmlCap >= 251) return 5;
		if (xmlCap >= 201) return 4;
		if (xmlCap >= 121) return 3;
		if (xmlCap >= 70)  return 2;
		return 1;
	}

	void flushPendingDeaths() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;
		int minBases = getMinBasesOverFactions();
		for (uint i = 0; i < factions.size(); ++i) {
			int fid = int(i);
			string key = factionKey(fid);
			if (!m_pendingDeaths.exists(key)) continue;
			int n = int(m_pendingDeaths[key]);
			m_pendingDeaths.delete(key);
			if (isWeakestFactionSlotBlockDisabled(fid, minBases)) continue;

			int xmlCap      = getXmlCapacity(fid);
			int slotsPerDeath = getSlotsPerDeathForCapacity(xmlCap) + (fid == m_leaderFactionId ? 2 : 0);
			float delay     = getEffectiveDelaySeconds(fid);

			float addBlocked = float(n) * float(slotsPerDeath) * delay;
			float prev = m_totalSlotSecondsBlocked.exists(key) ? float(m_totalSlotSecondsBlocked[key]) : 0.0f;
			m_totalSlotSecondsBlocked[key] = prev + addBlocked;

			float expireTime = m_timeAccum + delay;
			string ts = m_slotExpireTimes.exists(key) ? string(m_slotExpireTimes[key]) : "";
			for (int j = 0; j < n; ++j)
				for (int k = 0; k < slotsPerDeath; ++k) {
					if (ts.length() > 0) ts += ",";
					ts += "" + expireTime;
				}
			m_slotExpireTimes[key] = ts;
		}
	}

	dictionary parseSlotExpireTimes(int factionId) {
		dictionary result;
		result["count"] = 0;
		result["kept"]  = string("");
		string key = factionKey(factionId);
		if (!m_slotExpireTimes.exists(key)) return result;
		string s = string(m_slotExpireTimes[key]);
		if (s.length() == 0) return result;
		float now   = m_timeAccum;
		int   count = 0;
		string kept = "";
		uint start  = 0;
		for (uint i = 0; i <= s.length(); ++i) {
			if (i < s.length() && s.substr(i, 1) != ",") continue;
			string part = s.substr(start, i - start);
			start = i + 1;
			if (part.length() == 0) continue;
			float expire = parseFloat(part);
			if (expire > now) {
				count++;
				if (kept.length() > 0) kept += ",";
				kept += part;
			}
		}
		result["count"] = count;
		result["kept"]  = kept;
		return result;
	}

	int getReservedSlots(int factionId) {
		dictionary d = parseSlotExpireTimes(factionId);
		int c = 0;
		d.get("count", c);
		return c;
	}

	void pruneSlotExpireTimes(int factionId) {
		dictionary d = parseSlotExpireTimes(factionId);
		string kept;
		d.get("kept", kept);
		string key = factionKey(factionId);
		if (kept.length() > 0) m_slotExpireTimes[key] = kept;
		else m_slotExpireTimes.delete(key);
	}

	float getTotalSlotSecondsBlocked(int factionId) {
		string key = factionKey(factionId);
		return m_totalSlotSecondsBlocked.exists(key) ? float(m_totalSlotSecondsBlocked[key]) : 0.0f;
	}

	int getMinBasesOverFactions() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return 0;
		int minBases = 999;
		for (uint i = 0; i < factions.size(); ++i) {
			int b = getBasesForFactionCached(int(i));
			if (b < minBases) minBases = b;
		}
		return (minBases == 999) ? 0 : minBases;
	}

	bool isWeakestFactionSlotBlockDisabled(int factionId, int minBases) {
		return getBasesForFactionCached(factionId) <= 1;
	}

	void applyCapacityWithReservedSlots() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;
		int minBases = getMinBasesOverFactions();

		XmlElement command("command");
		command.setStringAttribute("class", "change_game_settings");
		for (uint i = 0; i < factions.size(); ++i) {
			int fid = int(i);
			float mult;
			if (isWeakestFactionSlotBlockDisabled(fid, minBases)) {
				mult = 1.0f;
			} else {
				int reserved    = getReservedSlots(fid);
				float nativeCap = getNativeCap(fid);
				if (reserved <= 0 || nativeCap <= 0.0f) {
					mult = 1.0f;
				} else {
					float targetCap = nativeCap - float(reserved);
					if (targetCap < 0.0f) targetCap = 0.0f;
					mult = targetCap / nativeCap;
					if (mult < CAPACITY_MULTIPLIER_NEAR_ZERO) mult = CAPACITY_MULTIPLIER_NEAR_ZERO;
					_log("RespawnSlotDelay: fid=" + fid + " native=" + nativeCap + " reserved=" + reserved + " target=" + targetCap + " mult=" + mult, 1);
				}
			}
			// BalanceCompensator: überschreibt mult nach oben wenn Verhältnis extrem ist
			float balanceMult = getBalanceMult(fid);
			if (balanceMult > mult) {
				_log("RespawnSlotDelay+Balance: fid=" + fid + " slotMult=" + mult + " balanceMult=" + balanceMult, 1);
				mult = balanceMult;
			}
			// spawn_interval: 60s wenn liveCount >= effectiveCap (Fraktion ist voll oder drüber).
			// Sobald Soldaten unter die effektive Kapazität fallen, normaler Takt.
			int effectiveCap = getEffectiveCapacityForFaction(fid);
			int liveCount    = getLiveCount(fid);
			bool throttle    = (effectiveCap > 0 && liveCount >= effectiveCap);
			XmlElement faction("faction");
			faction.setFloatAttribute("capacity_multiplier", mult);
			faction.setFloatAttribute("spawn_interval", throttle ? SPAWN_INTERVAL_BLOCKED : SPAWN_INTERVAL_NORMAL);
			if (throttle) _log("RespawnSlotDelay: fid=" + fid + " THROTTLE live=" + liveCount + " >= cap=" + effectiveCap, 1);
			command.appendChild(faction);
		}
		m_metagame.getComms().send(command);
		for (uint i = 0; i < factions.size(); ++i) pruneSlotExpireTimes(int(i));
	}

	// Für HUD/Stats: effektive Kapazität = nativeCap - reserved (entspricht dem was die Engine spawnt).
	int getEffectiveCapacityForFaction(int factionId) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factionId < 0 || uint(factionId) >= factions.size()) return 0;
		if (isWeakestFactionSlotBlockDisabled(factionId, getMinBasesOverFactions()))
			return int(getNativeCap(factionId));
		int effective = int(getNativeCap(factionId)) - getReservedSlots(factionId);
		return (effective > 0) ? effective : 0;
	}

	protected void handleCharacterDieEvent(const XmlElement@ event) {
		const XmlElement@ character = event.getFirstElementByTagName("character");
		const XmlElement@ target = character is null ? event.getFirstElementByTagName("target") : character;
		if (target is null) return;
		int factionId = target.getIntAttribute("faction_id");
		addPendingDeath(factionId);
	}

	private string factionKey(int factionId) { return "" + factionId; }
}
