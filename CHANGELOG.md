# Change Log

## [2.0.0] - 2026-03-30: The Tactical Evolution Update


### Major visual effects update (Heavy Infantry)
With permission from the Heavy Infantry mod author, Broken Alliances uses its **grittier, more cinematic combat look**. **What you see in game:**

- **Bullet impacts:** Hits on ground, metal, and cover read more clearly - more dust, sparks, and brief flashes instead of the flatter look before.
- **Muzzle flash:** When firing, there is a stronger flash at the muzzle and visible smoke or dust right at the weapon. **Machine guns and miniguns** look visually heavier and “dirtier” than standard rifles.
- **Explosions and heavy ordnance:** Grenades, mortars, and many explosive charges have more smoke and a clearer shockwave; large guns and very heavy MGs leave thicker dust and smoke clouds on impact.
- **Retuning:** Effects were adjusted to match the new weapons and explosions.
- **Some vehicle MGs back to “normal”:** Certain light vehicle MGs visually fire like standard MG rounds again - no longer with the look of .50 BMG.
- **Blood effect on heavy hits:** When an **MG, LMG, minigun, vehicle MG, tank MG**, or **very large calibre** (e.g. heavy anti-materiel rifles) hits a **soldier**, you see a **red blood spray** (short mist) at the impact. 


### Tracers (visible flight trails)
- **Standard rifles** (anything using the usual rifle round): The trace is **yellow**. It does **not appear on every shot** - roughly **every fourth** shot randomly shows a trace, similar to real ammunition where only some rounds are tracers.
- **Heavy Ammunition like from MGs:** The trace is **red**. 


### Commands:

**HUD**
| Command | Description |
|---|---|
| `/alive hud on` | Alive-HUD ON → FP-HUD automatically OFF |
| `/alive hud off` | Alive-HUD OFF |
| `/fov on` | FoV expansion ON |
| `/fov off` | FoV expansion OFF |

**Faction Point System**
| Command | Description |
|---|---|
| `/fp` | Show all FP commands |
| `/fp_status` | Show FP for all factions |
| `/fp hud on` | FP-HUD ON → Alive-HUD automatically OFF |
| `/fp hud off` | FP-HUD OFF |
| `/fp_add <fid> <n>` | **Admin**: Add FP to a faction (debug) |
| `/fp_set <fid> <n>` | **Admin**: Set FP for a faction (debug) |
| `/fp_ai` | **Admin**: Show AI status |
| `/fp_ai_tick` | **Admin**: Trigger AI tick immediately (debug) |
| `/fp_event event4` | **Admin**: Force Event 4 (no FP check), own faction |
| `/fp_event event5` | **Admin**: Force Event 5 (no FP check), own faction |
| `/event1..5` | **Admin**: Trigger event with FP check |

**AI**
| Command | Description |
|---|---|
| `/ai_attack` | Trigger AI attack |
| `/ai_defend` | Trigger AI defence |
| `/ai_status` | Show AI status |

**Reinforcement System (RS)**
| Command | Description |
|---|---|
| `/rs stats` | Per faction: **A/K/D** (alive / kills / deaths) and **LR** (lost reservists spent to deaths) |
| `/rs hud on` | **Admin**: RS reserve HUD ON → Alive-HUD automatically OFF |
| `/rs hud off` | **Admin**: RS reserve HUD OFF |
| `/rs debug` | **Admin**: Toggle RS debug HUD (A/C R reserves + penalty info) |

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
| 1   | Support Squad      | 250 FP  | Player (squad ≤ 2 men)        | Drops `paratroopers1` call at player position - small squad reinforcement             |
| 2   | Company Attack     | 1200 FP | AI (strategic)                | 2× `paratroopers2` platoon drops flanking the nearest enemy base - large assault wave |
| 3   | Defense Response   | 700 FP  | AI (on base loss, 25% chance) | 3× `paratroopers1` squad drops around the just-lost base - immediate counter-push     |
| 4   | Base Reinforcement | 350 FP  | AI (strategic)                | 1× `paratroopers2` drop at a friendly base (round-robin) - steady line reinforcement  |
| 5   | Vehicle Support    | 500 FP  | AI (strategic)                | Spawns a random medium vehicle (APC, IFV, etc.) at a friendly base                    |
| 6   | Heavy Armour       | 1800 FP | AI (strategic, >3 bases)      | Spawns a random heavy vehicle (tank, etc.) at a friendly base     |
| 7   | Armoured Wave      | 1500 FP | AI (strategic)                | 3× random medium vehicles at friendly bases, 2 s apart |

**AI Decision Logic**

- **Every 60 s:** 5% chance to trigger Event 1 for each faction (if affordable).
- **On base loss:** 25% chance to trigger Event 3 (if affordable).
- **Strategic goal (weighted roll):** AI picks a saving target - Event 2 (weight 0.2), Event 4 (0.6), Event 5 (0.5), or a passive saving phase (0.3, only when holding > 2 bases). Once FP ≥ cost + random reserve (0–450), the event fires and a new goal is rolled.

### Slotblock system 

- The slotblock system had effectively stopped working. Some bugs was found and fixed. The system has new configured, adjusted and feels like what you would await. Consider checking on /hud on.

### Assaults & Last Defenses

- When the leading faction has a 3:1 troop advantage over the other faction, a compensator kicks in. The faction at a 1:3 disadvantage gets a 4× capacity boost and receives correspondingly more soldiers. This acts as a push for that faction. Each faction has exactly one such mobilisation ability.
  On assault maps this is usually applied immediately to the attacking faction, representing a storm assault.

### New deployables

- mg scoped
- minigun scoped
- support mortar (higher range, normal projectiles)

### Weapons

- Weapons are tuned toward realism; retrigger rates and weapon characteristic settings are reality-based. (No guarantee of 100% match - inspiration only.)

**Miscellaneous:**

- AI sight range has been slightly reduced, so getting shot without seeing the enemy is rarer.
- **CAWS:** Scaled more strongly than the shotgun at range (higher `spread_range`, lower `accuracy_factor`, slightly slower `projectile_speed`, `kill_decay` earlier/shorter, stance accuracy like the SPAS-12 in the pack).
- **Weapons:** Where `sight_range_modifier` (_multiplier for effective sight range with the weapon_) is set, `ai_sight_range_modifier` (_AI version of the same factor_) is **90%** of the player value (10% less). At **0** the AI stays at **0**. Weapons referenced only via `file="…"` with no own entry are unchanged (vanilla base). **Fix:** `patch_ai_sight_modifiers.ps1` uses `(?<!ai_)` so it does not match inside `ai_sight_range_modifier`; tank `tank_cannon*` / `tank_mg*` / `radar_tank_cannon` were missing `sight_range_modifier` (loader crash) - fixed.
- **AI `fire_open_min_time` by role:** Line infantry `default_soldiers` / `default.ai` / `map12` **9s** (was 12); elite (Captain, Bodyguard, Miniboss, SF) **8s**; MG `support.ai` **20s** unchanged; EOD **8s**; shotgun **6s** unchanged.
- Cover deploy carry capacity increased
- Wiesel flare price set to 400 RP
- Origin shotgun price raised to 120 RP
- Humvee call (land vehicle) price raised to 350
- VFS flare in armory reduced to 250
- EOD vest is now respawnable
- FAH-01 is now respawnable


**Further**
- Hovercraft flare added
- Legion flare added
- Support Quad flare added

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
