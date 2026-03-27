# Option 1: Exponentielles HP- & Schadens-Scaling _(Empfohlen)_

Die robusteste Taktik ist, die Lebenspunkte (HP) der Fahrzeuge extrem nach oben zu skalieren, um die Diskrepanz zwischen Infanterie und schwerer Panzerung realistisch darzustellen. 1 Schaden heißt so viel wie das sie eine Westenwert durchdring. Da High explosive oder .50  cal jeden soldat mit egal welcher weste tötet brauchen wir hier ein besseres System:

---

## Übersicht nach Tiers

### Tier 0: Infanterie & Westen

- **HP:**  
  - 1 HP (Basis)  
  - +1–3 HP durch Westen  
  - **Maximal:** 4 HP

- **HE-Wirkung:**  
  - Tödlich ab **5 Schaden**  
  - Overkill garantiert

- **AT-Wirkung:**  
  - Jedes AT-Projektil = sofortiger *Instakill*

- **Artillerie-Calls:**  
  - `artillery_shell` (2.3 Dmg):  
    - Direkter Treffer: tötet fast sicher  
    - Splitter: schwere Verletzungen  
  - Höhere Calls: löschen Infanterie im Radius komplett aus




---

## Tier 1: **Soft** (`ARMOR_SOFT`) – *Die Blechdose*
- **Ziel-HP:** 30–60
- **40mm HE / Granaten:** Absolut tödlich. 1–3 Treffer führen zur sofortigen Zerstörung, technische Defekte oder Brand.
- **Leichte AT (RPG/LAW):** Totaler Overkill. Ein Treffer löscht das Fahrzeug und die Insassen komplett aus – meist bleibt nur eine Rauchwolke.
- **Mittlere & Schwere AT:** Völlig übertrieben – Munition verschwendet, da das Fahrzeug sogar von MG-Feuer zerstört werden könnte.
- **Artillerie / Mörser:** Ein Naheinschlag reicht meist; Direkttreffer pulverisieren das Ziel. Ein einzelner Artillerie-Call (`artillery_shell`) zerstört das Fahrzeug sofort oder setzt es in Brand.
- **Handgranaten:** Gefährlich. 2–4 Stück am Unterboden genügen, um den Truck zu zerlegen. 
---

## Tier 2: **Light** (`ARMOR_LIGHT`) – *Patrouillenschutz*
- **Ziel-HP:** 120–200
- **HE (40mm):** 4–8 Treffer. Genug Schutz, um unter Feuer kurz zu manövrieren.
- **AT Leicht (RPG/LAW):** 1 Treffer reicht meistens aus (One-Shot-Potential).
- **Artillerie-Calls:**
  - `artillery_shell`: 2–4 Naheinschläge nötig.
  - `heavy_mortar`: 1 Direkttreffer = Schrott.
- **Handgranaten:** 5+ Stück (mühsam, aber machbar).

---

## Tier 3: **Medium** (`ARMOR_MEDIUM`) – *Das Schlachtschiff der Infanterie*
- **Ziel-HP:** 600–900
- **HE (40mm):** Vernachlässigbar (15–30 Treffer). Nur zum „Stunnen“ der Besatzung.
- **AT Leicht (RPG/LAW):** Gefährlich in Gruppen. 2–3 Treffer für den Kill.
- **AT Mittel (SMAW/CarlG):** Sehr effektiv. 1–2 Treffer.
- **AT Schwer (Javelin/TOW):** Instakill. Ein Treffer einer Javelin (1.200+ Dmg) pulverisiert jeden APC.
- **Artillerie-Calls:**
  - `heavy_mortar`: Zieht ca. 50 % HP ab.
  - `heavy_artillery`: 1 Hit-Kill.
- **Sprengsatz:** 1× C4 oder 2-3× AT-Granate.

---

## Tier 4: **Heavy** (`ARMOR_HEAVY`) – *Der Panzer-Jäger*
- **Ziel-HP:** 1.500–2.200
- **HE (40mm):** Immun.
- **AT Leicht (RPG/LAW):** „Mückenstiche“. 5–8 Treffer nötig. Infanterie ohne schwere AT sollte fliehen.
- **AT Mittel (SMAW/CarlG):** Die Standard-Antwort. 3–4 Treffer.
- **AT Schwer (Javelin/TOW):** Primärgefahr. 2 Treffer für den Kill.
- **Artillerie-Calls:**
  - `heavy_artillery`: Verursacht schweren Schaden (50–70 %).
  - `tactical_strike` (`bomb1`): Instakill.
- **Sprengsatz:** 2× C4 oder 3–4× AT-Granate.


---

## Tier 5: **Battle** (`ARMOR_BATTLE`) – *Die Stahlfaust (MBT)*

- **Ziel-HP:** 4.500–5.500
- **AT Leicht (RPG/LAW):** Nur zum Finishen. 12–15 Treffer.
- **AT Mittel (SMAW/CarlG):** Mühsam. 6–8 Treffer.
- **AT Schwer (Javelin/TOW):** Das Duell-Werkzeug. 3–4 Treffer.
- **AT Top (Javelin Elite):** Die ultimative Gefahr. 2 Treffer.
- **Artillerie-Calls:**
  - `heavy_artillery`: Zieht ca. 20 % HP. Ein MBT kann einen Call „aussitzen“, wenn er sich bewegt.
  - `tactical_strike` (`bomb1`): Abhängig der anderen .
  - `railway_artillery`: Instakill.
- **Sprengsatz:** 2–3× C4 direkt am Heck.


---

## Tier 6: **Superheavy** (`ARMOR_SUPERHEAVY`) – *Der Endboss (Legion)*
- **Ziel-HP:** 9.000 – 11.000
- **AT Leicht:** Nutzlos (25+ Treffer).
- **AT Mittel:** Vernachlässigbar (15+ Treffer).
- **AT Schwer (Javelin/TOW):** Braucht konzentriertes Feuer von 3–4 Soldaten. 6–8 Treffer.
- **AT Top (Javelin Elite):** Die einzige tragbare Gefahr. 3–4 Treffer.
- **Artillerie-Calls:**
  - `heavy_artillery`: Kratzt nur an der Oberfläche (ca. 10 % Schaden).
  - `tactical_strike`: SPÜRBAR ABHÄNGIG DER ANDEREN.
  - `railway_artillery`: Der einzige Instakill für die Legion.
- **Sprengsatz:** 5+ Ladungen C4. Ohne Deckung der Infanterie ist die Legion kaum zu knacken.

**Schlachtfeld-Rolle:**  
Die Legion ist das beste und schwerst gepanzerte Fahrzeug im Spiel. Seine Schüsse sind verherrend. 
---



| Waffentyp                     | Empfohlener Blast Damage     |
|-------------------------------|------------------------------|
| HE (40mm / Autokanone)        | 10 – 15                      |
| AT Leicht (RPG-7 / LAW)       | 400 – 500                    |
| AT Mittel (SMAW / CG)         | 800 – 1.000                  |
| AT Schwer (Javelin / TOW)     | 1.800 – 2.200                |
| AT Top (Elite Javelin)        | 3.500 – 4.500                |
| Tactical Strike (`bomb1`)     | 5.000                        |

