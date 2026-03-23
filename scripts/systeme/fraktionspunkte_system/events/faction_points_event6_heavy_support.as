#include "helpers.as"
#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_interface.as"

const string FP_EVENT6_TOKEN                 = "event6";
const string FP_EVENT6_NAME                  = "Heavy Vehicle";
const int    FP_EVENT6_COST                  = 1800;
const float  FP_EVENT6_ANNOUNCEMENT_DELAY    = 25.0f;
const string FP_EVENT6_FRIENDLY_ANNOUNCEMENT = "Heavy armour inbound - 25 seconds.";
const string FP_EVENT6_FRIENDLY_EXECUTION    = "Heavy armour deployed. Hold the line!";
const string FP_EVENT6_ENEMY_ANNOUNCEMENT    = "";
const string FP_EVENT6_ENEMY_EXECUTION       = "";

// Heavy-Vehicle-Keys - identisch zu HEAVY_VEHICLE_KEYS in vehicle_interval_spawn.as,
// vollstaendig isoliert: kein Zugriff auf VehicleIntervalSpawn-State.
const string FP_EVENT6_HEAVY_KEYS = "tank_alt.vehicle,tank_1_alt.vehicle,tank_2_alt.vehicle,m551.vehicle,fv101.vehicle,legion.vehicle,m528.vehicle,flamer_tank.vehicle";

// Spawn-Offset vom Basis-Mittelpunkt (identisch zu VehicleIntervalSpawn)
const float FP_EVENT6_OFFSET_XZ = 8.0f;
const float FP_EVENT6_OFFSET_Y  = 5.0f;

// Event6 (AI Event):
// Bedingung: mindestens 4 eigene Basen (> 3).
// Aktion: zufaelliges Heavy-Fahrzeug direkt an einer eigenen Basis spawnen (Round-Robin).
// Vollstaendig isoliert - beruehrt keinerlei VehicleIntervalSpawn-State.
class FactionPointsEvent6HeavySupport : FactionPointsEvent {
	protected Metagame@ m_metagame;
	protected uint m_baseCallIndex = 0;
	protected array<string> m_vehicleKeys;

	FactionPointsEvent6HeavySupport(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_vehicleKeys = parseKeys(FP_EVENT6_HEAVY_KEYS);
	}

	string getCommandToken() const { return FP_EVENT6_TOKEN; }
	string getDisplayName()  const { return FP_EVENT6_NAME; }
	int    getCost()         const { return FP_EVENT6_COST; }
	bool   isPlayerEvent()   const { return false; }
	float  getAnnouncementDelaySeconds() const { return FP_EVENT6_ANNOUNCEMENT_DELAY; }
	string getFriendlyAnnouncementText() const { return FP_EVENT6_FRIENDLY_ANNOUNCEMENT; }
	string getFriendlyExecutionText()    const { return FP_EVENT6_FRIENDLY_EXECUTION; }
	string getEnemyAnnouncementText()    const { return FP_EVENT6_ENEMY_ANNOUNCEMENT; }
	string getEnemyExecutionText()       const { return FP_EVENT6_ENEMY_EXECUTION; }

	bool canExecute(int playerId, int factionId, string &out reason) {
		Vector3 ignored;
		string ignoredName;
		if (!pickOwnedBase(factionId, ignored, ignoredName)) {
			reason = "No friendly base found.";
			return false;
		}
		return true;
	}

	bool execute(int playerId, int factionId, string &out result) {
		Vector3 basePos;
		string baseName;
		if (!pickOwnedBase(factionId, basePos, baseName)) {
			result = "No friendly base found.";
			return false;
		}

		string vehicleKey = pickRandomVehicleKey();

		float angle = float(rand(0, 5)) * 1.047f;
		basePos.m_values[0] += FP_EVENT6_OFFSET_XZ * cos(angle);
		basePos.m_values[1] += FP_EVENT6_OFFSET_Y;
		basePos.m_values[2] += FP_EVENT6_OFFSET_XZ * sin(angle);

		m_metagame.getComms().send(
			"<command class='create_instance' instance_class='vehicle'"
			+ " instance_key='" + vehicleKey + "'"
			+ " position='" + basePos.toString() + "'"
			+ " faction_id='" + factionId + "' />");

		result = "Event6: " + getVehicleDisplayName(vehicleKey) + " deployed at " + baseName + ".";
		return true;
	}

	bool tryGetTargetBaseName(int factionId, string &out baseName) {
		array<const XmlElement@>@ allBases = getBases(m_metagame);
		if (allBases is null || allBases.size() == 0) return false;
		array<const XmlElement@> ownedBases;
		for (uint i = 0; i < allBases.size(); ++i) {
			const XmlElement@ base = allBases[i];
			if (base is null) continue;
			if (base.getIntAttribute("owner_id") != factionId) continue;
			ownedBases.insertLast(base);
		}
		if (ownedBases.size() == 0) return false;
		uint index = m_baseCallIndex % ownedBases.size();
		const XmlElement@ selected = ownedBases[index];
		baseName = selected.getStringAttribute("name");
		if (baseName.length() == 0) baseName = selected.getStringAttribute("key");
		if (baseName.length() == 0) baseName = "base";
		return true;
	}

	protected bool pickOwnedBase(int factionId, Vector3 &out outPos, string &out outName) {
		array<const XmlElement@>@ allBases = getBases(m_metagame);
		if (allBases is null || allBases.size() == 0) return false;

		array<const XmlElement@> ownedBases;
		for (uint i = 0; i < allBases.size(); ++i) {
			const XmlElement@ base = allBases[i];
			if (base is null) continue;
			if (base.getIntAttribute("owner_id") != factionId) continue;
			ownedBases.insertLast(base);
		}
		if (ownedBases.size() == 0) return false;

		uint index = (m_baseCallIndex++) % ownedBases.size();
		const XmlElement@ selected = ownedBases[index];
		outPos = stringToVector3(selected.getStringAttribute("position"));
		outName = selected.getStringAttribute("name");
		if (outName.length() == 0) outName = selected.getStringAttribute("key");
		if (outName.length() == 0) outName = "base";
		return true;
	}

	protected string pickRandomVehicleKey() {
		if (m_vehicleKeys.size() == 0) return "tank_alt.vehicle";
		return m_vehicleKeys[rand(0, int(m_vehicleKeys.size()) - 1)];
	}

	protected string getVehicleDisplayName(const string &in vehicleKey) {
		string name = getResourceName(m_metagame, vehicleKey, "vehicle");
		if (name.length() > 0) return name;
		int dot = vehicleKey.findFirst(".vehicle");
		string base = (dot >= 0) ? vehicleKey.substr(0, dot) : vehicleKey;
		return base.length() > 0 ? base : "vehicle";
	}

	protected array<string> parseKeys(const string &in csv) {
		array<string> result;
		int start = 0;
		for (uint i = 0; i <= csv.length(); ++i) {
			if (i == csv.length() || csv.substr(i, 1) == ",") {
				string part = csv.substr(start, int(i) - start);
				if (part.length() > 0) result.insertLast(part);
				start = int(i) + 1;
			}
		}
		return result;
	}
}
