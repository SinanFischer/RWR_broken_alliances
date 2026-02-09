// Reinforcement-Pool-Tracker: Pro Fraktion begrenzter Nachschub (z. B. 1000).
// Jeder Tod eines Soldaten verringert den Pool seiner Fraktion; bei 0 wird das Spawnen eingestellt.
// Commander meldet Schwellen; optional: update_score_display (UI oben, wenn die Engine es anzeigt).
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

const int REINFORCEMENT_POOL_INITIAL = 1000;  // Nachschub pro Fraktion

class ReinforcementPoolTracker : Tracker {
	protected Metagame@ m_metagame;
	protected dictionary m_pool;
	protected dictionary m_spawnDisabled;
	protected dictionary m_announcedThresholds;
	protected bool m_initialAnnounceDone = false;
	protected float m_timeAccum = 0.0f;
	// Schwellen für Commander-Meldungen: 800, 600, 500, 300, 100, 10
	protected array<int> m_thresholds;

	ReinforcementPoolTracker(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
		m_thresholds.insertLast(800);
		m_thresholds.insertLast(600);
		m_thresholds.insertLast(500);
		m_thresholds.insertLast(300);
		m_thresholds.insertLast(100);
		m_thresholds.insertLast(10);
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void update(float time) {
		if (!m_initialAnnounceDone) {
			m_timeAccum += time;
			if (m_timeAccum < 3.0f) return;
			m_initialAnnounceDone = true;
			array<const XmlElement@>@ factions = getFactions(m_metagame);
			for (uint i = 0; i < factions.size(); ++i) {
				int factionId = int(i);
				sendFactionMessage(m_metagame, factionId, "Nachschub: " + REINFORCEMENT_POOL_INITIAL + " verbleibend.", 0.95);
			}
			updateScoreDisplay();
			return;
		}
	}

	// Nutzt das gleiche UI wie Minimodes (Score-Anzeige oben). Nur die Zahl pro Fraktion, in Fraktionsfarbe.
	void updateScoreDisplay() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		for (uint i = 0; i < factions.size(); ++i) {
			int factionId = int(i);
			int pool = getPoolForFaction(factionId);
			const XmlElement@ faction = factions[i];
			string colorStr = faction.getStringAttribute("color");
			XmlElement cmd("command");
			cmd.setStringAttribute("class", "update_score_display");
			cmd.setIntAttribute("id", factionId);
			cmd.setStringAttribute("text", "" + pool);
			if (colorStr != "") {
				cmd.setStringAttribute("color", colorStr);
			}
			m_metagame.getComms().send(cmd);
		}
	}

	string factionKey(int factionId) { return "" + factionId; }

	int getPoolForFaction(int factionId) {
		string key = factionKey(factionId);
		if (!m_pool.exists(key)) {
			m_pool[key] = REINFORCEMENT_POOL_INITIAL;
		}
		return int(m_pool[key]);
	}

	void setPoolForFaction(int factionId, int value) {
		m_pool[factionKey(factionId)] = value;
	}

	bool isSpawnDisabled(int factionId) {
		string key = factionKey(factionId);
		return m_spawnDisabled.exists(key) && bool(m_spawnDisabled[key]);
	}

	void setSpawnDisabled(int factionId) {
		m_spawnDisabled[factionKey(factionId)] = true;
	}

	bool hasAnnouncedThreshold(int factionId, int value) {
		string key = factionKey(factionId) + "_" + value;
		return m_announcedThresholds.exists(key) && bool(m_announcedThresholds[key]);
	}

	void setAnnouncedThreshold(int factionId, int value) {
		m_announcedThresholds[factionKey(factionId) + "_" + value] = true;
	}

	void announceThreshold(int factionId, int pool) {
		if (pool == 0) {
			sendFactionMessage(m_metagame, factionId, "Nachschub aufgebraucht. Keine Verstärkung mehr.", 1.0);
			return;
		}
		for (uint i = 0; i < m_thresholds.size(); ++i) {
			if (int(m_thresholds[i]) == pool && !hasAnnouncedThreshold(factionId, pool)) {
				sendFactionMessage(m_metagame, factionId, "Nachschub: " + pool + " verbleibend.", 0.95);
				setAnnouncedThreshold(factionId, pool);
				break;
			}
		}
	}

	protected void handleCharacterKillEvent(const XmlElement@ event) {
		const XmlElement@ target = event.getFirstElementByTagName("target");
		if (target is null) return;

		int factionId = target.getIntAttribute("faction_id");
		int pool = getPoolForFaction(factionId);
		if (pool <= 0) return;  // bereits aufgebraucht, nichts tun

		pool--;
		setPoolForFaction(factionId, pool);
		_log("ReinforcementPool: Faction " + factionId + " -> " + pool + " verbleibend", 1);

		updateScoreDisplay();

		// Commander-Meldung bei Schwellen (800, 600, 500, 300, 100, 10) und bei aufgebraucht
		announceThreshold(factionId, pool);

		if (pool <= 0 && !isSpawnDisabled(factionId)) {
			disableSpawnForFaction(factionId);
			setSpawnDisabled(factionId);
		}
	}

	// Setzt capacity_multiplier der betroffenen Fraktion auf 0; andere Fraktionen unverändert lassen.
	void disableSpawnForFaction(int factionId) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		uint count = factions.size();
		if (count == 0) return;

		XmlElement command("command");
		command.setStringAttribute("class", "change_game_settings");
		for (uint i = 0; i < count; ++i) {
			XmlElement faction("faction");
			if (int(i) == factionId) {
				faction.setFloatAttribute("capacity_multiplier", 0.0f);
			}
			command.appendChild(faction);
		}
		m_metagame.getComms().send(command);
		_log("ReinforcementPool: Faction " + factionId + " – Nachschub aufgebraucht, Spawn deaktiviert.", 0);
	}
}
