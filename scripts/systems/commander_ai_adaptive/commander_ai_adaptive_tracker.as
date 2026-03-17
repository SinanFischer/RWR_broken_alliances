// Adaptive Commander AI — Tracker: nutzt Capacity-Ratio, setzt commander_ai, sendet Radio bei Wechsel.
// Ueberschreibt /ai_* manuell gesetzte Werte alle AI_UPDATE_INTERVAL Sekunden (MVP akzeptiert).

#include "tracker.as"
#include "helpers.as"
#include "query_helpers.as"
#include "trackers/respawn_slot_delay_tracker.as"
#include "systems/commander_ai_adaptive/commander_ai_adaptive_logic.as"

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

		if (m_lastState.size() < int(factions.size()))
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
}
