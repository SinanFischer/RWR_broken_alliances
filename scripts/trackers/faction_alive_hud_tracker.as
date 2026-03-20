// Faction-Alive-HUD-Tracker: Zeigt pro Fraktion "alive / effectiveCap" in Fraktionsfarbe.
// Format ohne Bases: "42 / 180"  — Format mit Bases: "42 / 180 (5)"
// Mit RespawnSlotDelayTracker: effectiveCap = gecachte effektive Kapazität.
// Ohne Tracker: effectiveCap = rohe soldier_capacity aus Engine.
// Throttle: max. 1x/s — getCharacters ist ein Engine-Query, sparsam einsetzen.
//
// Default: HUD AUS, Basen-Anzeige AUS.
// Commands (Admin):
//   /hud         – Status + verfügbare Befehle (jeder Spieler)
//   /hud on      – HUD einschalten
//   /hud off     – HUD ausschalten
//   /hud bases   – Basen-Anzeige "(x)" ein-/ausschalten (Toggle)

#include "tracker.as"
#include "log.as"
#include "query_helpers.as"
#include "helpers.as"
#include "admin_manager.as"

const float HUD_UPDATE_THROTTLE = 1.0f;  // 1x/s reicht für HUD-Anzeige, spart Engine-Queries

class FactionAliveHudTracker : Tracker {
	protected Metagame@ m_metagame;
	protected RespawnSlotDelayTracker@ m_respawnTracker;  // optional; liefert effectiveCap + bases
	protected float m_accum = 0.0f;
	protected bool m_enabled      = false;  // Default AUS; per /hud on einschalten
	protected bool m_showBases    = false;  // Default ohne Basen-Anzeige; /hud bases togglet

	FactionAliveHudTracker(Metagame@ metagame, RespawnSlotDelayTracker@ respawnTracker = null) {
		@m_metagame = @metagame;
		@m_respawnTracker = respawnTracker;
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void setEnabled(bool enabled) {
		m_enabled = enabled;
		if (!enabled) clearScoreDisplays();
	}

	bool isEnabled() const { return m_enabled; }

	void update(float time) {
		m_accum += time;
		if (m_accum < HUD_UPDATE_THROTTLE) return;
		m_accum = 0.0f;

		if (!m_enabled) return;

		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;

		for (uint i = 0; i < factions.size(); ++i) {
			int fid = int(i);
			array<const XmlElement@>@ chars = getCharacters(m_metagame, fid);
			int alive = (chars is null) ? 0 : int(chars.size());

			string text = buildHudText(fid, alive);
			string color = getScoreDisplayColor(factions[fid], fid);

			XmlElement cmd("command");
			cmd.setStringAttribute("class", "update_score_display");
			cmd.setIntAttribute("id", fid);
			cmd.setStringAttribute("text", text);
			cmd.setStringAttribute("color", color);
			m_metagame.getComms().send(cmd);
		}
	}

	// Löscht alle Score-Displays wenn HUD deaktiviert wird
	private void clearScoreDisplays() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;
		for (uint i = 0; i < factions.size(); ++i) {
			XmlElement cmd("command");
			cmd.setStringAttribute("class", "update_score_display");
			cmd.setIntAttribute("id", int(i));
			cmd.setStringAttribute("text", "");
			cmd.setStringAttribute("color", "0 0 0");
			m_metagame.getComms().send(cmd);
		}
	}

	protected void handleChatEvent(const XmlElement@ event) {
		string msg = event.getStringAttribute("message");
		if (!checkCommand(msg, "hud")) return;

		string playerName = event.getStringAttribute("player_name");
		int    playerId   = event.getIntAttribute("player_id");
		array<string> params = parseParameters(msg, "hud");
		string sub = (params.size() > 0) ? params[0].toLowerCase() : "";

		// Status-Abfrage ist für jeden erlaubt
		if (sub != "on" && sub != "off" && sub != "bases") {
			string status  = m_enabled   ? "AN"  : "AUS";
			string bases   = m_showBases ? "AN"  : "AUS";
			sendPrivateMessage(m_metagame, playerId,
				"[HUD] Status: " + status + " | Bases: " + bases +
				" | Befehle: /hud on  /hud off  /hud bases");
			return;
		}

		// on/off/bases nur für Admins – betrifft alle Spieler gleichzeitig
		if (!m_metagame.getAdminManager().isAdmin(playerName, playerId)) {
			sendPrivateMessage(m_metagame, playerId, "[HUD] Nur Admins koennen das HUD umschalten (gilt fuer alle Spieler).");
			return;
		}

		if (sub == "on") {
			setEnabled(true);
			sendPrivateMessage(m_metagame, playerId, "[HUD] Fraktions-HUD eingeschaltet.");
		} else if (sub == "off") {
			setEnabled(false);
			sendPrivateMessage(m_metagame, playerId, "[HUD] Fraktions-HUD ausgeschaltet.");
		} else {
			m_showBases = !m_showBases;
			string state = m_showBases ? "AN" : "AUS";
			sendPrivateMessage(m_metagame, playerId, "[HUD] Basen-Anzeige: " + state + ".");
		}
	}

	// Baut den Anzeigetext: "alive / cap" oder "alive / cap (bases)" je nach m_showBases
	private string buildHudText(int fid, int alive) {
		if (m_respawnTracker !is null) {
			int cap = m_respawnTracker.getEffectiveCapacityForFaction(fid);
			string text = "" + alive + "/" + cap;
			if (m_showBases) text += " (" + m_respawnTracker.getBasesForFactionCached(fid) + ")";
			return text;
		}
		// Fallback ohne Tracker: rohe Engine-Capacity
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || fid < 0 || uint(fid) >= factions.size()) return "" + alive;
		int rawCap = factions[fid].getIntAttribute("soldier_capacity");
		return "" + alive + " / " + rawCap;
	}

	string getScoreDisplayColor(const XmlElement@ faction, int factionId) {
		if (faction !is null) {
			string color = faction.getStringAttribute("color");
			if (color.length() > 0) return color;
			string name = faction.getStringAttribute("name").toLowerCase();
			string key  = faction.getStringAttribute("key").toLowerCase();
			if (name.findFirst("green") >= 0 || key.findFirst("green") >= 0 || name.findFirst("united states") >= 0) return "0.0 0.5 0.1";
			if (name.findFirst("grey") >= 0 || name.findFirst("gray") >= 0 || key.findFirst("grey") >= 0 || key.findFirst("gray") >= 0 || name.findFirst("european") >= 0) return "0.3 0.3 0.3";
			if (name.findFirst("brown") >= 0 || key.findFirst("brown") >= 0 || name.findFirst("russian") >= 0) return "0.5 0.35 0.1";
		}
		if (factionId == 0) return "0.0 0.5 0.1";
		if (factionId == 1) return "0.3 0.3 0.3";
		if (factionId == 2) return "0.5 0.35 0.1";
		return "0.5 0.5 0.5";
	}
}
