#include "metagame.as"
#include "log.as"
#include "query_helpers.as"
#include "systeme/reinforcemnt_system/reinforcement_config.as"

// Zeitverzoegerter Funk-Eintrag (sendAt = absoluter m_totalTime).
class RsCompPendingMessage {
	float  sendAt    = 0.0f;
	int    factionId = -1;
	string message   = "";
}

// Underdog-Kompensator: einmalige Eval, dann capacity_multiplier-Kette mit 60s-Lerps.
class ReinforcementCompensator {
	protected Metagame@ m_metagame;
	protected float m_totalTime = 0.0f;
	protected bool m_evaluated = false;
	protected bool m_sequenceActive = false;
	protected int m_underdogId = -1;
	protected int m_segment = RS_COMP_SEG_RAMP_UP;
	protected float m_segmentElapsed = 0.0f;
	protected array<RsCompPendingMessage@> m_pendingMessages;

	ReinforcementCompensator(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	void update(float dt) {
		if (dt < 0.0f) dt = 0.0f;
		m_totalTime += dt;
		flushPendingMessages();

		if (!m_evaluated) {
			if (m_totalTime >= RS_COMP_EVAL_DELAY_SECONDS) {
				m_evaluated = true;
				tryStartSequence();
			}
			return;
		}

		if (!m_sequenceActive) return;

		m_segmentElapsed += dt;
		while (m_sequenceActive) {
			float dur = getDurationForSegment(m_segment);
			if (m_segmentElapsed < dur) break;
			m_segmentElapsed -= dur;
			if (m_segment >= RS_COMP_SEG_RAMP_2_TO_1) {
				int endedFid = m_underdogId;
				m_sequenceActive = false;
				m_underdogId = -1;
				m_segmentElapsed = 0.0f;
				_log("UnderdogComp: sequence complete", 0);
				sendCompensatorEndMessages(endedFid);
				break;
			}
			m_segment++;
		}
	}

	float getCapacityMultiplier(int factionId) {
		if (!m_sequenceActive) return RS_COMP_MULT_BASE;
		if (factionId != m_underdogId) return RS_COMP_MULT_BASE;
		return computeCurrentMult();
	}

	protected float getDurationForSegment(int seg) {
		if (seg == RS_COMP_SEG_RAMP_UP || seg == RS_COMP_SEG_RAMP_4_TO_2 || seg == RS_COMP_SEG_RAMP_2_TO_1)
			return RS_COMP_LERP_SECONDS;
		if (seg == RS_COMP_SEG_HOLD1) return RS_COMP_PHASE1_HOLD_SECONDS;
		if (seg == RS_COMP_SEG_HOLD2) return RS_COMP_PHASE2_HOLD_SECONDS;
		return RS_COMP_LERP_SECONDS;
	}

	protected float lerp(float a, float b, float t) {
		if (t < 0.0f) t = 0.0f;
		if (t > 1.0f) t = 1.0f;
		return a + (b - a) * t;
	}

	protected float rampT(float elapsed) {
		if (RS_COMP_LERP_SECONDS <= 0.0f) return 1.0f;
		float t = elapsed / RS_COMP_LERP_SECONDS;
		if (t > 1.0f) t = 1.0f;
		return t;
	}

	protected float computeCurrentMult() {
		if (m_segment == RS_COMP_SEG_RAMP_UP)
			return lerp(RS_COMP_MULT_BASE, RS_COMP_MULT_PHASE1, rampT(m_segmentElapsed));
		if (m_segment == RS_COMP_SEG_HOLD1)
			return RS_COMP_MULT_PHASE1;
		if (m_segment == RS_COMP_SEG_RAMP_4_TO_2)
			return lerp(RS_COMP_MULT_PHASE1, RS_COMP_MULT_PHASE2, rampT(m_segmentElapsed));
		if (m_segment == RS_COMP_SEG_HOLD2)
			return RS_COMP_MULT_PHASE2;
		if (m_segment == RS_COMP_SEG_RAMP_2_TO_1)
			return lerp(RS_COMP_MULT_PHASE2, RS_COMP_MULT_BASE, rampT(m_segmentElapsed));
		return RS_COMP_MULT_BASE;
	}

	protected void tryStartSequence() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) {
			_log("UnderdogComp: eval skip - no factions", 0);
			return;
		}

		array<const XmlElement@>@ bases = getBases(m_metagame);
		array<int> baseCounts;
		baseCounts.resize(factions.size());
		for (uint i = 0; i < factions.size(); ++i) baseCounts[i] = 0;

		if (bases !is null) {
			for (uint b = 0; b < bases.size(); ++b) {
				int oid = bases[b].getIntAttribute("owner_id");
				if (oid >= 0 && uint(oid) < baseCounts.size()) baseCounts[oid]++;
			}
		}

		int underdog = -1;
		int countOne = 0;
		for (uint i = 0; i < baseCounts.size(); ++i) {
			if (baseCounts[i] == 1) {
				countOne++;
				underdog = int(i);
			}
		}
		if (countOne != 1) {
			_log("UnderdogComp: eval fail - factions with exactly 1 base: " + countOne, 0);
			return;
		}

		bool hasDominant = false;
		for (uint i = 0; i < baseCounts.size(); ++i) {
			if (baseCounts[i] >= RS_COMP_DOMINANT_MIN_BASES) {
				hasDominant = true;
				break;
			}
		}
		if (!hasDominant) {
			_log("UnderdogComp: eval fail - no faction with >=" + RS_COMP_DOMINANT_MIN_BASES + " bases", 0);
			return;
		}

		m_underdogId = underdog;
		m_sequenceActive = true;
		m_segment = RS_COMP_SEG_RAMP_UP;
		m_segmentElapsed = 0.0f;
		_log("UnderdogComp: sequence start fid=" + underdog, 0);
		sendCompensatorStartMessages(underdog);
	}

	// --- Early-Game-Texte wie respawn_slot_delay_tracker (Zeilen 236-248) ---
	protected void sendCompensatorStartMessages(int factionId) {
		string name = getFactionName(factionId);
		postFactionMessage(factionId,
			"We have received massive troop reinforcements. Prepare for a major offensive!");
		postGlobalExceptFaction(factionId,
			"Intercepted transmission: " + name + " has received major reinforcements. Brace for a large-scale assault!");
		scheduleMessageToFaction(factionId, RS_COMP_MSG_DELAY_SECONDS,
			"All units - move out! Give everything you have!");
		scheduleMessageGlobalExceptFaction(factionId, RS_COMP_MSG_DELAY_SECONDS,
			"Warning: " + name + " is launching a full assault. Hold all positions!");
	}

	// Ende der Boost-Sequenz: gleiche Struktur (Sofort + verzoegert), inhaltlich Abschluss.
	protected void sendCompensatorEndMessages(int factionId) {
		if (factionId < 0) return;
		string name = getFactionName(factionId);
		postFactionMessage(factionId,
			"Our mobilisation surge has ended; combat deployment returns to normal capacity.");
		postGlobalExceptFaction(factionId,
			"Intercepted transmission: " + name + " has completed their mobilisation surge. Threat level normalising.");
		scheduleMessageToFaction(factionId, RS_COMP_MSG_DELAY_SECONDS,
			"All units: hold gains and maintain standard logistics.");
		scheduleMessageGlobalExceptFaction(factionId, RS_COMP_MSG_DELAY_SECONDS,
			"Update: " + name + "'s reinforcement surge has ended. Continue mission per standard orders.");
	}

	protected void postFactionMessage(int factionId, string message) {
		sendFactionMessage(m_metagame, factionId, message, RS_COMP_MSG_PRIORITY);
	}

	protected void postGlobalExceptFaction(int excludeFactionId, string message) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;
		for (uint i = 0; i < factions.size(); ++i) {
			if (int(i) == excludeFactionId) continue;
			sendFactionMessage(m_metagame, int(i), message, RS_COMP_MSG_PRIORITY);
		}
	}

	protected void scheduleMessageToFaction(int factionId, float delaySeconds, string message) {
		RsCompPendingMessage@ pm = RsCompPendingMessage();
		pm.sendAt = m_totalTime + delaySeconds;
		pm.factionId = factionId;
		pm.message = message;
		m_pendingMessages.insertLast(pm);
	}

	protected void scheduleMessageGlobalExceptFaction(int excludeFactionId, float delaySeconds, string message) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;
		for (uint i = 0; i < factions.size(); ++i) {
			if (int(i) == excludeFactionId) continue;
			scheduleMessageToFaction(int(i), delaySeconds, message);
		}
	}

	protected void flushPendingMessages() {
		if (m_pendingMessages.size() == 0) return;
		array<RsCompPendingMessage@> remaining;
		for (uint i = 0; i < m_pendingMessages.size(); ++i) {
			RsCompPendingMessage@ pm = m_pendingMessages[i];
			if (pm.sendAt <= m_totalTime) {
				sendFactionMessage(m_metagame, pm.factionId, pm.message, RS_COMP_MSG_PRIORITY);
			} else {
				remaining.insertLast(pm);
			}
		}
		m_pendingMessages = remaining;
	}

	protected string getFactionName(int factionId) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factionId < 0 || uint(factionId) >= factions.size()) return "Unknown";
		return factions[factionId].getStringAttribute("name");
	}
}
