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
const float RESPAWN_SLOT_DELAY = 10.0f;   // Sekunden, die der Slot nach einem Tod „besetzt“ bleibt
const float APPLY_INTERVAL = 1.0f;        // Alle 1 s an Engine senden (genauerer 10s-Effekt)
const float CAPACITY_MULTIPLIER_NEAR_ZERO = 0.00001f;  // Min-Mult, damit Engine Fraktion nicht als „tot“ sieht
//

#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

class RespawnSlotDelayTracker : Tracker {
	protected Metagame@ m_metagame;
	protected float m_timeAccum = 0.0f;
	protected float m_applyAccum = 0.0f;
	protected dictionary m_deathTimestamps;  // key = factionId, value = "t1,t2,t3"
	protected dictionary m_pendingDeaths;    // key = factionId, value = Anzahl (im nächsten update zeitstempeln)

	RespawnSlotDelayTracker(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_die' enabled='1' />");
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void start() {
		// Ersten Apply sofort, nicht erst nach 1 s warten
		applyCapacityWithReservedSlots();
	}

	void update(float time) {
		m_timeAccum += time;
		flushPendingDeaths();

		m_applyAccum += time;
		if (m_applyAccum < APPLY_INTERVAL) return;
		m_applyAccum = 0.0f;

		applyCapacityWithReservedSlots();
	}

	void addPendingDeath(int factionId) {
		string key = "" + factionId;
		int v = 0;
		if (m_pendingDeaths.exists(key)) v = int(m_pendingDeaths[key]);
		m_pendingDeaths[key] = v + 1;
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
			string ts = "";
			if (m_deathTimestamps.exists(key)) ts = string(m_deathTimestamps[key]);
			for (int j = 0; j < n; ++j) {
				if (ts.length() > 0) ts += ",";
				ts += "" + m_timeAccum;
			}
			m_deathTimestamps[key] = ts;
		}
	}

	// Nur zählen, keine Seiteneffekte. Aufräumen separat in pruneDeathTimestamps().
	int getReservedSlots(int factionId) {
		string key = "" + factionId;
		if (!m_deathTimestamps.exists(key)) return 0;
		string s = string(m_deathTimestamps[key]);
		if (s.length() == 0) return 0;
		float now = m_timeAccum;
		int count = 0;
		uint start = 0;
		for (uint i = 0; i <= s.length(); ++i) {
			if (i < s.length() && s.substr(i, 1) != ",") continue;
			string part = s.substr(start, i - start);
			start = i + 1;
			if (part.length() == 0) continue;
			float t = parseFloat(part);
			// Nur gültige Zeitstempel: im Fenster [now-DELAY, now] und sinnvoll (t > 0)
			if (t > 0.0f && t <= now && (now - t) <= RESPAWN_SLOT_DELAY)
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
		string kept = "";
		uint start = 0;
		for (uint i = 0; i <= s.length(); ++i) {
			if (i < s.length() && s.substr(i, 1) != ",") continue;
			string part = s.substr(start, i - start);
			start = i + 1;
			if (part.length() == 0) continue;
			float t = parseFloat(part);
			if (t > 0.0f && t <= now && (now - t) <= RESPAWN_SLOT_DELAY) {
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
