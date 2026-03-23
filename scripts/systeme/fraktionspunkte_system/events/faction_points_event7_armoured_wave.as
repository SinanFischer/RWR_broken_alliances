#include "helpers.as"
#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_interface.as"

const string FP_EVENT7_TOKEN                 = "event7";
const string FP_EVENT7_NAME                  = "Armoured Wave";
const int    FP_EVENT7_COST                  = 1500;
const float  FP_EVENT7_ANNOUNCEMENT_DELAY    = 20.0f;
const string FP_EVENT7_FRIENDLY_ANNOUNCEMENT = "Armoured wave incoming — 20 seconds.";
const string FP_EVENT7_FRIENDLY_EXECUTION    = "Three armoured vehicles deployed. Push!";
const string FP_EVENT7_ENEMY_ANNOUNCEMENT    = "";
const string FP_EVENT7_ENEMY_EXECUTION       = "";

// Abstand zwischen den drei Einzel-Spawns in Sekunden.
const float FP_EVENT7_SPAWN_INTERVAL = 2.0f;
// Anzahl Fahrzeuge pro Welle.
const int   FP_EVENT7_SPAWN_COUNT    = 3;

// Medium-Vehicle-Keys — identisch zu Event5, vollstaendig isoliert.
const string FP_EVENT7_MEDIUM_KEYS = "humvee.vehicle,wiesel_mk20.vehicle,apc.vehicle,apc_1.vehicle,apc_2.vehicle,vulcan_tank.vehicle,noxe.vehicle,hovercraft.vehicle,sev90.vehicle,radio_jammer.vehicle,m113_tank_acav.vehicle,m113_tank_mortar.vehicle";

const float FP_EVENT7_OFFSET_XZ = 8.0f;
const float FP_EVENT7_OFFSET_Y  = 5.0f;

// Haelt einen ausstehenden Einzel-Spawn (Fraktion + Countdown).
class FpEvent7PendingSpawn {
	int   m_factionId = -1;
	float m_countdown = 0.0f; // Sekunden bis zum Spawn
}

// Event7 (AI Event):
// Bedingung: mindestens eine eigene Basis vorhanden.
// Aktion: 3 zufaellige Medium-Fahrzeuge an (zufaelligen) eigenen Basen,
//         jeweils FP_EVENT7_SPAWN_INTERVAL Sekunden auseinander.
// Die verzoegerten Spawns werden ueber updateSpawnQueue() abgearbeitet,
// das die Registry in ihrem update()-Tick aufruft.
class FactionPointsEvent7ArmouredWave : FactionPointsEvent {
	protected Metagame@ m_metagame;
	protected uint m_baseCallIndex = 0;
	protected array<string> m_vehicleKeys;
	protected array<FpEvent7PendingSpawn@> m_queue; // ausstehende Spawns

	FactionPointsEvent7ArmouredWave(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_vehicleKeys = parseKeys(FP_EVENT7_MEDIUM_KEYS);
	}

	string getCommandToken() const { return FP_EVENT7_TOKEN; }
	string getDisplayName()  const { return FP_EVENT7_NAME; }
	int    getCost()         const { return FP_EVENT7_COST; }
	bool   isPlayerEvent()   const { return false; }
	float  getAnnouncementDelaySeconds() const { return FP_EVENT7_ANNOUNCEMENT_DELAY; }
	string getFriendlyAnnouncementText() const { return FP_EVENT7_FRIENDLY_ANNOUNCEMENT; }
	string getFriendlyExecutionText()    const { return FP_EVENT7_FRIENDLY_EXECUTION; }
	string getEnemyAnnouncementText()    const { return FP_EVENT7_ENEMY_ANNOUNCEMENT; }
	string getEnemyExecutionText()       const { return FP_EVENT7_ENEMY_EXECUTION; }

	bool canExecute(int playerId, int factionId, string &out reason) {
		Vector3 ignored;
		string ignoredName;
		if (!pickOwnedBase(factionId, ignored, ignoredName)) {
			reason = "No friendly base found.";
			return false;
		}
		return true;
	}

	// Queued 3 Spawns mit je FP_EVENT7_SPAWN_INTERVAL Sekunden Abstand.
	// Spawn 1 sofort (0s), Spawn 2 nach 2s, Spawn 3 nach 4s.
	bool execute(int playerId, int factionId, string &out result) {
		Vector3 ignored;
		string ignoredName;
		if (!pickOwnedBase(factionId, ignored, ignoredName)) {
			result = "No friendly base found.";
			return false;
		}

		for (int i = 0; i < FP_EVENT7_SPAWN_COUNT; ++i) {
			FpEvent7PendingSpawn@ pending = FpEvent7PendingSpawn();
			pending.m_factionId = factionId;
			pending.m_countdown = float(i) * FP_EVENT7_SPAWN_INTERVAL;
			m_queue.insertLast(pending);
		}

		result = "Event7: Armoured wave queued for faction " + factionId + " (3 vehicles).";
		return true;
	}

	// Wird von der Registry in update() aufgerufen — arbeitet die Spawn-Queue ab.
	void updateSpawnQueue(float time) {
		for (int i = int(m_queue.size()) - 1; i >= 0; --i) {
			FpEvent7PendingSpawn@ p = m_queue[i];
			if (p is null) { m_queue.removeAt(i); continue; }

			p.m_countdown -= time;
			if (p.m_countdown > 0.0f) continue;

			spawnVehicle(p.m_factionId);
			m_queue.removeAt(i);
		}
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

	protected void spawnVehicle(int factionId) {
		Vector3 basePos;
		string baseName;
		if (!pickOwnedBase(factionId, basePos, baseName)) return;

		string vehicleKey = pickRandomVehicleKey();

		float angle = float(rand(0, 5)) * 1.047f;
		basePos.m_values[0] += FP_EVENT7_OFFSET_XZ * cos(angle);
		basePos.m_values[1] += FP_EVENT7_OFFSET_Y;
		basePos.m_values[2] += FP_EVENT7_OFFSET_XZ * sin(angle);

		m_metagame.getComms().send(
			"<command class='create_instance' instance_class='vehicle'"
			+ " instance_key='" + vehicleKey + "'"
			+ " position='" + basePos.toString() + "'"
			+ " faction_id='" + factionId + "' />");
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

	protected string pickRandomVehicleKey() {
		if (m_vehicleKeys.size() == 0) return "apc.vehicle";
		return m_vehicleKeys[rand(0, int(m_vehicleKeys.size()) - 1)];
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
