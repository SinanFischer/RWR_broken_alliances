# Change Log

## [1.2.0] - 2026-03-17

### Commands:

**HUD**
| Command | Description |
|---|---|
| `/hud on` | Alive-HUD AN → FP-HUD automatisch AUS |
| `/hud off` | Alive-HUD AUS |
| `/fov on` | FoV-Erweiterung AN |
| `/fov off` | FoV-Erweiterung AUS |

**Faction Point System**
| Command | Description |
|---|---|
| `/fp` | Alle FP-Befehle anzeigen |
| `/fp_status` | FP aller Fraktionen anzeigen |
| `/fp hud on` | FP-HUD AN → Alive-HUD automatisch AUS |
| `/fp hud off` | FP-HUD AUS |
| `/fp_add <fid> <n>` | **Admin**: FP einer Fraktion hinzufügen (Debug) |
| `/fp_set <fid> <n>` | **Admin**: FP einer Fraktion setzen (Debug) |
| `/fp_ai` | **Admin**: AI-Status anzeigen |
| `/fp_ai_tick` | **Admin**: AI-Tick sofort auslösen (Debug) |
| `/fp_event event4` | **Admin**: Event 4 erzwingen (ohne FP-Prüfung), eigene Fraktion |
| `/fp_event event5` | **Admin**: Event 5 erzwingen (ohne FP-Prüfung), eigene Fraktion |
| `/event1..5` | **Admin**: Event mit FP-Prüfung auslösen |

**AI**
| Command | Description |
|---|---|
| `/ai_attack` | KI-Angriff auslösen |
| `/ai_defend` | KI-Verteidigung auslösen |
| `/ai_status` | KI-Status anzeigen |

### Calls 
Information list of all calls: 



### Faction Points System

**FP income** (tune in `faction_points_tracker.as` + `faction_points_kill_rank.as`):
 **base capture** (+120 FP), 
 **hold tick** every 20 s (+5 FP per owned base), 
 **kills** (every 30 s factions are ranked by owned base count; **1st** +2 FP; with **3+ factions**: **2nd** +3, **3rd+** +4; with **2 factions only**: the trailing faction gets +4; friendly fire excluded; tune `FP_KILL_RANK_*` + `FP_KILL_RANK_REFRESH_INTERVAL`; `FP_KILL_REWARD_AI` toggles AI vs player-only kills). The AI spends FP automatically; players can trigger eligible events manually via chat commands.

**Events**

| #   | Name               | Cost    | Trigger                       | Effect                                                                                |
| --- | ------------------ | ------- | ----------------------------- | ------------------------------------------------------------------------------------- |
| 1   | Support Squad      | 250 FP  | Player (squad ≤ 2 men)        | Drops `paratroopers1` call at player position — small squad reinforcement             |
| 2   | Company Attack     | 1200 FP | AI (strategic)                | 2× `paratroopers2` platoon drops flanking the nearest enemy base — large assault wave |
| 3   | Defense Response   | 700 FP  | AI (on base loss, 25% chance) | 3× `paratroopers1` squad drops around the just-lost base — immediate counter-push     |
| 4   | Base Reinforcement | 350 FP  | AI (strategic)                | 1× `paratroopers2` drop at a friendly base (round-robin) — steady line reinforcement  |
| 5   | Vehicle Support    | 500 FP  | AI (strategic)                | Spawns a random medium vehicle (APC, IFV, etc.) at a friendly base                    |
| 6   | Heavy Armour       | 1800 FP | AI (strategic, >3 bases)      | Spawns a random heavy vehicle (tank, etc.) at a friendly base — requires dominance     |

**AI Decision Logic**

- **Every 60 s:** 5% chance to trigger Event 1 for each faction (if affordable).
- **On base loss:** 25% chance to trigger Event 3 (if affordable).
- **Strategic goal (weighted roll):** AI picks a saving target — Event 2 (weight 0.2), Event 4 (0.6), Event 5 (0.5), or a passive saving phase (0.3, only when holding > 2 bases). Once FP ≥ cost + random reserve (0–450), the event fires and a new goal is rolled.

### Slotblock System gefixt

- Slotblock System hat nicht wirklich mehr gegriffen. Dank HUD Fehler erkannt und behoben. Nun funktioniert das System wie erwartet.

### Assaults & Last Defenses

- Wenn die führende Fraktion x:3 mehr Truppen hat als die andere Fraktion findet ein kompensator statt. Die 1:3 unterlegende Fraktion erhält einen 4x Capacity Boost und erhält entsprechend viele Soldaten. Dies dient als Push der Fraktion. Jede Fraktion hat genau 1x so eine mobilisierungsfähigkeit.
  Bei Aussault Maps wird üblicherweise der angreifenden Fraktion dieser sofort ausgespielt. Was einen Sturm Angriff darstellt.

### New deployables

- mg scoped
- minigun scoped
- support mortar (higher range, normal projectiles)

### Weapons

- Waffen sind der Realität angepasst, retrigger rates und Waffenmerkmal Einstellugnen basieren auf realität. (Keine Garantie auf 100% Übereinstimmung, Inspiration).

**Kleines:**

- AI Sight range has got a little debuff. So getting shot is rarer without seeing the enemy.
- **CAWS:** stärker als Schrotflinte auf Distanz abgestuft (höhere `spread_range`, niedrigerer `accuracy_factor`, etwas langsamere `projectile_speed`, `kill_decay` früher/kürzer, Stance-Genauigkeit wie SPAS-12 im Paket).
- **Waffen:** Wo `sight_range_modifier` (_Multiplikator für die effektive Sichtweite mit der Waffe_) gesetzt ist, ist `ai_sight_range_modifier` (_KI-Variante desselben Faktors_) **90 %** des Spielerwerts (10 % weniger). Bei **0** bleibt die KI bei **0**. Waffen nur per `file="…"` ohne eigenen Eintrag unverändert (Vanilla-Basis). **Fix:** `patch_ai_sight_modifiers.ps1` nutzt `(?<!ai_)`, damit nicht innerhalb von `ai_sight_range_modifier` gematcht wird; Panzer-`tank_cannon*` / `tank_mg*` / `radar_tank_cannon` hatten fehlendes `sight_range_modifier` (Loader-Crash) – repariert.
- **KI `fire_open_min_time` rollenbasiert:** Line-Infanterie `default_soldiers` / `default.ai` / `map12` **9s** (statt 12); Elite (Captain, Bodyguard, Miniboss, SF) **8s**; MG `support.ai` **20s** unverändert; EOD **8s**; Shotgun **6s** unverändert.
- cover deploy tragmenge erweitert
- wiesel flare preis auf 400 RP
- origin shotgun waffe auf 120 RP
- call humvee (landfahrzeug) teurer machen auf 350
- VFS Flare in Waffenkammer auf 250 reduzieren
- EOD Weste in Waffenkammer respawnable
- FAH-01 in Waffenkammer respawnable machen
- warum m4a1 so teuer? - 36 RP die anderne viel weniger? ggf preislich anpassen wenn kein triftiger Grund.

**Weiteres**

- luftkissenboot als flare für Waffenkammer einrichten. Kosten: 1100 .
- legion flare erstellen und für 3800 in die
- mg deploy weapon duplizieren und eine weitere variante erstellen welche 2.5x so viel kostet aber die variante scoped ist und 0.325x mehr sight_range modifier hat als die normale variante
- die minigun deploy weapon duplizieren und ebenfalls eine scoped variante machen mit 2.5x der kosten aber die variante scoped ist und 0.225x mehr sight_range modifier hat als die normale variante

## [1.1.0] - 2026-03-01

This updates is concentrated to give more content to the mod.

- **Admin-Command `/fov`:** FOV Visualization (Sichtkegel-Anzeige) zur Laufzeit steuerbar: `/fov true` oder `/fov false` (auch `1`/`0`, `on`/`off`). Kampagne + Quick Match.

- activated fov on all quick match maps, you can deactivate map specific by setting value 0 in fov for example under: RWR_broken_alliances\packages\vanilla\maps\map17\init_match.xml

### Weapons

- Big rebalance of many weapons & new currency prices
- Cooldown visualisation added for Coastal Gun & Heavy Mortar
- 3 new Heavy MGs – one per faction
- - RU: Volk MG – fires .50 cal rounds, damages vehicles and destroys crates
- - USA: Lewis MG
- - EU: MG08
- M120 Heavy Mortar – extreme range field artillery, 20 second reload
- Origin-12 – fully automatic shotgun, 30-round magazine. Rarely carried by shotgun troops.
- Medic Dartgun
- QBZ-95 – hybrid shotgun/rifle. Rarely carried by shotgun troops.

**Leader AI Troops (Miniboss)**
How to spot them: Look for the beret. You can instantly recognize these elite officers on the battlefield by their distinctive headgear.
They spawn with fully rebalanced gear and wield devastating special or elite weaponry. Defeating them is highly rewarding, as they often carry exclusive faction weapons that cannot be acquired in the standard armory. Additionally, there is a rare chance they will drop a highly valuable secondary weapon, such as a Golden Knife.

Can sometimes carry (among other weapons):

- (new) Golden Knife (1000)
- (new) Truvelo Amris suppressed (648)
- (new) Cavalry saber (333)
- (new) Javelin Elite (250) – increased damage, 2x sight range
- MG-42 (800)
- Milkor MGL (650)
- Lahti L-39 (640)
- VSS Vintorez (500)
- Stoner LMG (500)
- F2000 (400)
- Steyr AUG (250)
- Neostead 2000 (110)
- Javelin (100)
- MGL Flasher (80)
- FHJ-01 Cluster (50)

**Exotic Weapons**
When supply lines collapse, soldiers use whatever they find. Not every weapon comes from an armory.

**Special Force Troop**

- can carry origin_12 & QBZ-95

  **ALL Factions**

- each faction received a grenade launcher rifle: M16A4 M203 (USA), G36 AG36 (EU), AK-74M GP25 (RU)
- add: Tommy Gun - relic firearm, carried by MG troops. Because sometimes the old ones still work.

  **Europe**
  added:

- TTI (combat shield)

**Russia**
added:

- RPK-16
- AN94

**USA**
added:

- Camo Shield
- XM25
- M1 Garand – high lethality at close to medium range
- CheyTac M200 – extreme long-range sniper, 2-shot capacity, 2.6x sight modifier. Rarely carried by sniper units.

### Calls

- **Tank Drops (RWR1a1, Leopold II, TroX-80)**:
  - Preis erhöht: 1000 -> 1200

## [1.0.1] - 2026-03-01

_Initial release of the RWR Broken Alliances Mod package adjustments._

### Calls

- Heavy Artillery Price: 450 -> 850
- Heavy Mortal Price: 350 -> 400

### Vehicles

- New Deployable Artillery Gun. It offers a 3x sight multipliers but needs 15 seconds to reload. Small rotation radius. Low life (7 instead of 20).
- Limited Coastal Gun turret rotation range to 170 degrees (±85°) to prevent 360-degree firing.
- Deactivated Vehicle spawn when no player is in-game.

### Weapons & Items

- **Coastal Gun (Deploy Item)**:
  - Increased price in armory from 950 to 1000 RP.
- **Coastal Gun (Weapon)**:
  - Increased sight range modifier by 10% (from 1.75 to 1.925).
- **Dogbone (Paratroopers)**:
  - Increased number of spawned dog crates from 1 to 2-4 per throw.

## [Unreleased]
