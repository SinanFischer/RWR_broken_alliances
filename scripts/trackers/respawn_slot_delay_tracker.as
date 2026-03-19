// Respawn-Slot-Delay: Nach Tod bleibt ein Spawn-Slot X Sekunden „besetzt" → capacity_multiplier sinkt.
// Mechanismus: mult = (liveCount - reserved) / liveCount
//   liveCount  = aktuell lebende Soldaten der Fraktion (echte Feldstärke, nicht XML-soldier_capacity)
//   reserved   = Anzahl noch aktiver Slot-Ablaufzeitstempel nach Toden
//
// Warum liveCount statt soldier_capacity:
//   Die Engine verteilt max_soldiers proportional auf Fraktionen; soldier_capacity ist nur ein
//   Gewichtungsfaktor, keine absolute Feldstärke. capacity_multiplier skaliert diesen Anteil.
//   Nur mit liveCount als Basis ergibt sich ein sinnvoller Multiplikator.
//
// Fraktion mit ≤1 Basis: Slotblock immer AUS → mult = 1.0 (unabhängig von anderen Fraktionen).
//
// Timestamps: Gespeichert wird der Ablaufzeitpunkt (expireTime = now + delay), nicht der Todeszeitpunkt.
//
// --- Konfiguration ---
const float RESPAWN_SLOT_DELAY          = 15.0f;   // s, 3+ Basen
const float RESPAWN_SLOT_DELAY_2_BASES  =  5.0f;   // s, 2 Basen
const float RESPAWN_SLOT_DELAY_1_BASE   =  2.0f;   // s, 1 Basis
const float ALIVE_CHECK_INTERVAL        = 15.0f;   // s, Intervall für Alive/Basen-Update
const int   TROOPS_PER_EXTRA_BLOCK      = 25;      // pro 25 Truppen Vorsprung …
const float EXTRA_SECONDS_PER_BLOCK     =  4.0f;   // … +4 s Slot-Delay
const float APPLY_INTERVAL             =  1.0f;   // s, wie oft capacity_multiplier gesendet wird
const float CAPACITY_MULTIPLIER_NEAR_ZERO = 0.00001f; // Engine-Minimum (Fraktion nicht ignorieren)
// Slots pro Tod: XML-soldier_capacity <70→1, 70–120→2, 121–200→3, 201–250→4, 251–299→5, ≥300→6; Führer +2.

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

		m_leaderFactionId = -1;
		for (uint i = 0; i < factions.size(); ++i) {
			string key = factionKey(int(i));
			int alive = aliveCounts[i];
			m_liveCount[key] = alive;
			m_xmlCapacity[key] = factions[i].getIntAttribute("soldier_capacity");
			float extra = (alive > second)
				? float((alive - second) / TROOPS_PER_EXTRA_BLOCK) * EXTRA_SECONDS_PER_BLOCK
				: 0.0f;
			m_extraDelaySeconds[key] = extra;
			if (alive == first && m_leaderFactionId < 0) m_leaderFactionId = int(i);
			m_basesPerFaction[key] = getBasesForFaction(m_metagame, int(i));
		}
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
				int reserved  = getReservedSlots(fid);
				int liveCount = getLiveCount(fid);
				if (reserved <= 0 || liveCount <= 0) {
					mult = 1.0f;
				} else {
					float effective = float(liveCount - reserved);
					if (effective < 0.0f) effective = 0.0f;
					mult = effective / float(liveCount);
					if (mult < CAPACITY_MULTIPLIER_NEAR_ZERO) mult = CAPACITY_MULTIPLIER_NEAR_ZERO;
					_log("RespawnSlotDelay: fid=" + fid + " live=" + liveCount + " reserved=" + reserved + " mult=" + mult, 1);
				}
			}
			XmlElement faction("faction");
			faction.setFloatAttribute("capacity_multiplier", mult);
			command.appendChild(faction);
		}
		m_metagame.getComms().send(command);
		for (uint i = 0; i < factions.size(); ++i) pruneSlotExpireTimes(int(i));
	}

	// Für HUD/Stats: effektive Feldstärke = liveCount - reserved.
	int getEffectiveCapacityForFaction(int factionId) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factionId < 0 || uint(factionId) >= factions.size()) return 0;
		if (isWeakestFactionSlotBlockDisabled(factionId, getMinBasesOverFactions()))
			return getLiveCount(factionId);
		int effective = getLiveCount(factionId) - getReservedSlots(factionId);
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
