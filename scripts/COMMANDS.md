# In-Game-Commands (Chat mit `/`)

Alle **eingebundenen** Chat-Commands des Mods. Ausgenommen: Reinforcement-Pool-Tracker (`/nachschub`, `/pool`) und nicht eingebundene Scripte.

---

## 1. Commands aus dem Mod (eigene Scripts)

| Command | Quelle | Gamemode | Beschreibung |
|--------|--------|----------|--------------|
| `/stats` oder `/stat` | `trackers/stats_command_tracker.as` | Quick Match | Kompakte Statistik pro Fraktion: A-K-D (Alive-Kills-Deaths), C-B (Capacity-Blocked), B(s) (blocked Slot-Sekunden). |
| `/vehicle`, `/vehicle_spawn`, `/fahrzeug` | `trackers/vehicle_interval_spawn.as` | Quick Match, Invasion | Status: nächste Fahrzeug-Spawns pro Fraktion (Simple 2–4 min, Medium 5–8 min). |
| `/vehicle test`, `/vehicle_spawn test`, `/fahrzeug test` | wie oben | Quick Match, Invasion | Sofort-Spawn eines Simple-Fahrzeugs für die eigene Fraktion. |
| `/bane_spawn` | `trackers/bane_spawn_command_tracker.as` | Quick Match | **Admin.** Spawnt 1 Bane + 2 Terminators bei Spielerposition (eigene Fraktion). |
| `/bane_spawn paradrop` (oder `para`, `1`) | wie oben | Quick Match | Wie oben, mit Paradrop (Höhe). |
| `/test_defender_tank` | `trackers/defender_tank_help.as` | **nur Invasion** | **Admin.** Simuliert Panzer-Spawn für Verteidiger (Test). |

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

### 2.2 SupporterCommandHandler (Vanilla) – nur Invasion

- **Nur Invasion**, nur für Spieler mit Supporter-DLC.
- Emotes/Animationen: `sit`, `hi`, `salute`, `handstand`, `push`, `yay1`, `yay2`, `dance1`, `dance2`, `dance3`.

---

## 3. Nicht aufgeführt (bewusst ausgenommen)

- **Reinforcement-Pool-Tracker:** `/nachschub`, `/pool` – Script ist im Mod auskommentiert (nicht eingebunden).
- Alle Scripte, die in keinem aktiven Gamemode (Quick Match / Invasion) per `addTracker()` oder Include eingebunden sind.

---

## 4. Gamemode-Übersicht

| Gamemode | Mod-Commands | BasicCommandHandler | SupporterCommandHandler | DefenderTankHelp |
|----------|----------------|---------------------|--------------------------|------------------|
| **Quick Match** | `/stats`, `/vehicle`, `/fahrzeug`, `/bane_spawn` | ja | nein | nein |
| **Invasion**   | `/vehicle`, `/fahrzeug`, `/test_defender_tank` | ja | ja (Supporter) | ja (Admin) |

*Hinweis: `/bane_spawn` ist nur in Quick Match eingebunden.*
