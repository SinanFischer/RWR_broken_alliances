// Captain Spawn Command Tracker
// /captain_spawn [paradrop] - spawnt 1 Captain (vorne) + 3 orange_bodyguards bei Spielerposition
// Admin only. Captain-Position wird mit VIP-Ziel-Symbol (atlas 17) auf der Karte angezeigt, nur für eigene Fraktion.
// Logik wie kill_commander: Captain erhält periodisch soldier_objective 'defend' an Spawn-Position (bleibt in Base).
// Bodyguards erhalten soldier_objective 'defend' an Captain-Position → folgen ihm.
//
// PRO FRAKTION: Jede Fraktion kann eigenen Captain haben (Cargo Truck). Gray + Brown = 2 Captains parallel.
//
// Import aus Project Apocalypse.

#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"

const string CMD_CAPTAIN_SPAWN = "captain_spawn";
const float SPAWN_OFFSET_FWD = 5.0f;
const float SPAWN_OFFSET_SIDE = 4.0f;
const float PARADROP_HEIGHT = 50.0f;
const int MARKER_ID_CAPTAIN_BASE = 70001;   // 70001 + factionId pro Fraktion
const int MARKER_ID_ENEMY_BASE = 70010;     // 70010 + ownerFactionId*16 + spotterFactionId (max 8 Fraktionen)
const int MARKER_ID_ENEMY_STRIDE = 16;
const int MARKER_ATLAS_VIP_OBJECTIVE = 17;
const int MARKER_ATLAS_ENEMY_COMMANDER = 18;
const float OBJECTIVE_INTERVAL = 1.5f;
const float BODYGUARD_SEARCH_RADIUS = 105.0f;
const float SCOUT_CAPTAIN_RADIUS = 120.0f;  // Basis-Position: Captain in diesem Radius = "entdeckt"
const string SOLDIER_GROUP_BODYGUARD = "orange_bodyguards";
const int MAX_FACTIONS = 8;
const int CAPTAIN_KILL_RP_REWARD = 250;  // RP fuer Spieler, der den feindlichen Captain erledigt

// --------------------------------------------
class CaptainSpawnCommandTracker : Tracker {
	protected Metagame@ m_metagame;
	protected bool m_started = false;

	// Pro Fraktion (index = factionId, max MAX_FACTIONS)
	protected array<int> m_captainIds;
	protected array<string> m_captainSpawnPositions;
	protected array<int> m_captainBaseIds;  // Basis, an der Captain gespawnt ist (-1 = unbekannt)
	protected array<array<int>> m_bodyguardIdsByFaction;
	protected array<array<int>> m_enemyFactionsSpottedByFaction;
	protected array<float> m_objectiveTimersByFaction;

	CaptainSpawnCommandTracker(Metagame@ metagame) {
		@m_metagame = metagame;
		m_captainIds.resize(MAX_FACTIONS);
		m_captainSpawnPositions.resize(MAX_FACTIONS);
		m_captainBaseIds.resize(MAX_FACTIONS);
		m_bodyguardIdsByFaction.resize(MAX_FACTIONS);
		m_enemyFactionsSpottedByFaction.resize(MAX_FACTIONS);
		m_objectiveTimersByFaction.resize(MAX_FACTIONS);
		for (int i = 0; i < MAX_FACTIONS; ++i) {
			m_captainIds[i] = -1;
			m_captainSpawnPositions[i] = "";
			m_captainBaseIds[i] = -1;
			m_objectiveTimersByFaction[i] = 0.0f;
		}
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
	}

	void start() {
		m_started = true;
	}

	void update(float time) {
		for (int fid = 0; fid < MAX_FACTIONS; ++fid) {
			updateFactionCaptain(fid, time);
		}
	}

	void updateFactionCaptain(int factionId, float time) {
		if (m_captainIds[factionId] < 0 && m_captainSpawnPositions[factionId].length() == 0) return;

		if (m_captainIds[factionId] < 0) {
			findCaptain(factionId);
			return;
		}

		const XmlElement@ info = getCharacterInfo2(m_metagame, m_captainIds[factionId]);
		if (info is null) {
			cleanupOnCaptainGone(factionId);
			return;
		}
		if (info.getIntAttribute("dead") != 0) {
			cleanupOnCaptainGone(factionId);
			return;
		}

		string captainPos = info.getStringAttribute("position");
		addCaptainMarker(factionId, captainPos);
		addEnemyMarkers(factionId, captainPos);

		m_objectiveTimersByFaction[factionId] -= time;
		if (m_objectiveTimersByFaction[factionId] <= 0.0f) {
			m_objectiveTimersByFaction[factionId] = OBJECTIVE_INTERVAL;
			if (m_captainSpawnPositions[factionId].length() > 0) {
				setCaptainObjective(m_captainIds[factionId], m_captainSpawnPositions[factionId], "defend");
			}
			if (m_bodyguardIdsByFaction[factionId].length() == 0) {
				findBodyguardsNearCaptain(factionId, captainPos);
			}
			setBodyguardsOnDefend(factionId, captainPos, "defend");
		}
	}

	void setCaptainObjective(int captainId, string position, string objective) {
		XmlElement c("command");
		c.setStringAttribute("class", "soldier_objective");
		c.setIntAttribute("character_id", captainId);
		c.setStringAttribute("objective", objective);
		c.setStringAttribute("target", position);
		m_metagame.getComms().send(c);
	}

	void findBodyguardsNearCaptain(int factionId, string captainPosition) {
		array<int>@ bg = m_bodyguardIdsByFaction[factionId];
		bg.resize(0);
		Vector3 pos = stringToVector3(captainPosition);
		array<const XmlElement@>@ chars = getCharactersNearPosition(m_metagame, pos, factionId, BODYGUARD_SEARCH_RADIUS);
		if (chars is null) return;
		for (uint i = 0; i < chars.length(); ++i) {
			int charId = chars[i].getIntAttribute("id");
			const XmlElement@ ci = getCharacterInfo(m_metagame, charId);
			if (ci !is null && ci.getStringAttribute("soldier_group_name") == SOLDIER_GROUP_BODYGUARD) {
				bg.insertLast(charId);
			}
		}
		if (bg.length() > 0) {
			_log("CaptainSpawnCommandTracker: Fraktion " + factionId + " - " + bg.length() + " Bodyguards gefunden", 1);
		}
	}

	void setBodyguardsOnDefend(int factionId, string captainPosition, string objective) {
		array<int>@ bg = m_bodyguardIdsByFaction[factionId];
		for (int i = int(bg.length()) - 1; i >= 0; --i) {
			int id = bg[i];
			const XmlElement@ info = getCharacterInfo2(m_metagame, id);
			if (info is null) {
				bg.removeAt(uint(i));
				continue;
			}
			if (info.getIntAttribute("dead") != 0) {
				bg.removeAt(uint(i));
				continue;
			}
			XmlElement c("command");
			c.setStringAttribute("class", "soldier_objective");
			c.setIntAttribute("character_id", id);
			c.setStringAttribute("objective", objective);
			c.setStringAttribute("target", captainPosition);
			m_metagame.getComms().send(c);
		}
	}

	void cleanupOnCaptainGone(int factionId) {
		removeCaptainMarker(factionId);
		removeEnemyMarkers(factionId);
		m_enemyFactionsSpottedByFaction[factionId].resize(0);
		m_captainIds[factionId] = -1;
		m_bodyguardIdsByFaction[factionId].resize(0);
		m_captainSpawnPositions[factionId] = "";
		m_captainBaseIds[factionId] = -1;
		_log("CaptainSpawnCommandTracker: Captain Fraktion " + factionId + " weg, Marker entfernt", 1);
	}

	/** Wird von IntelManager aufgerufen: Basis gescoutet oder Hauptangriffsziel → wenn dort Captain, zeigt Spotter den Enemy Commander.
	 *  Prüfung: (1) exakte baseId-Übereinstimmung ODER (2) Captain-Position innerhalb baseRadius (120m) der Basis-Position. */
	void notifyCaptainDiscoveredAtBase(int baseId, int baseOwnerFactionId, int spotterFactionId, const Vector3 &in basePosition) {
		if (baseOwnerFactionId < 0 || baseOwnerFactionId >= MAX_FACTIONS) return;
		if (spotterFactionId == baseOwnerFactionId) return;
		if (m_captainSpawnPositions[baseOwnerFactionId].length() == 0) return;

		bool match = false;
		if (m_captainBaseIds[baseOwnerFactionId] == baseId) {
			match = true;
		} else {
			// Fallback: Captain im Umkreis von basePosition? (z.B. wenn baseId abweicht oder Captain neben Base steht)
			Vector3 captainPos = stringToVector3(m_captainSpawnPositions[baseOwnerFactionId]);
			if (checkRange(captainPos, basePosition, SCOUT_CAPTAIN_RADIUS))
				match = true;
		}
		if (!match) return;

		array<int>@ spotted = m_enemyFactionsSpottedByFaction[baseOwnerFactionId];
		for (uint i = 0; i < spotted.length(); ++i) {
			if (spotted[i] == spotterFactionId) return;
		}
		spotted.insertLast(spotterFactionId);
		sendFactionMessage(m_metagame, spotterFactionId, "Enemy Commander spotted. Eliminate him - the reward is worth it!", 1.5f);
		_log("CaptainSpawnCommandTracker: Captain an Basis " + baseId + " (Fraktion " + baseOwnerFactionId + ") von Fraktion " + spotterFactionId + " entdeckt (Scout/Attack) - Enemy Commander Marker", 1);
	}

	protected void handleCharacterKillEvent(const XmlElement@ event) {
		const XmlElement@ target = event.getFirstElementByTagName("target");
		if (target is null) return;
		int deadId = target.getIntAttribute("id");
		int deadFactionId = target.getIntAttribute("faction_id");
		bool isCaptain = (target.getStringAttribute("soldier_group_name") == "captain");

		for (int fid = 0; fid < MAX_FACTIONS; ++fid) {
			// Match: entweder bekannte Captain-ID ODER Captain-Typ + Fraktion hat Captain-Spawn (Fallback falls findCaptain noch nicht lief)
			bool match = (m_captainIds[fid] == deadId) ||
				(isCaptain && deadFactionId == fid && m_captainSpawnPositions[fid].length() > 0);
			if (match) {
				// Fraktion, die den Captain verloren hat: immer benachrichtigen
				sendFactionMessage(m_metagame, fid, "Our Commander has been eliminated!", 1.5f);

				// Killer-Fraktion (wenn vorhanden und != Captain-Fraktion): benachrichtigen + RP an Spieler
				const XmlElement@ killer = event.getFirstElementByTagName("killer");
				if (killer !is null) {
					int killerFactionId = killer.getIntAttribute("faction_id");
					if (killerFactionId >= 0 && killerFactionId < MAX_FACTIONS && killerFactionId != fid) {
						sendFactionMessage(m_metagame, killerFactionId, "Excellent work! Enemy Commander eliminated!", 1.5f);
						// Spieler-Killer erkennt man an player_id != -1 (AI hat -1)
						if (killer.getIntAttribute("player_id") != -1) {
							int killerCharId = killer.getIntAttribute("id");
							m_metagame.getComms().send("<command class='rp_reward' character_id='" + killerCharId + "' reward='" + CAPTAIN_KILL_RP_REWARD + "' />");
						}
					}
				}

				cleanupOnCaptainGone(fid);
				return;
			}
		}
	}

	void findCaptain(int factionId) {
		array<const XmlElement@>@ characters = getCharacters(m_metagame, factionId);
		if (characters is null) return;
		for (uint i = 0; i < characters.length(); ++i) {
			int charId = characters[i].getIntAttribute("id");
			const XmlElement@ info = getCharacterInfo(m_metagame, charId);
			if (info !is null && info.getStringAttribute("soldier_group_name") == "captain") {
				m_captainIds[factionId] = charId;
				_log("CaptainSpawnCommandTracker: Captain Fraktion " + factionId + " gefunden, ID " + charId, 1);
				return;
			}
		}
	}

	void addCaptainMarker(int factionId, string position) {
		XmlElement c("command");
		c.setStringAttribute("class", "set_marker");
		c.setIntAttribute("id", MARKER_ID_CAPTAIN_BASE + factionId);
		c.setIntAttribute("faction_id", factionId);
		c.setIntAttribute("atlas_index", MARKER_ATLAS_VIP_OBJECTIVE);
		c.setFloatAttribute("size", 0.75f);
		c.setFloatAttribute("range", 0.0f);
		c.setIntAttribute("enabled", 1);
		c.setStringAttribute("position", position);
		c.setStringAttribute("text", "Captain");
		c.setStringAttribute("type_key", "default");
		c.setBoolAttribute("show_in_map_view", true);
		c.setBoolAttribute("show_in_game_view", true);
		c.setBoolAttribute("show_at_screen_edge", false);
		m_metagame.getComms().send(c);
	}

	void removeCaptainMarker(int factionId) {
		XmlElement c("command");
		c.setStringAttribute("class", "set_marker");
		c.setIntAttribute("id", MARKER_ID_CAPTAIN_BASE + factionId);
		c.setIntAttribute("enabled", 0);
		c.setIntAttribute("faction_id", factionId);
		m_metagame.getComms().send(c);
	}

	void addEnemyMarkers(int ownerFactionId, string captainPosition) {
		array<int>@ spotted = m_enemyFactionsSpottedByFaction[ownerFactionId];
		for (uint i = 0; i < spotted.length(); ++i) {
			int spotterFid = spotted[i];
			int markerId = MARKER_ID_ENEMY_BASE + ownerFactionId * MARKER_ID_ENEMY_STRIDE + spotterFid;
			XmlElement c("command");
			c.setStringAttribute("class", "set_marker");
			c.setIntAttribute("id", markerId);
			c.setIntAttribute("faction_id", spotterFid);
			c.setIntAttribute("atlas_index", MARKER_ATLAS_ENEMY_COMMANDER);
			c.setFloatAttribute("size", 0.75f);
			c.setFloatAttribute("range", 0.0f);
			c.setIntAttribute("enabled", 1);
			c.setStringAttribute("position", captainPosition);
			c.setStringAttribute("text", "Enemy Captain");
			c.setStringAttribute("type_key", "default");
			c.setBoolAttribute("show_in_map_view", true);
			c.setBoolAttribute("show_in_game_view", false);
			c.setBoolAttribute("show_at_screen_edge", true);
			m_metagame.getComms().send(c);
		}
	}

	void removeEnemyMarkers(int ownerFactionId) {
		array<int>@ spotted = m_enemyFactionsSpottedByFaction[ownerFactionId];
		for (uint i = 0; i < spotted.length(); ++i) {
			int spotterFid = spotted[i];
			int markerId = MARKER_ID_ENEMY_BASE + ownerFactionId * MARKER_ID_ENEMY_STRIDE + spotterFid;
			XmlElement c("command");
			c.setStringAttribute("class", "set_marker");
			c.setIntAttribute("id", markerId);
			c.setIntAttribute("enabled", 0);
			c.setIntAttribute("faction_id", spotterFid);
			m_metagame.getComms().send(c);
		}
	}

	/** Öffentlich: Spawn bei Position (z.B. von VehicleIntervalSpawn bei Cargo-Truck). baseId = Basis, an der gespawnt wird (-1 bei /captain_spawn). */
	void spawnCaptainSquadAt(int factionId, const Vector3 &in pos, int baseId = -1) {
		if (factionId < 0 || factionId >= MAX_FACTIONS) return;

		// Alten Captain dieser Fraktion entfernen
		if (m_captainIds[factionId] >= 0 || m_captainSpawnPositions[factionId].length() > 0) {
			removeCaptainMarker(factionId);
			removeEnemyMarkers(factionId);
			m_enemyFactionsSpottedByFaction[factionId].resize(0);
		}

		m_captainSpawnPositions[factionId] = pos.toString();
		m_captainBaseIds[factionId] = baseId;
		Vector3 p = pos;
		sendSpawnSoldier("captain", p, factionId);
		p.m_values[0] -= SPAWN_OFFSET_SIDE;
		sendSpawnSoldier("orange_bodyguards", p, factionId);
		p.m_values[2] += SPAWN_OFFSET_SIDE;
		sendSpawnSoldier("orange_bodyguards", p, factionId);
		p.m_values[2] -= SPAWN_OFFSET_SIDE * 2.0f;
		sendSpawnSoldier("orange_bodyguards", p, factionId);

		m_captainIds[factionId] = -1;
		m_bodyguardIdsByFaction[factionId].resize(0);
		m_objectiveTimersByFaction[factionId] = 0.0f;
		_log("CaptainSpawnCommandTracker: Squad bei Cargo-Truck " + pos.toString() + " für Fraktion " + factionId + " (pro Fraktion - andere Captains unverändert)", 1);
	}

	protected void handleChatEvent(const XmlElement@ event) {
		string message = event.getStringAttribute("message");
		if (!startsWith(message, "/") || !checkCommand(message, CMD_CAPTAIN_SPAWN)) return;
		if (!m_metagame.getAdminManager().isAdmin(event.getStringAttribute("player_name"), event.getIntAttribute("player_id"))) return;

		array<string> params = parseParameters(message, CMD_CAPTAIN_SPAWN);
		bool paradrop = params.size() > 0 && (params[0] == "paradrop" || params[0] == "para" || params[0] == "1");

		int senderId = event.getIntAttribute("player_id");
		if (!trySpawnCaptainSquad(senderId, paradrop)) return;

		sendPrivateMessage(m_metagame, senderId, "Squad spawned (1 Captain, 3 orange_bodyguards)" + (paradrop ? " with paradrop" : ""));
	}

	bool trySpawnCaptainSquad(int senderId, bool paradrop) {
		const XmlElement@ player = getPlayerInfo(m_metagame, senderId);
		if (player is null) {
			sendPrivateMessage(m_metagame, senderId, "Player not found.");
			return false;
		}
		int factionId = player.getIntAttribute("faction_id");
		if (factionId < 0) factionId = 0;
		if (factionId >= MAX_FACTIONS) {
			sendPrivateMessage(m_metagame, senderId, "Faction " + factionId + " out of range (max " + MAX_FACTIONS + ").");
			return false;
		}

		const XmlElement@ charInfo = getCharacterInfo(m_metagame, player.getIntAttribute("character_id"));
		if (charInfo is null) {
			sendPrivateMessage(m_metagame, senderId, "No character (dead/spectating?).");
			return false;
		}

		Vector3 pos = stringToVector3(charInfo.getStringAttribute("position"));
		pos.m_values[0] += SPAWN_OFFSET_FWD;
		if (paradrop) pos.m_values[1] += PARADROP_HEIGHT;

		if (m_captainIds[factionId] >= 0 || m_captainSpawnPositions[factionId].length() > 0) {
			removeCaptainMarker(factionId);
			removeEnemyMarkers(factionId);
			m_enemyFactionsSpottedByFaction[factionId].resize(0);
		}
		m_captainSpawnPositions[factionId] = pos.toString();
		m_captainBaseIds[factionId] = -1;  // Admin-Spawn: keine Basis-Referenz

		sendSpawnSoldier("captain", pos, factionId);
		pos.m_values[0] -= SPAWN_OFFSET_SIDE;
		sendSpawnSoldier("orange_bodyguards", pos, factionId);
		pos.m_values[2] += SPAWN_OFFSET_SIDE;
		sendSpawnSoldier("orange_bodyguards", pos, factionId);
		pos.m_values[2] -= SPAWN_OFFSET_SIDE * 2.0f;
		sendSpawnSoldier("orange_bodyguards", pos, factionId);

		sendFactionMessage(m_metagame, factionId, "Captain + 3 orange_bodyguards deployed!", 1.5f);
		_log("CaptainSpawnCommandTracker: Squad bei " + pos.toString() + " Fraktion " + factionId, 1);

		m_captainIds[factionId] = -1;
		m_bodyguardIdsByFaction[factionId].resize(0);
		m_objectiveTimersByFaction[factionId] = 0.0f;

		return true;
	}

	void sendSpawnSoldier(const string &in soldierKey, const Vector3 &in pos, int factionId) {
		m_metagame.getComms().send(
			"<command class='create_instance' instance_class='soldier' instance_key='" + soldierKey +
			"' position='" + pos.toString() + "' faction_id='" + factionId + "' />");
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return m_started; }
}
