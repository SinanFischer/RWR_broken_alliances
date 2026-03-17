// Adaptive Commander AI — Tracker: nutzt Capacity-Ratio, setzt commander_ai, sendet Radio bei Wechsel.
// Ueberschreibt /ai_* manuell gesetzte Werte alle AI_UPDATE_INTERVAL Sekunden (MVP akzeptiert).
// Admin-Befehl: /ai_adaptive_status — gibt Ratio, State und defense-Werte aller Fraktionen aus.

#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "query_helpers.as"
#include "trackers/respawn_slot_delay_tracker.as"
#include "systems/commander_ai_adaptive/commander_ai_adaptive_logic.as"

const string CMD_AI_ADAPTIVE_STATUS = "ai_adaptive_status";

class CommanderAiAdaptiveTracker : Tracker {
	protected Metagame@ m_metagame;
	protected RespawnSlotDelayTracker@ m_respawnTracker;
	protected float m_accum = 0.0f;
	protected array<int> m_lastState;

	CommanderAiAdaptiveTracker(Metagame@ metagame, RespawnSlotDelayTracker@ respawnTracker) {
		@m_metagame = @metagame;
		@m_respawnTracker = @respawnTracker;
		m_lastState.resize(4);
		for (uint i = 0; i < m_lastState.size(); i++)
			m_lastState[i] = -1;
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }
	void start() {}

	void update(float time) {
		m_accum += time;
		if (m_accum < AI_UPDATE_INTERVAL) return;
		m_accum = 0.0f;
		evaluateAndApplyAll();
	}

	void evaluateAndApplyAll() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;
		if (m_respawnTracker is null) return;

		if (int(m_lastState.size()) < int(factions.size()))
			m_lastState.resize(factions.size());

		for (uint i = 0; i < factions.size(); i++) {
			int fid = factions[i].getIntAttribute("id");
			int rawCap = m_respawnTracker.getBaseCapacity(fid);
			if (rawCap <= 0) continue;
			int effectiveCap = m_respawnTracker.getEffectiveCapacityForFaction(fid);
			float ratio = float(effectiveCap) / float(rawCap);
			int state = computeAiState(ratio);

			int prev = (int(i) < int(m_lastState.size())) ? m_lastState[i] : -1;
			if (state != prev) {
				float baseDef = getAiBaseDef(state);
				float borderDef = getAiBorderDef(state);
				sendCommanderAiForFaction(fid, baseDef, borderDef);
				if (prev >= 0) broadcastRadioMessage(getAiRadioMessage(state));
				m_lastState[i] = state;
			}
		}
	}

	void sendCommanderAiForFaction(int fid, float baseDef, float borderDef) {
		string cmd = "<command class='commander_ai'"
			+ " faction='" + fid + "'"
			+ " base_defense='" + formatFloat(baseDef, "", 0, 2) + "'"
			+ " border_defense='" + formatFloat(borderDef, "", 0, 2) + "'"
			+ " />";
		m_metagame.getComms().send(cmd);
	}

	void broadcastRadioMessage(string msg) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;
		for (uint i = 0; i < factions.size(); i++)
			sendFactionMessage(m_metagame, factions[i].getIntAttribute("id"), msg, 1.5f);
	}

	protected void handleChatEvent(const XmlElement@ event) {
		string msg = event.getStringAttribute("message");
		if (!startsWith(msg, "/")) return;
		string playerName = event.getStringAttribute("player_name");
		int    playerId   = event.getIntAttribute("player_id");
		if (!m_metagame.getAdminManager().isAdmin(playerName, playerId)) return;
		if (checkCommand(msg, CMD_AI_ADAPTIVE_STATUS)) handleAdaptiveStatus(playerId);
	}

	private void handleAdaptiveStatus(int playerId) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || m_respawnTracker is null) {
			sendPrivateMessage(m_metagame, playerId, "[AI-Adaptive] Kein Tracker aktiv.");
			return;
		}

		// Zeitraum bis zum naechsten Check
		float nextCheck = AI_UPDATE_INTERVAL - m_accum;

		string report = "[AI-Adaptive] Check alle " + AI_UPDATE_INTERVAL + "s | naechster in "
			+ formatFloat(nextCheck, "", 0, 1) + "s\n";

		for (uint i = 0; i < factions.size(); i++) {
			int fid = factions[i].getIntAttribute("id");
			int rawCap = m_respawnTracker.getBaseCapacity(fid);
			if (rawCap <= 0) { report += "  Fakt." + fid + " — kein Capacity-Wert\n"; continue; }

			int effectiveCap = m_respawnTracker.getEffectiveCapacityForFaction(fid);
			float ratio = float(effectiveCap) / float(rawCap);
			int state = computeAiState(ratio);

			string stateLabel = "?";
			if      (state == AI_STATE_DOMINANT)  stateLabel = "DOMINANT";
			else if (state == AI_STATE_ATTACK)     stateLabel = "ATTACK";
			else if (state == AI_STATE_BALANCED)   stateLabel = "BALANCED";
			else if (state == AI_STATE_DEFENSIVE)  stateLabel = "DEFENSIVE";
			else if (state == AI_STATE_CRITICAL)   stateLabel = "CRITICAL";

			report += "  Fakt." + fid
				+ " | ratio=" + formatFloat(ratio, "", 0, 2)
				+ " (" + effectiveCap + "/" + rawCap + ")"
				+ " | state=" + stateLabel
				+ " | base=" + formatFloat(getAiBaseDef(state), "", 0, 2)
				+ " border=" + formatFloat(getAiBorderDef(state), "", 0, 2) + "\n";
		}

		_log(report);
		sendPrivateMessage(m_metagame, playerId, report);
	}
}
