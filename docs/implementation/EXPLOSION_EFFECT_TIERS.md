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

## Übersicht: Hauptstufen + Autocannon-HE + .50 BMG

| Stufe | Typische Waffen | Nebel/Rauch/Flash | Granaten-Flames | Splat (HI-Block, Beispiel) |
|-------|-----------------|-------------------|-----------------|----------------------------|
| **Klein (Granate)** | Handgranate, Cluster, Impact, Claymore | `xSmallExpFog` | `xGrenadeExpSmoke2` (statt `xSmallExpSmoke2` bei reinen Granaten) | `3.5` / `4.5` / `5.5` |
| **Autocannon HE (~60 % Granate, wuchtiger Blitz)** | APC **40 mm**, Flak-/Radar-HMG, Wiesel Mk20 (`apc_hmg*`, `radar_tank_hmg`, `wiesel_mk20`) | `xAcHeExpFog`, `xAcHeExpRise`, `xAcHeDirtExp`, `xAcHeExpSmoke2` + **dieselben** `xCannonFlash*` wie Granate | kein `xMed*`-Flammenpaar — Wucht über **kanonische** Blitz-/Ring-Refs | `2.2` / `2.85` / `3.35` (zweite **splat_map**-Triade nach Vanilla-`1.0`) |
| **.50 BMG (kinetisch)** | `50cal_bullet.projectile` | Vanilla `Burst` + `LowDust` + `x50CalDustKick` + `x50CalSmokeLinger` + **`x50CalImpactSmoke`** (sofortiger Aufprall-Rauch) | **kein** HE-/Cannon-Flash | keine zusätzliche **splat_map**-Triade (nur Vanilla-Einschlag) |
| **Mittel (~60 % Heavy)** | LAW, RPG-7, generische `rocket`/`rocket2`, Carl Gustaf, Javelin (Standard + Type2), **TOW** (`tow.projectile`), **AT-Granate** (`at_grenade.projectile`) | `xMedExpFog` … `xMedGrenade2` | inkl. `xMedExpFlash` … | `3.0` / `3.9` / `4.5` |
| **Heavy (voller HI-Block)** | Panzerrohr, schwerer Mörser, Luftschlag, Javelin Elite, AT-Mine, Küsten/Legion-Kanone | `xExpFog` … `xgrenade2` | unverändert | `5.0` / `6.5` / `7.5` |

**Kurz zum Realitätsbezug (Design-Intent):** Eine **.50-Cal-HMG** (*schweres Maschinengewehr, reine Vollgeschosse ohne HE-Füllung*) wirkt im Spiel eher wie Durchschlag + wenig Staub; **40 mm HE** (*Hochexplosivgranate im kleinen Kaliber*) ist weniger Sprengstoff als eine Handgranate, aber **kinetisch** (*Aufprallenergie der Masse*) und **punktuell** (*Detonation am Einschlagort*) — deshalb kleinere Rauchwolke als Granate, aber **volle** Cannon-Flashes für den „Hammer“-Eindruck.

---

## Stufe 1: Granaten (kompakt, wenig Wolke)

**Einsatz:** Alles, was wie eine **Hand-/AT-Granate** wirkt und **nicht** die große Artillerie-Nebelwolke braucht.

**Kernidee:** `xExpFog` ist für Heavy stark hochskaliert. Granaten nutzen daher **`xSmallExpFog`** (*eigener, kleinerer Kasten-Emitter für Bodennebel*). Zusätzlich **`xGrenadeExpSmoke2`** (*abgeschwächter Aufstiegsrauch*, damit es nicht mit MGL/Mörser-`xSmallExpSmoke2` kollidiert).

### Referenz-Dateien (identische HI-Granaten-Kette)

- `weapons/hand_grenade.projectile`
- `weapons/cluster_grenade.projectile`
- `weapons/impact_grenade.projectile`
- `weapons/claymore_blast.projectile`
- `weapons/ap_mine.projectile`

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

## Stufe 1b: Autocannon / 40 mm HE (zwischen Kugel und Granate)

**Einsatz:** Fahrzeug-Maschinenkanone mit **HE-Granate** im Sinne des Mods (`40mm.mesh`), nicht Infanterie-HMG-Kugeln.

**Kernidee:** Rauch/Nebel/Aufwirbelung auf **~60 %** der Granaten-Refs (`xSmall*` / `xGrenadeExpSmoke2`) skaliert unter den Namen **`xAcHe*`** (*Autocannon HE — eigene `particle_system`-Familie*). **Blitz und Lichtreflexe** bleiben auf **Granaten-Niveau** (`xCannonFlash`, `xShieldBurst2`, `xcannon_round*`), damit der Treffer **wuchtiger** wirkt als die kleinere Wolke. Auf **Fahrzeugen** zusätzlich **`xAtBurstSmall`** (*kleiner panzer-spezifischer Aufprallblitz*).

### Partikelnamen

| Name | Rolle |
|------|--------|
| `xAcHeExpFog` | Bodennebel, ~60 % von `xSmallExpFog` |
| `xAcHeExpRise` | Aufstiegssäule, ~60 % von `xSmallExpRise` |
| `xAcHeDirtExp` | Erdbrocken, nur `key="terrain"` |
| `xAcHeExpSmoke2` | HE-Rauchpuff, ~60 % von `xGrenadeExpSmoke2`, leicht angehobene **Emission** (*Partikel pro Zeiteinheit*) für sichtbaren HE-Rauch |

### Referenz-Dateien

- `weapons/apc_hmg.projectile`
- `weapons/apc_hmg_1.projectile`
- `weapons/apc_hmg_2.projectile`
- `weapons/radar_tank_hmg.projectile`
- `weapons/wiesel_mk20.projectile`

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
- `weapons/tow.projectile`

### Vorlage `terrain` + `other` (ohne die davorliegenden Vanilla-`BigBurst`-Effekte)

```xml
<!-- HI explosion ~60% (medium AT rocket); full heavy: Panzerrohr/M120/javelin_elite -->
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

## Sonderfall: Benzinfass (`fuel_barrel.static_object`)

**Vanilla-Pfad:** `vanilla/static_objects/fuel_barrel.static_object` — beim **`destroy`** (*Zerstören des Objekts*) spielen **`event_key="destroy"`**-**`effect`**-Einträge (*Partikel an der Stelle des Fasses*) sowie per **`spawn`** gespawnte **`projectile`** mit **`instance_key`** (*welches unsichtbare Projektil sofort die Druckwelle auslöst*).

**Broken Alliances:** Überschreibung unter `static_objects/fuel_barrel.static_object` (**`destroy`**: **`SmokeMinor`** / **`ShadowSmokeMinor`** + **`BigBurst`**, kurzer Rauch) + **`fuel_barrel_stun.projectile`** / **`fuel_barrel_destroy.projectile`** (größere **`blast`**-Radien; **`fuel_barrel_destroy`** ohne lange HI-Rauchwolken — nur **`LowDust`**, Blitz-Refs, **`splat_map`**). So bleiben **`debri_*`** für die WW2-Bombe unangetastet.

---

## Richtlinie: Wann `50cal_bullet.projectile` — wann `bullet.projectile`

**Nur echte schwere HMG-/Anti-Material-Kaliber** (*12,7 mm NATO **.50 BMG** oder 12,7×108 mm wie **DSchK/Kord/QJZ-89***) dürfen im Paket **`50cal_bullet.projectile`** nutzen (einheitliche HI-Aufschlagskette **`x50Cal*`**).

**Kein .50 für:**

- **7,62×51 mm NATO** (*Full-Power wie G3/SCAR-H/MG3/M240*) → immer **`bullet.projectile`**. Das **MG3** überzeugt durch **Feuerrate** (~1000–1200 RPM), nicht durch Patronen wie eine **M2 Browning**.
- **7,62 mm Minigun** (*M134 / GAU-17 in 7,62*) → **`bullet.projectile`**.
- **Leichte Fahrzeug-MGs** (*PKM, „Buggy MG“, Koaxial-MG*) → **`bullet.projectile`**.

**Im Broken-Alliances-Paket** verweist aktuell **nur** **`weapons/brown/qjz89_volk.weapon`** auf **`50cal_bullet.projectile`** (QJZ-89 = 12,7×108 mm HMG). Alle anderen genannten Fahrzeug-MGs im Mod nutzen **`bullet.projectile`**.

---

## Sonderfall: .50 BMG / schweres Vollgeschoss (kinetisch, kein HE)

**Einsatz:** `weapons/50cal_bullet.projectile` — siehe Richtlinie oben; im Paket: **`qjz89_volk`**.

**Kernidee:** Weiter **`Burst`** + **`LowDust`** (Vanilla), plus **`x50CalDustKick`** (*verstärkte Staub-/Splitterwolke auf **Dust4**-Basis, ähnlich `LowDust`*), **`x50CalSmokeLinger`** (*kleiner, langsamer **Nebel** mit **`xExpSmoke`**, ohne Cannon-/HE-Flash*) und **`x50CalImpactSmoke`** (*kurzer, gut sichtbarer Rauchstoß direkt am Einschlag*). **Kein** `xCannonFlash` / `xExpFog` — optisch **Aufschlag**, keine **Detonation**.

**Mündung (.50-Waffen):** Zusätzlich zu bestehenden Blitzen/Rauch **`x50CalMuzzleFog`** und **`x50CalMuzzleDust`** (`class="muzzle"`) — im Paket derzeit bei **`qjz89_volk`**.

---

## Neue Waffe anschließen — Entscheidungsbaum

1. **Ist es eine wurfbare Granate / kleine Ladung?** → Stufe 1 (`xSmallExpFog` + `xGrenadeExpSmoke2` + …).
2. **Ist es eine Fahrzeug-40-mm-HE-Maschinenkanone (kleine HE-Ladung, harter Einschlag)?** → Stufe 1b (`xAcHe*` + Cannon-Flash-Set wie Granate; Fahrzeug `xAtBurstSmall`).
3. **Ist es .50 BMG / 12,7×108 HMG (kinetisch)?** → nur dann `50cal_bullet.projectile` + `x50Cal*` + optional `x50CalMuzzleFog` / `x50CalMuzzleDust`. **Kein** Punkt 3 bei 7,62 mm (MG3, M240, Minigun 7,62, …) → **`bullet.projectile`**.
4. **Ist es eine AT-Rakete / ATGM** (*z. B. LAW, RPG, Carl Gustaf, Standard-Javelin, **TOW***) **ohne Artillerie-/Elite-Charakter?** → Stufe 2 (`xMed*` + splat `3.0`/`3.9`/`4.5`).
5. **Ist es schweres Rohr, großer Sprengkopf, Luftschlag oder Elite-Top-AT** (*z. B. Panzerkanone, Javelin Elite, Mörser schwer*) **?** → Stufe 3 (`xExp*` + splat `5.0`/`6.5`/`7.5`).
6. **Brauchst du eine Zwischenstufe?** → Entweder bestehende Stufe wählen oder **neue** `particle_system`-Namen anlegen (Kopie + Parameter), statt globale `xExp*` zu verbiegen.

---

## Mündungsfeuer vs. Einschlag

Diese Datei betrifft **`class="result"`** (*Effekt beim Aufprall/Detonieren*). **Mündungsblitze** sind **`class="muzzle"`** in `weapons/*.weapon` und andere Partikelnamen (`xRifleFlash`, …) — siehe Basen wie `weapons/base_primary.weapon` und die Partikeldatei.

---

## Kugel-Einschlag (Infanterie)

Kleinkaliber-Einschläge hängen typischerweise an **`weapons/bullet.projectile`** und separaten **`result`-Refs** (nicht die `xExpFog`-Kette). **Schweres Vollgeschoss:** **`50cal_bullet.projectile`** mit **`x50Cal*`** — siehe Sonderfall oben.

---

## Pflege

- Wenn du **eine** Waffe anpassen willst: möglichst **`ref` in genau dieser `.projectile`-Datei** ändern oder **neuen** `particle_system`-Namen duplizieren.
- Wenn du **alle** schweren Detonationen änderst: nur die **`xExp*`-Blöcke** in `bullet_impact_fx.particle` anfassen — dann wirkt es auf alle Heavy-Nutzer gleichzeitig.

*Stand: Broken Alliances — Abgleich mit `particles/bullet_impact_fx.particle` und den genannten `.projectile`-Dateien.*
