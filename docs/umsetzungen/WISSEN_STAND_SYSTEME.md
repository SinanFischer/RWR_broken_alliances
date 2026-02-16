# Wissenstand Systeme (aktuell)

Stand: laufender Entwicklungszyklus.

---

## 1) VIP/Captain Spawn - aktuelles Verhalten

- Der 1-Base-Spawn kam aus `scripts/events/single_base_vip_tracker.as`.
- Dieser Pfad ist im aktiven Betrieb deaktiviert (Registry-Parameter `enableSingleBaseVip = false`).
- Captain/Escort soll nur noch ueber Cargo-Truck-Flow kommen:
  - `scripts/trackers/vehicle_interval_spawn.as`
  - dort wird bei `cargo_truck.vehicle` der Captain-Squad-Spawn getriggert.

## 2) Cargo-Event Meldungen

- Cargo-Captain Meldungen wurden textlich als Alert hervorgehoben:
  - `"[ALERT] Captain arrived with the supply convoy ..."`
  - `"[ALERT] Enemy ... Cargo truck reported ..."`
- Hinweis: `sendFactionMessage(...)` bietet hier keinen direkten Rahmen/Farb-Parameter.

---

## 3) Neue Spawn-Commands (Admin)

Quelle: `scripts/systems/platoon_spawn/platoon_spawn_command_tracker.as`

- `/platoon`
  - Spawn: `1x miniboss` + `4x default_ai`
  - Fallschirm-Einflug (Hoehenoffset)
- `/combatmedics` (Alias `/combatmedic`)
  - Spawn: `4x combat_medic`
  - Fallschirm-Einflug (Hoehenoffset)

Einbindung:

- zentral ueber `scripts/systems/game_systems_registry.as`
- Installation in Shared-Systems-Block (`installSharedCommandAndDeliverySystems(...)`)

---

## 4) Combat Medic Loot/Loadout

### Weapon-Pool (2. Hand)

Datei: `factions/common_combat_medic.resources`

- `medikit_ai.weapon`
- `taser_medic.weapon`

### Rucksack-/Zusatzloot-Chance

In allen Fraktionsdefinitionen fuer `combat_medic`:

- `factions/green.xml`
- `factions/brown.xml`
- `factions/grey.xml`

gesetzt auf:

- `<item_class_existence class="carry_item" slot="0" probability="0.35" />`

Interpretation:

- `slot="0"` = Zusatzslot/Backpack-Loot
- `0.35` = 35 % Chance auf zusaetzliches Carry-Item

---

## 5) Relevante Schalter

- Quick Match: `scripts/gamemode_quick_match.as`
- Invasion: `scripts/gamemodes/invasion/gamemode_invasion.as`
- Campaign: `scripts/my_gamemode.as`

Alle nutzen die Registry als zentrale Integrationsschicht.
