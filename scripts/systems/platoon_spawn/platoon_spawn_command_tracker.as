// Platoon Spawn Command Tracker
// Commands:
// - /platoon: 1 Miniboss + 4 Default-AI
// - /combatmedics: 4 Combat Medics
// Beide als Fallschirm-Einflug nahe Spielerposition.

#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "query_helpers.as"
#include "log.as"

const string CMD_PLATOON_SPAWN = "platoon";
const string CMD_COMBAT_MEDICS_SPAWN = "combatmedics";
const string CMD_COMBAT_MEDIC_SPAWN = "combatmedic";
const string PLATOON_MINIBOSS_KEY = "miniboss";
const string PLATOON_DEFAULT_SOLDIER_KEY = "default_ai";
const int PLATOON_DEFAULT_COUNT = 4;
const string COMBAT_MEDIC_SOLDIER_KEY = "combat_medic";
const int COMBAT_MEDIC_COUNT = 4;
const float PLATOON_SPAWN_OFFSET_FWD = 6.0f;
const float PLATOON_SPAWN_HEIGHT = 55.0f;
const float PLATOON_SPAWN_SPACING = 4.0f;

const int SQUAD_TYPE_NONE = 0;
const int SQUAD_TYPE_PLATOON = 1;
const int SQUAD_TYPE_COMBAT_MEDICS = 2;

class PlatoonSpawnCommandTracker : Tracker {
	protected Metagame@ m_metagame;
	protected bool m_adminOnly;

	PlatoonSpawnCommandTracker(Metagame@ metagame, bool adminOnly = true) {
		@m_metagame = @metagame;
		m_adminOnly = adminOnly;
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	protected void handleChatEvent(const XmlElement@ event) {
		string message = event.getStringAttribute("message");
		if (!startsWith(message, "/")) return;
		int squadType = resolveSquadType(message);
		if (squadType == SQUAD_TYPE_NONE) return;

		int senderId = event.getIntAttribute("player_id");
		string senderName = event.getStringAttribute("player_name");
		if (m_adminOnly && !m_metagame.getAdminManager().isAdmin(senderName, senderId)) {
			sendPrivateMessage(m_metagame, senderId, "Command locked: admin only.");
			return;
		}

		int factionId;
		Vector3 spawnPos;
		if (!tryResolvePlayerSpawn(senderId, factionId, spawnPos)) return;

		if (squadType == SQUAD_TYPE_PLATOON) {
			spawnPlatoonSquad(factionId, spawnPos);
			sendPrivateMessage(m_metagame, senderId, "Platoon deployed: 1 miniboss + 4 default_ai (paradrop).");
		} else if (squadType == SQUAD_TYPE_COMBAT_MEDICS) {
			spawnCombatMedicSquad(factionId, spawnPos);
			sendPrivateMessage(m_metagame, senderId, "Combat medics deployed: 4 combat_medic (paradrop).");
		}
	}

	protected int resolveSquadType(const string &in message) {
		if (checkCommand(message, CMD_PLATOON_SPAWN)) return SQUAD_TYPE_PLATOON;
		if (checkCommand(message, CMD_COMBAT_MEDICS_SPAWN)) return SQUAD_TYPE_COMBAT_MEDICS;
		if (checkCommand(message, CMD_COMBAT_MEDIC_SPAWN)) return SQUAD_TYPE_COMBAT_MEDICS;
		return SQUAD_TYPE_NONE;
	}

	protected bool tryResolvePlayerSpawn(int playerId, int &out factionId, Vector3 &out spawnPos) {
		const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
		if (player is null) {
			sendPrivateMessage(m_metagame, playerId, "Player not found.");
			return false;
		}

		int charId = player.getIntAttribute("character_id");
		const XmlElement@ character = getCharacterInfo(m_metagame, charId);
		if (character is null) {
			sendPrivateMessage(m_metagame, playerId, "No character (dead/spectating?).");
			return false;
		}

		factionId = player.getIntAttribute("faction_id");
		if (factionId < 0) factionId = 0;
		spawnPos = stringToVector3(character.getStringAttribute("position"));
		spawnPos.m_values[0] += PLATOON_SPAWN_OFFSET_FWD;
		spawnPos.m_values[1] += PLATOON_SPAWN_HEIGHT;
		return true;
	}

	protected void spawnPlatoonSquad(int factionId, const Vector3 &in basePos) {
		// Miniboss vorne
		sendSpawnSoldier(PLATOON_MINIBOSS_KEY, basePos, factionId);

		// 4 Default-Soldaten in einfacher 2x2-Formation
		for (int i = 0; i < PLATOON_DEFAULT_COUNT; ++i) {
			Vector3 p = basePos;
			float xOffset = (i % 2 == 0) ? -PLATOON_SPAWN_SPACING : PLATOON_SPAWN_SPACING;
			float zOffset = (i < 2) ? PLATOON_SPAWN_SPACING : -PLATOON_SPAWN_SPACING;
			p.m_values[0] += xOffset;
			p.m_values[2] += zOffset;
			sendSpawnSoldier(PLATOON_DEFAULT_SOLDIER_KEY, p, factionId);
		}

		_log("PlatoonSpawnCommandTracker: platoon spawned for faction " + factionId + " at " + basePos.toString(), 1);
	}

	protected void spawnCombatMedicSquad(int factionId, const Vector3 &in basePos) {
		for (int i = 0; i < COMBAT_MEDIC_COUNT; ++i) {
			Vector3 p = basePos;
			float xOffset = (i % 2 == 0) ? -PLATOON_SPAWN_SPACING : PLATOON_SPAWN_SPACING;
			float zOffset = (i < 2) ? PLATOON_SPAWN_SPACING : -PLATOON_SPAWN_SPACING;
			p.m_values[0] += xOffset;
			p.m_values[2] += zOffset;
			sendSpawnSoldier(COMBAT_MEDIC_SOLDIER_KEY, p, factionId);
		}

		_log("PlatoonSpawnCommandTracker: combat medics spawned for faction " + factionId + " at " + basePos.toString(), 1);
	}

	protected void sendSpawnSoldier(const string &in soldierKey, const Vector3 &in pos, int factionId) {
		m_metagame.getComms().send(
			"<command class='create_instance' instance_class='soldier' instance_key='" + soldierKey +
			"' position='" + pos.toString() + "' faction_id='" + factionId + "' />");
	}
}
