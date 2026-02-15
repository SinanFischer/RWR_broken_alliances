// Captain Spawn Command Tracker
// /captain_spawn [paradrop] - spawnt 1 Captain (vorne) + 3 orange_bodyguards bei Spielerposition
// Admin only. Captain-Position wird mit VIP-Ziel-Symbol (atlas 17) auf der Karte angezeigt, nur für eigene Fraktion.
// Logik wie kill_commander: Captain erhält periodisch soldier_objective 'defend' an Spawn-Position (bleibt in Base).
// Bodyguards erhalten soldier_objective 'defend' an Captain-Position → folgen ihm.
//
// PRO FRAKTION: Jede Fraktion kann eigenen Captain haben (Cargo Truck). Gray + Brown = 2 Captains parallel.
//
// Tod-Erkennung: character_kill (Killer bekannt) + character_die (jeder Tod, z. B. Artillerie/Umwelt).
// Gemeinsame Match-Logik, ein Cleanup, ein Log pro Tod.

/**
Logs: 
12:43:43: SCRIPT:  received: TagName=character_kill key=heavy_artillery_shell.projectile method_hint=blast     TagName=killer block=26 23 dead=0 faction_id=1 id=756 leader=1 name=Maik Schumacher player_id=0 position=902.466 21.4706 801.127 rp=5228 soldier_group_name=default squad_size=0 wounded=0 xp=1     TagName=target block=26 23 dead=0 faction_id=0 id=737 leader=1 name= player_id=-1 position=914.498 27.0706 795.033 rp=1293 soldier_group_name=captain squad_size=0 wounded=1 xp=100 
12:43:43: SCRIPT:  received: TagName=character_die character_id=737     TagName=character block=26 23 dead=1 faction_id=0 id=737 leader=1 name= player_id=-1 position=914.498 27.0706 795.033 rp=1293 soldier_group_name=captain squad_size=0 wounded=1 xp=100 
12:43:44: SCRIPT:  received: TagName=query_result query_id=11831     TagName=character block=26 23 dead=1 faction_id=0 id=737 leader=0 name= player_id=-1 position=911.854 27.1221 797.874 rp=1293 soldier_group_name=captain squad_size=0 wounded=1 xp=100     TagName=item amount=0 index=119 key=microgun_elite.weapon slot=0     TagName=item amount=0 index=-1 key= slot=1     TagName=item amount=0 index=-1 key= slot=2     TagName=item amount=0 index=-1 key= slot=4     TagName=item amount=0 index=112 key=eod_ai_6 slot=5 

*/


#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "events/character_death_helpers.as"

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
const float CAPTAIN_SPOT_AIM_RADIUS = 25.0f; // Fadenkreuz (aim_target) innerhalb 25m der Captain-Position = gespottet (wie Basis-Aufklärung)
const string SOLDIER_GROUP_BODYGUARD = "orange_bodyguards";
const string SOLDIER_GROUP_CAPTAIN = "captain";
const int MAX_FACTIONS = 8;
const int CAPTAIN_KILL_RP_REWARD = 250;  // RP fuer Spieler, der den feindlichen Captain erledigt
const float CAPTAIN_SPOT_BASE_DELAY = 2.0f; // Enemy-Commander-Meldung erst 2s nach Basis-Scout-Meldung (nur bei Entdeckung ueber Basis)

// --------------------------------------------
class CaptainSpawnCommandTracker : Tracker {
	protected Metagame@ m_metagame;
	protected bool m_started = false;
	protected float m_metagameTime = 0.0f;

	// Pro Fraktion (index = factionId, max MAX_FACTIONS)
	protected array<int> m_captainIds;
	protected array<string> m_captainSpawnPositions;
	protected array<int> m_captainBaseIds;  // Basis, an der Captain gespawnt ist (-1 = unbekannt)
	protected array<array<int>> m_bodyguardIdsByFaction;
	protected array<array<int>> m_enemyFactionsSpottedByFaction;
	protected array<float> m_objectiveTimersByFaction;

	// Verzögerte "Enemy Commander spotted" bei Basis-Scout: (ownerFactionId, spotterFactionId) → triggerTime
	protected array<int> m_pendingSpotOwner;
	protected array<int> m_pendingSpotter;
	protected array<float> m_pendingSpotTriggerTime;

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
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_die' enabled='1' />");
	}

	void start() {
		m_started = true;
	}

	void update(float time) {
		m_metagameTime += time;
		processPendingBaseSpotNotifications();
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
			sendFactionMessage(m_metagame, factionId, "Our Commander has been eliminated!", 1.5f);
			cleanupOnCaptainGone(factionId);
			return;
		}
		if (info.getIntAttribute("dead") != 0) {
			sendFactionMessage(m_metagame, factionId, "Our Commander has been eliminated!", 1.5f);
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
			checkSpotterAimAtCaptain(factionId, captainPos);
		}
	}

	// Feindlicher Spieler zielt mit Fadenkreuz (aim_target) auf/nah am Captain → Enemy Commander gespottet (wie Basis-Aufklärung 25m).
	void checkSpotterAimAtCaptain(int ownerFactionId, const string &in captainPositionStr) {
		array<const XmlElement@>@ players = getPlayers(m_metagame);
		if (players is null) return;
		Vector3 captainPos = stringToVector3(captainPositionStr);

		for (uint k = 0; k < players.size(); ++k) {
			const XmlElement@ player = players[k];
			int spotterFactionId = player.getIntAttribute("faction_id");
			if (spotterFactionId == ownerFactionId) continue;
			if (spotterFactionId < 0 || spotterFactionId >= MAX_FACTIONS) continue;
			if (!player.hasAttribute("aim_target")) continue;

			Vector3 aimTarget = stringToVector3(player.getStringAttribute("aim_target"));
			if (!checkRange(aimTarget, captainPos, CAPTAIN_SPOT_AIM_RADIUS)) continue;

			array<int>@ spotted = m_enemyFactionsSpottedByFaction[ownerFactionId];
			bool already = false;
			for (uint i = 0; i < spotted.length(); ++i)
				if (spotted[i] == spotterFactionId) { already = true; break; }
			if (already) continue;

			spotted.insertLast(spotterFactionId);
			sendFactionMessage(m_metagame, spotterFactionId, "Enemy Commander spotted. Eliminate him - the reward is worth it!", 1.5f);
			_log("CaptainSpawnCommandTracker: Captain (Fraktion " + ownerFactionId + ") von Fraktion " + spotterFactionId + " per Fadenkreuz gespottet", 1);
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
			_log("CaptainSpawnCommandTracker: Faction " + factionId + " - " + bg.length() + " bodyguards found", 1);
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

	/** Wird von Aufklärungs-Manager aufgerufen: Basis gescoutet oder Hauptangriffsziel → wenn dort Captain, Spot-Meldung 2s verzögert (nach Basis-Meldung). */
	void notifyCaptainDiscoveredAtBase(int baseId, int baseOwnerFactionId, int spotterFactionId, const Vector3 &in basePosition) {
		if (baseOwnerFactionId < 0 || baseOwnerFactionId >= MAX_FACTIONS) return;
		if (spotterFactionId == baseOwnerFactionId) return;
		if (m_captainSpawnPositions[baseOwnerFactionId].length() == 0) return;

		bool match = false;
		if (m_captainBaseIds[baseOwnerFactionId] == baseId) {
			match = true;
		} else {
			Vector3 captainPos = stringToVector3(m_captainSpawnPositions[baseOwnerFactionId]);
			if (checkRange(captainPos, basePosition, SCOUT_CAPTAIN_RADIUS))
				match = true;
		}
		if (!match) return;

		array<int>@ spotted = m_enemyFactionsSpottedByFaction[baseOwnerFactionId];
		for (uint i = 0; i < spotted.length(); ++i) {
			if (spotted[i] == spotterFactionId) return;
		}
		for (uint i = 0; i < m_pendingSpotOwner.length(); ++i) {
			if (m_pendingSpotOwner[i] == baseOwnerFactionId && m_pendingSpotter[i] == spotterFactionId) return;
		}
		m_pendingSpotOwner.insertLast(baseOwnerFactionId);
		m_pendingSpotter.insertLast(spotterFactionId);
		m_pendingSpotTriggerTime.insertLast(m_metagameTime + CAPTAIN_SPOT_BASE_DELAY);
	}

	void processPendingBaseSpotNotifications() {
		for (int i = int(m_pendingSpotTriggerTime.length()) - 1; i >= 0; --i) {
			if (m_pendingSpotTriggerTime[i] > m_metagameTime) continue;
			int ownerFactionId = m_pendingSpotOwner[i];
			int spotterFactionId = m_pendingSpotter[i];
			m_pendingSpotOwner.removeAt(i);
			m_pendingSpotter.removeAt(i);
			m_pendingSpotTriggerTime.removeAt(i);
			if (ownerFactionId < 0 || ownerFactionId >= MAX_FACTIONS || spotterFactionId == ownerFactionId) continue;
			if (m_captainSpawnPositions[ownerFactionId].length() == 0) continue; // Captain bereits weg
			array<int>@ spotted = m_enemyFactionsSpottedByFaction[ownerFactionId];
			bool already = false;
			for (uint k = 0; k < spotted.length(); ++k) { if (spotted[k] == spotterFactionId) { already = true; break; } }
			if (already) continue;
			spotted.insertLast(spotterFactionId);
			sendFactionMessage(m_metagame, spotterFactionId, "Enemy Commander spotted. Eliminate him - the reward is worth it!", 1.5f);
			_log("CaptainSpawnCommandTracker: Captain (Fraktion " + ownerFactionId + ") von Fraktion " + spotterFactionId + " entdeckt (Scout/Attack, 2s verzögert) - Enemy Commander Marker", 1);
		}
	}

	// Einheitliche Tod-Behandlung: nur einmal Cleanup/Nachricht pro Tod (erstes ankommendes Event gewinnt).
	void onCaptainDeath(int factionId, int deadId, const XmlElement@ event, bool fromKillEvent) {
		if (factionId < 0 || factionId >= MAX_FACTIONS) return;
		if (!(m_captainIds[factionId] >= 0 || m_captainSpawnPositions[factionId].length() > 0))
			return; // bereits bereinigt (z. B. anderes Event zuerst)

		const XmlElement@ dead = getDeadCharacterFromDeathEvent(event);
		logCaptainDeathEventPayload(event, fromKillEvent ? "character_kill" : "character_die", dead);

		cleanupOnCaptainGone(factionId);
		sendFactionMessage(m_metagame, factionId, "Our Commander has been eliminated!", 1.5f);

		if (fromKillEvent)
			sendKillerRewardAndMessage(event, factionId);
	}

	// Killer-Fraktion Nachricht + RP (auch bei verspätetem character_kill, wenn Cleanup schon aus Update lief).
	void sendKillerRewardAndMessage(const XmlElement@ event, int captainFactionId) {
		const XmlElement@ killer = event.getFirstElementByTagName("killer");
		if (killer is null) return;
		int killerFactionId = killer.getIntAttribute("faction_id");
		if (killerFactionId < 0 || killerFactionId >= MAX_FACTIONS || killerFactionId == captainFactionId) return;
		sendFactionMessage(m_metagame, killerFactionId, "Excellent work! Enemy Commander eliminated!", 1.5f);
		if (killer.getIntAttribute("player_id") != -1) {
			int killerCharId = killer.getIntAttribute("id");
			m_metagame.getComms().send("<command class='rp_reward' character_id='" + killerCharId + "' reward='" + CAPTAIN_KILL_RP_REWARD + "' />");
		}
	}

	// Gibt die Fraktion zurück, zu der der tote Charakter als Captain gehört (-1 = keiner).
	int matchCaptainFaction(const XmlElement@ dead) {
		if (dead is null) return -1;
		int deadId = dead.getIntAttribute("id");
		int deadFactionId = dead.getIntAttribute("faction_id");
		bool isCaptain = (dead.getStringAttribute("soldier_group_name") == SOLDIER_GROUP_CAPTAIN);

		for (int fid = 0; fid < MAX_FACTIONS; ++fid) {
			bool match = (m_captainIds[fid] == deadId) ||
				(isCaptain && deadFactionId == fid && m_captainSpawnPositions[fid].length() > 0);
			if (match) return fid;
		}
		return -1;
	}

	protected void handleCharacterKillEvent(const XmlElement@ event) {
		const XmlElement@ dead = getDeadCharacterFromDeathEvent(event);
		if (dead is null) return;

		int fid = matchCaptainFaction(dead);
		if (fid >= 0) {
			onCaptainDeath(fid, dead.getIntAttribute("id"), event, true);
			return;
		}
		// Late character_kill (cleanup already ran e.g. from Update) - still send killer message + RP
		if (dead.getStringAttribute("soldier_group_name") != SOLDIER_GROUP_CAPTAIN) return;
		int deadFactionId = dead.getIntAttribute("faction_id");
		sendKillerRewardAndMessage(event, deadFactionId);
	}

	protected void handleCharacterDieEvent(const XmlElement@ event) {
		const XmlElement@ dead = getDeadCharacterFromDeathEvent(event);
		// Bei manchen Todesarten (z. B. Artillerie) enthält character_die nur character_id, kein <character>-Kind.
		if (dead is null) {
			int charId = event.getIntAttribute("character_id");
			if (charId < 0) return;
			const XmlElement@ info = getCharacterInfo(m_metagame, charId);
			if (info is null) return;
			int fid = matchCaptainFaction(info);
			if (fid < 0) return;
			onCaptainDeath(fid, charId, event, false);
			return;
		}

		int fid = matchCaptainFaction(dead);
		if (fid < 0) return;

		onCaptainDeath(fid, dead.getIntAttribute("id"), event, false);
	}

	void findCaptain(int factionId) {
		array<const XmlElement@>@ characters = getCharacters(m_metagame, factionId);
		if (characters is null) return;
		for (uint i = 0; i < characters.length(); ++i) {
			int charId = characters[i].getIntAttribute("id");
			const XmlElement@ info = getCharacterInfo(m_metagame, charId);
			if (info !is null && info.getStringAttribute("soldier_group_name") == SOLDIER_GROUP_CAPTAIN) {
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
		m_captainBaseIds[factionId] = -1;

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
