#include "helpers.as"
#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_interface.as"
#include "systeme/fraktionspunkte_system/faction_points_map_marker.as"

// ============================================================
// EVENT 4 - Double Paratroopers Reinforcement (Front-Line)
// Cost:        485 FP
// Trigger:     AI spare event + player /event4
// AI condition: none (weight 0.6)
// Exec condition: min. 1 owned base + min. 1 enemy base exists
// Action:      finds the friendly base closest to any enemy base
//              (front-line proxy), then drops paratroopers2 twice
//              with a 5-second gap between drops
// ============================================================

const string FP_EVENT4_TOKEN                 = "event4";
const string FP_EVENT4_NAME                  = "20 Paratroopers to the Front-Line";
const int    FP_EVENT4_COST                  = 485;
const string FP_EVENT4_CALL_KEY              = "paratroopers2.call";
const float  FP_EVENT4_ANNOUNCEMENT_DELAY    = 30.0f;
const float  FP_EVENT4_DROP_INTERVAL         = 5.0f; // seconds between the two drops

const string FP_EVENT4_FRIENDLY_ANNOUNCEMENT = "Sending double paratroopers to the front line in 30 seconds.";
const string FP_EVENT4_FRIENDLY_EXECUTION    = "Paratroopers away - double drop on the front line!";
const string FP_EVENT4_ENEMY_ANNOUNCEMENT    = "";
const string FP_EVENT4_ENEMY_EXECUTION       = "";

// Holds the pending second drop so the registry update loop can fire it.
class FpEvent4PendingDrop {
	int    m_factionId = -1;
	float  m_countdown = 0.0f;
	Vector3 m_position;
}

class FactionPointsEvent4BaseReinforcement : FactionPointsEvent {
	protected Metagame@ m_metagame;
	protected array<FpEvent4PendingDrop@> m_queue;

	FactionPointsEvent4BaseReinforcement(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	string getCommandToken() const { return FP_EVENT4_TOKEN; }
	string getDisplayName()  const { return FP_EVENT4_NAME; }
	int    getCost()         const { return FP_EVENT4_COST; }
	bool   isPlayerEvent()   const { return false; }
	float  getAnnouncementDelaySeconds() const { return FP_EVENT4_ANNOUNCEMENT_DELAY; }
	string getFriendlyAnnouncementText() const { return FP_EVENT4_FRIENDLY_ANNOUNCEMENT; }
	string getFriendlyExecutionText()    const { return FP_EVENT4_FRIENDLY_EXECUTION; }
	string getEnemyAnnouncementText()    const { return FP_EVENT4_ENEMY_ANNOUNCEMENT; }
	string getEnemyExecutionText()       const { return FP_EVENT4_ENEMY_EXECUTION; }

	bool canExecute(int playerId, int factionId, string &out reason) {
		Vector3 ignored;
		string ignoredName;
		if (!pickFrontLineBase(factionId, ignored, ignoredName)) {
			reason = "No front-line base found (need at least one owned and one enemy base).";
			return false;
		}
		return true;
	}

	bool execute(int playerId, int factionId, string &out result) {
		Vector3 basePos;
		string baseName;
		if (!pickFrontLineBase(factionId, basePos, baseName)) {
			result = "No front-line base found.";
			return false;
		}

		// First drop fires immediately.
		spawnDrop(factionId, basePos);

		// Queue the second drop with a delay.
		FpEvent4PendingDrop@ pending = FpEvent4PendingDrop();
		pending.m_factionId = factionId;
		pending.m_countdown = FP_EVENT4_DROP_INTERVAL;
		pending.m_position  = basePos;
		m_queue.insertLast(pending);

		// Set a map marker at the front-line base so players can see the target.
		fpUpdateEventMarker(
			m_metagame,
			factionId,
			FP_MARKER_SLOT_EVENT4,
			"Double Drop: " + baseName,
			basePos.toString(),
			FP_MARKER_ATLAS_PARADROP
		);

		result = "Event4: Double paratroopers incoming at front-line base '" + baseName + "'.";
		return true;
	}

	// Called every frame by the registry update loop to process the delayed second drop.
	void updateDropQueue(float dt) {
		if (m_queue.size() == 0) return;

		for (int i = int(m_queue.size()) - 1; i >= 0; i--) {
			FpEvent4PendingDrop@ p = m_queue[i];
			p.m_countdown -= dt;
			if (p.m_countdown > 0.0f) continue;

			spawnDrop(p.m_factionId, p.m_position);
			// Clear the marker after the final drop lands.
			fpClearEventMarker(m_metagame, p.m_factionId, FP_MARKER_SLOT_EVENT4);
			m_queue.removeAt(i);
		}
	}

	// ----------------------------------------------------------------
	// Helpers
	// ----------------------------------------------------------------

	// Thin wrapper used by the registry to resolve the marker/chat location text.
	bool tryGetTargetBaseName(int factionId, string &out baseName) {
		Vector3 ignored;
		return pickFrontLineBase(factionId, ignored, baseName);
	}

	// Fires a single paratroopers2 drop at the given position.
	protected void spawnDrop(int factionId, Vector3 pos) {
		string cmd = "<command class='create_instance' instance_class='call'"
			+ " instance_key='" + FP_EVENT4_CALL_KEY + "'"
			+ " position='" + pos.toString() + "'"
			+ " faction_id='" + factionId + "' />";
		m_metagame.getComms().send(cmd);
	}

	// Returns the friendly base that is geometrically closest to any enemy base.
	// This is the "front-line proxy" - no random, no round-robin.
	protected bool pickFrontLineBase(int factionId, Vector3 &out outPos, string &out outName) {
		array<const XmlElement@>@ allBases = getBases(m_metagame);
		if (allBases is null || allBases.size() == 0) return false;

		// Collect owned and enemy bases separately.
		array<const XmlElement@> enemyBases;
		array<const XmlElement@> ownedBases;

		for (uint i = 0; i < allBases.size(); ++i) {
			const XmlElement@ base = allBases[i];
			if (base is null) continue;
			int owner = base.getIntAttribute("owner_id");
			if (owner == factionId) {
				ownedBases.insertLast(base);
			} else {
				enemyBases.insertLast(base);
			}
		}

		if (ownedBases.size() == 0 || enemyBases.size() == 0) return false;

		// Find the owned base with the smallest minimum distance to any enemy base.
		float bestDist = -1.0f;
		int   bestIdx  = -1;

		for (uint i = 0; i < ownedBases.size(); ++i) {
			Vector3 ownedPos = stringToVector3(ownedBases[i].getStringAttribute("position"));
			float minDist = -1.0f;

			for (uint j = 0; j < enemyBases.size(); ++j) {
				Vector3 enemyPos = stringToVector3(enemyBases[j].getStringAttribute("position"));
				float d = getPositionDistance(ownedPos, enemyPos);
				if (minDist < 0.0f || d < minDist) minDist = d;
			}

			if (bestDist < 0.0f || minDist < bestDist) {
				bestDist = minDist;
				bestIdx  = int(i);
			}
		}

		if (bestIdx < 0) return false;

		const XmlElement@ selected = ownedBases[bestIdx];
		outPos  = stringToVector3(selected.getStringAttribute("position"));
		outName = selected.getStringAttribute("name");
		if (outName.length() == 0) outName = selected.getStringAttribute("key");
		if (outName.length() == 0) outName = "base";
		return true;
	}
}
