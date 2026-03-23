#include "helpers.as"
#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_interface.as"

const string FP_EVENT5_TOKEN                = "event5";
const string FP_EVENT5_NAME                 = "Vehicle Support";
const int    FP_EVENT5_COST                 = 500;
const string FP_EVENT5_CALL_KEY             = "apc_1.call";
const float  FP_EVENT5_ANNOUNCEMENT_DELAY   = 20.0f;
const string FP_EVENT5_FRIENDLY_ANNOUNCEMENT = "IFV inbound. Armoured support arriving at our position in 20 seconds.";
const string FP_EVENT5_FRIENDLY_EXECUTION    = "IFV deployed. Use armoured support to push forward.";
const string FP_EVENT5_ENEMY_ANNOUNCEMENT    = "Enemy commander: armoured reinforcements detected.";
const string FP_EVENT5_ENEMY_EXECUTION       = "";

// Event5 (AI Event):
// Bedingung: mindestens eine eigene Basis vorhanden.
// Aktion: apc_1.call (IFV-Drop) an einer zufaelligen eigenen Basis (Round-Robin).
class FactionPointsEvent5VehicleSupport : FactionPointsEvent {
	protected Metagame@ m_metagame;
	protected uint m_baseCallIndex = 0; // Round-Robin-Zaehler fuer Basisauswahl

	FactionPointsEvent5VehicleSupport(Metagame@ metagame) {
		@m_metagame = @metagame;
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

		string cmd = "<command class='create_instance' instance_class='call'"
			+ " instance_key='" + FP_EVENT5_CALL_KEY + "'"
			+ " position='" + basePos.toString() + "'"
			+ " faction_id='" + factionId + "' />";
		m_metagame.getComms().send(cmd);

		result = "Event5: IFV deployed at base '" + baseName + "'.";
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
}
