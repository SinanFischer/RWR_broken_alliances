#include "query_helpers.as"
#include "systeme/fraktionspunkte_system/faction_points_store.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event_interface.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event1_support_squad.as"
#include "systeme/fraktionspunkte_system/events/faction_points_event2_company_attack.as"

// Event-Registry (Registry = zentrale Event-Verwaltung und Lookup).
class FactionPointsEventRegistry {
	protected Metagame@ m_metagame;
	protected FactionPointsStore@ m_store;
	protected FactionPointsEvent1SupportSquad@ m_event1;
	protected FactionPointsEvent2CompanyAttack@ m_event2;

	FactionPointsEventRegistry(Metagame@ metagame, FactionPointsStore@ store) {
		@m_metagame = @metagame;
		@m_store = @store;
		@m_event1 = FactionPointsEvent1SupportSquad(m_metagame);
		@m_event2 = FactionPointsEvent2CompanyAttack(m_metagame);
	}

	bool isEventCommandToken(const string &in token) const {
		if (token == m_event1.getCommandToken()) return true;
		if (token == m_event2.getCommandToken()) return true;
		return false;
	}

	string getUsage() const {
		return "Events: /event1 (cost " + m_event1.getCost() + "), /event2 (cost " + m_event2.getCost() + ")";
	}

	bool tryExecute(const string &in token, int playerId, string &out response) {
		if (m_store is null) {
			response = "FP-Store nicht verfuegbar.";
			return false;
		}

		const XmlElement@ playerInfo = getPlayerInfo(m_metagame, playerId);
		if (playerInfo is null) {
			response = "Player nicht gefunden.";
			return false;
		}
		int factionId = playerInfo.getIntAttribute("faction_id");
		if (factionId < 0) {
			response = "Ungueltige Fraktion.";
			return false;
		}

		ensureFactionCountFromWorld();
		if (factionId >= m_store.getFactionCount()) {
			response = "Fraktionsindex ausserhalb des FP-Stores.";
			return false;
		}

		FactionPointsEvent@ ev = getEventByToken(token);
		if (ev is null) {
			response = "Unbekanntes Event.";
			return false;
		}

		string reason;
		if (!ev.canExecute(playerId, factionId, reason)) {
			response = ev.getDisplayName() + " nicht ausgefuehrt: " + reason;
			return false;
		}

		int cost = ev.getCost();
		if (!m_store.canSpend(factionId, cost)) {
			response = "Zu wenig FP fuer " + ev.getDisplayName() + " (cost " + cost + ", current " + m_store.get(factionId) + ").";
			return false;
		}

		string result;
		if (!ev.execute(playerId, factionId, result)) {
			response = ev.getDisplayName() + " fehlgeschlagen: " + result;
			return false;
		}

		m_store.spend(factionId, cost, true);
		response = result + " FP -" + cost + " (remaining " + m_store.get(factionId) + ").";
		return true;
	}

	protected FactionPointsEvent@ getEventByToken(const string &in token) const {
		if (token == m_event1.getCommandToken()) return m_event1;
		if (token == m_event2.getCommandToken()) return m_event2;
		return null;
	}

	protected void ensureFactionCountFromWorld() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;
		m_store.ensureFactionCount(int(factions.size()));
	}
}

