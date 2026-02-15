# In-Game-Commands (Chat mit `/`)

Alle **eingebundenen** Chat-Commands des Mods. Ausgenommen: Reinforcement-Pool-Tracker (`/nachschub`, `/pool`) und nicht eingebundene Scripte.

**Zugriff:** **Status-Commands** (nur Infos anzeigen) sind für **alle Spieler**. **Spawn-/Trigger-Commands** (etwas spawnen oder auslösen) sind **nur für Admins**.

---

## 1. Commands aus dem Mod (eigene Scripts)

| Command | Quelle | Gamemode | Zugriff | Beschreibung |
|--------|--------|----------|---------|--------------|
| `/stats` oder `/stat` | `trackers/stats_command_tracker.as` | Quick Match | Alle | Statistik pro Fraktion: A-K-D, C-B, B(s). |
| `/vehicle`, `/vehicle_spawn`, `/fahrzeug` | `trackers/vehicle_interval_spawn.as` | Quick Match, Invasion | Alle | Status: eigene Fraktion - light / medium / heavy (Zeiten in s); heavy zeigt „blocked (leading faction)“ wenn führend. |
| `/vehicle test`, `/vehicle_spawn test`, `/fahrzeug test` | wie oben | Quick Match, Invasion | **Admin** | Sofort-Spawn eines Leicht-Fahrzeugs für die eigene Fraktion. |
| `/blackops3` | `commands/blackops3_vest_command_tracker.as` | Quick Match | **Admin** | Spawnt Black-Ops-Veste III (vest_blackops3) bei Spielerposition; nur zum Testen, nicht in Waffenkammer. |
| `/captain_spawn` | `trackers/captain_spawn_command_tracker.as` | Quick Match | **Admin** | Spawnt 1 Captain + 3 orange_bodyguards bei Spielerposition (eigene Fraktion). |
| `/captain_spawn paradrop` (oder `para`, `1`) | wie oben | Quick Match | **Admin** | Wie oben, mit Paradrop (Höhe). |
| `/cargo_captain_test` oder `/test_cargo_captain` | `trackers/vehicle_interval_spawn.as` | Quick Match | **Admin** | Test: Spawnt Cargo Truck + Captain an zufälliger Basis deiner Fraktion. Simuliert das Cargo+Captain-Event. |
| `/test_enemy_cargo_captain` oder `/enemy_cargo_captain_test` | wie oben | Quick Match | **Admin** | Test: Spawnt Cargo Truck + Captain an zufälliger Basis einer **Feind-Fraktion**. Prüft die Feind-Meldung; Private Message nennt Spawn-Ort + Feind-Intel (nach 2 s). **Nicht** `/cargo_*` – BasicCommandHandler würde sonst zusätzlich Truck für eigene Fraktion spawnen. |
| `/spawn_enemy_cargo` oder `/enemy_cargo_spawn` | wie oben | Quick Match, Invasion | **Admin** | Spawnt einen **feindlichen** Cargo Truck neben der Spielerposition (zum Testen der Cargo-Delivery-Belohnung: in Waffenkammer bringen → RP + Fahrzeug-Spawn). |
| *Cargo-Truck-Spawn* | `vehicle_interval_spawn` + `captain_spawn` | Quick Match | automatisch | Wenn zufällig ein Cargo Truck spawnt (Medium, ~9 % Chance): Captain-Team spawnt mit. Nachrichten an alle Fraktionen. |
| `/test_defender_tank` | `trackers/defender_tank_help.as` | **nur Invasion** | **Admin** | Simuliert Panzer-Spawn für Verteidiger (Test). |

### Vehicle-Command (Kurz)

**`/vehicle`** (ohne Argument) ist ein **Status-Command** für alle Spieler. Er zeigt nur die **eigene Fraktion**: Restzeiten in Sekunden bis zum nächsten Spawn für **light**, **medium** und **heavy**. Überschrift: *Upcoming vehicle spawns*. Ist die eigene Fraktion führend (meiste Basen), steht bei heavy **blocked (leading faction)** - dann gibt es keinen Schwer-Spawn für euch. **`/vehicle test`** spawnt sofort ein Leicht-Fahrzeug und ist **nur für Admins**.

---

## 2. Commands aus eingebundenen Vanilla-Skripten

Diese Handler werden vom Mod per `#include` geladen (Dateien liegen im Vanilla-Paket).

### 2.1 BasicCommandHandler (Vanilla)

- **Quick Match:** eingebunden  
- **Invasion:** eingebunden  
- **Admin-Pflicht:** viele Commands sind Admin-only (z. B. Spawns, Match-Ende, Kick).

Auswahl der Commands (alle mit `/` eingeben, z. B. `/god`, `/whereami`):

- **Match/Server:** `modtest`, `sidinfo`, `kick_id`, `kick`, `0_win`, `1_win`, `1_lose`, `1_own`, `test`, `test2`, `defend`, `0_attack`, `whereami`, `kill_aa`, `prom`, `rp`
- **Spieler:** `god`, `ghost`, `vest3`, `create_vehicle`, `jeep`, `laptop`, `c4`, `dc`, `dgl`, `dmg`, `milkor`, `flasher`, `ww2`, `evil`, `green`, `grey`, `brown`, `gl`, `smg`, `rpg`, `combo`, `vest`, `costume`, `banner`
- **Rollen/Spawns:** `com`, `ecom`, `bana`, `ebana`, `_vip`, `_evip`, `ss`, `atv`, `medal`, `atank`, `1atank`, `2atank`, `tank`, `1tank`, `2tank`, `apc`, `1apc`, `2apc`, `truck`, `1truck`, `2truck`, `rubber`, `arubber`, `megglo`, `emilkor`, `corn`, `xmasrl`, `cargo`, `tow`, `teddy`, `briefcase`, `friend`, `vet`, `demon`, `edemon`, `skel`, `eskel`, `squad`, `esquad`, `gren`, `egren`, `foe`, `lw`, `elw`, `eod`, `eeod`, `ran`, `eran`, `elite`, `eelite`, `femelite`, `efemelite`, `eripper`, `grinch`, `egrinch`, `bunny`, `ebunny`, `chi`, `echi`, `cub`, `ecub`, `sniper`, `dog`, `edog`, `evc`, …

*(Vollständige Liste siehe Vanilla: `scripts/trackers/basic_command_handler.as`.)*

### 2.2 SupporterCommandHandler (Vanilla) - nur Invasion

- **Nur Invasion**, nur für Spieler mit Supporter-DLC.
- Emotes/Animationen: `sit`, `hi`, `salute`, `handstand`, `push`, `yay1`, `yay2`, `dance1`, `dance2`, `dance3`.

---

## 3. Nicht aufgeführt (bewusst ausgenommen)

- **Reinforcement-Pool-Tracker:** `/nachschub`, `/pool` - Script ist im Mod auskommentiert (nicht eingebunden).
- Alle Scripte, die in keinem aktiven Gamemode (Quick Match / Invasion) per `addTracker()` oder Include eingebunden sind.

---

## 4. Gamemode-Übersicht

| Gamemode | Mod-Commands | BasicCommandHandler | SupporterCommandHandler | DefenderTankHelp |
|----------|----------------|---------------------|--------------------------|------------------|
| **Quick Match** | `/stats`, `/vehicle`, `/fahrzeug`, `/captain_spawn`, `/cargo_captain_test`, `/test_enemy_cargo_captain`, `/spawn_enemy_cargo` | ja | nein | nein |
| **Invasion**   | `/vehicle`, `/fahrzeug`, `/spawn_enemy_cargo`, `/test_defender_tank` | ja | ja (Supporter) | ja (Admin) |

*Hinweis: `/captain_spawn` und `/cargo_captain_test` sind nur in Quick Match eingebunden. `/spawn_enemy_cargo` (feindlicher Cargo neben Spieler) in Quick Match und Invasion.*

---

## 4.1 IntelManager (Quick Match) – Basis-Aufklärung

**Quelle:** `trackers/intel_manager_quickmatch.as` (angepasst aus Vanilla Invasion)

Wie in Invasion/Kampagne: Feind-Basen werden als „to investigate“ markiert. Wenn ein Spieler eine Feind-Basis scoutet (Einheit im center_block oder Fadenkreuz nahe Basis) → Commander meldet die Stärke (very weak / weak / medium / heavy) und RP-Belohnung.

| Verhalten | Beschreibung |
|-----------|--------------|
| Start | Pro Fraktion: alle capturable Feind-Basen (owner_id ≠ eigene Fraktion) mit „investigate“-Marker |
| Scout | Spieler geht in Basis oder zielt mit Fadenkreuz auf Basis (25 m) |
| Report | Commander meldet Stärke; bei Spieler zusätzlich Privatnachricht mit Taktik-Tipp |
| **Stale-Reset** | Nach 5 Min wird Intel verworfen → Basis zurück auf „to investigate" (neu scouten) |
| **Besitzerwechsel** | base_owner_change_event → Intel verworfen, Marker neu gesetzt |
| **Pro Fraktion** | Gray, Brown usw. können jeweils Feind-Basen scouten (symmetrisch) |

---

## 4.2 Cargo+Captain-Event – Ablauf & Nachrichten

**Quelle:** `vehicle_interval_spawn.as` + `captain_spawn_command_tracker.as`

### Auslöser

1. **Zufällig:** Medium-Fahrzeug-Spawn (alle 5-8 Min pro Fraktion) wählt zufällig ein Fahrzeug - ~9 % Chance auf Cargo Truck.
2. **Test:** `/cargo_captain_test` oder `/test_cargo_captain` (Admin) – eigene Basis. `/test_enemy_cargo_captain` oder `/enemy_cargo_captain_test` – Feind-Basis.

### Ablauf

| Schritt | Aktion | Ort |
|---------|--------|-----|
| 1 | Zufällige Basis der Fraktion (die gerade spawnt) auswählen | `spawnVehicle()` / `spawnCargoTruckWithCaptain()` |
| 2 | Cargo Truck an Basis-Position spawnen | `create_instance` |
| 3 | Captain + 3 Bodyguards an derselben Position spawnen | `CaptainSpawnCommandTracker.spawnCaptainSquadAt()` |
| 4 | **Eigene Fraktion:** Commander-Message (2 s nach Vehicle-Meldung) | „Captain arrived with the supply convoy and will defend our position.“ (Ort bereits in Standard-Vehicle-Meldung) |
| 5 | **Feind-Fraktionen:** Commander-Message | „Enemy [Fraktionsname] Cargo truck reported - escorted by a Captain. Take him out; he's carrying high-value weapons.“ (ohne Basisdaten) |
| 6 | Captain-Marker (VIP-Ziel, atlas 17) für eigene Fraktion | `update()` in Captain-Tracker |
| 7 | Feind spottet Cargo Truck → Feind-Marker (Enemy Commander, atlas 18) | `vehicle_spot_event` |

**Pro Fraktion:** Gray und Brown können gleichzeitig jeweils einen Captain haben. Das System trackt bis zu 8 Fraktionen parallel.

### Troubleshooting: Kein Enemy Commander / keine Commander-Meldung

- **Commander-Meldung:** Erscheint 2 s nach dem Vehicle-Spawn. Bitte warten.
- **vehicle_spot_event:** Wird ausgelöst, wenn eine Fraktion den Cargo Truck des Gegners **erstmals** spottet (Fog-of-War / Karte). Im F5-Debug-Modus kann das Event ausbleiben.
- **Log prüfen:** In `captain_spawn_command_tracker.as` ist `DEBUG_VEHICLE_SPOT = true` – bei aktivem Log wird jeder Cargo-Truck-Spot geloggt (`vehicle_spot_event cargo_truck owner=X spotter=Y`).

### Commands für Test

- **`/cargo_captain_test`** oder **`/test_cargo_captain`** – eigene Basis (vehicle_interval_spawn.as).
- **`/test_enemy_cargo_captain`** oder **`/enemy_cargo_captain_test`** – Feind-Basis. **Nicht** `/cargo_*` verwenden – Vanilla BasicCommandHandler spawnt sonst zusätzlich einen Truck für die eigene Fraktion.
- **`/spawn_enemy_cargo`** oder **`/enemy_cargo_spawn`** – feindlicher Cargo Truck **neben Spielerposition** (Quick Match + Invasion). Zum Testen der Cargo-Delivery-Belohnung: in Waffenkammer fahren → RP + Fahrzeug-Spawn.

---

## 5. Vehicle-Spawn-Commands (Übersicht)

Alle Chat-Commands, die ein **Fahrzeug** bei der Spielerposition spawnen. Mit `/` eingeben (z. B. `/jeep`). **Admin-only**, sofern nicht anders angegeben. Quelle: Vanilla BasicCommandHandler bzw. Mod.

| Command | Fahrzeug (Key) | Anmerkung |
|---------|----------------|-----------|
| `/create_vehicle` | special_cargo_vehicle1.vehicle | Cargo-Fahrzeug |
| `/jeep` | jeep.vehicle | Jeep |
| `/atv` | atv_base.vehicle | Quad (Standard) |
| `/quad` | atv_armory.vehicle | Versorgungs-Quad |
| `/guntruck` | atv_armory.vehicle + Flare | wie quad, mit Flare |
| `/armory` | mobile_armory.vehicle | Mobile Waffenkammer |
| `/atank` | tank_alt.vehicle | Panzer Alt-Variante |
| `/1atank` | tank_1_alt.vehicle | |
| `/2atank` | tank_2_alt.vehicle | |
| `/tank` | tank.vehicle | Panzer |
| `/1tank` | tank_1.vehicle | |
| `/2tank` | tank_2.vehicle | |
| `/apc` | apc.vehicle | APC |
| `/1apc` | apc_1.vehicle | |
| `/2apc` | apc_2.vehicle | |
| `/truck` | truck.vehicle | LKW |
| `/1truck` | truck_1.vehicle | |
| `/2truck` | truck_2.vehicle | |
| `/rubber` | rubber_boat.vehicle | Gummiboot |
| `/arubber` | rubber_boat_alt.vehicle | Gummiboot Alt |
| `/cargo` | cargo_truck.vehicle | Cargo-LKW (Faktion 1) |
| `/tow` | tow.vehicle | Abschleppwagen (Faktion 1) |
| `/scorpion` | fv101.vehicle | Scorpio AXN (Leichter Panzer) |
| `/hover` | hovercraft.vehicle | Hovercraft |
| `/m551` | m551.vehicle | M551 |
| `/vfs` | vfs_base.vehicle | VFS |
| `/noxe` | noxe.vehicle | NOXE Ghost (Mod: mit MG-Passagier) |
| `/legion` | legion.vehicle | Legion |
| `/m528` | m528.vehicle | M528 |
| `/croc` | flamer_tank.vehicle | Flammenpanzer |
| `/sev90` | sev90.vehicle | SEV90 |
| `/repair_crane` | repair_crane.vehicle | Reparaturkran |
| `/mustela` | wiesel_tow.vehicle | Wiesel TOW |
| `/icecream` | icecream.vehicle | Event-Fahrzeug |
| `/rj` | radio_jammer.vehicle | Radio Jammer (Faktion 1) |
| `/cat` | darkcat.vehicle | Darkcat (Faktion 0) |
| `/ecat` | darkcat.vehicle | Darkcat (Faktion 1) |
| `/snowman` | snowman.vehicle | Event (Faktion 1) |
| `/vehicle test` | (zufälliges Leicht-Fahrzeug) | **Mod**, Admin only |
| `/captain_spawn` | (1 Captain + 3 orange_bodyguards) | **Mod**, Quick Match, Admin only |
| `/spawn_enemy_cargo` oder `/enemy_cargo_spawn` | cargo_truck.vehicle (Feind-Fraktion) neben Spieler | **Mod**, Quick Match + Invasion, Admin only |

---

## 6. Debug-Mode (RWR mit debugmode starten)

Wenn du RWR im **Debug-Mode** startest, stehen zusätzliche **Tastenkombinationen** und **Optionen** zur Verfügung (Engine-Features, unabhängig vom Mod).

**Starten:** In Steam → RWR → Rechtsklick → *Eigenschaften* → *Startoptionen* → eintragen: **`debugmode`**. Spiel starten.  
**Hinweis:** Im Debug-Mode kannst du **kein Multiplayer** verbinden.

### Tastenkombinationen im Debug-Mode

| Taste / Kombination | Funktion |
|--------------------|----------|
| **F4** | Freie Kamera (umherfliegen). **Umschalt (Links)** gedrückt halten = schneller fliegen. |
| **F5** | Erweiterte Sichtweite, weißes Licht, kein Nebel (Rendering-Check). |
| **F6** | Tageslicht erzwingen. |
| **F8** | Live-Reload von Ressourcen (z. B. XML-Änderungen im laufenden Spiel nachladen). |
| **Strg+F8** | Live-Reload (Alternative). |
| **F9** | Performance- und Zustandsdaten anzeigen. |
| **1-0** (Ziffern) | Grafikelemente nach Gruppen ein-/ausblenden (Einfluss auf Performance prüfen). |
| **Strg+1** bis **Strg+0** | KI-Debug-Visuals ein-/ausblenden (z. B. Sichtbereiche, Squad-Zugehörigkeit). |

*Quelle: [RWR Wiki - Debugmode](https://runningwithrifles.fandom.com/wiki/Debugmode), [Command line switches](https://runningwithrifles.fandom.com/wiki/Command_line_switches).*
