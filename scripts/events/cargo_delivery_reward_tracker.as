// Cargo-Delivery-Belohnung: Feind-Cargo-Truck in eigene Waffenkammer gebracht →
// RP für Fahrer, Objective-Sound, Fahrzeug sperren/entfernen, Medium- oder Heavy-Spawn an Basis.
// Keine Item-Freischaltung. Logik angelehnt an vanilla VehicleDeliveryToArmory.
// VehicleIntervalSpawn muss vor diesem Script eingebunden sein.
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

const string CARGO_TRUCK_KEY = "cargo_truck.vehicle";
const int PLAYER_FACTION_ID = 0;
// RP-Belohnung für Fahrer (angelehnt an vanilla fallbackRewardIfNothingToUnlock ~400–800)
const float CARGO_DELIVERY_RP_REWARD = 600.0f;

// Pro getracktes Fahrzeug: vehicleId + Hitbox-IDs zum Aufräumen
class TrackedCargo {
	int m_vehicleId;
	array<string> m_hitboxIds;

	TrackedCargo(int vehicleId) {
		m_vehicleId = vehicleId;
	}
};

class CargoDeliveryRewardTracker : Tracker {
	protected Metagame@ m_metagame;
	protected VehicleIntervalSpawn@ m_vehicleSpawn;
	protected array<TrackedCargo@> m_tracked;
	protected bool m_eventsEnabled = false;

	CargoDeliveryRewardTracker(Metagame@ metagame, VehicleIntervalSpawn@ vehicleSpawn) {
		@m_metagame = metagame;
		@m_vehicleSpawn = vehicleSpawn;
	}

	void start() {
		enableEvents();
		_log("CargoDeliveryRewardTracker: started (enemy cargo truck → armory = RP + vehicle reward at base).", 1);
	}

	void enableEvents() {
		if (m_eventsEnabled) return;
		m_eventsEnabled = true;
		m_metagame.getComms().send("<command class='set_metagame_event' name='vehicle_spawn_event' enabled='1' />");
		m_metagame.getComms().send("<command class='set_metagame_event' name='hitbox_event' enabled='1' />");
		m_metagame.getComms().send("<command class='set_metagame_event' name='vehicle_destroyed_event' enabled='1' />");
	}

	void update(float time) {}

	bool hasStarted() const { return true; }
	bool hasEnded() const { return false; }

	protected void handleVehicleSpawnEvent(const XmlElement@ event) {
		if (event.getStringAttribute("vehicle_key") != CARGO_TRUCK_KEY) return;
		int ownerId = event.getIntAttribute("owner_id");
		if (ownerId == PLAYER_FACTION_ID) return; // nur Feind-Cargo-Trucks
		int vehicleId = event.getIntAttribute("vehicle_id");
		if (vehicleId < 0) return;

		array<const XmlElement@>@ armoryList = getArmoryHitboxes(m_metagame, PLAYER_FACTION_ID);
		if (armoryList is null || armoryList.size() == 0) return;

		TrackedCargo@ t = TrackedCargo(vehicleId);
		array<string> addIds;
		associateHitboxesEx(m_metagame, armoryList, "vehicle", vehicleId, t.m_hitboxIds, addIds);
		m_tracked.insertLast(t);
		_log("CargoDeliveryRewardTracker: tracking enemy cargo_truck vehicle_id=" + vehicleId, 2);
	}

	protected void handleVehicleDestroyEvent(const XmlElement@ event) {
		int vehicleId = event.getIntAttribute("vehicle_id");
		removeTracked(vehicleId);
	}

	protected void handleHitboxEvent(const XmlElement@ event) {
		if (event.getStringAttribute("instance_type") != "vehicle") return;
		int instanceId = event.getIntAttribute("instance_id");

		for (uint i = 0; i < m_tracked.size(); ++i) {
			if (m_tracked[i].m_vehicleId != instanceId) continue;

			// Delivery complete
			clearHitboxAssociations(m_metagame, "vehicle", instanceId, m_tracked[i].m_hitboxIds);
			m_tracked.erase(i);

			const XmlElement@ vehicleInfo = getVehicleInfo(m_metagame, instanceId);
			if (vehicleInfo is null) return;

			// Fahrer finden und RP geben (wie vanilla VehicleDelivery)
			int driverId = -1;
			array<const XmlElement@> characterList = vehicleInfo.getElementsByTagName("character");
			for (uint c = 0; c < characterList.size(); ++c) {
				const XmlElement@ character = characterList[c];
				if (character.getIntAttribute("slot_type") == 0) { // driver
					driverId = character.getIntAttribute("id");
					break;
				}
			}
			if (driverId >= 0 && CARGO_DELIVERY_RP_REWARD > 0.0f) {
				m_metagame.getComms().send("<command class='rp_reward' character_id='" + driverId + "' reward='" + CARGO_DELIVERY_RP_REWARD + "' />");
			}

			playObjectiveCompleteSound(m_metagame, PLAYER_FACTION_ID);
			lockVehicle(m_metagame, instanceId);
			destroyVehicle(m_metagame, instanceId);

			// Basis: Fahrzeugposition → nächste Basis der Spielerfraktion
			Vector3 pos = stringToVector3(vehicleInfo.getStringAttribute("position"));
			float dist = 0.0f;
			const XmlElement@ base = getClosestBase(m_metagame, pos, dist, PLAYER_FACTION_ID);
			if (base !is null) {
				int baseId = base.getIntAttribute("id");
				if (m_vehicleSpawn !is null)
					m_vehicleSpawn.spawnRewardVehicleAtBase(PLAYER_FACTION_ID, baseId, rand(0, 1) == 1);
			}

			sendFactionMessage(m_metagame, PLAYER_FACTION_ID, "Enemy cargo truck delivered. Reinforcement vehicle dispatched.", 1.0f);
			_log("CargoDeliveryRewardTracker: delivery reward (RP + vehicle) at base.", 1);
			return;
		}
	}

	void removeTracked(int vehicleId) {
		for (uint i = 0; i < m_tracked.size(); ++i) {
			if (m_tracked[i].m_vehicleId == vehicleId) {
				clearHitboxAssociations(m_metagame, "vehicle", vehicleId, m_tracked[i].m_hitboxIds);
				m_tracked.erase(i);
				return;
			}
		}
	}
}
