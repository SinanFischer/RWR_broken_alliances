// Faction-Alive-HUD-Tracker: Zeigt pro Fraktion "alive / effectiveCap (bases)" in Fraktionsfarbe.
// Format: "42 / 180 (5)" — alive / effective capacity (Anzahl Basen)
// Mit RespawnSlotDelayTracker: effectiveCap = gecachte effektive Kapazität, bases = Basen-Anzahl.
// Ohne Tracker: effectiveCap = rohe soldier_capacity aus Engine, bases entfällt.
// Throttle: max. 1x/s — getCharacters ist ein Engine-Query, sparsam einsetzen.

#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

const float HUD_UPDATE_THROTTLE = 1.0f;  // 1x/s reicht für HUD-Anzeige, spart Engine-Queries

class FactionAliveHudTracker : Tracker {
	protected Metagame@ m_metagame;
	protected RespawnSlotDelayTracker@ m_respawnTracker;  // optional; liefert effectiveCap + bases
	protected float m_accum = 0.0f;

	FactionAliveHudTracker(Metagame@ metagame, RespawnSlotDelayTracker@ respawnTracker = null) {
		@m_metagame = @metagame;
		@m_respawnTracker = respawnTracker;
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void update(float time) {
		m_accum += time;
		if (m_accum < HUD_UPDATE_THROTTLE) return;
		m_accum = 0.0f;

		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;

		for (uint i = 0; i < factions.size(); ++i) {
			int fid = int(i);
			array<const XmlElement@>@ chars = getCharacters(m_metagame, fid);
			int alive = (chars is null) ? 0 : int(chars.size());

			string text = buildHudText(fid, alive);
			string color = getScoreDisplayColor(factions[fid], fid);

			XmlElement cmd("command");
			cmd.setStringAttribute("class", "update_score_display");
			cmd.setIntAttribute("id", fid);
			cmd.setStringAttribute("text", text);
			cmd.setStringAttribute("color", color);
			m_metagame.getComms().send(cmd);
		}
	}

	// Baut den Anzeigetext: "alive / cap (bases)" mit Tracker, sonst nur "alive / rawCap"
	private string buildHudText(int fid, int alive) {
		if (m_respawnTracker !is null) {
			int cap   = m_respawnTracker.getEffectiveCapacityForFaction(fid);
			int bases = m_respawnTracker.getBasesForFactionCached(fid);
			return "" + alive + " / " + cap + " (" + bases + ")";
		}
		// Fallback ohne Tracker: rohe Engine-Capacity
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || fid < 0 || uint(fid) >= factions.size()) return "" + alive;
		int rawCap = factions[fid].getIntAttribute("soldier_capacity");
		return "" + alive + " / " + rawCap;
	}

	string getScoreDisplayColor(const XmlElement@ faction, int factionId) {
		if (faction !is null) {
			string color = faction.getStringAttribute("color");
			if (color.length() > 0) return color;
			string name = faction.getStringAttribute("name").toLowerCase();
			string key  = faction.getStringAttribute("key").toLowerCase();
			if (name.findFirst("green") >= 0 || key.findFirst("green") >= 0 || name.findFirst("united states") >= 0) return "0.0 0.5 0.1";
			if (name.findFirst("grey") >= 0 || name.findFirst("gray") >= 0 || key.findFirst("grey") >= 0 || key.findFirst("gray") >= 0 || name.findFirst("european") >= 0) return "0.3 0.3 0.3";
			if (name.findFirst("brown") >= 0 || key.findFirst("brown") >= 0 || name.findFirst("russian") >= 0) return "0.5 0.35 0.1";
		}
		if (factionId == 0) return "0.0 0.5 0.1";
		if (factionId == 1) return "0.3 0.3 0.3";
		if (factionId == 2) return "0.5 0.35 0.1";
		return "0.5 0.5 0.5";
	}
}
