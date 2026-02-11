// Faction-Kills-HUD-Tracker: Zeigt die Kills pro Fraktion (EU, UN, RU) live in der Score-Display-Anzeige unten an.
// character_kill Events werden gezählt; killer.faction_id bestimmt, welche Fraktion den Kill gutgeschrieben bekommt.
// Die Statistiken-Tabelle (Taste für Stats) ist engine-intern und kann nicht erweitert werden – diese HUD-Anzeige ist die Alternative.

#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

const float HUD_UPDATE_THROTTLE = 0.5f;  // Anzeige max. 2x/s aktualisieren

class FactionKillsHudTracker : Tracker {
	protected Metagame@ m_metagame;
	protected float m_accum = 0.0f;
	protected array<int> m_kills;

	FactionKillsHudTracker(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_kills = array<int>();
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void start() {
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
		m_accum = HUD_UPDATE_THROTTLE;  // erste Anzeige sofort
	}

	void handleCharacterKillEvent(const XmlElement@ event) {
		const XmlElement@ killer = event.getFirstElementByTagName("killer");
		if (killer is null) return;

		int factionId = killer.getIntAttribute("faction_id");
		if (factionId < 0) return;

		// Array bei Bedarf erweitern
		while (int(m_kills.size()) <= factionId) {
			m_kills.insertLast(0);
		}
		m_kills[factionId] += 1;
	}

	void update(float time) {
		m_accum += time;
		if (m_accum < HUD_UPDATE_THROTTLE) return;
		m_accum = 0.0f;

		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;

		for (uint i = 0; i < factions.size(); ++i) {
			int factionId = int(i);
			int kills = (factionId < int(m_kills.size())) ? m_kills[factionId] : 0;
			string color = getScoreDisplayColor(factions[factionId], factionId);

			// EU (id 0), UN (id 1), RU (id 2) – Reihenfolge gemäß my_stage_configurator
			string label = getFactionLabel(factionId);
			string text = (label.length() > 0) ? (label + ": " + kills) : ("" + kills);

			XmlElement cmd("command");
			cmd.setStringAttribute("class", "update_score_display");
			cmd.setIntAttribute("id", factionId);
			cmd.setStringAttribute("text", text);
			cmd.setStringAttribute("color", color);
			m_metagame.getComms().send(cmd);
		}
	}

	string getFactionLabel(int factionId) {
		if (factionId == 0) return "EU";
		if (factionId == 1) return "UN";
		if (factionId == 2) return "RU";
		return "";
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
