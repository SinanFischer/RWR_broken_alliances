// Respawn-Slot-Delay: Nach Tod bleibt der Capacity-Slot X Sekunden „besetzt“ → weniger Spawns.
// Kein natives API-Respawn-Delay; Umsetzung nur über dynamischen capacity_multiplier.
// Konflikt: change_game_settings mit capacity_multiplier – Tracker NACH anderen einbinden, die das senden.
//
// --- Konfiguration (eine Stelle, Einheiten in Kommentaren) ---
const float RESPAWN_SLOT_DELAY = 15.0f;           // s, 3+ Basen
const float RESPAWN_SLOT_DELAY_2_BASES = 5.0f;    // s, nur 2 Basen
const float RESPAWN_SLOT_DELAY_1_BASE = 2.0f;     // s, nur 1 Basis
const float ALIVE_CHECK_INTERVAL = 15.0f;         // s, Intervall für Alive/Basen-Update
const int   TROOPS_PER_EXTRA_BLOCK = 25;          // pro 25 Truppen Vorsprung …
const float EXTRA_SECONDS_PER_BLOCK = 4.0f;       // … +4 s Slot-Delay (führende Fraktion)
const float APPLY_INTERVAL = 1.0f;                // s, wie oft capacity_multiplier an Engine gesendet wird
const float CAPACITY_MULTIPLIER_NEAR_ZERO = 0.00001f;  // Min-Mult, damit Engine Fraktion nicht ignoriert
// Slots pro Tod: Capacity <70→1, 70–120→2, 121–200→3, 201–250→4, 251–299→5, ≥300→6; Führer +2.
// Schwächste Fraktion (wenigste Basen, ≤2 Basen): Slotblock aus → Vanilla-Spawn.

#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

class RespawnSlotDelayTracker : Tracker {
	protected Metagame@ m_metagame;
	protected float m_timeAccum = 0.0f;
	protected float m_applyAccum = 0.0f;
	protected float m_aliveCheckAccum = 0.0f;
	protected dictionary m_deathTimestamps;   // key = factionId, value = "t1,t2,t3"
	protected dictionary m_pendingDeaths;
	protected dictionary m_extraDelaySeconds;
	protected int m_leaderFactionId = -1;
	protected dictionary m_totalSlotSecondsBlocked;
	protected dictionary m_basesPerFaction;

	RespawnSlotDelayTracker(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_die' enabled='1' />");
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void start() {
		refreshAliveBasedExtraDelay();
		applyCapacityWithReservedSlots();
	}

	void update(float time) {
		m_timeAccum += time;
		flushPendingDeaths();

		m_aliveCheckAccum += time;
		if (m_aliveCheckAccum >= ALIVE_CHECK_INTERVAL) {
			m_aliveCheckAccum = 0.0f;
			refreshAliveBasedExtraDelay();
		}

		m_applyAccum += time;
		if (m_applyAccum < APPLY_INTERVAL) return;
		m_applyAccum = 0.0f;
		applyCapacityWithReservedSlots();
	}

	// --- Alive/Basen-Cache (alle ALIVE_CHECK_INTERVAL s) ---
	void refreshAliveBasedExtraDelay() {
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
			float extra = (alive > second) ? float((alive - second) / TROOPS_PER_EXTRA_BLOCK) * EXTRA_SECONDS_PER_BLOCK : 0.0f;
			m_extraDelaySeconds[key] = extra;
			if (alive == first && m_leaderFactionId < 0) m_leaderFactionId = int(i);
			m_basesPerFaction[key] = getBasesForFaction(m_metagame, int(i));
		}
	}

	// Effektives Delay = Basis (nach Basenanzahl) + Extra (Truppenüberlegenheit). Eine Stelle für alle Nutzer.
	float getEffectiveDelaySeconds(int factionId) {
		int bases = getBasesForFactionCached(factionId);
		float baseDelay = (bases <= 1) ? RESPAWN_SLOT_DELAY_1_BASE : (bases == 2) ? RESPAWN_SLOT_DELAY_2_BASES : RESPAWN_SLOT_DELAY;
		float extra = 0.0f;
		if (m_extraDelaySeconds.exists(factionKey(factionId))) extra = float(m_extraDelaySeconds[factionKey(factionId)]);
		return baseDelay + extra;
	}

	int getBasesForFactionCached(int factionId) {
		string key = factionKey(factionId);
		return m_basesPerFaction.exists(key) ? int(m_basesPerFaction[key]) : getBasesForFaction(m_metagame, factionId);
	}

	void addPendingDeath(int factionId) {
		string key = factionKey(factionId);
		int v = m_pendingDeaths.exists(key) ? int(m_pendingDeaths[key]) : 0;
		m_pendingDeaths[key] = v + 1;
	}

	int getSlotsPerDeathForCapacity(int factionCap) {
		if (factionCap >= 300) return 6;
		if (factionCap >= 251) return 5;
		if (factionCap >= 201) return 4;
		if (factionCap >= 121) return 3;
		if (factionCap >= 70) return 2;
		return 1;
	}

	void flushPendingDeaths() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;
		for (uint i = 0; i < factions.size(); ++i) {
			int fid = int(i);
			string key = factionKey(fid);
			if (!m_pendingDeaths.exists(key)) continue;
			int n = int(m_pendingDeaths[key]);
			m_pendingDeaths.delete(key);
			int rawCap = clampCapacity(factions[fid].getIntAttribute("soldier_capacity"));
			int slotsPerDeath = getSlotsPerDeathForCapacity(rawCap) + (fid == m_leaderFactionId ? 2 : 0);
			float delay = getEffectiveDelaySeconds(fid);
			float addBlocked = float(n) * float(slotsPerDeath) * delay;
			float prev = m_totalSlotSecondsBlocked.exists(key) ? float(m_totalSlotSecondsBlocked[key]) : 0.0f;
			m_totalSlotSecondsBlocked[key] = prev + addBlocked;
			string ts = m_deathTimestamps.exists(key) ? string(m_deathTimestamps[key]) : "";
			for (int j = 0; j < n; ++j)
				for (int k = 0; k < slotsPerDeath; ++k) { if (ts.length() > 0) ts += ","; ts += "" + m_timeAccum; }
			m_deathTimestamps[key] = ts;
		}
	}

	// Eine Parse-Schleife: liefert Anzahl aktiver Slots und den behaltenen String (für Prune).
	// dictionary: "count" = int, "kept" = string
	dictionary parseDeathTimestamps(int factionId) {
		dictionary result;
		result["count"] = 0;
		result["kept"] = string("");
		string key = factionKey(factionId);
		if (!m_deathTimestamps.exists(key)) return result;
		string s = string(m_deathTimestamps[key]);
		if (s.length() == 0) return result;
		float now = m_timeAccum;
		float delay = getEffectiveDelaySeconds(factionId);
		int count = 0;
		string kept = "";
		uint start = 0;
		for (uint i = 0; i <= s.length(); ++i) {
			if (i < s.length() && s.substr(i, 1) != ",") continue;
			string part = s.substr(start, i - start);
			start = i + 1;
			if (part.length() == 0) continue;
			float t = parseFloat(part);
			if (t > 0.0f && t <= now && (now - t) <= delay) {
				count++;
				if (kept.length() > 0) kept += ",";
				kept += part;
			}
		}
		result["count"] = count;
		result["kept"] = kept;
		return result;
	}

	int getReservedSlots(int factionId) {
		dictionary d = parseDeathTimestamps(factionId);
		int c = 0;
		d.get("count", c);
		return c;
	}

	void pruneDeathTimestamps(int factionId) {
		dictionary d = parseDeathTimestamps(factionId);
		string kept;
		d.get("kept", kept);
		string key = factionKey(factionId);
		if (kept.length() > 0) m_deathTimestamps[key] = kept;
		else m_deathTimestamps.delete(key);
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
		int bases = getBasesForFactionCached(factionId);
		return bases <= 2 && bases == minBases;
	}

	void applyCapacityWithReservedSlots() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;
		int minBases = getMinBasesOverFactions();

		XmlElement command("command");
		command.setStringAttribute("class", "change_game_settings");
		for (uint i = 0; i < factions.size(); ++i) {
			int fid = int(i);
			int rawCap = clampCapacity(factions[i].getIntAttribute("soldier_capacity"));
			int reserved = getReservedSlots(fid);
			float mult;
			if (isWeakestFactionSlotBlockDisabled(fid, minBases)) {
				mult = 1.0f;
			} else {
				float effective = float(rawCap - reserved);
				if (effective < 0.0f) effective = 0.0f;
				mult = (rawCap > 0) ? (effective / float(rawCap)) : CAPACITY_MULTIPLIER_NEAR_ZERO;
				if (mult < CAPACITY_MULTIPLIER_NEAR_ZERO) mult = CAPACITY_MULTIPLIER_NEAR_ZERO;
			}
			if (reserved > 0 && mult < 1.0f) _log("RespawnSlotDelay: fid=" + fid + " reserved=" + reserved + " mult=" + mult, 1);
			XmlElement faction("faction");
			faction.setFloatAttribute("capacity_multiplier", mult);
			command.appendChild(faction);
		}
		m_metagame.getComms().send(command);
		for (uint i = 0; i < factions.size(); ++i) pruneDeathTimestamps(int(i));
	}

	int getEffectiveCapacityForFaction(int factionId) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factionId < 0 || uint(factionId) >= factions.size()) return 0;
		int rawCap = clampCapacity(factions[factionId].getIntAttribute("soldier_capacity"));
		if (isWeakestFactionSlotBlockDisabled(factionId, getMinBasesOverFactions())) return rawCap;
		int effective = rawCap - getReservedSlots(factionId);
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
	private int clampCapacity(int raw) { return (raw < 0) ? 0 : raw; }
}
