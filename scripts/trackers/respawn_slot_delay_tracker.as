// Respawn-Slot-Delay: Nach Tod bleibt ein Spawn-Slot X Sekunden „besetzt" → capacity_multiplier sinkt.
// Zweiter Hebel: spawn_interval = 60s wenn liveCount >= effectiveCap (Fraktion ist voll/drüber).
// Mechanismus: mult = (nativeCap - reserved) / nativeCap
//   nativeCap  = (xmlCap / sumXmlCap) × totalLive  — stabiler Proxy für max_soldiers-Anteil
//   reserved   = Anzahl noch aktiver Slot-Ablaufzeitstempel nach Toden
//
// Warum totalLive statt liveCount als Nenner:
//   capacity_multiplier skaliert die Engine-interne Kapazität (xmlCap-proportionaler Anteil an max_soldiers).
//   liveCount sinkt durch Drosselung → würde den Nenner verkleinern → Feedback-Loop → Block hebt sich auf.
//   totalLive wird in refreshAliveBasedData() immer frisch aus allen Fraktionen summiert.
//
// Fraktion mit ≤1 Basis: Slotblock immer AUS → mult = 1.0, spawn_interval = SPAWN_INTERVAL_NORMAL.
//
// Timestamps: Gespeichert wird der Ablaufzeitpunkt (expireTime = now + delay), nicht der Todeszeitpunkt.
//
// --- Konfiguration ---
const float RESPAWN_SLOT_DELAY          = 10.0f;   // s, 3+ Basen
const float RESPAWN_SLOT_DELAY_2_BASES  =  5.0f;   // s, 2 Basen
const float RESPAWN_SLOT_DELAY_1_BASE   =  2.0f;   // s, 1 Basis
const float ALIVE_CHECK_INTERVAL        = 15.0f;   // s, Intervall für Alive/Basen-Update
const int   TROOPS_PER_EXTRA_BLOCK      = 25;      // pro 25 Truppen Vorsprung …
const float EXTRA_SECONDS_PER_BLOCK     =  4.0f;   // … +4 s Slot-Delay
const float APPLY_INTERVAL             =  1.0f;   // s, wie oft capacity_multiplier gesendet wird
const float CAPACITY_MULTIPLIER_NEAR_ZERO = 0.00001f; // Engine-Minimum (Fraktion nicht ignorieren)
const float SPAWN_INTERVAL_NORMAL      =  0.5f;   // s, normaler Respawn-Takt (Engine-Default ~0.05-0.2)
const float SPAWN_INTERVAL_BLOCKED     = 60.0f;   // s, Respawn-Takt wenn Slots geblockt sind
// Slots pro Tod: XML-soldier_capacity <70→1, 70-120→2, 121-200→3, 201-250→4, 251-299→5, ≥300→6; Führer +2.
//
// --- BalanceCompensator-Konfiguration ---
// Gleicht extreme Alive-Verhältnisse automatisch aus (z.B. 11 vs 80 = 1:7).
// Greift erst ab BALANCE_RATIO_THRESHOLD. Ziel-Mult wird sanft per Lerp aufgebaut.
// Einmal-Aktivierung: Wurde der Kompensator für eine Fraktion aktiv und fällt das Verhältnis
// wieder unter den Threshold, ist er für diese Fraktion dauerhaft deaktiviert (balanceBurned).
// Funktioniert für 1v1 und 1v1v1: jede Fraktion wird relativ zur stärksten bewertet.
const float BALANCE_RATIO_THRESHOLD = 3.0f;  // ab diesem Verhältnis (stärkste/schwächste) greift der Kompensator
const float BALANCE_MAX_MULT        = 3.0f;  // maximaler capacity_multiplier (Engine-Max ist 4.0)
const float BALANCE_LERP_SPEED      = 0.03f; // pro Sekunde Aufbaugeschwindigkeit (sanft, kein Sprung)
//
// --- Commander-Funk-Konfiguration ---
// Nachrichten werden zweimal gesendet: sofort + BALANCE_MSG_DELAY_SECONDS später.
// Frühe Phase = erste BALANCE_MSG_EARLY_PHASE_SECONDS der Spielzeit.
const float BALANCE_MSG_EARLY_PHASE_SECONDS = 600.0f; // 10 Minuten: vor/nach diesem Wert unterscheiden sich die Texte
const float BALANCE_MSG_DELAY_SECONDS       =  10.0f; // Verzögerung für die zweite Nachricht

#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

// ---------------------------------------------------------------------------
// PendingMessage: zeitverzögerter Commander-Funk-Eintrag.
// sendAt = absoluter m_timeAccum-Wert, ab dem die Nachricht gesendet wird.
// ---------------------------------------------------------------------------
class PendingMessage {
    float  sendAt    = 0.0f;
    int    factionId = -1;   // Ziel-Fraktion (-1 = alle)
    string message   = "";
}

// ---------------------------------------------------------------------------
// FactionState: gesamter per-Fraktion-Zustand an einem Ort.
// Kein dictionary-Cast-Roulette mehr - alle Typen sind statisch deklariert.
// Neue Felder hinzufügen: hier eintragen, fertig.
// ---------------------------------------------------------------------------
class FactionState {
    int          factionId            = -1;

    // --- Snapshot aus refreshAliveBasedData() ---
    int          liveCount            = 0;
    int          xmlCapacity          = 0;    // soldier_capacity aus XML (Größenindikator)
    float        nativeCap            = 0.0f; // proportionaler Anteil an totalLive
    int          bases                = 0;
    float        extraDelaySeconds    = 0.0f; // Bonus-Delay wegen Truppenvorteil
    bool         isLeader             = false; // führende Fraktion → +2 slotsPerDeath

    // --- Pending Deaths (werden in flushPendingDeaths() verarbeitet) ---
    int          pendingDeaths        = 0;

    // --- Aktive Slot-Ablaufzeitstempel ---
    // Jeder Eintrag = Zeitpunkt, ab dem der Slot wieder frei ist.
    // array<float> statt Comma-String: kein manuelles Parsen mehr nötig.
    array<float> slotExpireTimes;

    // --- Statistik ---
    float        totalSlotSecondsBlocked = 0.0f;

    // --- BalanceCompensator ---
    float        balanceMult              = 1.0f;
    bool         balanceBurned            = false; // true = einmalig verbraucht, nie wieder aktiv
    bool         balanceMsgSent           = false; // true = Commander-Funk für diese Aktivierung bereits gesendet
}

// ---------------------------------------------------------------------------
// RespawnSlotDelayTracker
// ---------------------------------------------------------------------------
class RespawnSlotDelayTracker : Tracker {
    protected Metagame@ m_metagame;
    protected float m_timeAccum       = 0.0f;
    protected float m_applyAccum      = 0.0f;
    protected float m_aliveCheckAccum = 0.0f;

    // Einziger Container für alle Fraktionsdaten.
    // Index entspricht factionId (array wird in getState() bei Bedarf erweitert).
    protected array<FactionState@> m_factions;

    // Warteschlange für zeitverzögerte Commander-Funk-Nachrichten.
    protected array<PendingMessage@> m_pendingMessages;

    RespawnSlotDelayTracker(Metagame@ metagame) {
        @m_metagame = @metagame;
        m_metagame.getComms().send("<command class='set_metagame_event' name='character_die' enabled='1' />");
    }

    bool hasEnded()   const { return false; }
    bool hasStarted() const { return true; }

    void start() {
        refreshAliveBasedData();
        applyCapacityWithReservedSlots();
    }

    void update(float time) {
        m_timeAccum += time;
        flushPendingDeaths();
        flushPendingMessages();

        m_aliveCheckAccum += time;
        if (m_aliveCheckAccum >= ALIVE_CHECK_INTERVAL) {
            m_aliveCheckAccum = 0.0f;
            refreshAliveBasedData();
        }

        m_applyAccum += time;
        if (m_applyAccum < APPLY_INTERVAL) return;
        m_applyAccum = 0.0f;
        applyCapacityWithReservedSlots();
    }

    // =========================================================================
    // STATE ACCESS
    // =========================================================================

    // Gibt den FactionState für factionId zurück, legt ihn bei Bedarf an.
    FactionState@ getState(int factionId) {
        while (int(m_factions.size()) <= factionId) {
            FactionState@ s = FactionState();
            s.factionId = int(m_factions.size());
            m_factions.insertLast(s);
        }
        return m_factions[factionId];
    }

    // =========================================================================
    // REFRESH - liest Engine-Daten und befüllt alle FactionStates
    // =========================================================================

    void refreshAliveBasedData() {
        array<const XmlElement@>@ factions = getFactions(m_metagame);
        if (factions is null || factions.size() == 0) return;

        // Pass 1: Alive-Counts lesen + first/second für Extra-Delay bestimmen
        array<int> aliveCounts;
        aliveCounts.resize(factions.size());
        int first = 0, second = 0;
        for (uint i = 0; i < factions.size(); ++i) {
            array<const XmlElement@>@ chars = getCharacters(m_metagame, int(i));
            int n = (chars is null) ? 0 : int(chars.size());
            aliveCounts[i] = n;
            if (n >= first) { second = first; first = n; }
            else if (n > second) second = n;
        }
        if (factions.size() == 1) second = first;

        // Pass 2: Summen für nativeCap-Schätzung
        int totalLive = 0, sumXmlCap = 0;
        for (uint i = 0; i < factions.size(); ++i) {
            totalLive += aliveCounts[i];
            sumXmlCap += factions[i].getIntAttribute("soldier_capacity");
        }

        // Pass 3: FactionStates aktualisieren
        for (uint i = 0; i < factions.size(); ++i) {
            int fid    = int(i);
            int alive  = aliveCounts[i];
            int xmlCap = factions[i].getIntAttribute("soldier_capacity");

            FactionState@ s = getState(fid);
            s.liveCount   = alive;
            s.xmlCapacity = xmlCap;
            s.bases       = getBasesForFaction(m_metagame, fid);
            s.isLeader    = (alive == first);
            s.nativeCap   = (sumXmlCap > 0 && totalLive > 0)
                ? float(xmlCap) / float(sumXmlCap) * float(totalLive)
                : float(alive);
            s.extraDelaySeconds = (alive > second)
                ? float((alive - second) / TROOPS_PER_EXTRA_BLOCK) * EXTRA_SECONDS_PER_BLOCK
                : 0.0f;

            updateBalanceMult(s, first);
        }
    }

    // =========================================================================
    // BALANCE COMPENSATOR
    // =========================================================================

    // Berechnet den Ziel-Multiplikator basierend auf dem Alive-Verhältnis.
    // Pure Funktion: kein Seiteneffekt, leicht testbar.
    float calcBalanceTarget(int alive, int maxAlive) {
        if (maxAlive <= 0 || alive <= 0) return 1.0f;
        float ratio = float(maxAlive) / float(alive);
        if (ratio < BALANCE_RATIO_THRESHOLD) return 1.0f;
        return (ratio > BALANCE_MAX_MULT) ? BALANCE_MAX_MULT : ratio;
    }

    // Aktualisiert balanceMult per Lerp; setzt Burned-Flag beim Deaktivieren.
    // Erkennt außerdem die erste Aktivierung und löst den Commander-Funk aus.
    void updateBalanceMult(FactionState@ s, int maxAlive) {
        if (s.balanceBurned) {
            s.balanceMult = 1.0f; // einmalig verbraucht: nie wieder aktiv
            return;
        }
        float target = calcBalanceTarget(s.liveCount, maxAlive);
        if (target <= 1.0f) {
            if (s.balanceMult > 1.01f) {
                // War aktiv, wird jetzt inaktiv → einmaligen Slot verbrauchen
                s.balanceBurned = true;
                _log("BalanceComp: fid=" + s.factionId + " BURNED - einmalige Aktivierung verbraucht", 1);
            }
            s.balanceMult = 1.0f;
        } else {
            // Erste Aktivierung: Commander-Funk auslösen (genau einmal pro Fraktion)
            if (!s.balanceMsgSent) {
                s.balanceMsgSent = true;
                sendCompensatorMessages(s);
            }
            s.balanceMult += (target - s.balanceMult) * BALANCE_LERP_SPEED * ALIVE_CHECK_INTERVAL;
            _log("BalanceComp: fid=" + s.factionId + " alive=" + s.liveCount
                + " maxAlive=" + maxAlive + " target=" + target + " mult=" + s.balanceMult, 1);
        }
    }

    // =========================================================================
    // COMMANDER-FUNK - Nachrichten beim Aktivieren des Kompensators
    // =========================================================================

    // Sendet sofort + verzögert zwei Nachrichtenpakete:
    // - An die Fraktion selbst (Ich-Perspektive): Truppennachschub / Mobilmachung
    // - Global für alle anderen (Geheimdienstperspektive): Feind hat Nachschub / Mobilmachung
    void sendCompensatorMessages(FactionState@ s) {
        string name         = getFactionName(s.factionId);
        bool   isEarlyGame  = (m_timeAccum < BALANCE_MSG_EARLY_PHASE_SECONDS);

        if (isEarlyGame) {
            // --- Early phase (< 10 min): fresh reinforcements from command ---

            postFactionMessage(s.factionId,
                "HQ to " + name + ": We have received massive troop reinforcements. Prepare for a major offensive!");
            postGlobalExceptFaction(s.factionId,
                "Intercepted transmission: " + name + " has received major reinforcements. Brace for a large-scale assault!");

            scheduleMessageToFaction(s.factionId, BALANCE_MSG_DELAY_SECONDS,
                name + " HQ: All units - move out! Give everything you have!");
            scheduleMessageGlobalExceptFaction(s.factionId, BALANCE_MSG_DELAY_SECONDS,
                "Warning: " + name + " is launching a full assault. Hold all positions!");

        } else {
            // --- Late phase (> 10 min): last reserves - all or nothing ---

            postFactionMessage(s.factionId,
                "HQ to " + name + ": Our last reserves have been mobilised. Prepare for a final counter-attack!");
            postGlobalExceptFaction(s.factionId,
                "Intelligence report: " + name + " has completed their final mobilisation. Expect an imminent counter-attack!");

            scheduleMessageToFaction(s.factionId, BALANCE_MSG_DELAY_SECONDS,
                name + ": Soldiers, this is our last major push - give it everything!");
            scheduleMessageGlobalExceptFaction(s.factionId, BALANCE_MSG_DELAY_SECONDS,
                "The enemy (" + name + ") is making their final push. All units - hold the line!");
        }
    }

    // Sendet eine Nachricht nur an Spieler einer bestimmten Fraktion.
    // Nutzt sendFactionMessage aus query_helpers.as - identisch zur reinforcement_pool_tracker-Logik.
    void postFactionMessage(int factionId, string message) {
        sendFactionMessage(m_metagame, factionId, message, 0.95);
    }

    // Sendet eine Nachricht an alle Fraktionen außer der angegebenen.
    void postGlobalExceptFaction(int excludeFactionId, string message) {
        array<const XmlElement@>@ factions = getFactions(m_metagame);
        if (factions is null) return;
        for (uint i = 0; i < factions.size(); ++i) {
            if (int(i) == excludeFactionId) continue;
            sendFactionMessage(m_metagame, int(i), message, 0.95);
        }
    }

    // Stellt eine verzögerte Nachricht an eine Fraktion in die Warteschlange.
    void scheduleMessageToFaction(int factionId, float delaySeconds, string message) {
        PendingMessage@ pm = PendingMessage();
        pm.sendAt    = m_timeAccum + delaySeconds;
        pm.factionId = factionId;
        pm.message   = message;
        m_pendingMessages.insertLast(pm);
    }

    // Stellt verzögerte Nachrichten an alle Fraktionen außer einer in die Warteschlange.
    void scheduleMessageGlobalExceptFaction(int excludeFactionId, float delaySeconds, string message) {
        array<const XmlElement@>@ factions = getFactions(m_metagame);
        if (factions is null) return;
        for (uint i = 0; i < factions.size(); ++i) {
            if (int(i) == excludeFactionId) continue;
            scheduleMessageToFaction(int(i), delaySeconds, message);
        }
    }

    // Verarbeitet die Warteschlange und sendet fällige Nachrichten.
    void flushPendingMessages() {
        if (m_pendingMessages.size() == 0) return;
        array<PendingMessage@> remaining;
        for (uint i = 0; i < m_pendingMessages.size(); ++i) {
            PendingMessage@ pm = m_pendingMessages[i];
            if (pm.sendAt <= m_timeAccum) {
                sendFactionMessage(m_metagame, pm.factionId, pm.message, 0.95);
            } else {
                remaining.insertLast(pm);
            }
        }
        m_pendingMessages = remaining;
    }

    // Liest den Fraktionsnamen aus dem XML (für Nachrichten-Texte).
    string getFactionName(int factionId) {
        array<const XmlElement@>@ factions = getFactions(m_metagame);
        if (factions is null || factionId < 0 || uint(factionId) >= factions.size()) return "Unbekannt";
        return factions[factionId].getStringAttribute("name");
    }

    // =========================================================================
    // SLOT-DELAY
    // =========================================================================

    // Slotblock ist deaktiviert wenn die Fraktion nur 1 oder 0 Basen hat.
    bool isSlotBlockEnabled(FactionState@ s) {
        return s.bases > 1;
    }

    // Effektive Verzögerung = Basis-Delay (abhängig von Basenzahl) + Truppenvorteil-Bonus.
    float getEffectiveDelay(FactionState@ s) {
        float base = (s.bases <= 1) ? RESPAWN_SLOT_DELAY_1_BASE
                   : (s.bases == 2) ? RESPAWN_SLOT_DELAY_2_BASES
                   :                  RESPAWN_SLOT_DELAY;
        return base + s.extraDelaySeconds;
    }

    // Slots pro Tod: skaliert mit der XML-Kapazität (Größenindikator der Fraktion).
    int getSlotsPerDeath(int xmlCap) {
        if (xmlCap >= 300) return 6;
        if (xmlCap >= 251) return 5;
        if (xmlCap >= 201) return 4;
        if (xmlCap >= 121) return 3;
        if (xmlCap >= 70)  return 2;
        return 1;
    }

    void addPendingDeath(int factionId) {
        getState(factionId).pendingDeaths++;
    }

    // Verarbeitet gesammelte Tode: schreibt Ablaufzeitstempel in slotExpireTimes.
    void flushPendingDeaths() {
        for (uint i = 0; i < m_factions.size(); ++i) {
            FactionState@ s = m_factions[i];
            if (s.pendingDeaths == 0) continue;
            int n = s.pendingDeaths;
            s.pendingDeaths = 0;

            if (!isSlotBlockEnabled(s)) continue;

            int   slotsPerDeath = getSlotsPerDeath(s.xmlCapacity) + (s.isLeader ? 2 : 0);
            float delay         = getEffectiveDelay(s);
            float expireTime    = m_timeAccum + delay;

            s.totalSlotSecondsBlocked += float(n) * float(slotsPerDeath) * delay;

            for (int j = 0; j < n * slotsPerDeath; ++j)
                s.slotExpireTimes.insertLast(expireTime);
        }
    }

    // Zählt noch aktive (nicht abgelaufene) Slot-Timestamps.
    int countReservedSlots(FactionState@ s) {
        int count = 0;
        float now = m_timeAccum;
        for (uint i = 0; i < s.slotExpireTimes.size(); ++i)
            if (s.slotExpireTimes[i] > now) count++;
        return count;
    }

    // Entfernt abgelaufene Timestamps aus dem Array (Speicher-Hygiene).
    void pruneExpiredSlots(FactionState@ s) {
        float now = m_timeAccum;
        array<float> kept;
        for (uint i = 0; i < s.slotExpireTimes.size(); ++i)
            if (s.slotExpireTimes[i] > now) kept.insertLast(s.slotExpireTimes[i]);
        s.slotExpireTimes = kept;
    }

    // =========================================================================
    // MULTIPLIER-BERECHNUNG (zwei klar getrennte Stufen)
    // =========================================================================

    // Stufe 1 - Slot-Bremse: wie stark drosselt der Slot-Delay den Spawn?
    float calcSlotMult(FactionState@ s) {
        if (!isSlotBlockEnabled(s)) return 1.0f;
        int reserved = countReservedSlots(s);
        if (reserved <= 0 || s.nativeCap <= 0.0f) return 1.0f;
        float targetCap = s.nativeCap - float(reserved);
        if (targetCap < 0.0f) targetCap = 0.0f;
        float mult = targetCap / s.nativeCap;
        if (mult < CAPACITY_MULTIPLIER_NEAR_ZERO) mult = CAPACITY_MULTIPLIER_NEAR_ZERO;
        _log("SlotMult: fid=" + s.factionId + " native=" + s.nativeCap
            + " reserved=" + reserved + " mult=" + mult, 1);
        return mult;
    }

    // Stufe 2 - Finaler Mult: Balance-Boost gewinnt wenn er höher ist als Slot-Bremse.
    // Regel: der höhere Wert gewinnt (Slot bremst nach unten, Balance hebt nach oben).
    float calcFinalMult(FactionState@ s) {
        float slotMult    = calcSlotMult(s);
        float balanceMult = s.balanceMult;
        if (balanceMult > slotMult) {
            _log("FinalMult: fid=" + s.factionId + " balanceMult=" + balanceMult
                + " overrides slotMult=" + slotMult, 1);
            return balanceMult;
        }
        return slotMult;
    }

    // Effektive Kapazität (für Throttle-Check und HUD/Stats).
    int calcEffectiveCapacity(FactionState@ s) {
        if (!isSlotBlockEnabled(s)) return int(s.nativeCap);
        int effective = int(s.nativeCap) - countReservedSlots(s);
        return (effective > 0) ? effective : 0;
    }

    // =========================================================================
    // APPLY - sendet capacity_multiplier und spawn_interval an die Engine
    // =========================================================================

    void applyCapacityWithReservedSlots() {
        array<const XmlElement@>@ factions = getFactions(m_metagame);
        if (factions is null || factions.size() == 0) return;

        XmlElement command("command");
        command.setStringAttribute("class", "change_game_settings");
        for (uint i = 0; i < factions.size(); ++i) {
            FactionState@ s    = getState(int(i));
            float mult         = calcFinalMult(s);
            int   effectiveCap = calcEffectiveCapacity(s);
            bool  throttle     = (effectiveCap > 0 && s.liveCount >= effectiveCap);

            XmlElement faction("faction");
            faction.setFloatAttribute("capacity_multiplier", mult);
            faction.setFloatAttribute("spawn_interval", throttle ? SPAWN_INTERVAL_BLOCKED : SPAWN_INTERVAL_NORMAL);
            if (throttle) _log("THROTTLE: fid=" + i + " live=" + s.liveCount + " >= cap=" + effectiveCap, 1);
            command.appendChild(faction);

            pruneExpiredSlots(s);
        }
        m_metagame.getComms().send(command);
    }

    // =========================================================================
    // EVENTS
    // =========================================================================

    protected void handleCharacterDieEvent(const XmlElement@ event) {
        const XmlElement@ character = event.getFirstElementByTagName("character");
        const XmlElement@ target = character is null ? event.getFirstElementByTagName("target") : character;
        if (target is null) return;
        addPendingDeath(target.getIntAttribute("faction_id"));
    }

    // =========================================================================
    // PUBLIC STATS API (für HUD / externe Abfragen)
    // =========================================================================

    int getEffectiveCapacityForFaction(int factionId) {
        return calcEffectiveCapacity(getState(factionId));
    }

    float getTotalSlotSecondsBlocked(int factionId) {
        return getState(factionId).totalSlotSecondsBlocked;
    }

    // =========================================================================
    // LEGACY API - Wrapper für externe Tracker-Aufrufer.
    // Nicht intern verwenden; stattdessen getState(fid).field direkt nutzen.
    // =========================================================================

    int getLiveCount(int factionId) {
        return getState(factionId).liveCount;
    }

    int getXmlCapacity(int factionId) {
        return getState(factionId).xmlCapacity;
    }

    int getBasesForFactionCached(int factionId) {
        return getState(factionId).bases;
    }

    int getReservedSlots(int factionId) {
        return countReservedSlots(getState(factionId));
    }

    int getMinBasesOverFactions() {
        int minBases = 999;
        for (uint i = 0; i < m_factions.size(); ++i) {
            int b = m_factions[i].bases;
            if (b < minBases) minBases = b;
        }
        return (minBases == 999) ? 0 : minBases;
    }

    // Signatur-kompatibel mit altem Aufruf (minBases-Parameter wird nicht benötigt).
    bool isWeakestFactionSlotBlockDisabled(int factionId, int minBases) {
        return !isSlotBlockEnabled(getState(factionId));
    }
}
