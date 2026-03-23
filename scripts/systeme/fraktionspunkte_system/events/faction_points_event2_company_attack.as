#include "helpers.as"
#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_interface.as"

// ============================================================
// EVENT 2 - Company Attack
// Cost:        1200 FP
// Trigger:     AI spare event + player /event2
// AI condition: none (weight 0.2)
// Exec condition: min. 1 owned base as attack target
// Action:      2x paratroopers2 outside an enemy base
// ============================================================

const string FP_EVENT2_TOKEN = "event2";
const string FP_EVENT2_NAME = "Company Attack";
const int FP_EVENT2_COST = 1200;
const string FP_EVENT2_PLATOON_CALL_KEY = "paratroopers2.call";
const int FP_EVENT2_PLATOON_COUNT = 2;
const float FP_EVENT2_OUTSIDE_RADIUS = 42.0f;
const float FP_EVENT2_ANNOUNCEMENT_DELAY = 60.0f;
const string FP_EVENT2_FRIENDLY_ANNOUNCEMENT = "Airborne assault assigned. Drop in 60 seconds.";
const string FP_EVENT2_FRIENDLY_EXECUTION = "Airborne on the deck. Take the objective.";
const string FP_EVENT2_ENEMY_ANNOUNCEMENT = "Hostile airborne inbound. Sixty seconds.";
const string FP_EVENT2_ENEMY_EXECUTION = "Hostile airborne on the ground in your sector.";

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
	float getAnnouncementDelaySeconds() const { return FP_EVENT2_ANNOUNCEMENT_DELAY; }
	string getFriendlyAnnouncementText() const { return FP_EVENT2_FRIENDLY_ANNOUNCEMENT; }
	string getFriendlyExecutionText() const { return FP_EVENT2_FRIENDLY_EXECUTION; }
	string getEnemyAnnouncementText() const { return FP_EVENT2_ENEMY_ANNOUNCEMENT; }
	string getEnemyExecutionText() const { return FP_EVENT2_ENEMY_EXECUTION; }

	bool tryGetTargetBaseName(int factionId, string &out baseName) {
		baseName = "";
		Vector3 refPos;
		if (!getReferencePositionForFaction(factionId, refPos)) return false;
		const XmlElement@ targetBase = getClosestEnemyBase(factionId, refPos);
		if (targetBase is null) return false;
		baseName = getBaseLabel(targetBase);
		return baseName.length() > 0;
	}

	bool canExecute(int playerId, int factionId, string &out reason) {
		Vector3 refPos;
		if (!getReferencePositionForFaction(factionId, refPos)) {
			reason = "No reference position found for faction.";
			return false;
		}

		const XmlElement@ targetBase = getClosestEnemyBase(factionId, refPos);
		if (targetBase is null) {
			reason = "No enemy base found.";
			return false;
		}
		return true;
	}

	bool execute(int playerId, int factionId, string &out result) {
		Vector3 refPos;
		if (!getReferencePositionForFaction(factionId, refPos)) {
			result = "No reference position found for faction.";
			return false;
		}

		const XmlElement@ targetBase = getClosestEnemyBase(factionId, refPos);
		if (targetBase is null) {
			result = "No enemy base found.";
			return false;
		}

		Vector3 basePos = stringToVector3(targetBase.getStringAttribute("position"));
		float dx = basePos.m_values[0] - refPos.m_values[0];
		float dz = basePos.m_values[2] - refPos.m_values[2];
		float length2d = sqrt(dx * dx + dz * dz);
		float dirX = 1.0f;
		float dirZ = 0.0f;
		if (length2d > 0.01f) {
			dirX = dx / length2d;
			dirZ = dz / length2d;
		}
		float sideX = -dirZ;
		float sideZ = dirX;

		for (int i = 0; i < FP_EVENT2_PLATOON_COUNT; ++i) {
			Vector3 callPos = basePos;
			float sideMul = (i == 0) ? -1.0f : 1.0f;
			callPos.m_values[0] += sideX * (FP_EVENT2_OUTSIDE_RADIUS * sideMul);
			callPos.m_values[2] += sideZ * (FP_EVENT2_OUTSIDE_RADIUS * sideMul);
			callPos.m_values[0] += dirX * FP_EVENT2_OUTSIDE_RADIUS;
			callPos.m_values[2] += dirZ * FP_EVENT2_OUTSIDE_RADIUS;

			string cmd = "<command class='create_instance' instance_class='call' instance_key='" + FP_EVENT2_PLATOON_CALL_KEY +
				"' position='" + callPos.toString() + "' faction_id='" + factionId + "' />";
			m_metagame.getComms().send(cmd);
		}

		string baseName = getBaseLabel(targetBase);

		result = "Event2 executed: 2 platoons at base " + baseName + ".";
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

	protected string getBaseLabel(const XmlElement@ base) const {
		if (base is null) return "target base";
		string baseName = base.getStringAttribute("name");
		if (baseName.length() == 0) baseName = base.getStringAttribute("key");
		if (baseName.length() == 0) baseName = "target base";
		return baseName;
	}
}

