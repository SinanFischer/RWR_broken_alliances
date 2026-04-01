# Change Log

## [2.0.0] - 2026-03-30: The Tactical Evolution Update


[b] VISUAL EFFECT UPDATE (Heavy Infantry Mod)  [/b]
Thanks to the Heavy Infantry Mod i was able to add these effects and modify some to Broken Alliances:
- Bullet Impact Effects 
- Bigger Muzzle Flashes for MG, Tanks, Rifles..
- Explosives have massive smoke and explosions, from small to heavy...
- Blood Spray effect on heavy hits (like mgs or heavy caliber)
- Tracers, yellow from rifles, red from mg's and heavier
- some more stuff. Just check out the Heavy Infantry Mod. He did the awesome work ;-)

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



[b] NEW REINFORCEMENT SYSTEM [/b]
The Slotblock system has been replaced by the this system. 
...

[b] THE NEW FACTION POINT SYSTEM [/b]
Now every faction gains Faction Points (FP) which will be used from the AI to request support. 
How it is gained: 
 - base capture (+120 FP), 
 - base hold every 20 s (+5 FP per owned base), 
 - kills (2nd +2 FP, 3nd +3 FP, 4nd +5 FP)
  
Events:
1. Support Squad, Cost: 250 FP, Trigger: (Player squad ≤ 2 men), Effect: Drops paratroopers1 call at player position (small squad reinforcement)
2. Company Attack, Cost: 1200 FP, Trigger: (AI strategic), Effect: Drops 2× paratroopers2 platoons flanking nearest enemy base (large assault wave)
3. Defense Response, Cost: 700 FP, Trigger: (AI on base loss, 25% chance), Effect: Drops 3× paratroopers1 squads around the just-lost base (counter-push)
4. Base Reinforcement, Cost: 350 FP, Trigger: (AI strategic), Effect: Drops 1× paratroopers2 at friendly base (round-robin reinforcement)
5. Vehicle Support, Cost: 500 FP, Trigger: (AI strategic), Effect: Spawns random medium vehicle at friendly base
6. Heavy Armour, Cost: 1800 FP, Trigger: (AI strategic, >3 bases), Effect: Spawns random heavy vehicle at friendly base
7. Armoured Wave, Cost: 1500 FP, Trigger: (AI strategic), Effect: Spawns 3× random medium vehicles at friendly bases (2s apart)


[b] ASSAULT BOOST [/b] 
With the new logic, it's much harder to get a stand in assault maps.
So, from now on, there will be a 5-minute boost to give the assault troops (starting with 1 base) a chance.


[b] NEW DEPLOYABLES [/b] 
- mg scoped
- minigun scoped
- support mortar (higher range, normal projectiles)


[b] WEAPONS [/b] 
Weapons are tuned toward realism; retrigger rates and weapon characteristic settings are reality-based. (No guarantee of 100% match - inspiration only.)

Kill probabilities of a bullet are now:
~ SMG / PDW        0.65–1.0
~ 5.56mm           0.85–0.95
~ 5.45mm           0.90–1.0
~ 7.62×39mm        1.0–1.1
~ DMR              1.1–1.2
~ LMG 5.56mm       1.3–1.4
~ MG 7.62mm        1.4–1.5
~ Sniper 7.62mm    1.8
~ Sniper 12.7mm    3.0
~ 12.7mm Blast     damage 1.0 (splash damage)


[b] MISCELLANEOUS [/b] 
- AI sight range has been slightly reduced, so getting shot without seeing the enemy is rarer.
- AI was reworked to the new conditions (reaction, firetime, fire in open...)
- Cover deploy carry capacity increased
- Wiesel flare price set to 400 RP
- Origin shotgun price raised to 120 RP
- Humvee call (land vehicle) price raised to 350
- VFS flare in armory reduced to 250
- EOD vest is now respawnable
- FAH-01 is now respawnable
- The cluster grenade now actually clusters....


[b] FLARES [/b] 
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
