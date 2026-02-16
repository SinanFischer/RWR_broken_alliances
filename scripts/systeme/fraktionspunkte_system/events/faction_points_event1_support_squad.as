#include "helpers.as"
#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_interface.as"

const string FP_EVENT1_TOKEN = "event1";
const string FP_EVENT1_NAME = "Support-Ausflug";
const int FP_EVENT1_COST = 250;
const string FP_EVENT1_CALL_KEY = "paratroopers1.call";
const int FP_EVENT1_SQUAD_HALF_THRESHOLD = 2;
const float FP_EVENT1_PLAYER_OFFSET_X = 6.0f;
const float FP_EVENT1_PLAYER_OFFSET_Z = 3.0f;

// Event1 (PlayerEvent):
// Bedingung: Spieler hat squad_size <= 2 (als "haelfte gefuellt").
// Aktion: Support-Call an Spielerposition.
class FactionPointsEvent1SupportSquad : FactionPointsEvent {
	protected Metagame@ m_metagame;

	FactionPointsEvent1SupportSquad(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	string getCommandToken() const { return FP_EVENT1_TOKEN; }
	string getDisplayName() const { return FP_EVENT1_NAME; }
	int getCost() const { return FP_EVENT1_COST; }
	bool isPlayerEvent() const { return true; }

	bool canExecute(int playerId, int factionId, string &out reason) {
		if (playerId < 0) {
			reason = "Player-Event benoetigt gueltigen player_id.";
			return false;
		}
		const XmlElement@ playerInfo = getPlayerInfo(m_metagame, playerId);
		if (playerInfo is null) {
			reason = "Player nicht gefunden.";
			return false;
		}

		const XmlElement@ characterInfo = getCharacterInfo(m_metagame, playerInfo.getIntAttribute("character_id"));
		if (characterInfo is null) {
			reason = "Kein Character (tot/spectator).";
			return false;
		}

		int squadSize = characterInfo.getIntAttribute("squad_size");
		if (squadSize > FP_EVENT1_SQUAD_HALF_THRESHOLD) {
			reason = "Bedingung nicht erfuellt: squad_size=" + squadSize + " > " + FP_EVENT1_SQUAD_HALF_THRESHOLD + ".";
			return false;
		}

		return true;
	}

	bool execute(int playerId, int factionId, string &out result) {
		if (playerId < 0) {
			result = "Player-Event benoetigt gueltigen player_id.";
			return false;
		}
		const XmlElement@ playerInfo = getPlayerInfo(m_metagame, playerId);
		if (playerInfo is null) {
			result = "Player nicht gefunden.";
			return false;
		}

		const XmlElement@ characterInfo = getCharacterInfo(m_metagame, playerInfo.getIntAttribute("character_id"));
		if (characterInfo is null) {
			result = "Kein Character (tot/spectator).";
			return false;
		}

		Vector3 pos = stringToVector3(characterInfo.getStringAttribute("position"));
		pos.m_values[0] += FP_EVENT1_PLAYER_OFFSET_X;
		pos.m_values[2] += FP_EVENT1_PLAYER_OFFSET_Z;

		string cmd = "<command class='create_instance' instance_class='call' instance_key='" + FP_EVENT1_CALL_KEY +
			"' position='" + pos.toString() + "' faction_id='" + factionId + "' />";
		m_metagame.getComms().send(cmd);

		result = "Event1 ausgefuehrt: Support-Call nahe Spielerposition.";
		return true;
	}
}

