# Unit Types – Broken Alliances Mod

Übersicht aller spawnbaren und eingebundenen Einheiten im Mod. **Skin** bezieht sich auf die 3D-Modelldatei(en) – entweder als feste `model filename` oder als Pool über `models file`.

**Fraktionen:** Grey = European Union, Green = United States, Brown = Russian Federation. Boss-Fraktionen (Graycollars, Greenbelts, Brownpants) nutzen teils dieselben Unit-Typen mit angepassten Spawn-Raten.

---

## Spawnbare Infanterie (Quick Match / Invasion)

| Unit Type | Beschreibung | Character | Skin (Filename) |
|-----------|--------------|-----------|-----------------|
| **default** | Spieler-Spawn, Standardinfanterie. Sturmgewehre, Westen, optionale Granaten. Kann Spieler-Squad beitreten. | european_soldier / usa_soldier / russian_soldier | grey_default_basic.models + grey_default.models / green_default_basic.models + green_default.models / brown_default_basic.models + brown_default.models |
| **default_ai** | KI-Infanterie (Spawns). Wie default, geringere Sichtweite. ~78 % der Spawns. | wie default | wie default |
| **shotgun** | Shotgun-Truppe. Nahkampf, ~17 % Spawn. | wie default | wie default |
| **sniper** | Scharfschütze/DMR. Erhöhte Sichtweite, ~5 % Spawn. | wie default | wie default |
| **lonewolf** | Lonewolf-Sniper. Flankiert, zielt wichtige Ziele. ~1 % Spawn. | wie default | wie default (Kopie von sniper) |
| **support** | MG-Schütze. Schwere Waffen, erhöhter RP-Pool. ~27 % Spawn. | wie default | wie default |
| **specialforces** | Special Forces / Black Ops. Elite-AI, SF-Suit nötig. ~2 % Spawn. | default.character | Grey: gerops.xml / Green: soldier_blackops.xml / Brown: rusops.xml |
| **miniboss** | Elite-Soldat (Miniboss). Hoher XP/RP, starke Bewaffnung. ~5,4 % Spawn. | default.character | Grey: ger_office.xml / Green: us_officer.xml / Brown: rus_officer.xml |
| **miniboss_female** | Elite-Soldatin. Wie miniboss, weiblich. Selten (~0,2 % Grey, ~0,15 % Green). | default.character / default_female.character (Green) | Grey: soldier_elite_b2.xml / Green: soldier_elite_a2.xml |
| **medic** | Sanitäter. Medikit, heilt Verwundete. ~7 % Spawn. | wie default (copy_from) | wie default |
| **prisoner** | Gefangener. Kein Spawn (nur Map), geringe Ausrüstung. | default.character | soldier_prison.xml |
| **eod** | EOD / Stürmer. Schweres AT, EOD-Weste. ~2 % Spawn, kein Squad-Cap. | default.character | Grey: soldier_b1eod.xml / Green: soldier_a1eod.xml / Brown: soldier_c1eod.xml |
| **eod_light** | Leichter EOD. AT-lastig (Javelin etc.), keine Stürmer. ~4,8 % Spawn. | wie default | grey_eod_light.models (soldier_riotgear.xml) / green_eod_light.models / brown_eod_light.models |
| **mortar_operator** | Mörser-Bediener. Mörser-Deploy im Slot 1. ~1,2 % Spawn. | wie default | grey_mortar_operator.models / green_mortar_operator.models / brown_mortar_operator.models |
| **cover_troop** | Deckungstruppe (Pionier). Sandsack oder Schild, gibt Deckung. ~6 % Spawn. | wie default | grey_cover_troop.models / green_cover_troop.models / brown_cover_troop.models |
| **grenadier** | Grenadier. Milkor MGL, Explosiv-Granaten. ~4 % Spawn. | wie default | grey_default_basic.models + grey_default.models (analog Green/Brown) |
| **captain** | Captain / Kommandant. VIP, orange Weste, Cargo-Truck-Event. Kein Spawn, nur Events. | captain.character | soldier_orange_bodyguards.xml |
| **orange_bodyguards** | Bodyguards des Captains. Begleiten Captain, starke Bewaffnung. | default_miniboss_male.character | soldier_captain.xml |
| **dog** | Kampfhund. Biss-Angriff, Heil-Fähigkeit. ~4 % Spawn. | dog.character | dog_1.xml – dog_5.xml (zufällig) |
| **supply** | Supply-Box. Kein Soldat, nur Ressourcen-Pool für Lieferungen. | – | – |

---

## Boss-Fraktionen (Invasion)

| Unit Type | Beschreibung | Character | Skin (Filename) |
|-----------|--------------|-----------|-----------------|
| **default** | Standardinfanterie (Boss-Fraktion). | default.character | grey_default / green_default / brown_default |
| **default_ai** | KI-Infanterie. | default.character | wie default |
| **miniboss** | Elite. | default.character | Grey: soldier_elite_b1.xml / Green: us_officer.xml / Brown: soldier_elite_c1.xml + soldier_elite_c2.xml |
| **miniboss_female** | Elite weiblich. Nur Grey, Green (Brown-Boss hat keine). | default.character / default_female.character | soldier_elite_b2.xml |
| **medic** | Sanitäter. | default.character | wie default |
| **captain** | Captain. | captain.character | soldier_orange_bodyguards.xml |
| **orange_bodyguards** | Bodyguards. | default_miniboss_male.character | soldier_captain.xml |

---

## Character-Dateien (Stimme / Identität)

| Character | Verwendung |
|-----------|------------|
| european_soldier.character | Grey (EU) – deutsche Stimmen |
| usa_soldier.character | Green (USA) – englische Stimmen |
| russian_soldier.character | Brown (Russland) – russische Stimmen |
| default.character | Basis-Stimmen, Special Forces, EOD, Prisoner, Miniboss, Boss-Fraktionen |
| default_female.character | Weibliche Variante (miniboss_female Green) |
| default_miniboss_male.character | Bodyguards |
| captain.character | Captain |
| dog.character | Hund |

---

## Skin-Modelle pro Fraktion (Hauptvarianten)

| Fraktion | Default-Basis | Default-Pool | Special Forces | EOD | Miniboss |
|----------|---------------|--------------|----------------|-----|----------|
| Grey | ger_army_1.xml, ger_army_1_1.xml, ger_army_1_2.xml | ger_army_1_3.xml, soldier_b1_camouflage_suit.xml, soldier_b1eod.xml, gerops.xml, costume_* | gerops.xml | soldier_b1eod.xml | ger_office.xml |
| Green | soldier_a1.xml, soldier_a2.xml, soldier_a3.xml | soldier_a1_vest.xml, soldier_camouflage_suit.xml, soldier_a1eod.xml, soldier_blackops.xml | soldier_blackops.xml | soldier_a1eod.xml | us_officer.xml |
| Brown | soldier_c1.xml, soldier_c2.xml, soldier_c3.xml | soldier_c1_vest.xml, soldier_c1_camouflage_suit.xml, soldier_c1eod.xml, rusops.xml | rusops.xml | soldier_c1eod.xml | rus_officer.xml |

---

## Sniper / Lonewolf – Waffen (Resources)

**Wo die Waffen festgelegt werden:** In den **factions**-Resource-Dateien. Sniper und Lonewolf nutzen einen **eigenen** Waffen-Pool (kein `common.resources`).

| Datei | Inhalt | Verwendung |
|-------|--------|------------|
| `common_sniper_weapons.resources` | Primärwaffen: vss_vintorez, barrett_m107, lahti_l39, apr, scarssr | Sniper + Lonewolf |
| `common_sniper_secondary.resources` | Zweitwaffen (SMG/PDW): mp5sd, mini_uzi, p90, aks74u, mp7, kriss_vector, scorpion-evo, steyr_tmp, qcw-05 | Sniper + Lonewolf |
| `grey_sniper.resources` / `green_sniper.resources` / `brown_sniper.resources` | Fraktions-Primaries: Grey psg90, g28; Green m24_a2, m14_ebr; Brown dragunov_svd, sv98 | nur Sniper (Lonewolf erbt sie) |
| `lonewolf_sniper.resources` | Zusatz für Lonewolf: gepard_m6_lynx, Calls (mortar1, paratroopers_medic). **Ohne** clear_weapons → voller Sniper-Pool bleibt aktiv. | nur Lonewolf |

**Aktivierung:** In diesen Sniper-Ressourcen gibt es **keine** `enabled="0"`-Einträge – alle genannten Waffen sind im Mod aktiv. Die in `common.resources` deaktivierten Waffen (z. B. mk23, desert_eagle, xm25) gelten nur für andere Unit-Typen (default, etc.), nicht für Sniper/Lonewolf.

*Quelle: factions/grey.xml, green.xml, brown.xml; factions/common_sniper_*.resources, *_sniper.resources, lonewolf_sniper.resources*
