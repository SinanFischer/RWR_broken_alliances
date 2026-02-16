# Platoon Spawn System

---

## Ziel

Ein modulares Command-System bereitstellen, das per Chat-Command ein vordefiniertes Squad spawnt.

- Command: `/platoon`
- Squad: `1x miniboss` + `4x default_ai`
- Spawnart: Fallschirm-Einflug (Spawn mit Hoehenoffset)

---

## Architektur (KISS)

- `scripts/systems/platoon_spawn/platoon_spawn_system.as`  
  Facade-Include (Facade = schlanker Einstiegspunkt).
- `scripts/systems/platoon_spawn/platoon_spawn_api.as`  
  Installiert den Tracker idempotent (idempotent = mehrfacher Aufruf erzeugt kein doppeltes Ergebnis).
- `scripts/systems/platoon_spawn/platoon_spawn_command_tracker.as`  
  Behandelt Chat-Command, Validierung und Spawnlogik.
- `scripts/systems/game_systems_registry.as`  
  Zentrale Registry-Installation (Registry = zentrale Stelle zum Einbinden von Systemen).

---

## Ablauf

1. Spieler sendet `/platoon`.
2. Tracker prueft Zugriff (default: Admin-only).
3. Spieler- und Charakterdaten werden geladen.
4. Spawnposition = Spielerposition + Vorwaerts-Offset + Hoehenoffset.
5. Squad wird als `create_instance` gespawnt:
   - 1 Miniboss vorne
   - 4 Default-AI in kleiner Formation

---

## Konfiguration (aktuell im Tracker)

- `PLATOON_MINIBOSS_KEY = "miniboss"`
- `PLATOON_DEFAULT_SOLDIER_KEY = "default_ai"`
- `PLATOON_DEFAULT_COUNT = 4`
- `PLATOON_SPAWN_HEIGHT = 55.0f`
- `PLATOON_SPAWN_OFFSET_FWD = 6.0f`
- `PLATOON_SPAWN_SPACING = 4.0f`

---

## Modus-Einbindung

Das System wird ueber `installSharedCommandAndDeliverySystems(...)` zentral installiert und ist damit in allen Modi aktiv, die diesen Registry-Installer aufrufen:

- Quick Match
- Invasion
- Campaign

---

## Erweiterung (naechster Schritt)

Fuer bedingungsbasiertes Spawnen kann das System um eine Condition-Schicht erweitert werden, z. B.:

- pro Fraktion unterschiedliche Squad-Templates
- Cooldown pro Spieler/Fraktion
- Kosten (RP/Call-Token)
- Basis-/Frontlinien-Pruefung vor Spawn
