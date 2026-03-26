// Adaptive Commander AI - Tracker.
// Grundprinzip: Native AI laeuft unberuehrt. Nur bei konkreten Events (DEFENSIVE_PAUSE /
// GRAND_ASSAULT) greift der Tracker zeitlich begrenzt ein und revertiert danach.
//
// Ablauf:
//   1. start() wartet AI_START_DELAY Sekunden (Map-Ladezeit ueberbruecken).
//   2. Beim ersten evaluateAndApplyAll(): Native-Cache befuellen (Map-Lookup oder Formel).
//   3. Alle AI_UPDATE_INTERVAL Sekunden: Ratio pruefen, Event ggf. starten.
//   4. Event laeuft AI_DURATION_* Sekunden, dann automatischer Revert auf native Werte.
//   5. Nach Revert: AI_COOLDOWN_AFTER_EVENT Sekunden Sperrzeit.
//
// Admin-Commands: /ai_status, /ai_attack [faction], /ai_defend [faction]

#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "query_helpers.as"
#include "trackers/respawn_slot_delay_tracker.as"
#include "systems/commander_ai_adaptive/commander_ai_adaptive_logic.as"

const string CMD_AI_STATUS = "ai_status";
const string CMD_AI_ATTACK = "ai_attack";
const string CMD_AI_DEFEND = "ai_defend";

// Pro Fraktion gespeicherter Zustand
class FactionAiState {
	int   eventId       = AI_EVENT_IDLE;
	float eventTimer    = 0.0f;   // verbleibende Sekunden des aktiven Events
	float cooldownTimer = 0.0f;   // verbleibende Sperrzeit nach Event-Ende
	float nativeBase    = AI_NATIVE_FALLBACK_BASE;
	float nativeBorder  = AI_NATIVE_FALLBACK_BORDER;
	bool  nativeCached  = false;
}

class CommanderAiAdaptiveTracker : Tracker {
	protected Metagame@ m_metagame;
	protected RespawnSlotDelayTracker@ m_respawnTracker;

	protected float m_startDelay  = AI_START_DELAY;
	protected bool  m_started     = false;
	protected float m_accum       = 0.0f;
	protected array<FactionAiState@> m_states;

	// Pseudo-Zufallszaehler fuer GRAND_ASSAULT-Chance (deterministisch, kein API-Aufruf noetig)
	protected float m_randSeed = 0.37f;

	CommanderAiAdaptiveTracker(Metagame@ metagame, RespawnSlotDelayTracker@ respawnTracker) {
		@m_metagame      = @metagame;
		@m_respawnTracker = @respawnTracker;
		m_states.resize(8);
		for (uint i = 0; i < m_states.size(); i++)
			@m_states[i] = FactionAiState();
	}

	bool hasEnded()   const { return false; }
	bool hasStarted() const { return true; }
	void start() {}

	void update(float time) {
		// --- Phase 1: Startverzoegerung abwarten ---
		if (!m_started) {
			m_startDelay -= time;
			if (m_startDelay > 0.0f) return;
			m_started = true;
			initNativeCache();  // einmalig Native-Werte befuellen
		}

		// --- Phase 2: Event-Timer pro Fraktion herunterzaehlen ---
		tickEventTimers(time);

		// --- Phase 3: Evaluierungs-Intervall ---
		m_accum += time;
		if (m_accum < AI_UPDATE_INTERVAL) return;
		m_accum = 0.0f;
		evaluateAndApplyAll();
	}

	// -----------------------------------------------------------------------
	// Native-Cache: einmalig beim Start befuellen
	// -----------------------------------------------------------------------
	private void initNativeCache() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || m_respawnTracker is null) return;

		ensureStatesSize(int(factions.size()));

		// Gesamtbasen aller Fraktionen fuer Formel-Fallback
		int totalBases = 0;
		for (uint i = 0; i < factions.size(); i++)
			totalBases += m_respawnTracker.getBasesForFactionCached(factions[i].getIntAttribute("id"));

		// Map-Key fuer Lookup (leer wenn nicht verfuegbar)
		string mapPath = "";

		for (uint i = 0; i < factions.size(); i++) {
			int fid = factions[i].getIntAttribute("id");
			FactionAiState@ s = m_states[i];

			float base = 0.0f;
			float border = 0.0f;
			getNativeCommanderAiValues(mapPath, fid, base, border);

			// Wenn Lookup keinen Map-Eintrag hatte (Fallback-Wert zurueck), Formel nutzen
			if (base == AI_NATIVE_FALLBACK_BASE && border == AI_NATIVE_FALLBACK_BORDER && totalBases > 0) {
				int factionBases = m_respawnTracker.getBasesForFactionCached(fid);
				computeNativeFallbackFromBases(factionBases, totalBases, base, border);
			}

			s.nativeBase   = base;
			s.nativeBorder = border;
			s.nativeCached = true;
			_log("AI-Adaptive: Fakt." + fid + " native cache → base=" + base + " border=" + border);
		}
	}

	// -----------------------------------------------------------------------
	// Event-Timer herunterzaehlen, Revert bei Ablauf
	// -----------------------------------------------------------------------
	private void tickEventTimers(float time) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;

		for (uint i = 0; i < factions.size() && i < m_states.size(); i++) {
			FactionAiState@ s = m_states[i];
			int fid = factions[i].getIntAttribute("id");

			// Cooldown herunterzaehlen
			if (s.cooldownTimer > 0.0f) {
				s.cooldownTimer -= time;
				if (s.cooldownTimer < 0.0f) s.cooldownTimer = 0.0f;
			}

			// Aktives Event herunterzaehlen
			if (s.eventId != AI_EVENT_IDLE) {
				s.eventTimer -= time;
				if (s.eventTimer <= 0.0f) {
					revertToNative(fid, i);
				}
			}
		}
	}

	// -----------------------------------------------------------------------
	// Evaluierung: Trigger pruefen und ggf. Event starten
	// -----------------------------------------------------------------------
	private void evaluateAndApplyAll() {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || factions.size() == 0) return;
		if (m_respawnTracker is null) return;

		ensureStatesSize(int(factions.size()));

		for (uint i = 0; i < factions.size(); i++) {
			FactionAiState@ s = m_states[i];
			int fid = factions[i].getIntAttribute("id");

			// Kein neues Event wenn bereits eines laeuft oder Cooldown aktiv
			if (s.eventId != AI_EVENT_IDLE || s.cooldownTimer > 0.0f) continue;

			int liveCount = m_respawnTracker.getLiveCount(fid);
			if (liveCount <= 0) continue;
			int effectiveCap = m_respawnTracker.getEffectiveCapacityForFaction(fid);
			// ratio = effektive Slots / tatsächlich lebende Soldaten (nicht xmlCapacity!)
			// xmlCapacity ist ein Map-Gewichtungsfaktor, kein Feldstärke-Vergleichswert.
			float ratio = float(effectiveCap) / float(liveCount);

			// DEFENSIVE_PAUSE hat Prioritaet ueber GRAND_ASSAULT
			if (shouldTriggerDefensivePause(ratio)) {
				startEvent(fid, i, AI_EVENT_DEFENSIVE_PAUSE);
			} else {
				float rnd = nextRandom();
				if (shouldTriggerGrandAssault(ratio, rnd)) {
					startEvent(fid, i, AI_EVENT_GRAND_ASSAULT);
				}
			}
		}
	}

	// -----------------------------------------------------------------------
	// Event starten
	// -----------------------------------------------------------------------
	private void startEvent(int fid, int stateIdx, int eventId) {
		FactionAiState@ s = m_states[stateIdx];
		s.eventId = eventId;
		s.eventTimer = (eventId == AI_EVENT_DEFENSIVE_PAUSE)
			? AI_DURATION_DEFENSIVE_PAUSE
			: AI_DURATION_GRAND_ASSAULT;

		float baseDef = 0.0f;
		float borderDef = 0.0f;
		getEventDefenseValues(eventId, baseDef, borderDef);
		sendCommanderAiForFaction(fid, baseDef, borderDef);

		string msg = (eventId == AI_EVENT_DEFENSIVE_PAUSE)
			? AI_RADIO_DEFENSIVE_PAUSE
			: AI_RADIO_GRAND_ASSAULT;
		sendFactionMessage(m_metagame, fid, msg, 1.5f);

		_log("AI-Adaptive: Fakt." + fid + " Event START → " + getEventLabel(eventId)
			+ " (base=" + baseDef + " border=" + borderDef + ")");
	}

	// -----------------------------------------------------------------------
	// Revert auf native Werte
	// -----------------------------------------------------------------------
	private void revertToNative(int fid, int stateIdx) {
		FactionAiState@ s = m_states[stateIdx];
		s.eventId       = AI_EVENT_IDLE;
		s.eventTimer    = 0.0f;
		s.cooldownTimer = AI_COOLDOWN_AFTER_EVENT;

		sendCommanderAiForFaction(fid, s.nativeBase, s.nativeBorder);
		sendFactionMessage(m_metagame, fid, AI_RADIO_REVERT, 1.5f);

		_log("AI-Adaptive: Fakt." + fid + " REVERT → native base=" + s.nativeBase
			+ " border=" + s.nativeBorder + " | cooldown=" + AI_COOLDOWN_AFTER_EVENT + "s");
	}

	// -----------------------------------------------------------------------
	// Hilfsfunktionen
	// -----------------------------------------------------------------------
	private void sendCommanderAiForFaction(int fid, float baseDef, float borderDef) {
		string cmd = "<command class='commander_ai'"
			+ " faction='" + fid + "'"
			+ " base_defense='" + formatFloat(baseDef, "", 0, 2) + "'"
			+ " border_defense='" + formatFloat(borderDef, "", 0, 2) + "'"
			+ " />";
		m_metagame.getComms().send(cmd);
	}

	private void ensureStatesSize(int needed) {
		while (int(m_states.size()) < needed) {
			m_states.insertLast(FactionAiState());
		}
	}

	// Einfacher deterministischer Pseudo-Zufallsgenerator (LCG)
	private float nextRandom() {
		m_randSeed = m_randSeed * 1664525.0f + 1013904223.0f;
		// Auf 0.0–1.0 normalisieren via Modulo-Trick mit positiver Zahl
		float v = m_randSeed;
		if (v < 0.0f) v = -v;
		return (v - float(int(v)));
	}

	// -----------------------------------------------------------------------
	// Admin-Commands
	// -----------------------------------------------------------------------
	protected void handleChatEvent(const XmlElement@ event) {
		string msg = event.getStringAttribute("message");
		if (!startsWith(msg, "/")) return;
		string playerName = event.getStringAttribute("player_name");
		int    playerId   = event.getIntAttribute("player_id");
		if (!m_metagame.getAdminManager().isAdmin(playerName, playerId)) return;

		if (checkCommand(msg, CMD_AI_STATUS)) {
			handleStatusCommand(playerId);
			return;
		}
		if (checkCommand(msg, CMD_AI_ATTACK)) {
			handleManualEvent(playerId, msg, AI_EVENT_GRAND_ASSAULT);
			return;
		}
		if (checkCommand(msg, CMD_AI_DEFEND)) {
			handleManualEvent(playerId, msg, AI_EVENT_DEFENSIVE_PAUSE);
			return;
		}
	}

	// /ai_status - zeigt Zustand aller Fraktionen mit lesbaren Fraktionsnamen
	private void handleStatusCommand(int playerId) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null || m_respawnTracker is null) {
			sendPrivateMessage(m_metagame, playerId, "[AI] Kein Tracker aktiv.");
			return;
		}

		float nextEval = AI_UPDATE_INTERVAL - m_accum;
		string report = "naechste Eval in " + formatFloat(nextEval, "", 0, 1) + "s\n";

		for (uint i = 0; i < factions.size() && i < m_states.size(); i++) {
			int fid = factions[i].getIntAttribute("id");
			FactionAiState@ s = m_states[i];

			// Fraktionsname wie in /stats: key-Attribut, 2 Zeichen (z.B. "EU", "RU")
			string fName = getFactionShortName(factions[i], fid);

			int liveCount    = m_respawnTracker.getLiveCount(fid);
			int effectiveCap = (liveCount > 0) ? m_respawnTracker.getEffectiveCapacityForFaction(fid) : 0;
			float ratio      = (liveCount > 0) ? float(effectiveCap) / float(liveCount) : 0.0f;

			string eventLabel = getEventLabel(s.eventId);
			string timerInfo  = "";
			if (s.eventId != AI_EVENT_IDLE)
				timerInfo = " verbl.=" + formatFloat(s.eventTimer, "", 0, 1) + "s";
			else if (s.cooldownTimer > 0.0f)
				timerInfo = " cd=" + formatFloat(s.cooldownTimer, "", 0, 1) + "s";

			// ratio = effectiveCap/liveCount (Engine-Logik); in Klammern bewusst live/cap wie HUD (weniger verwirrend)
			report += "  " + fName
				+ " ratio=" + formatFloat(ratio, "", 0, 2)
				+ " (" + liveCount + "/" + effectiveCap + ")"
				+ " | " + eventLabel + timerInfo
				+ " | nat.base=" + formatFloat(s.nativeBase, "", 0, 2)
				+ " brd=" + formatFloat(s.nativeBorder, "", 0, 2) + "\n";
		}

		_log(report);
		sendPrivateMessage(m_metagame, playerId, report);
	}

	// Fraktions-Kurzname aus key-Attribut (2 Zeichen), Fallback auf "F<id>"
	private string getFactionShortName(const XmlElement@ faction, int factionId) {
		if (faction is null) return "F" + factionId;
		string key = faction.getStringAttribute("key");
		if (key.length() >= 2) return key.substr(0, 2);
		string name = faction.getStringAttribute("name");
		if (name.length() >= 2) return name.substr(0, 2);
		return "F" + factionId;
	}

	// /ai_attack [factionId] oder /ai_defend [factionId]
	// Ohne Argument: eigene Fraktion des Admins. Mit Argument (z.B. "/ai_attack 2"): explizite Fraktion.
	private void handleManualEvent(int playerId, const string &in msg, int eventId) {
		array<const XmlElement@>@ factions = getFactions(m_metagame);
		if (factions is null) return;

		ensureStatesSize(int(factions.size()));

		// Argument parsen: "/ai_attack 2" → targetFid=2; ohne Argument → Spieler-Fraktion
		int targetFid = -1;
		int space = msg.findFirst(" ");
		if (space >= 0 && space < int(msg.length()) - 1) {
			string arg = msg.substr(space + 1, int(msg.length()) - space - 1);
			targetFid = parseInt(arg);
		} else {
			// Kein Argument → Fraktion des Admins ermitteln
			const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
			if (player !is null) targetFid = player.getIntAttribute("faction_id");
			if (targetFid < 0) {
				sendPrivateMessage(m_metagame, playerId, "[AI] Keine Fraktion gefunden (Spectator?).");
				return;
			}
		}

		int triggered = 0;
		for (uint i = 0; i < factions.size(); i++) {
			int fid = factions[i].getIntAttribute("id");
			if (fid != targetFid) continue;

			FactionAiState@ s = m_states[i];
			s.cooldownTimer = 0.0f;
			s.eventId       = AI_EVENT_IDLE;
			startEvent(fid, int(i), eventId);
			triggered++;
		}

		string label = getEventLabel(eventId);
		string fName = "F" + targetFid;
		for (uint i = 0; i < factions.size(); i++) {
			if (factions[i].getIntAttribute("id") == targetFid) {
				fName = getFactionShortName(factions[i], targetFid);
				break;
			}
		}
		string feedback = "[AI] " + label + " " + fName
			+ (triggered > 0 ? " gestartet." : " - Fraktion nicht gefunden.");
		sendPrivateMessage(m_metagame, playerId, feedback);
	}
}
