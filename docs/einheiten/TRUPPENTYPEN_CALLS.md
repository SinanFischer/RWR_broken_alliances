# Truppentypen und verfügbare Calls (Broken Alliances)

Übersicht, welche **Calls** (Luft-/Artillerie-/Fahrzeug-Anforderungen) welchem **Truppentyp** zur Verfügung stehen. Basis: `factions/*.resources`.

---

## Tabelle: Truppentyp → Calls

| Truppentyp | Ressourcen-Datei(n) | Verfügbare Calls |
|------------|---------------------|------------------|
| **Default Brown** | `brown_default.resources` | `tank_2.call` |
| **Default Grey** | `grey_default.resources` | `tank_1.call` |
| **Default Green** | `green_default.resources` | `tank.call` |
| **Sniper** (alle Fraktionen) | `common.resources` + `common_sniper_base.resources` | artillery1, heavy_mortar, heavy_artillery, paratroopers1–4, humvee, wiesel_drop, vulcan_tank, apc, mg_drop, mines, **sniper_drop** |
| **Shotgun** (alle Fraktionen) | `common.resources` + `common_shotgun_base.resources` | artillery1, heavy_mortar, heavy_artillery, paratroopers1–4, humvee, wiesel_drop, vulcan_tank, apc, mg_drop, mines |
| **Weitere Common-Kits** (Mortar, MG, EOD, Medic, …) | `common.resources` | artillery1, heavy_mortar, heavy_artillery, paratroopers1–4, humvee, vulcan_tank, apc, mg_drop, mines *(ohne wiesel_drop)* |
| **Special Forces** | `common.resources` + `common_specialforces.resources` | wie Common-Kits *(keine eigenen Calls, nur Waffen/Westen)* |
| **Miniboss** | `common.resources` + `common_miniboss.resources` | wie Common-Kits *(keine eigenen Calls, nur Waffen/Westen)* |
| **Lonewolf Sniper** | `lonewolf_sniper.resources` | mortar1, paratroopers_medic *(ggf. plus Sniper-Calls je nach Vererbung)* |

---

## Tabelle: Call → Truppentypen (wo möglich?)

| Call | Default B/Gr/G | Sniper | Shotgun | Common-Kits | Special Forces | Miniboss | Lonewolf |
|------|:--------------:|:------:|:-------:|:------------:|:---------------:|:--------:|:--------:|
| tank_2 / tank_1 / tank.call | ✓ (je Fraktion) | — | — | — | — | — | — |
| artillery1.call | — | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| heavy_mortar.call | — | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| heavy_artillery.call | — | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| paratroopers1–4.call | — | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| humvee.call | — | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| vulcan_tank.call | — | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| apc.call | — | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| mg_drop.call | — | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| mines.call | — | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| wiesel_drop.call | — | ✓ | ✓ | — | — | — | — |
| sniper_drop.call | — | ✓ | — | — | — | — | (ggf.) |
| mortar1.call | — | — | — | — | — | — | ✓ |
| paratroopers_medic.call | — | — | — | — | — | — | ✓ |

---

## Tabelle: Truppentyp → RP (Spawn) – aus `factions/grey.xml`

**RP (Reinforcement Points):** Start-RP beim Spawn, definiert in der Fraktions-XML (`<attribute_config class="rp">`). Bei mehreren `<attribute>`-Einträgen: Zufallsauswahl pro Gewicht (weight); min–max = Spanne pro Band. Brown/Green: analog in `brown.xml` / `green.xml`.

| Soldatentyp | RP (min–max) | Anmerkung |
|-------------|--------------|-----------|
| **default** | 100–800 | 30 %: 200–800; 70 %: 100–600 |
| **default_ai** | 100–800 | wie default |
| **shotgun** | 100–800 | 30 %: 200–800; 70 %: 100–600 |
| **sniper** | 100–800 | 30 %: 200–800; 70 %: 100–600 |
| **lonewolf** | 100–800 | copy_from sniper |
| **support** | 200–600 | erhöhter RP-Pool |
| **specialforces** | 1600–4000 | |
| **miniboss** | 2000 | fix |
| **medic** | 100–800 | copy_from default |
| **miniboss_female** | 2000–4000 | |
| **prisoner** | 0–300 | 30 %: 80–300; 70 %: 0 |
| **eod** | 1600–2000 | |
| **eod_light** | 200–600 | |
| **mortar_operator** | 150–200 | |
| **cover_troop** | 180–550 | |
| **grenadier** | 400–900 | |
| **supply** | – | kein `attribute_config class="rp"` |
| **captain** | 1000–2000 | |
| **orange_bodyguards** | 500–1000 | |
| **dog** | 0 | kein RP für Calls |

---

## Tabelle: Truppentyp → Call-Slot (Weste, Spawn)

**Call-Slot (capacity):** Wie viele Flares/Calls der Soldat setzen kann (0 oder 1). Kommt aus der **Weste** (`items/*.carry_item`), abhängig vom **Rank** (`source="rank" source_value="X"` → ab Rank X gilt `capacity value="1"`). Ohne Slot kann keine Verstärkung angefordert werden.

| Truppentyp | Weste(n) (Spawn-Pool) | Call-Slot (von–bis) | Ab Rank 1 Slot |
|------------|------------------------|----------------------|----------------|
| **Default** (Brown/Grey/Green) | nur vest_default | 1 (immer) | 0 |
| **Sniper** | vest_default, vest1, camouflage_suit | 0–1 | vest_default: 0; vest1: 0.05; camo: 0.3 |
| **Shotgun** | vest1, vest2 (über common_shotgun_vest) | 0–1 | vest1: 0.05; vest2: 0.2 |
| **Mortar, MG, EOD, Medic, …** | vest1, vest_default (common) | 0–1 | vest_default: 0; vest1: 0.05 |
| **Special Forces** | sf_suit | 0–1 | 1.0 |
| **Miniboss** | vest4, vest_blackops3 | 0–1 | vest_blackops3: 0.3; vest4: 1.64 |
| **Lonewolf Sniper** | wie Sniper | 0–1 | wie Sniper |
| **Captain / Bodyguards** | vest_captain / eodvest_ai (orange) | 1 (Captain); Bodyguards siehe eodvest_ai | – |

**Westen-Referenz (Auszug):** vest_default: 1 ab 0. | vest1: 1 ab 0.05. | vest2: 1 ab 0.2. | vest3: 1 ab 0.64. | vest4: 1 ab 1.64. | vest_blackops3: 1 ab 0.3. | sf_suit: 1 ab 1.0. | camouflage_suit: 1 ab 0.3. *(Quelle: `items/*.carry_item` → `<capacity value="0|1" source="rank" source_value="…" />`.)*

---

## Kurzinfo

- **Default-Truppen** haben bewusst nur **einen** Call (Panzer-Variante pro Fraktion).
- **Common-Kits** (Sniper, Shotgun, Mortar, MG, **Special Forces**, **Miniboss**, …) bekommen die Artillerie-/Para-/Fahrzeug-Calls aus `common.resources`; Sniper/Shotgun erweitern mit `common_sniper_base` / `common_shotgun_base` (u.a. wiesel_drop, Sniper zusätzlich sniper_drop). **Special Forces** und **Miniboss** definieren in `common_specialforces.resources` bzw. `common_miniboss.resources` keine Calls, nur Waffen und Westen → sie haben dieselben Calls wie die übrigen Common-Kits (ohne wiesel_drop).
- **Lonewolf Sniper** definiert in `lonewolf_sniper.resources` nur **mortar1** und **paratroopers_medic**; ob er zusätzlich alle Sniper-Calls erbt, hängt von der Kit-Vererbung im Gamemode ab.
- In `common.resources` sind **tank/tank_1/tank_2** und **artillery2** auskommentiert; Tank-Calls liegen ausschließlich in den `*_default.resources`.

---

*Quelle: `factions/*.resources` (Stand Paket RWR_broken_alliances).*
