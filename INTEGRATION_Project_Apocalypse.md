# Project Apocalypse als Vorbild – Integration in RWR Total Conversion Mod

## Was hat Project Apocalypse, was wir nicht haben?

### Calls (Funkunterstützung)
| PA hat | Wir haben |
|--------|-----------|
| **cluster_bomb.call** | – |
| **bm21.call** (Raketenwerfer-Salve) | – |
| **supply_quad.call** (Nachschub-Quad per Fallschirm) | – |
| **a10_gun_run.call** | – |
| **gunship_run.call** / **gunship_run2.call** | – |
| **legion.call** | – |
| **paratroopers_medic.call** (Fallschirmjäger mit Medics) | – |
| **gps.call** | – |
| **tracer_dart.call** (als Call; PA nutzt es teils als Waffe) | – |
| **experimental_calls.xml** (u.a. weitere A10/Gunship-Varianten) | – |
| artillery2 (in PA aktiv) | artillery2-Datei vorhanden, nicht in all_calls |
| rubber_boat, buggy (in PA aktiv) | Dateien bei uns da, nicht in all_calls |  
| – | **heavy_mortar, heavy_artillery, railway_artillery, tactical_strike, vulcan_tank, paratroopers3/4, apc, tank_1/2, tow_drop, minig_drop, mg_drop, mines** (haben wir, PA nicht) |

### Soldier-Typen (KI / Spieler)
| PA hat | Wir haben |
|--------|-----------|
| **default** (nur Spieler, spawn_score 0) | default (auch KI, spawn 1.0) |
| **default_ai** (eigener KI-Standard) | – (ein default für alle) |
| **IUS Sergeant** / Master-Sergeant-Äquivalent | **support** (MG) |
| **rambo** (sehr selten) | – |
| **ncr_ranger** (Ranger mit SMAW, Gunship-Call) | – |
| **snake** (Infiltrator) | – |
| **supply_medic** | – |
| **sniper** (eigener Typ + sniper.ai) | – (nur common_snipers.resources, kein eigener Soldier) |
| **lonewolf** (copy_from sniper) | – |
| **medic2** | – |
| **para** (Fallschirmjäger-Loadout) | – |
| **grenadier** | **grenadier** ✓ |
| **chicken** (Gag) | – |
| **dog** (Hund-Einheit) | – |
| **elite ripper** | – |
| **skeleton** | – |
| **eod** | **eod** ✓ |
| **miniboss, medic, prisoner, supply** | **miniboss, medic, prisoner, supply** ✓ |
| – | **specialforces, miniboss_female** (haben wir, PA anders benannt/strukturiert) |

### AI-Dateien
| PA hat | Wir haben |
|--------|-----------|
| **grenadier.ai** | **grenadier.ai** ✓ (übernommen) |
| **ranger.ai** | – |
| **lonewolf.ai** | – |
| **medic.ai** | – |
| **sniper.ai** | – |
| **dog.ai** | – |
| **chicken.ai** | – |
| **infected.ai** | – |
| **grinch.ai** | – |
| **bomber.ai** | – |
| **default_pvp.ai** | – |

### Fahrzeuge
- PA: **atv_armory_para.vehicle** (Fallschirm-Quad für supply_quad) – wir haben nur atv_armory.
- PA: deutlich mehr Vehicle-Varianten (270+ .vehicle), wir ~58.
- Wir: **vulcan_tank, tow, deployable_minig**, etc. – PA teils andere Namen/Listen.

### Items (Carry Items)
- PA: **160+** carry_items (Vesten, Kostüme, Gags, Belohnungen: captain_vest, camo_vest, dog, gift_box_1–7, costume_*, dollars, gold_bar, …).
- Wir: **6** in items/, Rest aus common.resources (vest1–3, costume_were/clown/santa, eodvest_ai, …).

### Scripts (AngelScript)
- PA: **115** Scripts (Campaign: difficulty_tracker, map_rotator_campaign, stage_configurator, world_marker; Invasion: vehicle_delivery, stage_invasion, …; Tracker: a10_gun_run, gunship_run, gps_laptop, prison_break_objective, …).
- Wir: **5** (start_campaign, my_gamemode, my_*_configurator).

### Sonstiges (PA hat, wir nicht)
- **achievements.xml** / **extra_achievements.xml**
- **languages/** (65+ XML, 29 .character)
- **fonts/** (36 .fontdef, 32 PNG)
- **names/** (32 .txt für First/Last Names)
- **Campaign-Presets** mit eigenen Namen: Infant, Adult, Terminator, Custom
- **Maps:** PA 2500+ Dateien (viele Maps), wir ~43
- **models / textures / sounds:** PA jeweils ein Vielfaches (z. B. 1601 models vs. 92, 2037 textures vs. 66)

---

## Übersicht (kurz)

**Project Apocalypse** (PA) enthält u.a.:
- **Calls:** cluster_bomb, bm21, supply_quad, a10_gun_run, gunship_run, legion, paratroopers_medic, gps, …
- **Soldier-Typen:** ranger, lonewolf, master_sergeant, medic2, para, sniper (eigene Resources), grenadier (eigene AI)
- **AI-Dateien:** grenadier.ai, ranger.ai, lonewolf.ai, medic.ai, sniper.ai
- **Campaign-Optionen:** benannte Presets (Infant, Adult, Terminator)
- Deutlich mehr Waffen, Fahrzeuge, Items, Maps, Scripts

---

## Zwei Wege zur Integration

### A) Abhängigkeit (beide Mods nötig)

In deiner **map_config.xml** (z.B. `maps/map12/map_config.xml`):

```xml
<dependency package="Project_Apocalypse" />
```

- **Vorteil:** Kein Kopieren; du kannst in deinen XMLs Keys aus PA referenzieren (weapon key="…", call key="…"), sofern die Engine geladene Packages zusammenführt.
- **Nachteil:** Spieler müssen **beide** Mods abonnieren; Key-Konflikte möglich.

### B) Kopieren (standalone)

Gewünschte Dateien aus PA in deinen Mod kopieren und ggf. Referenzen anpassen (Pfade/Keys).

- **Vorteil:** Dein Mod funktioniert ohne PA.
- **Nachteil:** Du musst alle Abhängigkeiten mitkopieren (z.B. Call → Projektile, Sounds, Vehicles).

---

## Empfohlene Integration (Kopieren) – nach Priorität

### 1. Grenadier-AI (sofort nutzbar)

PA hat eine **grenadier.ai**, die nur wenige Parameter überschreibt.

- **Kopieren:** `Project_Apocalypse/factions/grenadier.ai` → `RWR_total_conversion_mod/factions/grenadier.ai`
- **Anpassen:** In deinen Faction-XMLs (grey, green, brown) beim Soldier `grenadier` statt `default.ai` eintragen: `<ai filename="grenadier.ai" />`

### 2. Supply-Quad-Call (Nachschub per Fallschirm)

- **Kopieren aus PA:**
  - `calls/supply_quad.call`
  - `vehicles/atv_armory_para.vehicle`
- **In deinem Mod:**
  - `vehicles/all_vehicles.xml`: `<vehicle file="atv_armory_para.vehicle" />` eintragen (falls noch nicht vorhanden).
  - `calls/all_calls.xml`: `<call file="supply_quad.call" />` eintragen.
- **Abhängigkeiten:** `atv_armory_para` spawnt beim Zerstören `atv_armory.vehicle` – das hast du schon. Er braucht `chute_medium.weapon` (oft Vanilla) und gleiche Meshes wie `atv_armory` (atv_armory_body.mesh, atv.png) – prüfen, ob bei dir vorhanden.

### 3. Cluster-Bomb-Call

- **Kopieren aus PA:** `calls/cluster_bomb.call`, `weapons/cluster_bomb.projectile` (und ggf. `selfstun.projectile`, falls nicht in deinem Mod).
- **Sounds/Effects:** In PA: cb_ussr.wav, f22_flyby.wav, explosion6.wav, ShadowAirplaneFlyby_F22, burning_piece_car5.visual_item. Diese aus PA oder Vanilla in deinen Mod übernehmen, falls nötig.
- **Eintrag:** In `calls/all_calls.xml` `<call file="cluster_bomb.call" />` hinzufügen.

### 4. Campaign-Presets (Texte/Stimmung)

- **Idee:** In deiner `package_config.xml` die Preset-Texte von PA übernehmen (z.B. "Infant", "Adult", "Terminator" statt "Normal", "Hard", "Realism") oder Werte (friendly_capacity, enemy_accuracy, …) übernehmen.
- **Kopieren:** Nur die gewünschten `<preset …>`-Blöcke aus `Project_Apocalypse/package_config.xml` in deine `package_config.xml` übertragen und anpassen.

### 5. Weitere Soldier-Typen (Ranger, Sniper, Para, …)

- **Ranger:** PA hat `common_ranger.resources` (u.a. SMAW, tracer_dart_ai, gunship_run2). Du hast bereits Specialforces mit SMAW; Ranger wäre ein zusätzlicher Typ mit eigener AI (`ranger.ai`) und eigenen Resources – aufwendiger, weil Calls/Waffen abgeglichen werden müssen.
- **Sniper:** PA hat dedizierte `*_sniper.resources` und `sniper.ai`. Du hast `common_snipers.resources`; optional könntest du eine eigene Sniper-Soldier-Definition + sniper.ai aus PA übernehmen.
- **Para:** Fallschirmjäger-Loadout; eigene Resources in PA – gleiche Vorgehensweise: Resources + Soldier-Block kopieren, Referenzen prüfen.

### 6. Weitere Calls aus PA

- **bm21.call**, **a10_gun_run.call**, **gunship_run.call**, **legion.call**, **paratroopers_medic.call**, **gps.call**  
- Pro Call: Call-Datei kopieren, dann in der `.call` alle `instance_key`, `fileref`, `ref` durchgehen und fehlende Projektile/Vehicles/Sounds/Effects in deinen Mod kopieren oder auf vorhandene Keys mappen.

---

## Checkliste vor dem Kopieren

- [ ] In PA prüfen: Welche `instance_key`, `fileref`, `ref` nutzt die Datei?
- [ ] Existieren diese Keys/Dateien schon in deinem Mod oder in Vanilla?
- [ ] Wenn nicht: komplette Kette kopieren (z.B. projectile → model → texture/sound) oder Call anpassen (auf andere Keys umstellen).
- [ ] Nach dem Kopieren: `all_weapons.xml` / `all_vehicles.xml` / `all_calls.xml` bzw. Map-Config aktualisieren, damit die neuen Assets geladen werden.

---

## Schnellstart (nur Grenadier-AI)

1. Aus PA kopieren: `factions/grenadier.ai` → dein `factions/grenadier.ai`.
2. In `grey.xml`, `green.xml`, `brown.xml` beim Soldier `name="grenadier"` ersetzen:  
   `<ai filename="default.ai" />` → `<ai filename="grenadier.ai" />`
3. Fertig – Grenadiere nutzen dann die PA-Grenadier-AI (etwas andere Autorität/Genauigkeit).

Wenn du möchtest, können wir als Nächstes **Supply-Quad** oder **Cluster-Bomb** Schritt für Schritt (mit genauen Dateinamen und Zeilen) durchgehen.
