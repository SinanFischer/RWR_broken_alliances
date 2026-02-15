// IntelManager für Quick Match
// Basis: Vanilla IntelManager (Invasion). Angepasst für Metagame.
//
// Pro Fraktion: Jede Fraktion kann Feind-Basen scouten. Feind-Base = owner_id != eigene Fraktion.
// Scout = Einheit im center_block oder Fadenkreuz nahe Basis → Commander meldet Stärke.
// Stale-Reset: Nach 5 Min wird Intel als veraltet gewertet → Basis zurück auf "to investigate".
// Marker-ID: 5000 + factionId * 256 + baseId (max 8 Fraktionen, ~256 Basen).

#include "tracker.as"
#include "log.as"
#include "query_helpers.as"
#include "announce_task.as"
#include "events/captain_spawn_command_tracker.as"

const float INVESTIGATION_COMPLETE_CHECK_INTERVAL_TIME = 5.0;
const float INVESTIGATION_STALE_SECONDS = 300.0;  // Nach 5 Min: Intel veraltet → neu scouten
const int INTEL_MAX_FACTIONS = 8;
const int MARKER_ID_STRIDE = 256;

// --------------------------------------------
class IntelManagerQuickMatch : Tracker {
	protected Metagame@ m_metagame;
	protected bool m_started;
	protected float m_timer;
	protected float m_metagameTime;

	protected float m_reward;
	protected string m_requiredCallForHint;
	protected float m_requiredXPForHint;

	// Pro Fraktion: Basen zu scouten (owner_id != factionId)
	protected array<array<int>> m_basesToInvestigateByFaction;
	// Pro Fraktion: baseId -> letzter Scout-Zeitpunkt (für Stale-Reset)
	protected array<dictionary> m_investigatedTimestampByFaction;
	// Pro Fraktion: baseId -> zuletzt gemeldete Feindanzahl (für Marker-Text)
	protected array<dictionary> m_lastReportedEnemyCountByFaction;
	protected uint m_numFactions;
	protected bool m_basesInitialized;
	protected CaptainSpawnCommandTracker@ m_captainTracker;

	// ----------------------------------------------------
	IntelManagerQuickMatch(Metagame@ metagame, float reward = 100.0, string requiredCallForHint = "paratroopers1.call", float requiredXPForHint = 0.150, CaptainSpawnCommandTracker@ captainTracker = null) {
		@m_metagame = metagame;
		@m_captainTracker = captainTracker;
		m_started = false;
		m_timer = -1.0f;
		m_metagameTime = 0.0f;
		m_reward = reward;
		m_requiredCallForHint = requiredCallForHint;
		m_requiredXPForHint = requiredXPForHint;
		m_numFactions = 0;
		m_basesInitialized = false;
	}

	// ----------------------------------------------------
	protected void tryInitFactions() {
		if (m_numFactions > 0) return;
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;

		m_numFactions = factions.size();
		if (m_numFactions > INTEL_MAX_FACTIONS) m_numFactions = INTEL_MAX_FACTIONS;

		m_basesToInvestigateByFaction.resize(m_numFactions);
		m_investigatedTimestampByFaction.resize(m_numFactions);
		m_lastReportedEnemyCountByFaction.resize(m_numFactions);
		for (uint i = 0; i < m_numFactions; ++i) {
			m_investigatedTimestampByFaction[i] = dictionary();
			m_lastReportedEnemyCountByFaction[i] = dictionary();
		}
	}

	// ----------------------------------------------------
	void start() {
		m_started = true;
		m_timer = INVESTIGATION_COMPLETE_CHECK_INTERVAL_TIME;
		tryInitFactions();

		m_metagame.getComms().send("<command class='set_metagame_event' name='base_owner_change_event' enabled='1' />");
		m_metagame.getComms().send("<command class='set_metagame_event' name='attack_change_event' enabled='1' />");

		doBasesInit();
	}

	protected void doBasesInit() {
		if (m_basesInitialized) return;
		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (bases is null || m_numFactions == 0) return;

		m_basesInitialized = true;
		for (uint fid = 0; fid < m_numFactions; ++fid) {
			m_basesToInvestigateByFaction[fid].resize(0);
			for (uint i = 0; i < bases.size(); ++i) {
				const XmlElement@ base = bases[i];
				int ownerId = base.getIntAttribute("owner_id");
				if (int(fid) != ownerId && ownerId >= 0 && base.getBoolAttribute("capturable")) {
					m_basesToInvestigateByFaction[fid].push_back(base.getIntAttribute("id"));
				}
			}
			setBaseMarkersForFaction(int(fid));
		}
		_log("IntelManagerQuickMatch: Started, " + m_numFactions + " factions, each can scout enemy bases", 0);
	}

	// ----------------------------------------------------
	protected int getMarkerId(int baseId, int factionId) const {
		return 5000 + factionId * MARKER_ID_STRIDE + baseId;
	}

	// ----------------------------------------------------
	protected void setBaseMarker(const XmlElement@ base, int factionId, string style, string text = "") {
		int baseId = base.getIntAttribute("id");
		string position = base.getStringAttribute("position");
		int markerId = getMarkerId(baseId, factionId);
		int atlasIndex = style == "investigate" ? 5 : (style == "capture" ? 15 : 0);

		XmlElement command("command");
		command.setStringAttribute("class", "set_marker");
		command.setIntAttribute("id", markerId);
		command.setIntAttribute("faction_id", factionId);
		command.setIntAttribute("atlas_index", atlasIndex);
		command.setFloatAttribute("size", 2.0f);
		command.setBoolAttribute("enabled", style != "");
		command.setStringAttribute("position", position);
		if (text != "") command.setStringAttribute("text", text);
		command.setBoolAttribute("show_in_map_view", true);
		command.setBoolAttribute("show_in_game_view", false);
		command.setBoolAttribute("show_at_screen_edge", false);
		m_metagame.getComms().send(command);
	}

	// ----------------------------------------------------
	protected void clearBaseMarker(int baseId, int factionId) {
		int markerId = getMarkerId(baseId, factionId);
		XmlElement command("command");
		command.setStringAttribute("class", "set_marker");
		command.setIntAttribute("id", markerId);
		command.setIntAttribute("enabled", 0);
		command.setIntAttribute("faction_id", factionId);
		m_metagame.getComms().send(command);
	}

	// ----------------------------------------------------
	protected void setBaseMarkersForFaction(int factionId) {
		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (bases is null) return;
		array<int>@ toInv = m_basesToInvestigateByFaction[factionId];
		dictionary@ investigated = m_investigatedTimestampByFaction[factionId];

		for (uint i = 0; i < bases.size(); ++i) {
			const XmlElement@ base = bases[i];
			int baseId = base.getIntAttribute("id");
			int ownerId = base.getIntAttribute("owner_id");
			if (ownerId == factionId || !base.getBoolAttribute("capturable")) continue;

			bool isToInvestigate = toInv.find(baseId) >= 0;
			string key = "" + baseId;
			bool isInvestigated = investigated.exists(key);

			if (isToInvestigate)
				setBaseMarker(base, factionId, "investigate");
			else if (isInvestigated)
				setBaseMarker(base, factionId, "capture", getScoutedMarkerText(baseId, factionId));
		}
	}

	// ----------------------------------------------------
	protected bool isBaseToInvestigate(int baseId, int factionId) const {
		if (factionId < 0 || uint(factionId) >= m_numFactions) return false;
		return m_basesToInvestigateByFaction[factionId].find(baseId) >= 0;
	}

	// ----------------------------------------------------
	protected void setBaseToInvestigate(const XmlElement@ base, int factionId) {
		int baseId = base.getIntAttribute("id");
		if (isBaseToInvestigate(baseId, factionId)) return;
		m_basesToInvestigateByFaction[factionId].push_back(baseId);
		setBaseMarker(base, factionId, "investigate");
	}

	// ----------------------------------------------------
	protected void clearBaseToInvestigate(int baseId, int factionId) {
		if (!isBaseToInvestigate(baseId, factionId)) return;
		clearBaseMarker(baseId, factionId);
		array<int>@ arr = m_basesToInvestigateByFaction[factionId];
		int idx = arr.find(baseId);
		if (idx >= 0) arr.removeAt(idx);
	}

	// ----------------------------------------------------
	protected void setInvestigated(int baseId, int factionId) {
		string key = "" + baseId;
		m_investigatedTimestampByFaction[factionId].set(key, m_metagameTime);
	}

	// ----------------------------------------------------
	protected void clearInvestigated(int baseId, int factionId) {
		string key = "" + baseId;
		if (m_investigatedTimestampByFaction[factionId].exists(key))
			m_investigatedTimestampByFaction[factionId].delete(key);
	}

	// ----------------------------------------------------
	protected float getInvestigatedTimestamp(int baseId, int factionId) const {
		string key = "" + baseId;
		if (!m_investigatedTimestampByFaction[factionId].exists(key)) return -999.0f;
		float t = 0.0f;
		m_investigatedTimestampByFaction[factionId].get(key, t);
		return t;
	}

	protected int getLastReportedEnemyCount(int baseId, int factionId) const {
		string key = "" + baseId;
		if (!m_lastReportedEnemyCountByFaction[factionId].exists(key)) return -1;
		int c = 0;
		m_lastReportedEnemyCountByFaction[factionId].get(key, c);
		return c;
	}

	protected void setLastReportedEnemyCount(int baseId, int factionId, int count) {
		string key = "" + baseId;
		m_lastReportedEnemyCountByFaction[factionId].set(key, count);
	}

	protected string getScoutedMarkerText(int baseId, int factionId) const {
		float ts = getInvestigatedTimestamp(baseId, factionId);
		if (ts < -900.0f) return "";
		int count = getLastReportedEnemyCount(baseId, factionId);
		float mins = (m_metagameTime - ts) / 60.0f;
		string strength = (count < 0) ? "scouted" : (count <= 4 ? "very weak" : (count <= 10 ? "weak" : (count <= 15 ? "medium" : (count <= 20 ? "heavy" : "very heavy"))));
		return strength + ", " + formatInt(int(mins)) + " min ago";
	}

	// ----------------------------------------------------
	void gameContinuePreStart() {
		m_started = true;
	}

	// ----------------------------------------------------
	void end() {
	}

	// ----------------------------------------------------
	bool hasStarted() const {
		return m_started;
	}

	// ----------------------------------------------------
	bool hasEnded() const {
		return false;
	}

	// ----------------------------------------------------
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		tryInitFactions();
		if (m_numFactions == 0) return;

		int baseId = event.getIntAttribute("base_id");
		int newOwner = event.getIntAttribute("owner_id");
		const XmlElement@ base = getBase(m_metagame, baseId);
		if (base is null || !base.getBoolAttribute("capturable")) return;

		array<const XmlElement@>@ players = getPlayers(m_metagame);
		if (players is null) return;

		for (uint fid = 0; fid < m_numFactions; ++fid) {
			int factionId = int(fid);
			if (newOwner == factionId) {
				clearBaseMarker(baseId, factionId);
				clearBaseToInvestigate(baseId, factionId);
				clearInvestigated(baseId, factionId);
			} else if (newOwner >= 0) {
				clearInvestigated(baseId, factionId);
				int charId = -1, playerId = -1;
				if (checkProximity(base, players, factionId, charId, playerId)) {
					int enemy = base.getIntAttribute("owner_id");
					Vector3 pos = stringToVector3(base.getStringAttribute("position"));
					array<const XmlElement@>@ enemies = getCharactersNearPosition(m_metagame, pos, enemy, 60.0f);
					setLastReportedEnemyCount(baseId, factionId, enemies !is null ? int(enemies.size()) : 0);
					setInvestigated(baseId, factionId);
					setBaseMarker(base, factionId, "capture", getScoutedMarkerText(baseId, factionId));
				} else {
					setBaseToInvestigate(base, factionId);
				}
			}
		}
	}

	// ----------------------------------------------------
	protected void handleAttackChangeEvent(const XmlElement@ event) {
		tryInitFactions();
		if (m_numFactions == 0) return;

		int baseId = event.getIntAttribute("base_id");
		int attackingFactionId = event.getIntAttribute("faction_id");
		if (baseId < 0 || attackingFactionId < 0 || uint(attackingFactionId) >= m_numFactions) return;
		if (!isBaseToInvestigate(baseId, attackingFactionId)) return;

		const XmlElement@ base = getBase(m_metagame, baseId);
		if (base !is null) {
			int enemy = base.getIntAttribute("owner_id");
			Vector3 pos = stringToVector3(base.getStringAttribute("position"));
			array<const XmlElement@>@ enemies = getCharactersNearPosition(m_metagame, pos, enemy, 60.0f);
			setLastReportedEnemyCount(baseId, attackingFactionId, enemies !is null ? int(enemies.size()) : 0);
			clearBaseToInvestigate(baseId, attackingFactionId);
			setInvestigated(baseId, attackingFactionId);
			setBaseMarker(base, attackingFactionId, "capture", getScoutedMarkerText(baseId, attackingFactionId));

			if (m_captainTracker !is null)
				m_captainTracker.notifyCaptainDiscoveredAtBase(baseId, enemy, attackingFactionId, pos);
		}
	}

	// ----------------------------------------------------
	void update(float time) {
		m_metagameTime += time;
		tryInitFactions();
		doBasesInit();
		if (m_numFactions == 0) return;

		m_timer -= time;
		if (m_timer < 0.0) {
			m_timer = INVESTIGATION_COMPLETE_CHECK_INTERVAL_TIME;
			checkProximityCompletion();
			checkStaleReset();
			checkCaptainDiscoveryAtInvestigatedBases();
			for (uint fid = 0; fid < m_numFactions; ++fid)
				setBaseMarkersForFaction(int(fid));
		}
	}

	protected void checkCaptainDiscoveryAtInvestigatedBases() {
		if (m_captainTracker is null) return;
		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (bases is null) return;

		for (uint fid = 0; fid < m_numFactions; ++fid) {
			int spotterFactionId = int(fid);
			for (uint i = 0; i < bases.size(); ++i) {
				const XmlElement@ base = bases[i];
				int baseId = base.getIntAttribute("id");
				int ownerId = base.getIntAttribute("owner_id");
				if (ownerId == spotterFactionId || ownerId < 0 || !base.getBoolAttribute("capturable")) continue;
				if (getInvestigatedTimestamp(baseId, spotterFactionId) < -900.0f) continue;

				Vector3 pos = stringToVector3(base.getStringAttribute("position"));
				m_captainTracker.notifyCaptainDiscoveredAtBase(baseId, ownerId, spotterFactionId, pos);
			}
		}
	}

	protected void checkStaleReset() {
		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (bases is null) return;

		for (uint i = 0; i < bases.size(); ++i) {
			const XmlElement@ base = bases[i];
			int baseId = base.getIntAttribute("id");
			int ownerId = base.getIntAttribute("owner_id");
			if (!base.getBoolAttribute("capturable")) continue;

			for (uint fid = 0; fid < m_numFactions; ++fid) {
				if (ownerId == int(fid)) continue;
				if (ownerId < 0) continue;
				if (isBaseToInvestigate(baseId, int(fid))) continue;

				float ts = getInvestigatedTimestamp(baseId, int(fid));
				if (ts > -900.0f && (m_metagameTime - ts) >= INVESTIGATION_STALE_SECONDS) {
					clearInvestigated(baseId, int(fid));
					setBaseToInvestigate(base, int(fid));
				}
			}
		}
	}

	// ----------------------------------------------------
	protected bool checkProximity(const XmlElement@ base, const array<const XmlElement@>@ players, int factionId, int &out characterId, int &out playerId) const {
		characterId = -1;
		playerId = -1;

		string block = base.getStringAttribute("center_block");
		array<string> blocks;
		blocks.insertLast(block);
		array<const XmlElement@>@ list = getCharactersInBlocks(m_metagame, factionId, blocks);
		if (list !is null && list.size() > 0) {
			for (uint k = 0; k < players.size() && characterId < 0; ++k) {
				const XmlElement@ player = players[k];
				if (player.getIntAttribute("faction_id") != factionId) continue;
				int playerCid = player.getIntAttribute("character_id");
				for (uint j = 0; j < list.size() && characterId < 0; ++j) {
					const XmlElement@ character = list[j];
					if (character.getIntAttribute("id") == playerCid) {
						characterId = playerCid;
						playerId = player.getIntAttribute("player_id");
					}
				}
			}
			if (characterId < 0) characterId = list[0].getIntAttribute("id");
		} else {
			Vector3 centerBlockPosition = stringToVector3(base.getStringAttribute("position"));
			for (uint k = 0; k < players.size(); ++k) {
				const XmlElement@ player = players[k];
				if (player.getIntAttribute("faction_id") != factionId) continue;
				if (player.hasAttribute("aim_target")) {
					Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
					if (checkRange(target, centerBlockPosition, 25.0f)) {
						characterId = player.getIntAttribute("character_id");
						playerId = player.getIntAttribute("player_id");
						break;
					}
				}
			}
		}
		return characterId >= 0;
	}

	// ----------------------------------------------------
	protected void checkProximityCompletion() {
		array<const XmlElement@>@ players = getPlayers(m_metagame);
		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (players is null || bases is null) return;

		for (uint fid = 0; fid < m_numFactions; ++fid) {
			for (uint i = 0; i < bases.size(); ++i) {
				const XmlElement@ base = bases[i];
				int baseId = base.getIntAttribute("id");
				if (!isBaseToInvestigate(baseId, int(fid))) continue;

				int characterId = -1, playerId = -1;
				if (checkProximity(base, players, int(fid), characterId, playerId)) {
					setInvestigationComplete(base, characterId, playerId, int(fid));
				}
			}
		}
	}

	// ----------------------------------------------------
	protected void setInvestigationComplete(const XmlElement@ base, int characterId, int playerId, int factionId) {
		string baseName = base.getStringAttribute("name");
		int baseId = base.getIntAttribute("id");

		clearBaseToInvestigate(baseId, factionId);
		setInvestigated(baseId, factionId);

		int enemy = base.getIntAttribute("owner_id");
		Vector3 position = stringToVector3(base.getStringAttribute("position"));
		array<const XmlElement@>@ enemies = getCharactersNearPosition(m_metagame, position, enemy, 60.0f);
		int enemyCount = enemies !is null ? int(enemies.size()) : 0;
		setLastReportedEnemyCount(baseId, factionId, enemyCount);
		setBaseMarker(base, factionId, "capture", getScoutedMarkerText(baseId, factionId));

		if (m_captainTracker !is null)
			m_captainTracker.notifyCaptainDiscoveredAtBase(baseId, enemy, factionId, position);

		string c = "<command class='rp_reward' character_id='" + characterId + "' reward='" + m_reward + "' />";
		m_metagame.getComms().send(c);

		int otherEnemy = (enemy == 1 && factionId == 0) || (enemy == 0 && factionId == 1) ? 2 : ((enemy == 2 || factionId == 2) ? 1 : -1);
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (otherEnemy >= 0 && factions !is null && otherEnemy < int(factions.size())) {
			const XmlElement@ factionEl = factions[otherEnemy];
			if (factionEl !is null && factionEl.getStringAttribute("name") == "Neutral") otherEnemy = -1;
		}
		int otherEnemyCount = 0;
		if (otherEnemy >= 0) {
			array<const XmlElement@>@ oe = getCharactersNearPosition(m_metagame, position, otherEnemy, 60.0f);
			otherEnemyCount = oe !is null ? int(oe.size()) : 0;
		}

		if (otherEnemyCount >= 2 || otherEnemyCount > enemyCount) {
		} else {
			string range = "";
			int veryWeak = 4, weak = 10, medium = 15;
			string intelKey, commanderKey;
			if (enemyCount <= veryWeak) {
				intelKey = "report very weak defense";
				commanderKey = "respond very weak defense";
				range = "0-4";
			} else if (enemyCount <= weak) {
				intelKey = "report weak defense";
				commanderKey = "respond weak defense";
				range = "5-10";
			} else if (enemyCount <= medium) {
				intelKey = "report medium defense";
				commanderKey = "respond medium defense";
				range = "10-15";
			} else if (enemyCount <= 20) {
				intelKey = "report heavy defense";
				commanderKey = "respond heavy defense";
				range = "16-20";
			} else {
				intelKey = "report very heavy defense";
				commanderKey = "respond very heavy defense";
				range = "20+";
			}

			dictionary a = {
				{"%base_name", baseName},
				{"%enemy_count", formatInt(enemyCount)},
				{"%enemy_range", range}
			};

			sendFactionMessageKeySaidAsCharacter(m_metagame, factionId, characterId, intelKey, a);
			sendFactionMessageKey(m_metagame, factionId, intelKey, a);

			if (playerId >= 0) {
				m_metagame.getTaskSequencer().add(AnnouncePrivateTask(m_metagame, 2.0f, playerId, ""));
				m_metagame.getTaskSequencer().add(AnnouncePrivateTask(m_metagame, 4.0f, playerId, commanderKey));
			}
		}
	}

	// ----------------------------------------------------
	protected bool hasCallAvailable(string key, int factionId) {
		array<const XmlElement@>@ calls = getFactionResources(m_metagame, factionId, "call", "calls");
		if (calls is null) return false;
		for (uint i = 0; i < calls.size(); ++i) {
			if (calls[i].getStringAttribute("key") == key) return true;
		}
		return false;
	}

	// ----------------------------------------------------
	protected bool hasEnoughXP(int characterId, float xp) {
		const XmlElement@ info = getCharacterInfo(m_metagame, characterId);
		return info !is null && info.getFloatAttribute("xp") >= xp;
	}

	// ----------------------------------------------------
	void onRemove() {
		m_started = false;
	}
}
