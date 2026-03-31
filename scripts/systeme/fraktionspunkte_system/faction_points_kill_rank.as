#include "query_helpers.as"

// Kill-FP pro Platz (Platz = Rang nach Basisbesitz, 1 = meiste Basen).
const int FP_KILL_RANK_PLACE_1 = 2; // 2 
const int FP_KILL_RANK_PLACE_2 = 3; // 3 
const int FP_KILL_RANK_PLACE_3 = 5; // 4 

// Intervall fuer Neuberechnung der Kill-FP aus Basis-Ranking.
const float FP_KILL_RANK_REFRESH_INTERVAL = 30.0f;

// Schreibt pro faction_id den FP-Wert pro Kill: Ranking nach getBasesForFaction (absteigend).
// Gleichstand: niedrigere faction_id gilt als "besserer" Platz (deterministisch).
void fpComputeKillFpByBaseRanking(Metagame@ metagame, int factionCount, array<int>@ outRewards) {
	if (outRewards is null || metagame is null) return;
	if (factionCount < 0) factionCount = 0;
	outRewards.resize(factionCount);
	if (factionCount == 0) return;

	array<int> order;
	for (int i = 0; i < factionCount; ++i) order.insertLast(i);

	for (int i = 0; i < factionCount; ++i) {
		for (int j = i + 1; j < factionCount; ++j) {
			int bi = getBasesForFaction(metagame, order[i]);
			int bj = getBasesForFaction(metagame, order[j]);
			bool swap = false;
			if (bj > bi) swap = true;
			else if (bj == bi && order[j] < order[i]) swap = true;
			if (swap) {
				int tmp = order[i];
				order[i] = order[j];
				order[j] = tmp;
			}
		}
	}

	for (int pos = 0; pos < factionCount; ++pos) {
		int fid = order[pos];
		int fpVal = FP_KILL_RANK_PLACE_3;
		if (pos == 0) {
			fpVal = FP_KILL_RANK_PLACE_1;
		} else if (factionCount == 2) {
			// Nur 2 Fraktionen: der Unterlegene bekommt den hoechsten Catch-up-Wert (wie "Platz 3").
			fpVal = FP_KILL_RANK_PLACE_3;
		} else if (pos == 1) {
			fpVal = FP_KILL_RANK_PLACE_2;
		} else {
			fpVal = FP_KILL_RANK_PLACE_3;
		}
		outRewards[fid] = fpVal;
	}
}
