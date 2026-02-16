// Decision Context (Snapshot = komprimierter Zustand fuer eine Entscheidung).
class FactionPointsAiDecisionContext {
	int m_factionId = -1;
	int m_currentPoints = 0;
	int m_basesOwned = 0;
	int m_seedPlayerId = -1;
	bool m_hasActivePlayer = false;
}
