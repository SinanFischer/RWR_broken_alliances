# FP Events Katalog

## Ziel

Ein zentraler Ueberblick ueber alle Fraktionspunkte-Events (FP-Events), deren Bedingungen, Kosten und Ausfuehrung.

- **FP-Event:** ausloesbare Aktion mit klarer Bedingung und fixen FP-Kosten pro Fraktion.
- **Event-Strategy:** jede Event-Logik ist in eigener Datei gekapselt.
- **Registry:** zentrale Zuordnung von Command-Token zu Event-Strategie.

---

## Technischer Aufbau

- `docs/ueberblick/COMMANDER_TONALITAET.md`  
  Verbindliche Sprach- und Tonregeln fuer Commander-Meldungen (abgeleitet aus `docs/ueberblick/ERA_STORY.md`).
- `faction_points_event_interface.as`  
  Vertrag fuer Events: `getCost`, `canExecute`, `execute`.
- `faction_points_event_registry.as`  
  Verwaltung/Lookup, Kostenpruefung, FP-Abzug, Ausfuehrung.
- `faction_points_event1_support_squad.as`  
  Support-Ausflug (`/event1`).
- `faction_points_event2_company_attack.as`  
  Company-Angriff (`/event2`).
- `faction_points_event3_defense_response.as`  
  Defense-Response (`/event3`, `/event3_sim`).

---

## Event-Definitionen

| Event | Typ | Command | Kosten (FP) | Bedingung | Aktion | Simulierbar | Status |
|---|---|---|---:|---|---|---|---|
| Event1 Support-Ausflug | PlayerEvent | `/event1` | 250 | `squad_size <= 2` beim ausloesenden Spieler | `paratroopers1.call` nahe Spielerposition | Ja (Admin-only) | Aktiv |
| Event2 Company-Angriff | AI Event | `/event2` | 1200 | Gegnerbasis vorhanden + genug FP | 2x `paratroopers2.call` seitlich/ausserhalb der gegnerischen Basis | Ja (Admin-only) | Aktiv |
| Event3 Defense-Response | AI Event | `/event3` | 700 | Fraktion hat kuerzlich eine Basis verloren + genug FP | 3x `paratroopers1.call` seitlich/ausserhalb der verlorenen Basis | Ja (`/event3_sim`) | Aktiv |

---

## Parameter pro Event

### Event1

- `FP_EVENT1_COST = 250`
- `FP_EVENT1_CALL_KEY = paratroopers1.call`
- `FP_EVENT1_SQUAD_HALF_THRESHOLD = 2`
- `FP_EVENT1_ANNOUNCEMENT_DELAY = 0`

### Event2

- `FP_EVENT2_COST = 1200`
- `FP_EVENT2_PLATOON_CALL_KEY = paratroopers2.call`
- `FP_EVENT2_PLATOON_COUNT = 2`
- `FP_EVENT2_OUTSIDE_RADIUS = 42.0`
- `FP_EVENT2_ANNOUNCEMENT_DELAY = 60`

### Event3

- `FP_EVENT3_COST = 700`
- `FP_EVENT3_CALL_KEY = paratroopers1.call`
- `FP_EVENT3_CALL_COUNT = 3`
- `FP_EVENT3_RING_RADIUS = 42.0`
- `FP_EVENT3_ANNOUNCEMENT_DELAY = 20`

---

## Ablauf (Engine-Datenfluss)

1. Admin triggert `/event1`, `/event2`, `/event3` oder `/event3_sim` (fuer Tests) oder AI triggert intern.
2. Registry resolved Event-Strategy und unterscheidet `PlayerEvent` vs. `AI Event`.
3. `canExecute(...)` prueft Bedingung im passenden Kontext (mit/ohne `player_id`).
4. FP-Konto prueft `canSpend(...)`.
5. Friendly + Enemy Commander-Ankuendigung wird gesendet.
6. Bei Delay > 0 wird Event in Queue eingeplant, sonst sofort ausgefuehrt.
7. Nach Ablauf startet der Spawn und es folgt die zweite Commander-Meldung.
8. FP-Abzug via `spend(...)` + Save.

---

## Erweiterungs-Template fuer neue Events

1. Neue Datei `faction_points_eventX_<name>.as` anlegen.
2. Interface `FactionPointsEvent` implementieren.
3. In Registry instanziieren und im Lookup registrieren.
4. Event in dieser MD-Tabelle dokumentieren.

