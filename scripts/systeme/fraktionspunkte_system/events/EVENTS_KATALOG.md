# FP Events Katalog

## Ziel

Ein zentraler Ueberblick ueber alle Fraktionspunkte-Events (FP-Events), deren Bedingungen, Kosten und Ausfuehrung.

- **FP-Event:** ausloesbare Aktion mit klarer Bedingung und fixen FP-Kosten pro Fraktion.
- **Event-Strategy:** jede Event-Logik ist in eigener Datei gekapselt.
- **Registry:** zentrale Zuordnung von Command-Token zu Event-Strategie.

---

## Technischer Aufbau

- `faction_points_event_interface.as`  
  Vertrag fuer Events: `getCost`, `canExecute`, `execute`.
- `faction_points_event_registry.as`  
  Verwaltung/Lookup, Kostenpruefung, FP-Abzug, Ausfuehrung.
- `faction_points_event1_support_squad.as`  
  Support-Ausflug (`/event1`).
- `faction_points_event2_company_attack.as`  
  Company-Angriff (`/event2`).

---

## Event-Definitionen

| Event | Command | Kosten (FP) | Bedingung | Aktion | Simulierbar | Status |
|---|---|---:|---|---|---|---|
| Event1 Support-Ausflug | `/event1` | 250 | `squad_size <= 2` beim ausloesenden Spieler | `paratroopers_medic.call` an Spielerposition | Ja (Admin-only) | Aktiv |
| Event2 Company-Angriff | `/event2` | 1200 | Gegnerbasis vorhanden + genug FP | 2x `paratroopers2.call` an naechster gegnerischer Basis | Ja (Admin-only) | Aktiv |

---

## Parameter pro Event

### Event1

- `FP_EVENT1_COST = 250`
- `FP_EVENT1_CALL_KEY = paratroopers_medic.call`
- `FP_EVENT1_SQUAD_HALF_THRESHOLD = 2`

### Event2

- `FP_EVENT2_COST = 1200`
- `FP_EVENT2_PLATOON_CALL_KEY = paratroopers2.call`
- `FP_EVENT2_PLATOON_COUNT = 2`
- `FP_EVENT2_CALL_SPACING = 8.0`

---

## Ablauf (Engine-Datenfluss)

1. Admin triggert `/event1` oder `/event2`.
2. Registry resolved Event-Strategy.
3. `canExecute(...)` prueft Bedingung.
4. FP-Konto prueft `canSpend(...)`.
5. Event fuehrt Aktion aus.
6. FP-Abzug via `spend(...)` + Save.

---

## Erweiterungs-Template fuer neue Events

1. Neue Datei `faction_points_eventX_<name>.as` anlegen.
2. Interface `FactionPointsEvent` implementieren.
3. In Registry instanziieren und im Lookup registrieren.
4. Event in dieser MD-Tabelle dokumentieren.

