# AI-Parameter-Vergleich (.ai-Dateien)

**Zweck:** Balance prüfen – Sight, Reaktionszeiten und Distanz-Parameter.  
**Legende:**  
- **leader_sight** = leader_sight_range (m) | **team_sight** = team_member_sight_range (m) | **max_muzzle** = max_sight_range_with_muzzle (m)  
- **day_min/max** = day_reaction_time_to_fight_min/max (s) | **night_min/max** = night_reaction_time_to_fight_min/max (s)  
- **reaction_target** = reaction_time_after_choosing_target (-1 = Standard)  
- **grenade_range** = grenade_monitor_range (m) | **reinforce** = call_reinforcements_max_distance (m) | **help_range** = check_need_for_help_range (m)  
- **dot_range** = monitor_enemies_max_dot_range (Sichtkegel: niedriger = breiter, höher = enger)

---

## 1. RWR Total Conversion Mod – Factions-AI (ohne Maps)

### Sight-Range-Parameter

| AI-Datei | leader_sight | team_sight | max_muzzle | dot_range |
|----------|-------------|------------|------------|-----------|
| **default.ai** | **75** | **65** | **85** | 1.8 |
| **default_soldiers.ai** | 55 | 55 | 65 | 1.8 |
| **cover_troop.ai** | 42 | 42 | 50 | **2.15** |
| **grenadier.ai** | – | – | – | – |
| **support.ai** | – | – | – | – |
| **elite.ai** | – | – | – | 2.4 |
| **elite2.ai** | 55 | 55 | – | 2.4 |
| **eod_light.ai** | 55 | 55 | – | – |
| **eod.ai** | 42 | 42 | 60 | 1.8 |
| **shotgun.ai** | 30 | 30 | 55 | 1.8 |
| **sniper.ai** | – | – | **80** | – |

→ **Erbschaft:** `default_soldiers.ai` → `default.ai`; `cover_troop`, `grenadier`, `support`, `elite`, `elite2`, `eod_light`, `eod`, `shotgun`, `sniper` überschreiben jeweils nur bestimmte Werte.

### Reaktionszeiten (auf Spieler / Gegner)

| AI-Datei | day_min | day_max | night_min | night_max | reaction_target |
|----------|---------|---------|------------|-----------|-----------------|
| **default.ai** | 1.2 | 1.5 | 1.2 | 1.8 | -1.0 |
| **default_soldiers.ai** | – | – | – | – | -1.0 |
| **cover_troop.ai** | 1.0 | 1.5 | 1.2 | 1.8 | -1.0 |
| **elite.ai** | **0.55** | **0.7** | **0.6** | **0.8** | -1.0 |
| **elite2.ai** | 0.55 | 0.7 | 0.6 | 0.8 | -1.0 |
| **eod_light.ai** | 0.5 | 1.0 | 0.75 | 1.3 | -1.0 |
| **eod.ai** | 0.6 | 1.5 | 1.0 | 2.0 | – |
| **shotgun.ai** | 0.5 | 1.2 | 1.5 | 2.1 | – |

→ **Erbschaft:** `grenadier`, `support` erben Reaktionszeiten von `default_soldiers.ai` → `default.ai` (1.2/1.5/1.2/1.8).

### Distanz-Parameter

| AI-Datei | grenade_range | reinforce | help_range | min_grenade | max_grenade |
|----------|---------------|-----------|------------|-------------|-------------|
| **default.ai** | 12 | **180** | 40 | 11 | 32 |
| **default_soldiers.ai** | – | – | – | – | – |
| **cover_troop.ai** | 12 | 180 | 40 | 11 | 32 |
| **elite2.ai** | – | **600** | – | – | – |
| **eod.ai** | 15 | **6000** | 40 | – | 25 |
| **shotgun.ai** | 15 | 6000 | – | – | 25 |

→ **Standard:** `reinforce` 40 (Vanilla), 180 (Mod default) – höher = KI ruft Verstärkung weiter entfernt.

---

## 2. RWR Total Conversion Mod – Map-spezifisch (map12)

| Metrik | map12/default.ai |
|--------|------------------|
| **leader_sight** | 75 |
| **team_sight** | 65 |
| **max_muzzle** | 80 |
| **day_min/max** | 0.3 / 0.6 |
| **night_min/max** | 0.8 / 1.1 |
| **grenade_range** | 15 |
| **reinforce** | 40 |
| **help_range** | 40 |

→ **map12** nutzt nahezu Vanilla-Reaktionszeiten (schneller: 0.3–0.6 / 0.8–1.1) bei erhöhter Mod-Sicht (75/65/80).

---

## 3. Vanilla – Alle Factions-AI (Vollständige Tabelle)

**Erbschaft:** `elite` → `default`; `sniper`, `grenadier`, `ranger`, `medic`, `lonewolf` → `default`; `eod` = Standalone; `evil_commander` → `elite`; `common_commander` → `elite`; `chicken`, `dog` → `default`; `infected`, `lonewolf` = Standalone/Override.

### Sight-Range-Parameter

| AI-Datei | leader_sight | team_sight | max_muzzle | dot_range |
|----------|-------------|------------|------------|-----------|
| **default.ai** | 35 | 30 | 40 | 1.8 |
| **sniper.ai** | **55** | – | – | – |
| **eod.ai** | 35 | 30 | 40 | 1.8 |
| **evil_commander.ai** | **50** | – | **55** | – |
| **ranger.ai** | – | – | – | – |
| **medic.ai** | – | – | – | – |
| **elite.ai** | – | – | – | – |
| **dog.ai** | 25 | 10 | 25 | **3.0** |
| **chicken.ai** | 25 | 25 | 25 | – |
| **infected.ai** | – | – | – | 3.0 |
| **lonewolf.ai** | – | – | – | – |
| **default_pvp.ai** | – | – | – | – |

### Reaktionszeiten

| AI-Datei | day_min | day_max | night_min | night_max | reaction_target |
|----------|---------|---------|------------|-----------|-----------------|
| **default.ai** | **0.3** | **0.6** | **0.8** | **1.1** | -1.0 |
| **sniper.ai** | – | – | – | – | – |
| **eod.ai** | 0.6 | 0.8 | 1.3 | 1.8 | – |
| **ranger.ai** | – | – | – | – | – |
| **dog.ai** | **0.0** | **0.1** | **0.0** | **0.1** | -1.0 |
| **lonewolf.ai** | 1.2 | 1.4 | **0.1** | **0.2** | -1.0 |
| **infected.ai** | – | – | – | – | -1.0 |
| **default_pvp.ai** | – | – | – | – | **0.15** |

→ **default_pvp:** `reaction_time_after_choosing_target` 0.15 (schnellere Zielreaktion im PvP).

### Vanilla Map-spezifisch (map11/default.ai)

| Metrik | Vanilla map11 |
|--------|---------------|
| leader_sight / team_sight / max_muzzle | 35 / 30 / 40 |
| day_min/max / night_min/max | 0.3 / 0.6 / 0.8 / 1.1 |
| grenade_range / reinforce / help_range | 15 / 40 / 40 |

→ Gleich wie Vanilla default.ai; Abweichungen: global_separation_radius_factor 2.0, favor_joining_player_squad 0.2, fire_open_min_time 20, willingness_to_guard 0.9.

### Distanz-Parameter

| AI-Datei | grenade_range | reinforce | help_range | min_grenade | max_grenade |
|----------|---------------|-----------|------------|-------------|-------------|
| **default.ai** | 15 | 40 | 40 | 13 | 25 |
| **eod.ai** | 15 | 40 | 40 | – | **35** |
| **ranger.ai** | – | – | – | 13 | **100** |
| **medic.ai** | – | – | **80** | – | – |
| **dog.ai** | **30** | – | – | – | – |
| **infected.ai** | 30 | – | – | 3 | 25 |

---

## 4. Mod vs. Vanilla – Direktvergleich (default.ai)

| Metrik | Vanilla default | RWR Mod default |
|--------|-----------------|-----------------|
| **leader_sight** | 35 | **75** |
| **team_sight** | 30 | **65** |
| **max_muzzle** | 40 | **85** |
| **day_min/max** | **0.3 / 0.6** | 1.2 / 1.5 |
| **night_min/max** | **0.8 / 1.1** | 1.2 / 1.8 |
| **grenade_range** | 15 | **12** |
| **reinforce** | 40 | **180** |
| **help_range** | 40 | 40 |

→ **Mod:** Deutlich höhere Sichtweite (75/65/85 vs. 35/30/40), **langsamere** Reaktion (1.2–1.8 vs. 0.3–1.1), kleinere Granat-Warnreichweite (12 vs. 15), größere Verstärkungs-Reichweite (180 vs. 40).

---

## 5. Kurzüberblick: Wer führt wo? (Mod)

| Metrik | Höchster | Niedrigster |
|--------|----------|-------------|
| **leader_sight** | default.ai (75) | shotgun.ai (30) |
| **max_muzzle** | default.ai (85) | shotgun.ai (55) |
| **Schnellste Reaktion Tag** | elite.ai (0.55/0.7) | default.ai (1.2/1.5) |
| **Schnellste Reaktion Nacht** | elite.ai (0.6/0.8) | default.ai (1.2/1.8) |
| **Langsamste Reaktion** | default.ai | – |
| **reinforce** | eod.ai (6000) | map12 (40) |
| **Engster Sichtkegel** | cover_troop, elite (2.15–2.4) | default (1.8) |

---

## 6. Stärken-Matrix: Mod vs. Vanilla

| Aspekt | Vanilla | RWR Mod |
|--------|---------|----------|
| **Sichtweite** | 35/30/40 | 75/65/85 (default) |
| **Reaktion auf Spieler** | Schnell (0.3–1.1 s) | Langsamer (1.2–1.8 s) |
| **Verstärkung rufen** | 40 m | 180 m (default), 6000 m (eod) |
| **Elite-Reaktion** | – | 0.55–0.8 s (schnellster Typ) |
| **Sniper-Sicht** | leader 55 | max_muzzle 80 |

**Fazit:** Mod hat höhere Sichtweite, aber bewusst verlangsamte Reaktion (weniger „instant snap“). Elites und EOD-Light sind die schnellsten Reaktions-KI-Typen.

---

*Stand: aus den .ai-Dateien des RWR Total Conversion Mod und Vanilla. „–“ = Wert nicht gesetzt (Basis-Standard oder Erbschaft).*
