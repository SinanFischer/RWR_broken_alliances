// Faction-Alive-HUD-Tracker: Zeigt die Anzahl lebender Soldaten pro Fraktion in der HUD-Anzeige unten an.
// Optional nur in der "Area" um den Spieler (Radius AREA_RADIUS), sonst globaler Fallback.
// Fraktion wird durch Farbe der Schrift gekennzeichnet (update_score_display). Keine Pool-/Spawn-Logik.

#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

const float HUD_UPDATE_THROTTLE = 0.5f;  // Anzeige max. 2x/s aktualisieren (getCharacters ist Engine-Query)
const float AREA_RADIUS = 200.0f;        // Radius um Spielerposition für "Alive in Area" (Meter)
const bool USE_AREA_COUNT = true;        // true = nur Soldaten in Spieler-Area zählen, false = global wie bisher

class FactionAliveHudTracker : Tracker {
	protected Metagame@ m_metagame;
	protected float m_accum = 0.0f;

	FactionAliveHudTracker(Metagame@ metagame) {
		@m_metagame = @metagame;
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
			int factionId = int(i);
			int alive = getAliveCountForFaction(factionId);
			string color = getScoreDisplayColor(factions[factionId], factionId);

			XmlElement cmd("command");
			cmd.setStringAttribute("class", "update_score_display");
			cmd.setIntAttribute("id", factionId);
			cmd.setStringAttribute("text", "" + alive);
			cmd.setStringAttribute("color", color);
			m_metagame.getComms().send(cmd);
		}
	}

	// Liefert Spielerposition des ersten Spielers mit gültigem character_id, sonst null (Fallback auf Global).
	bool getLocalPlayerPosition(Vector3 &out position) {
		array<const XmlElement@>@ players = getPlayers(m_metagame);
		if (players is null || players.size() == 0) return false;
		for (uint i = 0; i < players.size(); ++i) {
			int characterId = players[i].getIntAttribute("character_id");
			if (characterId < 0) continue;
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			if (character is null) continue;
			string posStr = character.getStringAttribute("position");
			if (posStr.length() == 0) continue;
			position = stringToVector3(posStr);
			return true;
		}
		return false;
	}

	int getAliveCountForFaction(int factionId) {
		if (USE_AREA_COUNT) {
			Vector3 playerPos;
			if (getLocalPlayerPosition(playerPos)) {
				array<const XmlElement@>@ chars = getCharactersNearPosition(m_metagame, playerPos, factionId, AREA_RADIUS);
				return (chars is null) ? 0 : int(chars.size());
			}
		}
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
