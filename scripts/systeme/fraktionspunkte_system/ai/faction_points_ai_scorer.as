#include "systeme/fraktionspunkte_system/ai/faction_points_ai_config.as"
#include "systeme/fraktionspunkte_system/ai/faction_points_ai_decision_context.as"

// Scorer (Scorer = Funktion, die Nutzwerte von 0.0 bis 1.0 liefert).
class FactionPointsAiScorer {
	float scoreEventToken(const string &in token, const FactionPointsAiDecisionContext &in ctx) const {
		if (token == "event1") {
			return scoreEvent1(ctx);
		}
		if (token == "event2") {
			return scoreEvent2(ctx);
		}
		if (token == "event3") {
			return scoreEvent3(ctx);
		}
		return 0.0f;
	}

	protected float scoreEvent1(const FactionPointsAiDecisionContext &in ctx) const {
		// Support wird relevanter, wenn wenige Basen gehalten werden.
		float basePressure = 0.2f;
		if (ctx.m_basesOwned <= 1) basePressure = 1.0f;
		else if (ctx.m_basesOwned == 2) basePressure = 0.7f;
		else if (ctx.m_basesOwned == 3) basePressure = 0.5f;

		float score = FP_AI_EVENT1_IMPORTANCE * basePressure;
		return clamp01(score);
	}

	protected float scoreEvent2(const FactionPointsAiDecisionContext &in ctx) const {
		// Angriff wird attraktiver, je naeher man am Sparziel ist.
		float economyProgress = 0.0f;
		if (FP_AI_EVENT2_SAVE_TARGET > 0) {
			economyProgress = float(ctx.m_currentPoints) / float(FP_AI_EVENT2_SAVE_TARGET);
		}

		float score = FP_AI_EVENT2_IMPORTANCE * clamp01(economyProgress);
		if (ctx.m_basesOwned <= 1) {
			// Unter Druck eher verteidigen als all-in angreifen.
			score *= 0.75f;
		}
		return clamp01(score);
	}

	protected float scoreEvent3(const FactionPointsAiDecisionContext &in ctx) const {
		// Defense hat Vorrang, wenn die Fraktion wenige Basen haelt.
		float pressure = 0.35f;
		if (ctx.m_basesOwned <= 1) pressure = 1.0f;
		else if (ctx.m_basesOwned == 2) pressure = 0.85f;
		else if (ctx.m_basesOwned == 3) pressure = 0.65f;
		return clamp01(FP_AI_EVENT3_IMPORTANCE * pressure);
	}

	protected float clamp01(float value) const {
		if (value < 0.0f) return 0.0f;
		if (value > 1.0f) return 1.0f;
		return value;
	}
}
