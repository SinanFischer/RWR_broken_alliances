// Defense-State (State = kleiner Laufzeitspeicher) fuer "frisch verlorene Basis".
array<int> g_fpLastLostBaseIdByFaction;
array<bool> g_fpHasPendingDefenseByFaction;

void fpDefenseEnsureFactionSlot(int factionId) {
	if (factionId < 0) return;
	int required = factionId + 1;
	if (int(g_fpLastLostBaseIdByFaction.size()) < required) {
		int oldSize = int(g_fpLastLostBaseIdByFaction.size());
		g_fpLastLostBaseIdByFaction.resize(required);
		g_fpHasPendingDefenseByFaction.resize(required);
		for (int i = oldSize; i < required; ++i) {
			g_fpLastLostBaseIdByFaction[i] = -1;
			g_fpHasPendingDefenseByFaction[i] = false;
		}
	}
}

void fpDefenseMarkBaseLost(int factionId, int baseId) {
	if (factionId < 0 || baseId < 0) return;
	fpDefenseEnsureFactionSlot(factionId);
	g_fpLastLostBaseIdByFaction[factionId] = baseId;
	g_fpHasPendingDefenseByFaction[factionId] = true;
}

bool fpDefensePeekLostBase(int factionId, int &out baseId) {
	baseId = -1;
	if (factionId < 0) return false;
	if (factionId >= int(g_fpLastLostBaseIdByFaction.size())) return false;
	if (!g_fpHasPendingDefenseByFaction[factionId]) return false;
	baseId = g_fpLastLostBaseIdByFaction[factionId];
	return baseId >= 0;
}

bool fpDefenseConsumeLostBase(int factionId, int &out baseId) {
	baseId = -1;
	if (!fpDefensePeekLostBase(factionId, baseId)) return false;
	g_fpHasPendingDefenseByFaction[factionId] = false;
	return true;
}
