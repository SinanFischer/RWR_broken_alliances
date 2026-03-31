// /rs stats: Pro Fraktion A/K/D + LR (Lost Reservists aus ReinforcementStore).
// Cooldown 1s wie stats_command_tracker (Engine-Chat-Doppelung).

#include "tracker.as"
#include "log.as"
#include "query_helpers.as"
#include "helpers.as"
#include "systeme/reinforcemnt_system/reinforcement_store.as"

class ReinforcementStatsCommandTracker : Tracker {
	protected Metagame@ m_metagame;
	protected ReinforcementStore@ m_store;
	protected dictionary m_killsPerFaction;
	protected dictionary m_deathsPerFaction;
	protected dictionary m_lastResponseTime;
	protected float m_timeAccum = 0.0f;

	ReinforcementStatsCommandTracker(Metagame@ metagame, ReinforcementStore@ store) {
		@m_metagame = @metagame;
		@m_store = @store;
		m_metagame.getComms().send("<command class='set_metagame_event' name='chat_event' enabled='1' />");
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_die' enabled='1' />");
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void update(float time) { m_timeAccum += time; }

	protected void handleChatEvent(const XmlElement@ event) {
		string message = event.getStringAttribute("message");
		if (!checkCommand(message, "rs")) return;

		array<string> params = parseParameters(message, "rs");
		if (params.size() == 0 || params[0].toLowerCase() != "stats") return;

		int senderId = event.getIntAttribute("player_id");
		string senderKey = "" + senderId;
		float lastTime = m_lastResponseTime.exists(senderKey) ? float(m_lastResponseTime[senderKey]) : -999.0f;
		if (m_timeAccum - lastTime < 1.0f) return;
		m_lastResponseTime[senderKey] = m_timeAccum;

		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) {
			sendPrivateMessage(m_metagame, senderId, "[RS] No factions.");
			return;
		}

		string block = "";
		for (uint i = 0; i < factions.size(); ++i) {
			int fid = int(i);
			string label = getFactionRsLabel(factions[fid], fid);
			int alive = getAliveCountGlobal(fid);
			int kills = getKillsForFaction(fid);
			int deaths = getDeathsForFaction(fid);
			int lr = m_store.getLostReservists(fid);

			if (block.length() > 0) block += "\n";
			block += label + ": A/K/D: " + alive + "/" + kills + "/" + deaths + "  LR: " + lr;
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

	string getFactionRsLabel(const XmlElement@ faction, int factionId) {
		if (faction !is null) {
			string name = faction.getStringAttribute("name").toLowerCase();
			string key = faction.getStringAttribute("key").toLowerCase();
			if (name.findFirst("united states") >= 0 || key.findFirst("green") >= 0 || name.findFirst("green") >= 0)
				return "USA";
			if (name.findFirst("european") >= 0 || key.findFirst("grey") >= 0 || name.findFirst("grey") >= 0 || name.findFirst("gray") >= 0)
				return "EU";
			if (name.findFirst("russian") >= 0 || key.findFirst("brown") >= 0 || name.findFirst("brown") >= 0)
				return "RU";
			string rawKey = faction.getStringAttribute("key");
			if (rawKey.length() >= 3) return rawKey.substr(0, 3).toUpperCase();
			if (rawKey.length() > 0) return rawKey.toUpperCase();
			string rawName = faction.getStringAttribute("name");
			if (rawName.length() >= 3) return rawName.substr(0, 3).toUpperCase();
		}
		if (factionId == 0) return "USA";
		if (factionId == 1) return "EU";
		if (factionId == 2) return "RU";
		return "F" + factionId;
	}

	int getAliveCountGlobal(int factionId) {
		array<const XmlElement@>@ chars = getCharacters(m_metagame, factionId);
		return (chars is null) ? 0 : int(chars.size());
	}

	int getKillsForFaction(int factionId) {
		return getFactionDictInt(m_killsPerFaction, factionId);
	}

	int getDeathsForFaction(int factionId) {
		return getFactionDictInt(m_deathsPerFaction, factionId);
	}

	private string factionKey(int factionId) { return "" + factionId; }

	private void incrementFactionDict(dictionary@ dict, int factionId) {
		string k = factionKey(factionId);
		int v = dict.exists(k) ? int(dict[k]) : 0;
		dict[k] = v + 1;
	}

	private int getFactionDictInt(const dictionary@ dict, int factionId) {
		string k = factionKey(factionId);
		return dict.exists(k) ? int(dict[k]) : 0;
	}
}
