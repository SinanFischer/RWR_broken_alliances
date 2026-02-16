#include "helpers.as"
#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_interface.as"

const string FP_EVENT2_TOKEN = "event2";
const string FP_EVENT2_NAME = "Company-Angriff";
const int FP_EVENT2_COST = 1200;
const string FP_EVENT2_PLATOON_CALL_KEY = "paratroopers2.call";
const int FP_EVENT2_PLATOON_COUNT = 2;
const float FP_EVENT2_CALL_SPACING = 8.0f;

// Event2 (AI Event):
// Bedingung: gueltige Zielbasis vorhanden.
// Aktion: 2x Platoon-Call an naechster gegnerischer Basis.
class FactionPointsEvent2CompanyAttack : FactionPointsEvent {
	protected Metagame@ m_metagame;

	FactionPointsEvent2CompanyAttack(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	string getCommandToken() const { return FP_EVENT2_TOKEN; }
	string getDisplayName() const { return FP_EVENT2_NAME; }
	int getCost() const { return FP_EVENT2_COST; }
	bool isPlayerEvent() const { return false; }

	bool canExecute(int playerId, int factionId, string &out reason) {
		Vector3 refPos;
		if (!getReferencePositionForFaction(factionId, refPos)) {
			reason = "Keine Referenzposition fuer Fraktion gefunden.";
			return false;
		}

		const XmlElement@ targetBase = getClosestEnemyBase(factionId, refPos);
		if (targetBase is null) {
			reason = "Keine gegnerische Basis gefunden.";
			return false;
		}
		return true;
	}

	bool execute(int playerId, int factionId, string &out result) {
		Vector3 refPos;
		if (!getReferencePositionForFaction(factionId, refPos)) {
			result = "Keine Referenzposition fuer Fraktion gefunden.";
			return false;
		}

		const XmlElement@ targetBase = getClosestEnemyBase(factionId, refPos);
		if (targetBase is null) {
			result = "Keine gegnerische Basis gefunden.";
			return false;
		}

		Vector3 basePos = stringToVector3(targetBase.getStringAttribute("position"));
		for (int i = 0; i < FP_EVENT2_PLATOON_COUNT; ++i) {
			Vector3 callPos = basePos;
			callPos.m_values[0] += (i == 0) ? -FP_EVENT2_CALL_SPACING : FP_EVENT2_CALL_SPACING;

			string cmd = "<command class='create_instance' instance_class='call' instance_key='" + FP_EVENT2_PLATOON_CALL_KEY +
				"' position='" + callPos.toString() + "' faction_id='" + factionId + "' />";
			m_metagame.getComms().send(cmd);
		}

		string baseName = targetBase.getStringAttribute("name");
		if (baseName.length() == 0) baseName = targetBase.getStringAttribute("key");
		if (baseName.length() == 0) baseName = "target base";

		result = "Event2 ausgefuehrt: 2 Platoons an Basis " + baseName + ".";
		return true;
	}

	protected const XmlElement@ getClosestEnemyBase(int factionId, const Vector3 &in playerPos) {
		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (bases is null || bases.size() == 0) return null;

		const XmlElement@ best = null;
		float bestDistance = -1.0f;

		for (uint i = 0; i < bases.size(); ++i) {
			const XmlElement@ base = bases[i];
			if (base is null) continue;
			if (!base.getBoolAttribute("capturable")) continue;

			int ownerId = base.getIntAttribute("owner_id");
			if (ownerId < 0 || ownerId == factionId) continue;

			Vector3 bpos = stringToVector3(base.getStringAttribute("position"));
			float distance = getPositionDistance(playerPos, bpos);
			if (bestDistance < 0.0f || distance < bestDistance) {
				bestDistance = distance;
				@best = base;
			}
		}

		return best;
	}

	protected bool getReferencePositionForFaction(int factionId, Vector3 &out outPos) {
		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (bases is null || bases.size() == 0) return false;

		for (uint i = 0; i < bases.size(); ++i) {
			const XmlElement@ base = bases[i];
			if (base is null) continue;
			if (base.getIntAttribute("owner_id") != factionId) continue;
			outPos = stringToVector3(base.getStringAttribute("position"));
			return true;
		}

		for (uint i = 0; i < bases.size(); ++i) {
			const XmlElement@ base = bases[i];
			if (base is null) continue;
			outPos = stringToVector3(base.getStringAttribute("position"));
			return true;
		}

		return false;
	}
}

