# Explosions- und Einschlags-Effekte: Stufen & Verwendung

Diese Datei beschreibt, **welche Partikel-**`ref`**-Namen** (*Verweise auf benannte `particle_system`-Blöcke*) für welche Waffenklasse gedacht sind. Ziel: neue Projektile konsistent anschließen, ohne globale Effekte zu „kaputtzuskalieren“.

---

## Wo lebt was?

| Ort | Rolle |
|-----|--------|
| `particles/bullet_impact_fx.particle` | Definition aller **`particle_system`**-Namen (Größe, Emission, Material, Lebensdauer, …). |
| `weapons/*.projectile` | Pro Treffer: `<effect class="result" key="terrain|other|vehicle" ref="…" />` verknüpft das Projektil mit den Partikelsystemen. |
| **`splat_map`** (*Terrain-Decal / Krater-Markierung in den Boden-Texturebenen*) | Steht oft **in derselben** `.projectile`-Datei; Radien sollten zur visuellen Stufe passen. |

**Wichtig:** Viele Systeme heißen in Anlehnung an **Heavy Infantry** (`xExp…`, `xSmall…`, `xMed…`). Änderungen an einem Namen betreffen **alle** Projektile, die diesen `ref` nutzen.

---

## Übersicht der drei Hauptstufen

| Stufe | Typische Waffen | Nebel/Rauch/Flash | Granaten-Flames | Splat (HI-Block, Beispiel) |
|-------|-----------------|-------------------|-----------------|----------------------------|
| **Klein (Granate)** | Handgranate, Cluster, Impact, Claymore | `xSmallExpFog` | `xGrenadeExpSmoke2` (statt `xSmallExpSmoke2` bei reinen Granaten) | `3.5` / `4.5` / `5.5` |
| **Mittel (~60 % Heavy)** | LAW, RPG-7, generische `rocket`/`rocket2`, Carl Gustaf, Javelin (Standard + Type2), **AT-Granate** (`at_grenade.projectile`) | `xMedExpFog` … `xMedGrenade2` | inkl. `xMedExpFlash` … | `3.0` / `3.9` / `4.5` |
| **Heavy (voller HI-Block)** | Panzerrohr, TOW, schwerer Mörser, Luftschlag, Javelin Elite, AT-Mine, Küsten/Legion-Kanone | `xExpFog` … `xgrenade2` | unverändert | `5.0` / `6.5` / `7.5` |

---

## Stufe 1: Granaten (kompakt, wenig Wolke)

**Einsatz:** Alles, was wie eine **Hand-/AT-Granate** wirkt und **nicht** die große Artillerie-Nebelwolke braucht.

**Kernidee:** `xExpFog` ist für Heavy stark hochskaliert. Granaten nutzen daher **`xSmallExpFog`** (*eigener, kleinerer Kasten-Emitter für Bodennebel*). Zusätzlich **`xGrenadeExpSmoke2`** (*abgeschwächter Aufstiegsrauch*, damit es nicht mit MGL/Mörser-`xSmallExpSmoke2` kollidiert).

### Referenz-Dateien (identische HI-Granaten-Kette)

- `weapons/hand_grenade.projectile`
- `weapons/cluster_grenade.projectile`
- `weapons/impact_grenade.projectile`
- `weapons/claymore_blast.projectile`

### Typische Kette (`terrain` / `other`; `vehicle` bei AT analog + ggf. `xAtBurstSmall`)

```xml
<!-- GRENADE EFFECTS HEAVY INFANTRY -->
<effect class="result" key="terrain" ref="xSmallExpFog" />
<effect class="result" key="terrain" ref="xSmallExpRise" />
<effect class="result" key="terrain" ref="xSmallDirtExp" use_surface_color="1" />
<effect class="result" key="terrain" ref="xGrenadeExpSmoke2" />
<effect class="result" key="terrain" ref="xCannonFlash" />
<effect class="result" key="terrain" ref="xCannonFlash2" />
<effect class="result" key="terrain" ref="xShieldBurst2" />
<effect class="result" key="terrain" ref="xcannon_round" lighting="0" />
<effect class="result" key="terrain" ref="xcannon_round2" lighting="0" />
<effect class="result" type="splat_map" surface_tag="" size="3.5" atlas_index="0" layer="1" />
<effect class="result" type="splat_map" surface_tag="" size="4.5" atlas_index="4" layer="0" />
<effect class="result" type="splat_map" surface_tag="" size="5.5" atlas_index="0" layer="2" additive="0" />
```

---

## Stufe 2: Mittlere AT-Raketen (~60 % von Heavy)

**Einsatz:** **Leichte Panzerfaust / RPG / Einwegrohr / Carl Gustaf / Standard-Javelin** — sichtbar kleiner als Artillerie, aber noch „AT-würdig“.

**Kernidee:** Eigene Namensfamilie **`xMed*`** in `bullet_impact_fx.particle` (Nebel, Rise, Smoke, Dirt, Flash, Shield-Burst, Flame-Pärchen). **`splat_map`** im HI-Block proportional verkleinert.

### Aktuell zugewiesene Projektile

- `weapons/at_grenade.projectile` (geworfene AT-Ladung, visuell wie mittlere Rakete; `vehicle` behält `xAtBurstSmall`)
- `weapons/m72_law_rocket.projectile`
- `weapons/rpg-7_rocket.projectile`
- `weapons/rocket.projectile`
- `weapons/rocket2.projectile`
- `weapons/m2_carlgustav_rocket.projectile`
- `weapons/javelin.projectile`
- `weapons/javelin_type2.projectile`

### Vorlage `terrain` + `other` (ohne die davorliegenden Vanilla-`BigBurst`-Effekte)

```xml
<!-- HI explosion ~60% (medium AT rocket); full heavy bleibt Panzer/TOW/M120/javelin_elite -->
<effect class="result" key="terrain" ref="xMedExpFog" />
<effect class="result" key="terrain" ref="xMedExpRise" />
<effect class="result" key="terrain" ref="xMedDirtExp" use_surface_color="1" />
<effect class="result" key="terrain" ref="xMedExpSmoke" />
<effect class="result" key="terrain" ref="xMedExpSmoke2" />
<effect class="result" key="terrain" ref="xMedExpFlash" />
<effect class="result" key="terrain" ref="xMedExpFlash2" />
<effect class="result" key="terrain" ref="xMedShieldBurst2" />
<effect class="result" key="terrain" ref="xMedGrenade" lighting="0" />
<effect class="result" key="terrain" ref="xMedGrenade2" lighting="0" />
<effect class="result" type="splat_map" surface_tag="" size="3.0" atlas_index="0" layer="1" />
<effect class="result" type="splat_map" surface_tag="" size="3.9" atlas_index="4" layer="0" />
<effect class="result" type="splat_map" surface_tag="" size="4.5" atlas_index="0" layer="2" additive="0" />

<effect class="result" key="other" ref="xMedExpFog" />
<effect class="result" key="other" ref="xMedExpRise" />
<effect class="result" key="other" ref="xMedExpSmoke" />
<effect class="result" key="other" ref="xMedExpSmoke2" />
<effect class="result" key="other" ref="xMedExpFlash" />
<effect class="result" key="other" ref="xMedExpFlash2" />
<effect class="result" key="other" ref="xMedShieldBurst2" />
<effect class="result" key="other" ref="xMedGrenade" lighting="0" />
<effect class="result" key="other" ref="xMedGrenade2" lighting="0" />
```

**Hinweis:** Viele dieser Projektile nutzen `copy="terrain"` für `static_object` / `vehicle` / `character` — dann reicht die **terrain**-Kette.

---

## Stufe 3: Heavy (voller HI-„Big Explosion“-Block)

**Einsatz:** **Großkaliber / Lenkflugkörper-Elite / Fahrzeugwaffen / schwere Artillerie / Luftschlag**.

### Namen (immer als Set verwenden)

`xExpFog`, `xExpRise`, `xDirtExp`, `xExpSmoke`, `xExpSmoke2`, `xExpFlash`, `xExpFlash2`, `xShieldBurst2`, `xgrenade`, `xgrenade2` + **splat** `5.0` / `6.5` / `7.5`.

### Referenz-Datei

- `weapons/javelin_elite.projectile` (kompletter Block kommentiert `heavy infantry Big Explosion effects`)

### Weitere Beispiele (nicht vollständige Liste)

- `weapons/tow.projectile`
- `weapons/tank_cannon.projectile` (und `tank_cannon_*`, `*_alt`)
- `weapons/tactical_strike.projectile`
- `weapons/m120_heavy_mortar_rocket.projectile`
- `weapons/legion_cannon.projectile`
- `weapons/at_mine.projectile` (Minen-Detonation als schwerer Eindruck)

---

## Sonderfall: Unterlauf / MGL / Mörsergranate (Hybrid)

**Einsatz:** z. B. `mounted_gl.projectile`, `milkor_mgl.projectile`, `mortar_shell.projectile`.

**Muster:** **`xExpFog`** (etwas Präsenz am Boden) **+** **`xSmallExpRise`**, **`xSmallDirtExp`**, **`xSmallExpSmoke2`** (kleinere Aufwirbelung) **+** dieselben Cannon-Flashes wie Granaten. Splat wie Granaten-Block (`3.5` / `4.5` / `5.5`).

Siehe: `weapons/mounted_gl.projectile` ab Kommentar `GRENADE EFFECTS HEAVY INFANTRY`.

---

## Neue Waffe anschließen — Entscheidungsbaum

1. **Ist es eine wurfbare Granate / kleine Ladung?** → Stufe 1 (`xSmallExpFog` + `xGrenadeExpSmoke2` + …).
2. **Ist es eine tragbare AT-Rakete ohne Artillerie-Charakter?** → Stufe 2 (`xMed*` + splat `3.0`/`3.9`/`4.5`).
3. **Ist es Fahrzeug, schweres Rohr, großer Sprengkopf oder Elite-Top-AT?** → Stufe 3 (`xExp*` + splat `5.0`/`6.5`/`7.5`).
4. **Brauchst du eine Zwischenstufe?** → Entweder bestehende Stufe wählen oder **neue** `particle_system`-Namen anlegen (Kopie + Parameter), statt globale `xExp*` zu verbiegen.

---

## Mündungsfeuer vs. Einschlag

Diese Datei betrifft **`class="result"`** (*Effekt beim Aufprall/Detonieren*). **Mündungsblitze** sind **`class="muzzle"`** in `weapons/*.weapon` und andere Partikelnamen (`xRifleFlash`, …) — siehe Basen wie `weapons/base_primary.weapon` und die Partikeldatei.

---

## Kugel-Einschlag (Infanterie)

Kleinkaliber-Einschläge hängen typischerweise an **`weapons/bullet.projectile`** und separaten **`result`-Refs** (nicht die `xExpFog`-Kette). Dafür eigenes Review, falls du neue Penetrations-/Material-Effekte planst.

---

## Pflege

- Wenn du **eine** Waffe anpassen willst: möglichst **`ref` in genau dieser `.projectile`-Datei** ändern oder **neuen** `particle_system`-Namen duplizieren.
- Wenn du **alle** schweren Detonationen änderst: nur die **`xExp*`-Blöcke** in `bullet_impact_fx.particle` anfassen — dann wirkt es auf alle Heavy-Nutzer gleichzeitig.

*Stand: Broken Alliances — Abgleich mit `particles/bullet_impact_fx.particle` und den genannten `.projectile`-Dateien.*
