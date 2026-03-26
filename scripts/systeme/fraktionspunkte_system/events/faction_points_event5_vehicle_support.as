#include "helpers.as"
#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_interface.as"

// ============================================================
// EVENT 5 - Medium Vehicle Support
// Cost:        500 FP
// Trigger:     AI spare event + player /event5
// AI condition: none (weight 0.5)
// Exec condition: min. 1 owned base
// Action:      spawns 1 random medium vehicle at a friendly base
// ============================================================

const string FP_EVENT5_TOKEN                 = "event5";
const string FP_EVENT5_NAME                  = "Medium Vehicle Support";
const int    FP_EVENT5_COST                  = 500;
const float  FP_EVENT5_ANNOUNCEMENT_DELAY    = 20.0f;
const string FP_EVENT5_FRIENDLY_ANNOUNCEMENT = "Armoured support arriving in 20 seconds.";
const string FP_EVENT5_FRIENDLY_EXECUTION    = "Armoured vehicle deployed. Push forward!";
const string FP_EVENT5_ENEMY_ANNOUNCEMENT    = "";
const string FP_EVENT5_ENEMY_EXECUTION       = "";

// Zufaelliges Medium-Fahrzeug aus dieser Liste - identisch zu VehicleIntervalSpawn MEDIUM_VEHICLE_KEYS,
// aber vollstaendig isoliert: kein Zugriff auf VehicleIntervalSpawn-State.
const string FP_EVENT5_MEDIUM_KEYS = "humvee.vehicle,wiesel_mk20.vehicle,apc.vehicle,apc_1.vehicle,apc_2.vehicle,vulcan_tank.vehicle,noxe.vehicle,hovercraft.vehicle,sev90.vehicle,radio_jammer.vehicle,m113_tank_acav.vehicle,m113_tank_mortar.vehicle";

// Spawn-Offset vom Basis-Mittelpunkt (identisch zu VehicleIntervalSpawn)
const float FP_EVENT5_OFFSET_XZ = 8.0f;
const float FP_EVENT5_OFFSET_Y  = 5.0f;

// Event5 (AI Event):
// Bedingung: mindestens eine eigene Basis vorhanden.
// Aktion: zufaelliges Medium-Fahrzeug direkt an einer eigenen Basis spawnen (Round-Robin).
// Vollstaendig isoliert - beruehrt keinerlei VehicleIntervalSpawn-State.
class FactionPointsEvent5VehicleSupport : FactionPointsEvent {
	protected Metagame@ m_metagame;
	protected uint m_baseCallIndex = 0;       // Round-Robin-Zaehler fuer Basisauswahl
	protected array<string> m_vehicleKeys;    // geparste Medium-Keys

	FactionPointsEvent5VehicleSupport(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_vehicleKeys = parseKeys(FP_EVENT5_MEDIUM_KEYS);
	}

	string getCommandToken() const { return FP_EVENT5_TOKEN; }
	string getDisplayName()  const { return FP_EVENT5_NAME; }
	int    getCost()         const { return FP_EVENT5_COST; }
	bool   isPlayerEvent()   const { return false; }
	float  getAnnouncementDelaySeconds() const { return FP_EVENT5_ANNOUNCEMENT_DELAY; }
	string getFriendlyAnnouncementText() const { return FP_EVENT5_FRIENDLY_ANNOUNCEMENT; }
	string getFriendlyExecutionText()    const { return FP_EVENT5_FRIENDLY_EXECUTION; }
	string getEnemyAnnouncementText()    const { return FP_EVENT5_ENEMY_ANNOUNCEMENT; }
	string getEnemyExecutionText()       const { return FP_EVENT5_ENEMY_EXECUTION; }

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

		// Zufaelliges Medium-Fahrzeug waehlen
		string vehicleKey = pickRandomVehicleKey();

		// Spawn-Offset wie VehicleIntervalSpawn (verhindert Spawn in Gebaeude-Mitte)
		float angle = float(rand(0, 5)) * 1.047f;
		basePos.m_values[0] += FP_EVENT5_OFFSET_XZ * cos(angle);
		basePos.m_values[1] += FP_EVENT5_OFFSET_Y;
		basePos.m_values[2] += FP_EVENT5_OFFSET_XZ * sin(angle);

		m_metagame.getComms().send(
			"<command class='create_instance' instance_class='vehicle'"
			+ " instance_key='" + vehicleKey + "'"
			+ " position='" + basePos.toString() + "'"
			+ " faction_id='" + factionId + "' />");

		result = "Event5: " + getVehicleDisplayName(vehicleKey) + " deployed at " + baseName + ".";
		return true;
	}

	// Gibt den Namen der naechsten Ziel-Basis zurueck, OHNE den Round-Robin-Zaehler vorzuruecken.
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

	// Sammelt alle eigenen Basen, waehlt per Round-Robin eine aus.
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

	// Zufaelliger Key aus m_vehicleKeys; Fallback auf apc.vehicle wenn Liste leer.
	protected string pickRandomVehicleKey() {
		if (m_vehicleKeys.size() == 0) return "apc.vehicle";
		return m_vehicleKeys[rand(0, int(m_vehicleKeys.size()) - 1)];
	}

	// Anzeigename aus Vehicle-Definition (name-Attribut), Fallback: Key ohne .vehicle
	protected string getVehicleDisplayName(const string &in vehicleKey) {
		string name = getResourceName(m_metagame, vehicleKey, "vehicle");
		if (name.length() > 0) return name;
		int dot = vehicleKey.findFirst(".vehicle");
		string base = (dot >= 0) ? vehicleKey.substr(0, dot) : vehicleKey;
		return base.length() > 0 ? base : "vehicle";
	}

	// Parst eine komma-separierte Key-Liste in ein Array.
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
