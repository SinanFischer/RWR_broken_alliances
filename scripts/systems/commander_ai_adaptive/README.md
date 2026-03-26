# Adaptive Commander AI

Ereignisgesteuertes System, das die native Karten-KI unberührt lässt und nur bei konkreten Auslösern zeitlich begrenzt eingreift. Nach Ablauf eines Events kehrt das System automatisch zu den nativen Werten zurück.

---

## Admin-Befehle

| Befehl | Beschreibung |
|---|---|
| `/ai_status` | Zeigt Zustand aller Fraktionen: Ratio, aktives Event, verbleibende Zeit, Cooldown, native Werte |
| `/ai_attack` | Startet **GRAND_ASSAULT** für die eigene Fraktion des Admins |
| `/ai_attack 2` | Startet **GRAND_ASSAULT** für Fraktion mit ID `2` |
| `/ai_defend` | Startet **DEFENSIVE_PAUSE** für die eigene Fraktion des Admins |
| `/ai_defend 1` | Startet **DEFENSIVE_PAUSE** für Fraktion mit ID `1` |

> Nur für Admins. Manuell ausgelöste Events überschreiben laufende Events sofort.

---

## Wie es funktioniert

### Grundprinzip

```
[MAP START]
    └─ 15s Startverzoegerung (Map-Ladezeit)
        └─ Native-Cache befuellen (Map-Lookup oder Formel)
            └─ Alle 45s: Capacity-Ratio pruefen
                ├─ ratio < 0.40 → DEFENSIVE_PAUSE starten (60s)
                ├─ ratio > 0.85 + 15% Zufallschance → GRAND_ASSAULT starten (90s)
                └─ Event laeuft ab → Revert auf native Werte → 120s Cooldown
```

### Capacity-Ratio

```
ratio = effectiveCapacity / baseCapacity
```

- **`baseCapacity`** (*konfigurierte Maximalgröße der Fraktion*) — Ausgangswert
- **`effectiveCapacity`** (*aktuell verfügbare Slots nach Slotblock durch Tode*) — sinkt bei Verlusten
- Bei hohen Verlusten sinkt die Ratio → Verteidigung wird ausgelöst
- Bei dominanter Fraktion steigt die Ratio → Angriff möglich

---

## Die 2 Events

### DEFENSIVE_PAUSE
- **Trigger:** `ratio < 0.40` (Fraktion hat schwere Verluste erlitten)
- **Dauer:** 60 Sekunden
- **Werte:** `base_defense=0.85`, `border_defense=0.90`
- **Effekt:** Alle Einheiten in Verteidigung, kein aktiver Angriff
- **Nachricht:** Nur an Spieler der betroffenen Fraktion

### GRAND_ASSAULT
- **Trigger:** `ratio > 0.85` + 15% Zufallschance pro Evaluierungszyklus
- **Dauer:** 90 Sekunden
- **Werte:** `base_defense=0.25`, `border_defense=0.15`
- **Effekt:** Aggressiver Push, Mindestverteidigung bleibt erhalten
- **Nachricht:** Nur an Spieler der betroffenen Fraktion

### Revert (nach Event-Ablauf)
- Setzt `base_defense` und `border_defense` auf die gecachten nativen Werte zurück
- Startet 120s Cooldown — kein sofortiges Re-Triggern möglich
- Nachricht an Fraktion: Rückkehr zur Standardhaltung

---

## Native Werte (Revert-Ziel)

Der Tracker speichert beim Start einmalig die "nativen" KI-Werte pro Fraktion, auf die nach einem Event zurückgekehrt wird.

**Priorität beim Befüllen:**
1. **Map-Lookup** — bekannte Vanilla-Maps haben hartcodierte Werte (aus `init_match.xml` extrahiert)
2. **Formel-Fallback** — für unbekannte Maps, basierend auf Basenanteil der Fraktion:
   ```
   base_defense   = clamp(0.20 + factionShare * 0.50,  0.20, 0.70)
   border_defense = clamp(0.10 + factionShare * 0.25,  0.10, 0.35)
   ```
   wobei `factionShare = factionBases / totalBases`
3. **Statischer Fallback** — `base=0.40`, `border=0.25` (wenn Basenzahl nicht verfügbar)

---

## Dateien & Zuständigkeiten

```
scripts/systems/commander_ai_adaptive/
├── commander_ai_adaptive_config.as     — Alle Konstanten (Thresholds, Dauer, Werte, Nachrichten)
├── commander_ai_adaptive_logic.as      — Reine Trigger-Logik (keine Engine-Calls)
├── commander_ai_adaptive_native_defaults.as — Native Vanilla-Werte + Formel-Fallback
├── commander_ai_adaptive_tracker.as    — Kern: Timer, Evaluierung, Engine-Commands, Admin-Commands
└── commander_ai_adaptive_system.as     — API-Wrapper, Einstiegspunkt für GameSystemsRegistry
```

| Datei | Was man dort anpasst |
|---|---|
| `config.as` | Trigger-Schwellwerte, Event-Dauer, Cooldown, Defense-Werte, Radio-Texte |
| `logic.as` | Trigger-Bedingungen (z.B. Zufallschance erhöhen) |
| `native_defaults.as` | Native Werte für neue Maps eintragen |
| `tracker.as` | Ablaufsteuerung, Timer-Logik, Admin-Command-Handling |

---

## Einbindung

Aktiviert in beiden Spielmodi über `GameSystemsRegistry`:

```angelscript
// gamemode_invasion.as + gamemode_quick_match.as
m_systemsRegistry.installCommanderAiAdaptiveSystem(true);
```

Voraussetzung: `installSpawnCapacitySystem()` muss vorher aufgerufen worden sein — der Tracker bezieht die Capacity-Daten vom `RespawnSlotDelayTracker`.

---

## Zusammenspiel mit anderen Systemen

```
RespawnSlotDelayTracker
    └─ liefert: baseCapacity, effectiveCapacity, basesPerFaction
        └─ CommanderAiAdaptiveTracker
            ├─ berechnet ratio
            ├─ sendet commander_ai-Commands an Engine
            └─ sendet Faction-Radio-Nachrichten (nur eigene Fraktion)
```

Der `StatsCommandTracker` (`/stats`-Befehl) und der `FactionAliveHudTracker` (HUD-Anzeige) nutzen denselben `RespawnSlotDelayTracker` — keine doppelten Engine-Queries.
