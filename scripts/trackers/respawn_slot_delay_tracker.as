// Respawn-Slot-Delay-Tracker: Nach jedem Tod bleibt der Capacity-Slot X Sekunden „besetzt“,
// sodass kein neuer Soldat/Spieler in diesem Slot spawnen kann. Macht Kills und Medic-Revi wertvoller.
//
// *** Gibt es einen nativen Weg, Respawn-Delay zu erhöhen? ***
// Nein. In der Modding-API (Scripts, XML, change_game_settings) existiert KEIN Attribut wie
// „respawn_delay“ oder „slot_cooldown“. Einziger Weg per Mod: capacity_multiplier dynamisch verringern.
//
// *** Konflikt mit anderen Trackern ***
// Wir senden nur capacity_multiplier (kein spawn_interval). Die Engine merged vermutlich pro Attribut;
// dann bleibt spawn_interval von SpawnTimeHandler etc. erhalten. Damit unser Multiplikator greift:
// Diesen Tracker NACH anderen einbinden, die change_game_settings senden (z.B. SpawnTimeHandler),
// oder nur diesen Tracker für Capacity nutzen.
//
// --- Konfiguration (anpassen nach Bedarf) ---
const float RESPAWN_SLOT_DELAY = 15.0f;   // Basis-Sekunden (3+ Basen)
const float RESPAWN_SLOT_DELAY_2_BASES = 5.0f;  // Nur 2 Basen → kürzeres Delay (nur diese Fraktion)
const float RESPAWN_SLOT_DELAY_1_BASE = 2.0f;  // Nur 1 Basis → stark reduziert (nur diese Fraktion)
// Pro 25 Truppen Vorsprung gegenüber der zweitstärksten Fraktion: +2 s extra pro Tod (z.B. 200 vs 150 → +4 s).
const float ALIVE_CHECK_INTERVAL = 15.0f; // Alle 15 s: Alive-Zahlen prüfen, Extra-Verzögerung pro Fraktion setzen
const int   TROOPS_PER_EXTRA_BLOCK = 25;  // Alle 25 Truppen Vorsprung …
const float EXTRA_SECONDS_PER_BLOCK = 4.0f; // … = 2 Sekunden länger Slot-Delay
// Slots per Death: <70→1, 70-120→2, 121-200→3, 201-250→4, 251-299→5, >=300→6; Führer +2 (getSlotsPerDeathForCapacity).
const float APPLY_INTERVAL = 1.0f;        // Alle 1 s an Engine senden (genauerer Delay-Effekt)
const float CAPACITY_MULTIPLIER_NEAR_ZERO = 0.00001f;  // Min-Mult, damit Engine Fraktion nicht als „tot“ sieht
//

#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

class RespawnSlotDelayTracker : Tracker {
	protected Metagame@ m_metagame;
	protected float m_timeAccum = 0.0f;
	protected float m_applyAccum = 0.0f;
	protected float m_aliveCheckAccum = 0.0f;
	protected dictionary m_deathTimestamps;   // key = factionId, value = "t1,t2,t3"
	protected dictionary m_pendingDeaths;     // key = factionId, value = Anzahl (im nächsten update zeitstempeln)
	protected dictionary m_extraDelaySeconds;  // key = factionId, value = float (extra Sekunden Slot-Delay bei Truppenüberlegenheit)
	protected int m_leaderFactionId = -1;    // Fraktion mit den meisten Alive (alle 15 s); erhält +2 Slots pro Tod
	protected dictionary m_totalSlotSecondsBlocked;  // key = factionId, value = float (kumulierte Slot·s durch Tode dieser Fraktion)
	protected dictionary m_basesPerFaction;         // key = factionId, value = int (Anzahl Basen, alle 15 s aktualisiert)

	RespawnSlotDelayTracker(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_die' enabled='1' />");
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void start() {
		refreshAliveBasedExtraDelay(); // Sofort erste Alive-basierte Extra-Verzögerung + Basen-Cache
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

	// Alle 15 s: Alive pro Fraktion holen; für jede Fraktion mit mehr Truppen als die 2. höchste
	// extraDelay = (Vorsprung / 25) * 2 Sekunden (z.B. 50 Vorsprung → 4 s länger bis Capacity zurück).
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
		if (factions.size() == 1) second = first; // Kein „Zweiter“ → kein Extra-Delay für die einzige Fraktion
		m_leaderFactionId = -1;
		for (uint i = 0; i < factions.size(); ++i) {
			string key = "" + int(i);
			int alive = aliveCounts[i];
			float extra = 0.0f;
			if (alive > second)
				extra = float((alive - second) / TROOPS_PER_EXTRA_BLOCK) * EXTRA_SECONDS_PER_BLOCK;
			m_extraDelaySeconds[key] = extra;
			if (alive == first && m_leaderFactionId < 0)
				m_leaderFactionId = int(i); // Erste Fraktion mit max Alive = Führer (+2 Slots pro Tod)
			int bases = getBasesForFaction(m_metagame, int(i));
			m_basesPerFaction[key] = bases;
		}
	}

	// Basis-Delay pro Fraktion: 1 Basis → 2 s, 2 Basen → 5 s, 3+ → RESPAWN_SLOT_DELAY (nur für diese Fraktion).
	float getBaseDelaySeconds(int factionId) {
		string key = "" + factionId;
		if (!m_basesPerFaction.exists(key)) return RESPAWN_SLOT_DELAY;
		int bases = int(m_basesPerFaction[key]);
		if (bases <= 1) return RESPAWN_SLOT_DELAY_1_BASE;
		if (bases == 2) return RESPAWN_SLOT_DELAY_2_BASES;
		return RESPAWN_SLOT_DELAY;
	}

	float getExtraDelaySeconds(int factionId) {
		string key = "" + factionId;
		if (!m_extraDelaySeconds.exists(key)) return 0.0f;
		return float(m_extraDelaySeconds[key]);
	}

	void addPendingDeath(int factionId) {
		string key = "" + factionId;
		int v = 0;
		if (m_pendingDeaths.exists(key)) v = int(m_pendingDeaths[key]);
		m_pendingDeaths[key] = v + 1;
	}

	// Slots pro Tod (Basis) nach eigener Capacity: <70→1, 70-120→2, 121-200→3, 201-250→4, 251-299→5, >=300→6.
	// Führer-Bonus (+2) wird in flushPendingDeaths() addiert.
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
			string key = "" + fid;
			if (!m_pendingDeaths.exists(key)) continue;
			int n = int(m_pendingDeaths[key]);
			m_pendingDeaths.delete(key);
			int rawCap = factions[fid].getIntAttribute("soldier_capacity");
			if (rawCap < 0) rawCap = 0;
			int slotsPerDeath = getSlotsPerDeathForCapacity(rawCap);
			if (fid == m_leaderFactionId) slotsPerDeath += 2; // Führer verliert 2 Slots mehr pro Tod
			float effectiveDelay = getBaseDelaySeconds(fid) + getExtraDelaySeconds(fid);
			float addBlocked = float(n) * float(slotsPerDeath) * effectiveDelay;
			float prev = 0.0f;
			if (m_totalSlotSecondsBlocked.exists(key)) prev = float(m_totalSlotSecondsBlocked[key]);
			m_totalSlotSecondsBlocked[key] = prev + addBlocked;
			string ts = "";
			if (m_deathTimestamps.exists(key)) ts = string(m_deathTimestamps[key]);
			for (int j = 0; j < n; ++j) {
				for (int k = 0; k < slotsPerDeath; ++k) {
					if (ts.length() > 0) ts += ",";
					ts += "" + m_timeAccum;
				}
			}
			m_deathTimestamps[key] = ts;
		}
	}

	// Kumulierte Slot-Sekunden: Jeder Tod dieser Fraktion hat slotsPerDeath × effectiveDelay Sekunden Blockade erzeugt (Impact-Metrik).
	float getTotalSlotSecondsBlocked(int factionId) {
		string key = "" + factionId;
		if (!m_totalSlotSecondsBlocked.exists(key)) return 0.0f;
		return float(m_totalSlotSecondsBlocked[key]);
	}

	// Nur zählen, keine Seiteneffekte. Aufräumen separat in pruneDeathTimestamps().
	// effectiveDelay = Basis + Extra bei Truppenüberlegenheit (alle 15 s aktualisiert).
	int getReservedSlots(int factionId) {
		string key = "" + factionId;
		if (!m_deathTimestamps.exists(key)) return 0;
		string s = string(m_deathTimestamps[key]);
		if (s.length() == 0) return 0;
		float now = m_timeAccum;
		float effectiveDelay = getBaseDelaySeconds(factionId) + getExtraDelaySeconds(factionId);
		int count = 0;
		uint start = 0;
		for (uint i = 0; i <= s.length(); ++i) {
			if (i < s.length() && s.substr(i, 1) != ",") continue;
			string part = s.substr(start, i - start);
			start = i + 1;
			if (part.length() == 0) continue;
			float t = parseFloat(part);
			if (t > 0.0f && t <= now && (now - t) <= effectiveDelay)
				count++;
		}
		return count;
	}

	// Alte Einträge entfernen, damit m_deathTimestamps nicht unbegrenzt wächst.
	void pruneDeathTimestamps(int factionId) {
		string key = "" + factionId;
		if (!m_deathTimestamps.exists(key)) return;
		string s = string(m_deathTimestamps[key]);
		if (s.length() == 0) return;
		float now = m_timeAccum;
		float effectiveDelay = getBaseDelaySeconds(factionId) + getExtraDelaySeconds(factionId);
		string kept = "";
		uint start = 0;
		for (uint i = 0; i <= s.length(); ++i) {
			if (i < s.length() && s.substr(i, 1) != ",") continue;
			string part = s.substr(start, i - start);
			start = i + 1;
			if (part.length() == 0) continue;
			float t = parseFloat(part);
			if (t > 0.0f && t <= now && (now - t) <= effectiveDelay) {
				if (kept.length() > 0) kept += ",";
				kept += part;
			}
		}
		if (kept.length() > 0) m_deathTimestamps[key] = kept;
		else m_deathTimestamps.delete(key);
	}

	void applyCapacityWithReservedSlots() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;

		XmlElement command("command");
		command.setStringAttribute("class", "change_game_settings");
		for (uint i = 0; i < factions.size(); ++i) {
			int fid = int(i);
			int rawCap = factions[i].getIntAttribute("soldier_capacity");
			if (rawCap < 0) rawCap = 0;
			int reserved = getReservedSlots(fid);
			float effective = float(rawCap) - float(reserved);
			if (effective < 0.0f) effective = 0.0f;
			float mult = (rawCap > 0) ? (effective / float(rawCap)) : CAPACITY_MULTIPLIER_NEAR_ZERO;
			if (mult < CAPACITY_MULTIPLIER_NEAR_ZERO) mult = CAPACITY_MULTIPLIER_NEAR_ZERO;

			if (reserved > 0)
				_log("RespawnSlotDelay: fid=" + fid + " reserved=" + reserved + " mult=" + mult, 1);

			XmlElement faction("faction");
			faction.setFloatAttribute("capacity_multiplier", mult);
			command.appendChild(faction);
		}
		m_metagame.getComms().send(command);

		for (uint i = 0; i < factions.size(); ++i)
			pruneDeathTimestamps(int(i));
	}

	// Für Debug-HUD: effektive Capacity (rawCap - reserved), die die Engine für Spawn-Limit nutzt.
	int getEffectiveCapacityForFaction(int factionId) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factionId < 0 || uint(factionId) >= factions.size()) return 0;
		int rawCap = factions[factionId].getIntAttribute("soldier_capacity");
		if (rawCap < 0) rawCap = 0;
		int reserved = getReservedSlots(factionId);
		int effective = rawCap - reserved;
		return (effective > 0) ? effective : 0;
	}

	protected void handleCharacterDieEvent(const XmlElement@ event) {
		const XmlElement@ character = event.getFirstElementByTagName("character");
		const XmlElement@ target = character is null ? event.getFirstElementByTagName("target") : character;
		if (target is null) return;
		int factionId = target.getIntAttribute("faction_id");
		addPendingDeath(factionId);
	}
}
