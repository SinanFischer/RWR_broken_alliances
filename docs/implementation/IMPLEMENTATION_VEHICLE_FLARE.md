# Dateiname: IMPLEMENTATION_VEHICLE_FLARE.md

# Fahrzeug-Flare (Throwable): Definition, Engine-Load, Match & Waffenkammer
**Ziel:** Eine neue **Flare** hinzufügen, die beim Abwurf nach Ablauf ein **Fahrzeug** spawnt und optional in der **Waffenkammer** (Armory) kaufbar ist.

**Referenz im Mod:** `weapons/legion_flare.projectile`, `weapons/willys_mb_flare.projectile`, `weapons/atv_armory_flare.projectile`.

---

## Kurzüberblick

| Schritt | Wo | Was tun |
|--------|-----|--------|
| **1. Fahrzeug** | `vehicles/*.vehicle` + `vehicles/all_vehicles.xml` | Ziel-Fahrzeug muss existieren und geladen sein (`key="…"` merken). |
| **2. Projectile** | `weapons/<name>_flare.projectile` | `class="grenade"`, **`result class="spawn"`** mit **`instance_class="vehicle"`** und **`instance_key="<fahrzeug>.vehicle"`**; Shop: **`in_stock="1"`**, **`<inventory price="…" encumbrance="…" />`**, **`commonness`** niedrig halten (KI-Loot). |
| **3. Engine-Load** | `weapons/all_throwables.xml` | **`<projectile file="…_flare.projectile" />`** – ohne dies wird die Datei nicht geladen. |
| **4. Match-Resources** | `factions/common_resources/common.resources` | **`<projectile key="…_flare.projectile" enabled="1" />`** – damit Default-Soldaten & Shop die Definition kennen. |
| **5. Zusatz-Pools** | z. B. `supply_common.resources`, `sniper/common_sniper_base.resources`, `common_shotgun_base.resources` | Wie bei anderen Fahrzeug-Flares spiegeln, falls alle Klassen die Flare nutzen sollen. |
| **6. Waffenkammer** | `factions/common_resources/armory_common.resources` (alle Fraktionen) oder `armory_green` / `armory_grey` / `armory_brown` | **`<projectile key="…_flare.projectile" enabled="1" />`** eintragen – analog zu Deployables in der Doku `IMPLEMENTATION_NEW_WEAPON_ARMORY.md`. |

**Wichtig:**
- **Kein** Eintrag in `weapons/all_weapons.xml` nötig – Flares sind **Projectiles**, keine `.weapon`-Dateien.
- **Visuell:** `model` / `hud_icon` auf vorhandene Assets legen (z. B. `flare_stick.mesh`, `flare_stick_*.png`, `hud_flare_*.png` aus Vanilla oder dem Mod).
- **Spawn-Offset:** `offset="0 3.0 0"` ist üblich, damit das Fahrzeug leicht über dem Boden erscheint (wie bei `legion_flare.projectile`).

---

## Minimal-Beispiel: Projectile-Datei

Pfad: `weapons/beispiel_flare.projectile` (Name und `key` konsistent halten).

```xml
<?xml version="1.0" encoding="utf-8"?>
<projectile class="grenade" name="Mein Fahrzeug Drop" key="beispiel_flare.projectile" slot="0" radius="0.15" time_to_live_out_in_the_open="90.0" drop_count_factor_on_death="1.0">

    <result class="spawn" instance_class="vehicle" instance_key="ZIELFAHRZEUG.vehicle" min_amount="1" max_amount="1" offset="0 3.0 0" position_spread="0 0" direction_spread="0 0" />

    <trigger class="time" time_to_live="3.0"/>
    <rotation class="random" />

    <model mesh_filename="flare_stick.mesh" texture_filename="flare_stick_green.png" />
    <hud_icon filename="hud_flare_green.png" />

    <throwable curve_height="3.0" near_far_distance="5.0" speed_estimation_near="9.0" speed_estimation_far="17.0" max_speed="9.0" randomness="0.07" />

    <commonness value="0.02" can_respawn_with="0" in_stock="1" />
    <capacity value="1" source="rank" source_value="0.0" />
    <inventory encumbrance="2.0" price="250.0" />

</projectile>
```

**Parameter kurz:**
- **`instance_key`** – muss exakt dem **`key`** der Vehicle-XML entsprechen.
- **`time_to_live`** (Trigger) – Verzögerung bis zur Explosion/Spawn.
- **`in_stock` / `price` / `encumbrance`** – Voraussetzung für Anzeige in der Waffenkammer (siehe Hauptdoku).
- **`capacity`** – wie viele Stück je Rang im Inventar möglich sind (an bestehende Flares anpassen).

---

## Checkliste

- [ ] Fahrzeug in `vehicles/all_vehicles.xml` und in den benötigten **`*.resources`** (oft `common.resources`) als **`<vehicle key="…" />`** vorhanden.
- [ ] `weapons/all_throwables.xml`: Projectile eingetragen.
- [ ] `common.resources`: **`<projectile key="…" enabled="1" />`**
- [ ] Bei Bedarf: `armory_common.resources` (oder fraktionsspezifisch) + dieselben Projectile-Zeilen in Supply/Sniper/Shotgun-Pools wie bei `willys_mb_flare`.
- [ ] **`commonness`** nicht unnötig hoch – sonst droppt die KI die Flare zu oft.

---

## Fehlersuche

| Problem | Typische Ursache |
|--------|-------------------|
| Flare „existiert“ nicht / wird nicht geworfen | Eintrag in **`all_throwables.xml`** fehlt. |
| Kein Fahrzeug erscheint | Falscher **`instance_key`**, Vehicle nicht in **`all_vehicles.xml`** / **`common.resources`**. |
| Nicht im Shop | **`in_stock="1"`** und **`price`** fehlen; oder Projectile fehlt in **`common.resources`** / **`armory_*.resources`**. |
| Quick Match: Stash leer | Wie in `IMPLEMENTATION_NEW_WEAPON_ARMORY.md`: **`/_execute admin_stash.xml`** im Spiel-Root testen. |

---

## Siehe auch

- `IMPLEMENTATION_NEW_WEAPON_ARMORY.md` – allgemeine Armory-/Stash-Logik (Weapons, Deployables, `in_stock`).
- `weapons/legion_flare.projectile` – teure Legion-Variante mit Rank-**`capacity`**.
