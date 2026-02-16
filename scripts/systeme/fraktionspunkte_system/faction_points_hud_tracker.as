#include "tracker.as"
#include "metagame.as"
#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/faction_points_store.as"

const float FP_HUD_UPDATE_THROTTLE = 0.5f;
const int FP_HUD_MAX_FACTIONS = 3;

// HUD-Tracker (HUD = UI-Anzeige der Fraktionswerte unten).
// Nutzt update_score_display analog bestehender Anzeigen.
class FactionPointsHudTracker : Tracker {
	protected Metagame@ m_metagame;
	protected FactionPointsStore@ m_store;
	protected float m_accum = 0.0f;

	FactionPointsHudTracker(Metagame@ metagame, FactionPointsStore@ store) {
		@m_metagame = @metagame;
		@m_store = @store;
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void update(float time) {
		if (m_store is null) return;

		m_accum += time;
		if (m_accum < FP_HUD_UPDATE_THROTTLE) return;
		m_accum = 0.0f;

		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;

		int shown = int(factions.size());
		if (shown > FP_HUD_MAX_FACTIONS) shown = FP_HUD_MAX_FACTIONS;

		// Dynamisch aus getFactions ziehen: keine feste ID-/Ordner-Annahme.
		for (int slotIndex = 0; slotIndex < shown; ++slotIndex) {
			const XmlElement@ faction = factions[slotIndex];
			string color = getScoreDisplayColor(faction);
			int points = m_store.get(slotIndex);

			XmlElement cmd("command");
			cmd.setStringAttribute("class", "update_score_display");
			cmd.setIntAttribute("id", slotIndex);
			cmd.setStringAttribute("text", "FP " + points);
			cmd.setStringAttribute("color", color);
			m_metagame.getComms().send(cmd);
		}
	}

	string getScoreDisplayColor(const XmlElement@ faction) {
		if (faction !is null) {
			string color = faction.getStringAttribute("color");
			if (color.length() > 0) return color;

			// Fallback ueber Namen/Key statt fester Faction-ID.
			string name = faction.getStringAttribute("name").toLowerCase();
			string key = faction.getStringAttribute("key").toLowerCase();
			if (name.findFirst("green") >= 0 || key.findFirst("green") >= 0 || name.findFirst("greenbelt") >= 0 || name.findFirst("united states") >= 0) return "0.0 0.5 0.1";
			if (name.findFirst("grey") >= 0 || name.findFirst("gray") >= 0 || key.findFirst("grey") >= 0 || key.findFirst("gray") >= 0 || name.findFirst("european") >= 0 || name.findFirst("graycollar") >= 0) return "0.3 0.3 0.3";
			if (name.findFirst("brown") >= 0 || key.findFirst("brown") >= 0 || name.findFirst("russian") >= 0 || name.findFirst("brownpants") >= 0) return "0.5 0.35 0.1";
		}
		return "0.5 0.5 0.5";
	}
}

