#include "helpers.as"
#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_interface.as"
#include "systeme/fraktionspunkte_system/events/faction_points_defense_state.as"

const string FP_EVENT3_TOKEN = "event3";
const string FP_EVENT3_SIM_TOKEN = "event3_sim";
const string FP_EVENT3_NAME = "Defense-Response";
const int FP_EVENT3_COST = 700;
const string FP_EVENT3_CALL_KEY = "paratroopers1.call";
const int FP_EVENT3_CALL_COUNT = 3;
const float FP_EVENT3_RING_RADIUS = 42.0f;
const float FP_EVENT3_ANNOUNCEMENT_DELAY = 20.0f;
const string FP_EVENT3_FRIENDLY_ANNOUNCEMENT = "Defense response authorized. Reinforcements arrive in 20 seconds.";
const string FP_EVENT3_FRIENDLY_EXECUTION = "Defense response is active. Hold the perimeter.";
const string FP_EVENT3_ENEMY_ANNOUNCEMENT = "Prepare to defend. Enemy reinforcements expected in 20 seconds.";
const string FP_EVENT3_ENEMY_EXECUTION = "Prepare to defend. Enemy reinforcements have arrived.";

// Event3 (AI Event):
// Bedingung: Fraktion hat kuerzlich eine Basis verloren.
// Aktion: 3 Squad-Calls seitlich/ausserhalb der verlorenen Basis.
class FactionPointsEvent3DefenseResponse : FactionPointsEvent {
	protected Metagame@ m_metagame;

	FactionPointsEvent3DefenseResponse(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	string getCommandToken() const { return FP_EVENT3_TOKEN; }
	string getDisplayName() const { return FP_EVENT3_NAME; }
	int getCost() const { return FP_EVENT3_COST; }
	bool isPlayerEvent() const { return false; }
	float getAnnouncementDelaySeconds() const { return FP_EVENT3_ANNOUNCEMENT_DELAY; }
	string getFriendlyAnnouncementText() const { return FP_EVENT3_FRIENDLY_ANNOUNCEMENT; }
	string getFriendlyExecutionText() const { return FP_EVENT3_FRIENDLY_EXECUTION; }
	string getEnemyAnnouncementText() const { return FP_EVENT3_ENEMY_ANNOUNCEMENT; }
	string getEnemyExecutionText() const { return FP_EVENT3_ENEMY_EXECUTION; }

	bool canExecute(int playerId, int factionId, string &out reason) {
		int lostBaseId = -1;
		if (!fpDefensePeekLostBase(factionId, lostBaseId)) {
			reason = "Keine kuerzlich verlorene Basis registriert.";
			return false;
		}

		const XmlElement@ lostBase = getBase(m_metagame, lostBaseId);
		if (lostBase is null) {
			reason = "Verlorene Basis nicht gefunden.";
			return false;
		}
		return true;
	}

	bool execute(int playerId, int factionId, string &out result) {
		int lostBaseId = -1;
		if (!fpDefenseConsumeLostBase(factionId, lostBaseId)) {
			result = "Keine kuerzlich verlorene Basis registriert.";
			return false;
		}

		const XmlElement@ lostBase = getBase(m_metagame, lostBaseId);
		if (lostBase is null) {
			result = "Verlorene Basis nicht gefunden.";
			return false;
		}

		Vector3 basePos = stringToVector3(lostBase.getStringAttribute("position"));
		spawnDefenseCallsAroundBase(basePos, factionId);

		string baseName = lostBase.getStringAttribute("name");
		if (baseName.length() == 0) baseName = lostBase.getStringAttribute("key");
		if (baseName.length() == 0) baseName = "lost base";
		result = "Event3 ausgefuehrt: 3 Defense-Squads bei Basis " + baseName + ".";
		return true;
	}

	bool simulateAtFriendlyBase(int factionId, string &out result) {
		if (factionId < 0) {
			result = "Ungueltige Fraktion.";
			return false;
		}

		const XmlElement@ base = getFriendlyBase(factionId);
		if (base is null) {
			result = "Keine verbuendete Basis gefunden.";
			return false;
		}

		Vector3 basePos = stringToVector3(base.getStringAttribute("position"));
		spawnDefenseCallsAroundBase(basePos, factionId);

		string baseName = base.getStringAttribute("name");
		if (baseName.length() == 0) baseName = base.getStringAttribute("key");
		if (baseName.length() == 0) baseName = "friendly base";
		result = "Event3 Simulation: 3 Defense-Squads bei Basis " + baseName + ".";
		return true;
	}

	bool tryGetLostBaseName(int factionId, string &out baseName) {
		baseName = "";
		int lostBaseId = -1;
		if (!fpDefensePeekLostBase(factionId, lostBaseId)) return false;
		const XmlElement@ lostBase = getBase(m_metagame, lostBaseId);
		if (lostBase is null) return false;

		baseName = lostBase.getStringAttribute("name");
		if (baseName.length() == 0) baseName = lostBase.getStringAttribute("key");
		return baseName.length() > 0;
	}

	protected void spawnDefenseCallsAroundBase(const Vector3 &in basePos, int factionId) {
		array<Vector3> offsets = {
			Vector3(FP_EVENT3_RING_RADIUS, 0.0f, 0.0f),
			Vector3(-FP_EVENT3_RING_RADIUS, 0.0f, 0.0f),
			Vector3(0.0f, 0.0f, FP_EVENT3_RING_RADIUS)
		};

		for (uint i = 0; i < offsets.size() && i < FP_EVENT3_CALL_COUNT; ++i) {
			Vector3 callPos = basePos;
			callPos.m_values[0] += offsets[i].m_values[0];
			callPos.m_values[1] += offsets[i].m_values[1];
			callPos.m_values[2] += offsets[i].m_values[2];
			sendCallAt(callPos, factionId, FP_EVENT3_CALL_KEY);
		}
	}

	protected void sendCallAt(const Vector3 &in pos, int factionId, const string &in callKey) {
		string cmd = "<command class='create_instance' instance_class='call' instance_key='" + callKey +
			"' position='" + pos.toString() + "' faction_id='" + factionId + "' />";
		m_metagame.getComms().send(cmd);
	}

	protected const XmlElement@ getFriendlyBase(int factionId) {
		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (bases is null || bases.size() == 0) return null;

		for (uint i = 0; i < bases.size(); ++i) {
			const XmlElement@ base = bases[i];
			if (base is null) continue;
			if (!base.getBoolAttribute("capturable")) continue;
			if (base.getIntAttribute("owner_id") == factionId) return base;
		}
		return null;
	}
}
