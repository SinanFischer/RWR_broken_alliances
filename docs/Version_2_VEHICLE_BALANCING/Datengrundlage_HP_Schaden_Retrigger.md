# Datengrundlage: HP, Schaden, Retrigger (Broken Alliances)

Auszug aus den Paketdateien unter `RWR_broken_alliances` (Stand laut Workspace). Ergänzend Vanilla, wo die Waffendefinition **nicht** im BA-Ordner liegt, aber das Fahrzeug die Waffe referenziert.

## Legende

| Begriff | Quelle | Bedeutung für dieses Dokument |
|--------|--------|--------------------------------|
| **HP** (*Lebenspunkte des Fahrzeugs in der Engine*) | `vehicles/*.vehicle` → `max_health` in `<physics …/>` | Rohwert aus der XML; nicht identisch mit „Design-HP“ aus `Idee.md`, aber die messbare Basis im Paket. |
| **Blast-Damage** (*Schaden einer Explosion/HE-Granate*) | `weapons/*.projectile` → `<result class="blast" … damage="…"/>` | Primärer Zahlenwert für Flächenschaden; bei **Submunition** (*mehrere kleine Einschläge*) ist der Gesamteffekt die Summe/Verteilung der Subprojektile. |
| **Retrigger Time** (*Zeit in Sekunden zwischen zwei Schüssen/Salven*) | `weapons/*.weapon` → `retrigger_time` in `<specification …/>` | `-1.0` = Einzelschuss mit Nachlade-/Zykluslogik (kein reiner Feuertakt-Spam). |
| **Kinetisch** (*Treffer ohne `blast`-Damage in der Projectile-Datei*) | z. B. `bullet.projectile`, `bullet_mg.projectile` | Kein `damage="…"` im Sinne von HE-Blast; Fahrzeugschaden läuft über die interne Ballistik/Rüstungslogik der Engine. |

**Ausgeschlossen** (wie gewünscht): reine Spawn-/Dummy-Fahrzeuge (`*_spawn.vehicle`), Schießscheiben, Sonder-Props (Mülleimer, Lagerfeuer, Heli-Wracks, Spezialkisten), Sandbag-Cover, Karten-Duplikate unter `maps/`, sowie „Spaß“-Fahrzeuge (keine Eis-/Bananen-Varianten im Paket vorgefunden).

---

## Tabelle 1 — Kampf- und typische Nutzfahrzeuge (Auswahl)

Spalte **Primär**: die wichtigste antipanzer-/antifahrzeug-Waffe oder Hauptbewaffnung des Turms. **Koax** = koaxiales MG (*zweites Rohr parallel zur Hauptkanone*).

| Fahrzeug (Anzeigename) | Vehicle-Key | HP (`max_health`) | Primärwaffe(n) | Blast-Damage (Primär) | Retrigger (Primär) s |
|------------------------|-------------|-------------------|----------------|-------------------------|----------------------|
| SIK-AP APC | `apc.vehicle` | 15.2 | `apc_hmg.weapon` (Turm-Slot, kein `weapon_key` in Datei) | 0.45 (`apc_hmg.projectile`) | 0.45 |
| GT-C APC | `apc_1.vehicle` | 15.7 | `apc_hmg_1.weapon` | 1.1 | 0.44 |
| BTX APC | `apc_2.vehicle` | 15.6 | `apc_hmg_2.weapon` | 0.14 | 0.412 |
| Humvee | `humvee.vehicle` | 7.2 | `humvee_mg.weapon` | kinetisch | 0.096 |
| Humvee GL | `humvee_gl.vehicle` | 7.2 | `humvee_gl.weapon` | 0.60 (`mounted_gl.projectile`) | 1.0 |
| Willys MB | `willys_mb.vehicle` | 2.4 | `technical_mg.weapon` (×2 gleiche Turm-Refs) | kinetisch | 0.1 |
| Jeep / Jeep 1 / Jeep 2 | `jeep.vehicle` … | 2.4 | (kein `weapon_key`) | — | — |
| Buggy | `buggy.vehicle` | 2.4 | `buggy_mg.weapon` | kinetisch | 0.1 |
| Technical | `technical.vehicle` | 3.3 | `technical_mg.weapon` | kinetisch | 0.1 |
| Gun Truck | `guntruck.vehicle` | 5.0 | `technical_mg.weapon` (mehrere Lafetten) | kinetisch | 0.1 |
| Transport Truck (+_1/_2) | `transport_truck.vehicle` … | 6.8 | — | — | — |
| Cargo Truck | `cargo_truck.vehicle` | 12.0 | — | — | — |
| Armored Truck (Spawn) | `armored_truck.vehicle` | 6.2 | — | — | — |
| Prison Bus | `prison_bus.vehicle` | 12.0 | — | — | — |
| Truck / Truck 1 / Truck 2 | `truck.vehicle` … | (je Datei) | — | — | — |
| Tractor | `tractor.vehicle` | 1.5 | — | — | — |
| Rubber Boat | `rubber_boat.vehicle` | 0.75 | `deployable_mg.weapon` | kinetisch | siehe Waffe |
| ATV Base / Armory | `atv_base.vehicle` / `atv_armory.vehicle` | 5.5 | — | — | — |
| VFS Base / Sport / Para | `vfs_base.vehicle` … | 4.2 | `vfs_buggy_mg` + ggf. `technical_mg` / `vfs_shield` | kinetisch / — | 0.2 |
| Tank | `tank.vehicle` | 32.35 | `tank_cannon.weapon` + Koax `tank_mg.weapon` | 10.0 | 4.3 / Koax 0.08 |
| Tank 1 | `tank_1.vehicle` | 33.2 | `tank_cannon_1.weapon` + Koax `tank_mg_1.weapon` | 10.0 | 4.3 / 0.08 |
| Tank 2 | `tank_2.vehicle` | 32.95 | `tank_cannon_2.weapon` + Koax `tank_mg_2.weapon` | 10.0 | 4.3 / 0.08 |
| Doppelkanonen-Panzer | `doublecannon_tank.vehicle` | 3.0 | 2× `tank_cannon.weapon` | 10.0 | 4.3 |
| Legion | `legion.vehicle` | 45.0 | `legion_cannon.weapon` + Koax `legion_mg.weapon` | 12 (`legion_cannon.projectile`) | 4.0 / Koax 0.15 |
| Vulcan Tank | `vulcan_tank.vehicle` | 12.4 | `vulcan_tank_mg.weapon` | 0.03 (`vulcan.projectile`) | 0.02 |
| Flamer Tank | `flamer_tank.vehicle` | 20.8 | `flamer_tank_cannon.weapon` + `flamer_tank_mg.weapon` | Flammen-Projektil (Vanilla `flamethrower_flame_tank.projectile`) | 0.07 (Flamme) |
| FV101 Scorpio | `fv101.vehicle` | 20.0 | `scorpio_cannon.weapon` + `scorpio_mg1.weapon` | 3.01 | Kanone 3.5 s (**Vanilla**-Waffe) |
| M551 Sheriff | `m551.vehicle` | 24.0 | `m551_cannon.weapon` + Koax `m551_mg.weapon` | 4.01 | Kanone 4.5 s (**Vanilla**) |
| M528 | `m528.vehicle` | 23.2 | `m528_hmg.weapon` + 2× `m528_apj.weapon` | HMG: `apc_hmg_1.projectile` 1.1; APJ: Sub 0.16 × 4–5 | HMG 0.25; APJ 5.0 |
| Radar Tank | `radar_tank.vehicle` | 8.4 | `radar_tank_cannon.weapon` | 0.01 (`radar_tank_hmg.projectile`, 2 Schuss/Salve) | 0.3 |
| Noxe | `noxe.vehicle` | 14.8 | 2× `noxe.weapon` + `technical_mg.weapon` | 2.9 (`noxe.projectile`) | Raketen 4.5 s (**Vanilla** `noxe.weapon`); MG 0.1 |
| SEV-90 | `sev90.vehicle` | 14.8 | `sev90_cannon.weapon` (**Vanilla**-Datei) | 0.45 (`sev90_cannon.projectile`, Vanilla) | 0.70 |
| Hovercraft | `hovercraft.vehicle` | 12.0 | `hovercraft_minig.weapon` | kinetisch | 0.04 |
| Wiesel Mk20 | `wiesel_mk20.vehicle` | 9.5 | `wiesel_mk20.weapon` | 0.3 | 0.35 |
| Wiesel TOW | `wiesel_tow.vehicle` | 9.5 | `wiesel_tow.weapon` + `wiesel_mg3.weapon` | TOW 7.2 | 5.0 / MG 0.055 |
| Mortar (Fahrzeug) | `mortar.vehicle` / `mortar_extended.vehicle` | 1.8 | `mortar.weapon` / `mortar_extended.weapon` | 1.01 (`mortar_shell.projectile`) | 4.5 |
| M120 Heavy Mortar | `m120_heavy_mortar.vehicle` | 3.0 | `m120_heavy_mortar.weapon` | 8.00 | 20.0 |
| TOW-Lafette | `tow.vehicle` | 2.7 | `tow.weapon` | 7.2 | 5.1 |
| Deployable MG / Scoped | `deployable_mg.vehicle` … | 0.8 | `deployable_mg.weapon` … | kinetisch | 0.096 |
| Deployable Minigun | `deployable_minig.vehicle` … | 0.8 | `deployable_minig.weapon` … | kinetisch | 0.04 |
| Coastal Gun | `coastal_gun.vehicle` | 20.0 | `coastal_gun.weapon` | 15 (`coastal_gun.projectile`) | 8.0 |
| Heavy Artillery Gun | `heavy_artillery_gun.vehicle` | 13.0 | `heavy_artillery_gun.weapon` | 7.0 (`heavy_artillery_shell.projectile`) | 15.0 |
| Patrol Ship | `patrol_ship.vehicle` | 16.0 | `patrol_ship_cannon.weapon`, MG, Mörser | Kanone: wie `apc_hmg.projectile` (0.45); Mörser: `rocket2.projectile` 2.0 | Kanone 2.85; MG 0.096; Mörser 9.2 |
| Radar-/Jammer-Türme, Trucks | `radar_tower.vehicle` … | div. | meist ohne Turmkanone | — | — |

---


## Tabelle 2 — Anti-Tank & schwere Wurfwaffen (Granaten / Raketen / Lafetten)

| Eintrag | Waffe / Projektil | Blast-Damage | Retrigger s | Anmerkung |
|---------|-------------------|--------------|------------|-----------|
| RPG-7 | `rpg-7.weapon` → `rpg-7_rocket.projectile` | 4.0 | -1.0 | |
| Javelin | `javelin.weapon` → `javelin.projectile` | 8.7 | -1.0 | |
| Javelin (Captain / Typ 2) | `javelin_captain.weapon` → `javelin_type2.projectile` | 12 | -1.0 | |
| Javelin Elite | `javelin_elite.weapon` → `javelin_elite.projectile` | 13.05 | -1.0 | |
| SMAW | `smaw.weapon` → `smaw_rocket.projectile` | 6.0 | -1.0 | |
| M72 LAW | `m72_law.weapon` → `m72_law_rocket.projectile` | 3.6 | -1.0 | |
| Carl Gustaf M2 | `m2_carlgustav.weapon` → `m2_carlgustav_rocket.projectile` | 5.2 | -1.0 | |
| M202 FLASH | `m202_flash.weapon` → `m202.projectile` | 3.0 | 1.6 | |
| FHJ-01 | `fhj01.weapon` → `fhj01_rocket.projectile` | Sub `fhj01_rocket_sub`: 0.1, 8–10× | -1.0 | FAE-Cluster |
| TOW (Lafette / Wiesel) | `tow.weapon` / `wiesel_tow.weapon` → `tow.projectile` | 7.2 | 5.1 / 5.0 | |
| M528 APJ | `m528_apj.weapon` → `m528_apj.projectile` | Sub `m528_apj_sub`: 0.16, 4–5× | siehe Waffe | |
| Portable Mortar | `portable_mortar.weapon` → `rocket2.projectile` | 2.0 | 1.5 | |
| M120 (geschützt) | `m120_heavy_mortar.weapon` | 8.00 | 20.0 | |
| Lahti L-39 | `lahti_l39.weapon` → `lahti.projectile` | 0.76 | -1.0 | „AT-Gewehr“-Nische |
| AT-Mine (Platzierbar) | `at_mine.projectile` | 5.0 | — | kein `retrigger` (Mine) |
| Handgranate | `hand_grenade.projectile` | 1.01 | — | Wurfitem |
| AT-Granate | `at_grenade.projectile` | 9.99 | — | Wurfitem |
| Impact-Granate | `impact_grenade.projectile` | 2.4 | — | Wurfitem |
| Cluster (Sub) | `cluster_grenade_sub.projectile` | 0.99 je Sub | — | Parent spawnt 4× |
| Blendgranate | `stun_grenade.projectile` | 0.05 (Stun) | — | |

---

## Tabelle 3 — Explosiv / HE (Schwere MGs, GL, genannte Beispiele)

| Eintrag | Waffe → Projektil | Blast-Damage | Retrigger s |
|---------|-------------------|--------------|------------|
| APC HMG (40 mm HE) | `apc_hmg_1.weapon` → `apc_hmg_1.projectile` | 1.1 | 0.44 |
| QJZ-89 „Volk“ | `qjz89_volk.weapon` → `qjz89_volk_bullet.projectile` | 1.0 | 0.11 |
| Truvelo Amris | `truvelo_amris.weapon` → `truvelo_amris.projectile` | 1.5 | -1.0 |
| M79 | `m79.weapon` → `m79.projectile` | 0.48 | -1.0 |
| Humvee GL | `humvee_gl.weapon` → `mounted_gl.projectile` | 0.60 | 1.0 |
| Deployable GL | `deployable_gl.weapon` → `mounted_gl.projectile` | 0.60 | 1.0 |
| M528 HMG (Autokanone) | `m528_hmg.weapon` → `apc_hmg_1.projectile` | 1.1 | siehe Waffe |

---

## Nächste sinnvolle Erweiterung

- Alle verbleibenden `vehicles/*.vehicle` mit `max_health` maschinell in eine CSV spiegeln (lokal ohne Python z. B. per `findstr`), falls du 100 % Abdeckung willst.  
- Für **Koax-MGs** separate Spalte „DPS-Balancing“, sobald du Fahrzeugpanzerung gegen Kugeln modellierst.

Soll die Fahrzeugtabelle auf **alle** `.vehicle` mit `max_health` erweitert werden (inkl. Deployables/Radar), oder reicht diese Kampf-/Logistik-Kurzfassung für Phase 1?
