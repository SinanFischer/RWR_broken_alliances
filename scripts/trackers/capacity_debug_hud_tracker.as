// Capacity-Debug-HUD: Zeigt pro Fraktion "Alive/Capacity" (GesamtAliveAufDerKarte / effektive SoldatenCapacity).
// Nur für Test: Prüfen ob Respawn-Slot-Delay-Logik greift (Capacity sollte nach Toden sinken).
// Einbindung: NUR wenn RespawnSlotDelayTracker genutzt wird. RespawnTracker zuerst erstellen, dann diesen mit Referenz.
// Normalbetrieb (nur Alive auf 150m): FactionAliveHudTracker(this) ohne diesen Tracker.
//
// Darstellung: für jede Fraktion ein HUD-Element mit Fraktionsfarbe, Text "alive/capacity".

#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

const float CAPACITY_DEBUG_UPDATE_THROTTLE = 1.0f;  // 1x pro Sekunde (wie Apply-Intervall des Respawn-Trackers)

class CapacityDebugHudTracker : Tracker {
	protected Metagame@ m_metagame;
	protected RespawnSlotDelayTracker@ m_respawnTracker;
	protected float m_accum = 0.0f;

	CapacityDebugHudTracker(Metagame@ metagame, RespawnSlotDelayTracker@ respawnTracker) {
		@m_metagame = metagame;
		@m_respawnTracker = respawnTracker;
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void update(float time) {
		if (m_respawnTracker is null) return;
		m_accum += time;
		if (m_accum < CAPACITY_DEBUG_UPDATE_THROTTLE) return;
		m_accum = 0.0f;

		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;

		for (uint i = 0; i < factions.size(); ++i) {
			int factionId = int(i);
			int alive = getAliveCountGlobal(factionId);
			int capacity = m_respawnTracker.getEffectiveCapacityForFaction(factionId);
			string color = getScoreDisplayColor(factions[factionId], factionId);
			string text = "" + alive + "/" + capacity;

			XmlElement cmd("command");
			cmd.setStringAttribute("class", "update_score_display");
			cmd.setIntAttribute("id", factionId);
			cmd.setStringAttribute("text", text);
			cmd.setStringAttribute("color", color);
			m_metagame.getComms().send(cmd);
		}
	}

	int getAliveCountGlobal(int factionId) {
		array<const XmlElement@>@ chars = getCharacters(m_metagame, factionId);
		return (chars is null) ? 0 : int(chars.size());
	}

	string getScoreDisplayColor(const XmlElement@ faction, int factionId) {
		if (faction !is null) {
			string color = faction.getStringAttribute("color");
			if (color.length() > 0) return color;
			string name = faction.getStringAttribute("name").toLowerCase();
			string key = faction.getStringAttribute("key").toLowerCase();
			if (name.findFirst("green") >= 0 || key.findFirst("green") >= 0 || name.findFirst("greenbelt") >= 0 || name.findFirst("united states") >= 0) return "0.0 0.5 0.1";
			if (name.findFirst("grey") >= 0 || name.findFirst("gray") >= 0 || key.findFirst("grey") >= 0 || key.findFirst("gray") >= 0 || name.findFirst("european") >= 0 || name.findFirst("graycollar") >= 0) return "0.3 0.3 0.3";
			if (name.findFirst("brown") >= 0 || key.findFirst("brown") >= 0 || name.findFirst("russian") >= 0 || name.findFirst("brownpants") >= 0) return "0.5 0.35 0.1";
		}
		if (factionId == 0) return "0.0 0.5 0.1";
		if (factionId == 1) return "0.3 0.3 0.3";
		if (factionId == 2) return "0.5 0.35 0.1";
		return "0.5 0.5 0.5";
	}
}
