#include "tracker.as"
#include "log.as"
#include "systeme/fraktionspunkte_system/faction_points_store.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_registry.as"
#include "systeme/fraktionspunkte_system/ai/faction_points_ai_config.as"
#include "systeme/fraktionspunkte_system/ai/faction_points_ai_planner.as"

// AI-Tracker (Tracker = periodischer Taktgeber fuer AI-Entscheidungen).
class FactionPointsAiTracker : Tracker {
	protected Metagame@ m_metagame;
	protected FactionPointsStore@ m_store;
	protected FactionPointsEventRegistry@ m_eventRegistry;
	protected FactionPointsAiPlanner@ m_planner;
	protected float m_decisionTimer = FP_AI_DECISION_INTERVAL;
	protected string m_lastSummary = "AI: not started";

	FactionPointsAiTracker(Metagame@ metagame, FactionPointsStore@ store) {
		@m_metagame = @metagame;
		@m_store = @store;
		@m_eventRegistry = FactionPointsEventRegistry(m_metagame, m_store);
		@m_planner = FactionPointsAiPlanner(m_metagame, m_store, m_eventRegistry);
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void update(float time) {
		if (m_planner is null) return;
		m_decisionTimer -= time;
		if (m_decisionTimer > 0.0f) return;

		string summary;
		bool executed = m_planner.tick(summary);
		m_lastSummary = summary;
		if (executed || FP_AI_VERBOSE_LOG) {
			_log("FP-AI: " + summary, 1);
		}

		m_decisionTimer = FP_AI_DECISION_INTERVAL;
	}

	void forceTick(string &out result) {
		if (m_planner is null) {
			result = "AI planner missing.";
			return;
		}
		string summary;
		m_planner.tick(summary);
		m_lastSummary = summary;
		result = summary;
	}

	float getSecondsUntilNextTick() const {
		if (m_decisionTimer < 0.0f) return 0.0f;
		return m_decisionTimer;
	}

	string getLastSummary() const {
		return m_lastSummary;
	}
}
