// Test 1: Schatten-Call + call_event
// Test 10: Rang + Nachname in Meldung (Rang aus XP, Name aus Soldat/Fallback)
// Reagiert auf cover_drop.call (notify_metagame); zeigt Player/Character-Info + "Rang Nachname".

#include "tracker.as"
#include "helpers.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"

// Rang-Tabelle wie grey.xml: größtes xp <= character.xp → name (KISS, keine XML-Parse)
const array<float> RANK_XP = { 0.0f, 0.05f, 0.1f, 0.2f, 0.3f, 0.4f, 0.6f, 0.8f, 1.0f, 1.2f, 1.4f, 2.0f, 5.0f, 10.0f, 20.0f, 50.0f, 100.0f };
const array<string> RANK_NAMES = {
	"Private", "Private 1st Class", "Corporal", "Sergeant", "Staff Sergeant", "Staff Sergeant 1st Class",
	"2nd Lieutenant", "Lieutenant", "Captain", "Major", "Lieutenant Colonel", "Colonel",
	"Brigadier General", "Major General", "Lieutenant General", "General", "General of the Army"
};

string getRankNameForXp(float xp) {
	string name = "Private";
	for (uint i = 0; i < RANK_XP.length(); ++i) {
		if (xp >= RANK_XP[i])
			name = RANK_NAMES[i];
		else
			break;
	}
	return name;
}

// Nachname: aus "Vorname Nachname" letztes Wort; aus einem Wort das Wort; leer → Fallback
string getLastWord(string s) {
	s = s.trim();
	if (s.length() == 0) return "";
	array<string> parts = s.split(" ");
	if (parts.length() == 0) return "";
	return parts[parts.length() - 1];
}

class CoverDropTestTracker : Tracker {
	protected Metagame@ m_metagame;

	CoverDropTestTracker(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	protected void handleCallEvent(const XmlElement@ event) {
		string key = event.getStringAttribute("call_key");
		string phase = event.getStringAttribute("phase");

		if (key != "cover_drop.call")
			return;

		// queue = Spieler hat Call angefordert (Ziel geklickt); bei leerem round evtl. nur "launch"
		if (phase == "queue" || phase == "launch") {
			int characterId = event.getIntAttribute("character_id");
			int factionId = event.getIntAttribute("faction_id");
			string targetPosition = event.getStringAttribute("target_position");

			// Player-ID aus character_id ermitteln
			int playerId = -1;
			array<const XmlElement@>@ players = getPlayers(m_metagame);
			for (uint i = 0; i < players.size(); ++i) {
				if (players[i].getIntAttribute("character_id") == characterId) {
					playerId = players[i].getIntAttributeCoverDropTest("player_id");
					break;
				}
			}

			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, playerId);
			const XmlElement@ characterInfo = getCharacterInfo(m_metagame, characterId);

			string playerName = playerInfo !is null ? playerInfo.getStringAttribute("name") : "?";
			float xp = characterInfo !is null ? characterInfo.getFloatAttribute("xp") : 0.0f;

			// --- Test 10: Rang + Nachname ---
			string rankName = getRankNameForXp(xp);
			string soldierName = "Soldier";
			if (characterInfo !is null) {
				if (characterInfo.hasAttribute("name")) {
					string n = characterInfo.getStringAttribute("name");
					if (n.length() > 0) { string last = getLastWord(n); if (last.length() > 0) soldierName = last; }
				}
				if (soldierName == "Soldier" && characterInfo.hasAttribute("comment")) {
					string c = characterInfo.getStringAttribute("comment");
					if (c.length() > 0) { string last = getLastWord(c); if (last.length() > 0) soldierName = last; }
				}
			}
			if (soldierName == "Soldier" && playerName.length() > 0) {
				string last = getLastWord(playerName);
				if (last.length() > 0) soldierName = last;
			}
			string rangNachname = rankName + " " + soldierName;

			// Sichtbar: Test 1 + Test 10 in einer Meldung
			string msg = "Test 1+10 OK - Cover Drop. Rang+Name: \"" + rangNachname + "\". char=" + characterId + " player=" + playerId + " xp=" + xp + " pos=" + targetPosition;
			sendFactionMessage(m_metagame, factionId, msg, 1.0f);

			_log("CoverDropTest: " + msg, 0);
		}
	}
}
