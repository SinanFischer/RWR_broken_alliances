# Fahrzeugklassen nach Panzerungsstufen (Broken Alliances)

Dieses Dokument fasst **Design-Regeln** (*vereinbarte Kategorien für Balancing und Zielpriorität*) für euer Vehicle-Balancing zusammen. Es ist **keine** automatische Auslesung der Engine-Tags; die Zuordnung folgt eurer Vorgabe und der üblichen Einordnung im Paket.

**Vehicle-Key** (*der eindeutige Dateiname/Identifikator im Spiel, z. B. `humvee.vehicle`*) steht immer in Backticks, damit ihr ihn in XML/Skripten 1:1 übernehmen könnt.

### Englische Kurzlabels (ein Wort / ein Token)

Für Chats, Tabellen und optional **AngelScript-Konstanten** (*feste Namen im Code*) nutzt ihr dieselbe Abstufung überall:

| Klasse | Englisch (Wort) | `SCREAMING_SNAKE` (*Konstanten-Stil, z. B. in `.as`*) | Kurzbedeutung |
|--------|-----------------|--------------------------------------------------------|----------------|
| 1 | **Soft** | `ARMOR_SOFT` | weich / ungepanzert |
| 2 | **Light** | `ARMOR_LIGHT` | leicht gepanzert |
| 3 | **Medium** | `ARMOR_MEDIUM` | mittel (APC & Co.) |
| 4 | **Heavy** | `ARMOR_HEAVY` | schwerer als APC, noch kein voller MBT |
| 5 | **Battle** | `ARMOR_BATTLE` | Hauptkampfpanzer (*synonym in der Praxis oft „MBT“*) |
| 6 | **Superheavy** | `ARMOR_SUPERHEAVY` | über MBT — bei euch nur Legion |

**Hinweis:** Das international geläufige Kürzel **MBT** (*Main Battle Tank*) ist **kein** einzelnes englisches Wort — deshalb **`Battle`** als Label für Klasse 5; in Fließtext dürft ihr trotzdem „MBT“ schreiben, wenn ihr meint **Klasse 5 / `ARMOR_BATTLE`**.

---

## Klasse 1 — Nicht gepanzert (**Soft** / `ARMOR_SOFT`)

*Offene Karosserie oder reine Logistik, kein relevanter Kampfpanzerungsanspruch.*

| Vehicle-Key | Anmerkung |
|-------------|-----------|
| `jeep.vehicle`, `jeep_1.vehicle`, `jeep_2.vehicle` | Leichte Geländewagen |
| `willys_mb.vehicle`, `willys_mb_para.vehicle` | *(Para-Variante: Drop)* |
| `buggy.vehicle`, `buggy_alt.vehicle` | |
| `technical.vehicle` | Aufbau mit MG, faktisch un-/leicht gepanzert → hier bei **Klasse 1** eingeordnet (kann bei Bedarf nach **Klasse 2** rutschen) |
| `guntruck.vehicle`, `guntruck_para.vehicle` | *(Spawn/Para beachten)* |
| `transport_truck.vehicle`, `transport_truck_1.vehicle`, `transport_truck_2.vehicle` | |
| `truck.vehicle`, `truck_1.vehicle`, `truck_2.vehicle` | |
| `cargo_truck.vehicle` | wie von dir genannt |
| `tractor.vehicle` | |
| `rubber_boat.vehicle`, `rubber_boat_alt.vehicle` | |
| `armored_truck.vehicle` | Name irreführend; im Paket eher Spawn-/Logistikfahrzeug → **Klasse 1** |
| `dogcrate_para.vehicle` | Spezial / Para |
| `cover1.vehicle`, `cover_crate_para.vehicle` | eher Objekt/Support |
| `banana_car.vehicle`, `banana_car_spawn.vehicle`, `banana_peel_spawner.vehicle` | Spaß-Content; fürs Balancing meist ignorieren |

---

## Klasse 2 — Leicht gepanzert (**Light** / `ARMOR_LIGHT`)

*Geschützte Aufklärung / leichte Patrouille, MG oder leichte Bewaffnung, deutlich weniger Schutz als APC.*

| Vehicle-Key | Anmerkung |
|-------------|-----------|
| `humvee.vehicle`, `humvee_gl.vehicle`, `humvee_gl_alt.vehicle` | inkl. GL-Variante |
| `vfs_base.vehicle`, `vfs_sport.vehicle`, `vfs_para.vehicle`, `vfs_at.vehicle` | VFS-Familie |
| `hovercraft.vehicle` | wie von dir genannt |
| `atv_base.vehicle`, `atv_armory.vehicle`, `atv_armory_alt.vehicle` | „Quad“-Nische |

---

## Klasse 3 — Mittelgepanzert (**Medium** / `ARMOR_MEDIUM`)

*APC-Klasse, leichte Ketten-/Rad-Kampfwagen mit starker Bewaffnung aber nicht auf schwere Kampfpanzer-Niveau; Mörserfahrzeuge und M113-Varianten.*

| Vehicle-Key | Anmerkung |
|-------------|-----------|
| `apc.vehicle`, `apc_1.vehicle`, `apc_2.vehicle` | |
| `aav7.vehicle` | amphibischer APC → **Klasse 3** |
| `noxe.vehicle` | |
| `wiesel_mk20.vehicle`, `wiesel_tow.vehicle` | Wiesel inkl. TOW |
| `vulcan_tank.vehicle` | Flak-/Vulcan-Chassis |
| `m113_tank_acav.vehicle` | **ACAV** (*FST ACAV / M113 mit Aufbau*) |
| `m113_tank_mortar.vehicle` | **Mortar Tank** |
| `mortar.vehicle`, `mortar_extended.vehicle`, `mortar_2.vehicle` | fahrbare Mörser |
| `radar_tank.vehicle` | leichte Kanone, kein schwerer MBT → **Klasse 3** |
| `doublecannon_tank.vehicle` | falls aktiv: Sonderfall niedrige `max_health` im Paket — Balancing separat klären |

---

## Klasse 4 — Gepanzert (M528, SEV-90, M551, FV101, Flamer) (**Heavy** / `ARMOR_HEAVY`)

*Deutlich mehr Panzerung als APC; keine vollen MBT-„Hauptpanzer“ der Klasse 5.*

| Vehicle-Key | Anmerkung |
|-------------|-----------|
| `m528.vehicle` | |
| `sev90.vehicle` | |
| `m551.vehicle` | |
| `fv101.vehicle` | Scorpio |
| `flamer_tank.vehicle` | Flammenpanzer |

---

## Klasse 5 — Schwer gepanzert (Hauptkampfpanzer: tank / tank_1 / tank_2) (**Battle** / `ARMOR_BATTLE`)

*Klassische MBT der drei Basis-Typen.*

| Vehicle-Key | Anmerkung |
|-------------|-----------|
| `tank.vehicle`, `tank_1.vehicle`, `tank_2.vehicle` | |
| `tank_alt.vehicle`, `tank_1_alt.vehicle`, `tank_2_alt.vehicle` | Supporter-/Skin-Varianten derselben Klasse |

---

## Klasse 6 — Extrem schwer gepanzert (Legion) (**Superheavy** / `ARMOR_SUPERHEAVY`)

| Vehicle-Key | Anmerkung |
|-------------|-----------|
| `legion.vehicle` | **einziger** Eintrag nach eurer Regel |

---

## Spawn- und Dummy-Fahrzeuge (keine eigene Panzerstufe)

Diese Keys nur für Spawns/Technik; fürs **Balancing** meist **der Stufe des „echten“ Fahrzeugs** zuordnen oder ignorieren:

`legion_spawn.vehicle`, `sev90_spawn.vehicle`, `flamer_tank_spawn.vehicle`, `m528_spawn.vehicle`, `noxe_spawn.vehicle`, `wiesel_spawn.vehicle`, `hovercraft_spawn.vehicle`, `willys_mb_spawn.vehicle`, `vfs_spawn.vehicle`, `guntruck_spawn.vehicle`, `vulcan_acav_spawn.vehicle`, `*_spawn.vehicle` allgemein.

---

## Marine, Statik, Emplacement (separat von der Land-Panzerungsmatrix)

| Vehicle-Key | Vorschlag |
|-------------|-----------|
| `patrol_ship.vehicle` | **Marine** — eigene Matrix (oder Stufe 1–2 nach Spielgefühl) |
| `coastal_gun.vehicle`, `heavy_artillery_gun.vehicle`, `tow.vehicle`, `tow_2.vehicle`, `m120_heavy_mortar.vehicle` | **Emplacement** — feste oder aufgestellte Waffen/Lafetten, **keine** Panzerklasse 1–6. **`m120_heavy_mortar.vehicle`**: vom **Skin** (*sichtbares Modell im Spiel*) und vom Setup her nah an den **fahrbaren Mörsern** `mortar.vehicle` / `mortar_2.vehicle` (*Klasse 3*), gameplay aber **Aufstellung** (*platzierte Einheit, kein Fahrzeug*); **Panzerungsmatrix** hier nicht wie bei APC anwenden — eher **Soft**-Robustheit, leicht zerstörbar (**Überfahren** *Fahrzeugkollision kann die Einheit stark treffen*). **Feuerkraft** separat über `m120_heavy_mortar.weapon` / Projektil — AT-Tabelle **Indirekt (Spieler / Fahrzeug)**. |
| `deployable_mg.vehicle`, `deployable_mg_scoped.vehicle`, `deployable_mg_2.vehicle`, `deployable_minig.vehicle`, … | **Lafette** — keine Panzerstufe, nur Zielpriorität |
| `radar_tower.vehicle`, `radar_towera.vehicle`, `radio_jammer.vehicle`, `radio_jammer2.vehicle` | **Support-Struktur** — ggf. `blast_range`-Logik (siehe Jammer-Doku) |
| `sandbag_cover.vehicle`, `sandbag_cover_stable.vehicle` | Deckung, keine Fahrzeuge |

---

## Anti-Tank-Waffen — Typ-Raster (Entwurf, parallel zu den Fahrzeugstufen)

Ziel: später jeder **AT-Waffe** (*Anti-Tank-Waffe*) eine **wirksame Mindeststufe** (*ab welcher Fahrzeugklasse sie sinnvoll effizient bleiben soll*) und **Obergrenze** (*gegen welche Stufe sie absichtlich nachlässt*) zu geben.

| AT-Typ | Beispiele (BA) | Rolle |
|--------|----------------|--------|
| **AT leicht** | `m72_law.weapon`, `rpg-7.weapon` | Soft–Medium, marginal gegen Heavy–Battle |
| **AT mittel** | `m2_carlgustav.weapon`, `smaw.weapon`, `m202_flash.weapon`, `fhj01.weapon` | Soft–Heavy, begrenzt gegen Battle |
| **AT schwer** | `javelin.weapon`, `tow.weapon` / `wiesel_tow.weapon`, Fahrzeug-APJ `m528_apj.weapon` | Medium–Battle |
| **AT Top** | `javelin_captain.weapon`, `javelin_elite.weapon` | auch Battle–Superheavy mit Absicherung gegen „zu schnell“ |
| **Spreng / Satz** | `c4.projectile`, `at_grenade.projectile`, `at_mine.projectile` | stark abhängig von Platzierung und `blast_range` am Ziel |
| **Indirekt (Spieler / Fahrzeug)** | `portable_mortar.weapon`, `m120_heavy_mortar.weapon` | eher Fläche / offene Ziele — **keine** Kommandeur-**Calls** (*Fähigkeiten aus `.call`-XML, die Projektile per `instance_key` spawnen*) |
| **Indirekt (Calls)** | siehe Tabelle unten | gleiche Panzerungs-Logik wie andere **Blast** (*Flächenschaden mit Radius und `damage` im Projektil*), plus **Salven** (*viele Einschläge pro Call erhöhen effektiven Druck auf Soft–Medium*) |

**Calls — welches Projektil wie stark (BA, Stand XML)**

Die **AT-Tabelle** oben listet **`artillery_shell.projectile`** noch nicht explizit; **`artillery2.call`** (*Kommandeur-Artillerie mit mehreren `round`-Salven*) und **`artillery1.call`** nutzen beide genau dieses Projektil. Sortierung nach typischer Einzeltreffer-Stärke (`blast`-Zeile in der jeweiligen `.projectile`-Datei):

| Stufe (Richtung) | `instance_key` / Projektil | Typische `.call` / Nutzung | Blast `radius` / `damage` (BA) |
|------------------|----------------------------|----------------------------|--------------------------------|
| leicht | `artillery_shell.projectile` | `artillery1.call`, `artillery2.call` | 6.8 / 2.3 |
| mittel | `heavy_mortar_shell.projectile` | `heavy_mortar.call` | 10.5 / 5.0 |
| schwer | `heavy_artillery_shell.projectile` | `heavy_artillery.call` | 20.0 / 7.0 — gleiches Projektil wie **`heavy_artillery_gun.weapon`** (*geschütztes Geschütz im Spiel*) |
| Luft / präzise schwer | `bomb1.projectile` | `tactical_strike.call` | 9.2 / 17.0 |
| extrem | `railway_artillery_shell.projectile` | `railway_artillery.call`, `radio.call` (Feuerauftrag) | 50.0 / 30.0 |
| Sonst | `bomb.projectile` | `bomb.call` | nicht im BA-Paket definiert — Werte aus Basis-/Vanilla prüfen, falls der Call aktiv ist |
| Minenfeld | `ap_mine.projectile` | `mines.call` | eher Infanterie / Soft; nicht mit Artillerie-Blast vergleichen |

Hinweis: **`artillery2.call`** hat pro Salve viele **`instances`** (*Anzahl der Granaten pro `round`*) — effektiver Schaden auf ein Ziel hängt von Trefferzahl und Streuung (`instance_spread` / `common_spread`) ab, nicht nur von der Einzel-**Blast**-Zahl.

*(Konkrete Zahlen: an `Datengrundlage_HP_Schaden_Retrigger.md` andocken; Call-Salven dort bei Bedarf als eigene Zeilen ergänzen.)*

---

## Offene Abstimmungspunkte

1. **`technical.vehicle` / `guntruck.vehicle`** — Klasse **1** oder **2**? (MG-Schutz ohne echte Panzerung.)
2. **`cargo_truck`** steht in Skripten manchmal bei „mittleren“ Spawns — bei euch **nur** Klasse **1** oder doppelt führen?
3. **`doublecannon_tank.vehicle`** — gameplay vs. `max_health` im XML abstimmen.
4. **`aav7.vehicle`** — bei euch fest **Klasse 3** (APC) ok?

Wenn du willst, kann ich als Nächstes eine **Spalte „empfohlene AT-Typen“** pro Fahrzeugstufe ergänzen oder die AT-Tabelle an eure `Idee.md`-Zielwerte (Legion 300 HP-Design vs. Engine-`max_health`) koppeln.
