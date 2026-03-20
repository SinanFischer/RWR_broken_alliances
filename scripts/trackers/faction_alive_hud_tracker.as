// Faction-Alive-HUD-Tracker: Zeigt pro Fraktion "alive / effectiveCap (bases)" in Fraktionsfarbe.
// Format: "42 / 180 (5)" — alive / effective capacity (Anzahl Basen)
// Mit RespawnSlotDelayTracker: effectiveCap = gecachte effektive Kapazität, bases = Basen-Anzahl.
// Ohne Tracker: effectiveCap = rohe soldier_capacity aus Engine, bases entfällt.
// Throttle: max. 1x/s — getCharacters ist ein Engine-Query, sparsam einsetzen.
//
// Commands:
//   /hud       – zeigt Status + verfügbare Befehle (jeder Spieler)
//   /hud on    – HUD einschalten (nur Admin, betrifft alle Spieler)
//   /hud off   – HUD ausschalten (nur Admin, betrifft alle Spieler)

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
	protected bool m_enabled = true;  // per /hud on|off steuerbar

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
		if (sub != "on" && sub != "off") {
			string status = m_enabled ? "AN" : "AUS";
			sendPrivateMessage(m_metagame, playerId, "[HUD] Status: " + status + " | Admin-Befehle: /hud on  /hud off");
			return;
		}

		// on/off nur für Admins – betrifft alle Spieler gleichzeitig
		if (!m_metagame.getAdminManager().isAdmin(playerName, playerId)) {
			sendPrivateMessage(m_metagame, playerId, "[HUD] Nur Admins können das HUD umschalten (gilt fuer alle Spieler).");
			return;
		}

		if (sub == "on") {
			setEnabled(true);
			sendPrivateMessage(m_metagame, playerId, "[HUD] Fraktions-HUD eingeschaltet.");
		} else {
			setEnabled(false);
			sendPrivateMessage(m_metagame, playerId, "[HUD] Fraktions-HUD ausgeschaltet.");
		}
	}

	// Baut den Anzeigetext: "alive / cap (bases)" mit Tracker, sonst nur "alive / rawCap"
	private string buildHudText(int fid, int alive) {
		if (m_respawnTracker !is null) {
			int cap   = m_respawnTracker.getEffectiveCapacityForFaction(fid);
			int bases = m_respawnTracker.getBasesForFactionCached(fid);
			return "" + alive + "/" + cap + " (" + bases + ")";
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
