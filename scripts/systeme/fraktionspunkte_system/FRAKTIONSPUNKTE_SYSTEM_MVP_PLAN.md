# Fraktionspunkte-System (FP) - Zielbild, MVP und Aufbauplan

## Ziel

Ein modulares Fraktionspunkte-System (FP-System) bereitstellen, das pro existierender Fraktion Punkte sammelt, Punkte konsumiert und die Punkte live im unteren HUD anzeigt (max. 3 Fraktionen).

- **Fraktionspunkte (FP):** gemeinsame Team-Ressource je Fraktion, aus der Events/Support bezahlt werden.
- **MVP:** kleinster nutzbarer Funktionsumfang mit stabilem Datenfluss und HUD-Ausgabe.
- **Modular:** Erweiterungen (z. B. Last Defense, Sabotage, VIP) werden als eigene Module ergänzt, ohne Kernlogik umzubauen.

---

## Gewuenschte Features (Scope)

### MVP (Essentials)

1. FP-Store pro Fraktion (0..2) mit Guard-Logik gegen negative Werte.
2. FP-Gewinn aus Basiseroberung und Basishalten (Tick-basiert).
3. FP-Ausgabe fuer ein erstes Event-Budget (nur Platzhalter-API: `canSpend`, `spend`).
4. HUD-Anzeige ersetzt `faction_alive_hud_tracker` und zeigt pro Fraktion FP-Wert.
5. Admin-Debug-Command fuer Test (`/fp`, `/fp_add`, `/fp_set`) mit klaren Guards.

### Nach MVP (Phase 2+)

- Last-Defense-Bonus (temporaler Catch-up-Mechanismus).
- Sabotage/VIP-Belohnungen fuer unterlegene Fraktionen.
- Event-Strategien (z. B. Defense Platoon, Heavy Vehicle, Reinforcement Jump-Off).
- Persistenz ueber Match-/Map-Grenzen (nur wenn Spielmodus es benoetigt).

---

## Klare Voraussetzungen an das System

1. **Single Source of Truth:** FP liegen nur im FP-Store, kein Schattenzustand in Trackern.
2. **Klarer Datenfluss:** Event -> FP-Rechner -> FP-Store -> HUD/Commands.
3. **Defensive Guards:** fruehe Returns bei ungueltiger Fraktion, negativen Delta-Werten oder fehlenden Eventdaten.
4. **Invarianten:** FP nie negativ, Fraktionsindex immer gueltig (0 bis `factionCount-1`), max. HUD-Eintraege 3.
5. **Idempotenz:** wiederholte Installation von System-Trackern erzeugt keine doppelten Tracker.
6. **Observability:** Debug-Logs fuer FP-Delta, Source-Tag und Resultatwert.
7. **Erweiterbarkeit:** neue FP-Quellen/Senken als eigene Module, Kern-API bleibt stabil.
8. **Vanilla-Naehe:** bestehende Engine-Kommandos und Vanilla-Helfer bevorzugen statt Sonderwege.

---

## Architektur (KISS, modular)

- **Tracker:** Engine-gebundene Klasse mit `update()`/Event-Handling.
- **API:** schlanke Fassade fuer Installation und konsumierende Systeme.
- **Store:** zentrale Datenstruktur fuer FP pro Fraktion (`array<int>`), inklusive Validierungslogik.
- **HUD-Tracker:** schreibt FP-Werte in `update_score_display`.
- **Registry-Integration:** Einbindung ueber `scripts/systems/game_systems_registry.as`.

Empfohlene Struktur:

- `scripts/systeme/fraktionspunkte_system/faction_points_system.as`  
  Fassade-Include.
- `scripts/systeme/fraktionspunkte_system/faction_points_api.as`  
  Installation + Zugriff fuer andere Systeme.
- `scripts/systeme/fraktionspunkte_system/faction_points_store.as`  
  FP-Datenhaltung + Invarianten.
- `scripts/systeme/fraktionspunkte_system/faction_points_tracker.as`  
  Event/Tick-Verarbeitung (Erwerb/Kosten).
- `scripts/systeme/fraktionspunkte_system/faction_points_hud_tracker.as`  
  HUD-Rendering fuer FP.
- `scripts/systeme/fraktionspunkte_system/faction_points_debug_command_tracker.as`  
  Test-/Admin-Commands.

---

## Vanilla-Methoden/Patterns, die wir nutzen

1. **`update_score_display`** (Engine-Command): schreibt Werte in die untere Fraktionsleiste.
2. **`getFactions(...)`** (Query-Helfer): liefert aktive Fraktionen fuer dynamische Schleifen.
3. **Tracker-Pattern aus Vanilla** (z. B. `CommsCapacityHandler`): Event-Handler + gezieltes Senden von Commands.
4. **Resource-/Command-Pattern** (z. B. `resource.as`): klare, kleine Kommandopakete statt versteckter Seiteneffekte.

Hinweis:
- Bestehender `faction_alive_hud_tracker` wird fuer das FP-System deaktiviert/abgeloest.

---

## MVP-Schritte (nach Essentials sortiert)

| Schritt | Ziel | Ergebnis/Artefakt | Integriert (Ja/Nein + Info) |
|---|---|---|---|
| 1 | Systemordner + Dateigeruest anlegen | Leere, kompilierbare Struktur mit Includes | **Ja** - Ordner + Plan-Doku erstellt |
| 2 | FP-Store bauen | `get/set/add/spend/canSpend` mit Guards und Invarianten | **Ja** - `faction_points_store.as` + `faction_points_persistence_adapter.as` angelegt |
| 3 | API + idempotente Installation | `installCore()`, `installHud()`, `installDebug()` | **Ja** - `faction_points_api.as` inkl. idempotenter Install-Flags; Tracker-Scaffold angelegt |
| 4 | FP-Tracker (MVP-Quellen) | Basiseroberung + Basishalten erzeugt FP-Deltas | **Ja** - in `faction_points_tracker.as` umgesetzt (Capture-Event + Hold-Tick) |
| 5 | FP-HUD-Tracker | Anzeige FP statt Alive-Count via `update_score_display` | **Ja** - `faction_points_hud_tracker.as` aktiv (dynamisch, max. 3, nur Zahl fuer Platzersparnis) |
| 6 | Alte HUD-Anzeige deaktivieren | `faction_alive_hud_tracker` nicht mehr registrieren | **Ja** - SpawnCapacity-Fallback-HUD in QuickMatch/Campaign deaktiviert (`defaultAliveHudWhenNoDebug=false`) |
| 7 | Debug-Commands fuer Tests | `/fp`, `/fp_add`, `/fp_set` (Admin-only) | **Ja** - in `faction_points_debug_command_tracker.as` umgesetzt (Guards + Usage + Save) |
| 8 | Registry-Integration | Einbindung in `game_systems_registry.as` + Startpfade | **Ja** - `installFactionPointsSystem(...)` in Registry + Aufruf in QuickMatch/Campaign/Invasion |
| 9 | MVP-Validierung | Reproduzierbare Testfaelle + Logging-Check | **Nein** - offen |
| 10 | Erweiterungs-Hooks | klare Schnittstellen fuer Last Defense/VIP/Sabotage | **Nein** - offen |

---

## Live-Tabelle (Backlog / Todo / Status)

| ID | Thema | Ziel | Status | Integriert (Ja/Nein + Info) |
|---|---|---|---|---|
| L-001 | HUD nur eigene FP anzeigen | Unten nur FP der eigenen Fraktion statt aller Slots | **Todo** | **Nein** - Wunsch aufgenommen, noch nicht umgesetzt |
| L-002 | FP-Ausgabe erster Usecase | Ersten echten FP-Verbrauch mit `canSpend`/`spend` aktivieren | **Erledigt** | **Ja** - Event-Framework + `/event1` + `/event2` mit Kostenabzug implementiert |
| L-003 | MVP-Validierung | Reproduzierbare Tests und Log-Check dokumentieren | **Todo** | **Nein** - folgt nach Event-Playtests |
| L-004 | Event-Katalog | Event-Details (Kosten, Bedingungen, Parameter) zentral dokumentieren | **Erledigt** | **Ja** - `events/EVENTS_KATALOG.md` erstellt |
| L-005 | FP-AI Unterordner | Utility-AI als modulares Untermodul mit Konfiguration und Planner | **Erledigt** | **Ja** - `ai/` mit Tracker, Planner, Scorer, Config und `AI_SYSTEM.md` integriert |

Hinweis:
- Diese Tabelle ist fuer laufende Live-Erweiterungen gedacht und wird bei neuen Anforderungen fortgeschrieben.

---

## MVP-Definition (Done-Kriterien)

1. FP wird fuer jede aktive Fraktion korrekt gezaehlt (max. 3 angezeigt).
2. FP-HUD aktualisiert stabil ohne sichtbares Flackern.
3. FP kann nicht unter 0 fallen (Invariant gesichert).
4. Alte Alive-HUD-Anzeige ist deaktiviert.
5. Debug-Commands funktionieren nur fuer berechtigte Nutzer.
6. System kann zentral ueber Registry ein- und ausgeschaltet werden.

---

## Offene Architekturentscheidungen (vor Implementierung klaeren)

1. **Persistenz-Strategie (entschieden):**  
   Robuste Variante aktiv: Persistenz-Adapter von Anfang an (`save_data`/`saved_data`).
2. **FP-Quellen im MVP:**  
   Nur Base-Capture/Hold oder zusaetzlich Kills und Item-Verkauf schon in Phase 1?
3. **Budget-Regeln:**  
   Harte Kostenmatrix pro Event jetzt fest einbauen oder zunaechst einfache Konstante pro Eventtyp?

