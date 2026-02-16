// /stats und /stat: Kompaktes Format pro Fraktion.
// Beispiel: EU: A-K-D: 50-100-80 C-B: 65-5 B(s): 150
//
// Legende:
//   A-K-D   = Alive, Kills, Deaths (Kills/Deaths = Fraktions-Stat)
//   C       = effektive Capacity (Spawn-Slots; mit RespawnSlotDelay: raw minus blockierte Slots)
//   B       = aktuell blockierte Slots (wie viele Slots gerade durch Respawn-Delay reserviert sind, nicht die Anzahl Toter)
//   B(s)    = kumulierte Slot-Sekunden (Impact: Summe aller durch Tode blockierten Slot×Sekunden dieser Fraktion)
// Ohne RespawnSlotDelayTracker: C = Raw-Capacity, B=0, B(s)=0.

#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

class StatsCommandTracker : Tracker {
	protected Metagame@ m_metagame;
	protected RespawnSlotDelayTracker@ m_respawnTracker; // optional: für effektive Capacity + blocked
	protected dictionary m_killsPerFaction;  // key = "0","1",... value = Anzahl Kills
	protected dictionary m_deathsPerFaction; // key = "0","1",... value = Anzahl Tode (sterbende Fraktion)

	StatsCommandTracker(Metagame@ metagame, RespawnSlotDelayTracker@ respawnTracker = null) {
		@m_metagame = metagame;
		@m_respawnTracker = respawnTracker;
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	protected void handleChatEvent(const XmlElement@ event) {
		string message = event.getStringAttribute("message");
		if (message.length() < 5 || message.substr(0, 5).toLowerCase() != "/stat")
			return;
		// /stats oder /stat
		if (message.length() > 5 && message.substr(5, 1) != "s" && message.substr(5, 1) != " ")
			return;
		int senderId = event.getIntAttribute("player_id");

		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) {
			sendPrivateMessage(m_metagame, senderId, "No factions.");
			return;
		}

		string block = "";
		for (uint i = 0; i < factions.size(); ++i) {
			int fid = int(i);
			string shortName = getFactionShortName(factions[fid], fid);
			int alive = getAliveCountGlobal(fid);
			int kills = getKillsForFaction(fid);
			int deaths = getDeathsForFaction(fid);
			int capacity = (m_respawnTracker !is null) ? m_respawnTracker.getEffectiveCapacityForFaction(fid) : getRawCapacity(fid);
			int blocked = (m_respawnTracker !is null) ? m_respawnTracker.getReservedSlots(fid) : 0;
			int blockedS = (m_respawnTracker !is null) ? int(m_respawnTracker.getTotalSlotSecondsBlocked(fid)) : 0;

			if (block.length() > 0) block += "\n";
			block += shortName + ": A-K-D: " + alive + "-" + kills + "-" + deaths + " C-B: " + capacity + "-" + blocked + " B(s): " + blockedS;
		}
		sendPrivateMessage(m_metagame, senderId, block);
	}

	protected void handleCharacterKillEvent(const XmlElement@ event) {
		const XmlElement@ killer = event.getFirstElementByTagName("killer");
		if (killer is null) return;
		int fid = killer.getIntAttribute("faction_id");
		if (fid < 0) return;
		incrementFactionDict(m_killsPerFaction, fid);
	}

	protected void handleCharacterDieEvent(const XmlElement@ event) {
		const XmlElement@ character = event.getFirstElementByTagName("character");
		const XmlElement@ target = character is null ? event.getFirstElementByTagName("target") : character;
		if (target is null) return;
		int fid = target.getIntAttribute("faction_id");
		if (fid < 0) return;
		incrementFactionDict(m_deathsPerFaction, fid);
	}

	string getFactionShortName(const XmlElement@ faction, int factionId) {
		if (faction is null) return "F" + factionId;
		string key = faction.getStringAttribute("key");
		if (key.length() >= 2) return key.substr(0, 2);
		string name = faction.getStringAttribute("name");
		if (name.length() >= 2) return name.substr(0, 2);
		return "F" + factionId;
	}

	int getAliveCountGlobal(int factionId) {
		array<const XmlElement@>@ chars = getCharacters(m_metagame, factionId);
		return (chars is null) ? 0 : int(chars.size());
	}

	int getRawCapacity(int factionId) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factionId < 0 || uint(factionId) >= factions.size()) return 0;
		int c = factions[factionId].getIntAttribute("soldier_capacity");
		return (c > 0) ? c : 0;
	}

	int getKillsForFaction(int factionId) {
		return getFactionDictInt(m_killsPerFaction, factionId);
	}

	int getDeathsForFaction(int factionId) {
		return getFactionDictInt(m_deathsPerFaction, factionId);
	}

	private string factionKey(int factionId) { return "" + factionId; }

	private void incrementFactionDict(dictionary@ dict, int factionId) {
		string key = factionKey(factionId);
		int v = dict.exists(key) ? int(dict[key]) : 0;
		dict[key] = v + 1;
	}

	private int getFactionDictInt(const dictionary@ dict, int factionId) {
		string key = factionKey(factionId);
		return dict.exists(key) ? int(dict[key]) : 0;
	}
}
