# Waffenwert-Formeln v2 – Parametrisches Preis-Modell

Jeder Parameter pro Waffentyp hat einen Basisbereich (min/max aus dem Waffenpool), eine Richtung (höher = besser / niedriger = besser) und eine nicht-lineare Skalierung. Der Preis ergibt sich aus der Summe aller gewichteten Parameter-Scores.

---

## Preissegmente (Gesamtbild)

| Segment | RP-Bereich | Ziel-Waffentypen |
|---------|------------|------------------|
| **Billig** | 0–20 | Pistolen, MPs, Basis-Rifles |
| **Mittel** | 20–50 | DMRs, bessere Rifles, leichte MGs |
| **Gut** | 50–100 | Snipers, schwere MGs |
| **Teuer** | 100–250 | Top-Snipers, Spezial-MGs |
| **Sehr teuer** | 250+ | Barrett, M200, Lahti – extreme Spezialwaffen |

**Rifle-Einschränkung:** `sight_range_modifier` für Rifles auf **1.0–1.2** begrenzt (statt 1.65). Verhindert, dass Rifles ohne klare Schwäche zu stark werden.

---

## Preisskala pro Waffentyp (Basis, Anker, Zielbereich)

Alle Preise: `Preis = Basis × (Waffenwert / Waffenwert_Anker)^α`

| Waffentyp | Anker | Basis | α | Zielbereich (RP) | Segment |
|-----------|-------|-------|---|------------------|---------|
| **Pistole** | Glock 17 | 3 | 0.55 | 2–29 | Billig |
| **MP** | MP7 | 19 | 0.58 | 10–32 | Billig |
| **Rifle** | G36 | 14 | 0.60 | 10–29 | Billig |
| **DMR** | M14 EBR | 45 | 0.62 | 29–88 | Mittel |
| **MG** | MG4 | 50 | 0.60 | 35–160 | Mittel–Gut |
| **Sniper** | PSG90 | 80 | 0.65 | 72–448 | Gut–Sehr teuer |
| **Shotgun** | Mossberg 500 | 14 | 0.58 | 10–352 | Billig–Sehr teuer |

*\* GL-Varianten (Rifle): +25 % Aufschlag. Suppressed/Burst: +100 % Aufschlag (z.B. Honey Badger).*

**Rifle sight_range_modifier:** Max 1.2. Norm = `(wert - 1.0) / 0.2` (Range 1.0–1.2).

---

## Konzept

```
Für jeden Parameter p:
  norm_p = Normalisierung im Bereich [0, 1] (0 = schlechteste, 1 = beste Waffe im Pool)
  score_p = f_p(norm_p)   // Skalierungsfunktion (z.B. x^0.7 für abnehmenden Grenznutzen)
  
Waffenwert = Σ (gewicht_p × score_p)
Preis = Basis_Anker × (Waffenwert / Waffenwert_Anker)^α
```

- **Anker-Waffe**: Referenz mit bekanntem Preis; alle anderen relativ dazu.
- **α** (Dämpfung): 0.5–0.65, verhindert extreme Preissprünge.

---

## MG (Maschinengewehr)

### MG4 vs MG42 – Dominanz-Vergleich

| Parameter | MG4 | MG42 | Gewinner |
|-----------|-----|------|----------|
| retrigger_time (RPM) | 0.0674 (~890) | 0.05 (1200) | **MG42** (+35 % Feuerrate) |
| magazine_size | 100 | 250 | **MG42** (2.5×) |
| accuracy_factor | 0.84 | 0.72 | MG4 |
| projectile_speed | 143 | 170 | **MG42** |
| kill_probability | 1.35 | 1.45 | **MG42** |
| sustained_fire_grow_step | 0.50 | 0.25 | **MG42** (weniger Streuung) |
| sustained_fire_diminish_rate | 0.85 | 0.65 | MG4 |
| can_shoot_crouching | 0 | 1 | **MG42** |

**Fazit: MG42 dominiert.** Nur Vorteile MG4: bessere Genauigkeit, schnellerer Rückstoß-Rückgang. MG42: deutlich höhere Feuerrate, 2.5× Magazin, höhere Projektilgeschwindigkeit, höherer Schaden pro Treffer, bessere Streukontrolle, kann kniend schießen. → MG42 muss deutlich teurer sein.

---

### Preisformel

```
Preis = 50 × (Waffenwert / Waffenwert_MG4)^0.6  +  Sonderzuschläge
```

**Anker:** MG4, Basis 50, α = 0.6. Zielbereich: 35–160 RP (+ Sonderzuschläge).

**Sonderregeln (Zuschläge auf Formelpreis, *exclusiv* – nur einer gilt):**

| Bedingung | Zuschlag |
|-----------|----------|
| `can_shoot_standing="1"` | **+50 RP** |
| `can_shoot_standing="0"` UND `can_shoot_crouching="1"` | **+30 RP** |

*\* Stehend überwiegt: Wer stehend schießen kann, bekommt +50 (nicht +50+30). Nur kniend (ohne stehend) → +30.*

---

### Parameter-Range (aus Waffenpool, Stand nach Real-Anpassung)

| Parameter | Min | Max | Richtung | Gewicht |
|-----------|-----|-----|----------|---------|
| retrigger_time | 0.05 | 0.12 | **niedriger = besser** (RPM) | **0.40** |
| magazine_size | 30 | 250 | **höher = besser** | **0.28** |
| accuracy_factor | 0.72 | 0.92 | **höher = besser** | 0.08 |
| projectile_speed | 120 | 170 | **höher = besser** | 0.06 |
| kill_probability | 1.35 | 1.45 | **höher = besser** | 0.06 |
| sight_range_modifier | 1.0 | 1.2 | **höher = besser** | 0.04 |
| sustained_fire_grow_step | -0.2 | 0.7 | **niedriger = besser** | 0.04 |
| sustained_fire_diminish_rate | -1.35 | 0.86 | **höher = besser** (negativ = Constant Recoil) | 0.04 |

*\* retrigger_time + magazine_size: Beide dominieren den Waffenwert stark (0.40 + 0.28).*  
*\* sustained_fire: Negative Werte (Ultimax) = Constant Recoil = Sonderbonus; norm = 1.0 (beste).*

### Normalisierung

| Parameter | Formel (norm ∈ [0,1]) |
|-----------|------------------------|
| retrigger_time | `(max - wert) / (max - min)` |
| magazine_size | `(wert - min) / (max - min)` |
| accuracy_factor | `(wert - min) / (max - min)` |
| projectile_speed | `(wert - min) / (max - min)` |
| kill_probability | `(wert - 1.35) / 0.1` (1.35 = Min, 1.45 = Max) |
| sight_range_modifier | `(wert - 1.0) / 0.2` (1.0 = Default wenn fehlend) |
| sustained_fire_grow_step | `(max - wert) / (max - min)`; negativ → 1.0 |
| sustained_fire_diminish_rate | `(wert - min) / (max - min)`; wert &lt; 0 → 1.0 |

### Skalierungsfunktionen (score = f(norm))

| Parameter | f(norm) | Begründung |
|-----------|---------|------------|
| retrigger_time | **`norm^0.5`** | Starker Preisanstieg bei schneller Feuerrate (0.05→0.0674 = großer Sprung) |
| magazine_size | `norm^0.6` | 100→200 großer Sprung; mag 250 (MG42) vs 60 (RPK74m) = deutlicher Preisunterschied |
| accuracy_factor | `norm^0.8` | Leicht sublinear |
| projectile_speed | `norm^0.5` | Geringer Einfluss |
| kill_probability | `norm^0.7` | 7.62 vs 5.56 Kaliber-Unterschied |
| sight_range_modifier | `norm^0.6` | |
| sustained_fire_grow_step | `norm^0.7` | |
| sustained_fire_diminish_rate | `norm^0.6` | |

### Beispielrechnung MG4

```
retrigger: 0.0674 → norm = 0.75 → score = 0.75^0.5 = 0.87
mag: 100 → norm = 0.32 → score = 0.32^0.6 = 0.52
accuracy: 0.84 → norm = 0.6 → score = 0.6^0.8 = 0.66
proj_speed: 143 → norm = 0.21 → score = 0.21^0.5 = 0.46
kill: 1.35 → norm = 0 → score = 0
sight: 1.2 → norm = 1.0 → score = 1.0
grow: 0.5 → norm = 0.22 → score = 0.22^0.7 = 0.38
diminish: 0.85 → norm = 0.79 → score = 0.79^0.6 = 0.87

Waffenwert = 0.40×0.87 + 0.28×0.52 + 0.08×0.66 + 0.06×0.46 + 0.06×0 + 0.04×1.0 + 0.04×0.38 + 0.04×0.87
          = 0.35 + 0.15 + 0.05 + 0.03 + 0 + 0.04 + 0.02 + 0.03 = 0.67

Sonderzuschläge: standing 0, crouching 0 → +0 RP
Preis = 50 × (0.67/0.67)^0.6 = 50
```

### Beispielrechnung MG42

```
retrigger: 0.05 → norm = 1.0 → score = 1.0   ← starker Bonus (Gewicht 0.45)
mag: 250 → norm = 1.0 → score = 1.0
accuracy: 0.72 → norm = 0 → score = 0
proj_speed: 170 → norm = 1.0 → score = 1.0
kill: 1.45 → norm = 1.0 → score = 1.0
sight: 1.2 → norm = 1.0 → score = 1.0
grow: 0.25 → norm = 0.64 → score = 0.75
diminish: 0.65 → norm = 0.91 → score = 0.94

Waffenwert = 0.40×1.0 + 0.28×1.0 + 0.08×0 + 0.06×1.0 + 0.06×1.0 + 0.04×1.0 + 0.04×0.75 + 0.04×0.94
          = 0.40 + 0.28 + 0 + 0.06 + 0.06 + 0.04 + 0.03 + 0.04 = 0.91

Sonderzuschläge: standing 0, crouching 1 → +30 RP
Preis = 50 × (0.91/0.67)^0.6 + 30 ≈ 58 + 30 = 88 RP
```

### MG-Preiskalkulation

**Formel:** `Preis = 50 × (Waffenwert / Waffenwert_MG4)^0.6 + Sonderzuschläge`

**Sonderzuschläge (exclusiv):** Stehend +50 RP; nur kniend (nicht stehend) +30 RP.

**Sonderfälle:** `sustained_fire_grow_step` oder `sustained_fire_diminish_rate` negativ (z.B. Ultimax Constant Recoil) → norm = 1.0 (beste).

### MG-Übersicht (berechnete Waffenwerte → Preise, Basis 50, retrigger 0.40, mag 0.28)

| MG | Waffenwert | Formel | Zuschlag | Preis (formel) | Preis (aktuell) |
|----|------------|--------|----------|----------------|-----------------|
| MG4 | (Anker) 0.67 | 50 | – | 50 | 27 |
| M249 | 0.74 | 53 | – | 53 | 28 |
| M240 | 0.70 | 51 | – | 51 | 22 |
| PKM | 0.68 | 50 | – | 50 | 18 |
| **MG42** | **0.91** | **58** | **+30** (nur kniend) | **88** | 570 |
| Stoner LMG | 0.80 | 55 | **+50** (stehend) | **105** | 245 |
| Ultimax | 0.52 (Constant Recoil) | 44 | – | 44 | 135 |
| Negev | 0.75 | 54 | – | 54 | 20 |
| RPK74m | 0.56 | 46 | – | 46 | 24 |
| RPK16 | 0.64 | 49 | **+50** (stehend) | **99** | 64 |
| RPK16 long | 0.68 | 50 | **+50** (stehend) | **100** | 78 |
| Pecheneg | 0.69 | 51 | – | 51 | 500 |
| MG-08 Heavy | 0.50 | 45 | – | 45 | 60 |

*\* retrigger + mag dominieren: MG42 (mag 250, schnell) vs Ultimax (mag 100, langsam).*  
*\* Stoner LMG: can_shoot_standing=1 → +50 RP.*

---

## RIFLE (Sturmgewehr)

### Parameter-Range (aus Waffenpool)

| Parameter | Min | Max | Richtung | Gewicht |
|-----------|-----|-----|----------|---------|
| retrigger_time | 0.0333 | 0.1 | **niedriger = besser** | 0.22 |
| magazine_size | 25 | 48 | **höher = besser** | 0.12 |
| accuracy_factor | 0.70 | 1.0 | **höher = besser** | 0.20 |
| kill_probability | 0.85 | 1.1 | **höher = besser** | 0.18 |
| projectile_speed | 148 | 170 | **höher = besser** | 0.06 |
| sight_range_modifier | 1.0 | **1.2** (Cap) | **höher = besser** | 0.08 |
| sustained_fire_grow_step | 0.15 | 0.54 | **niedriger = besser** | 0.06 |
| sustained_fire_diminish_rate | 0.60 | 2.0 | **höher = besser** | 0.08 |

*\* sight_range_modifier: 1.0 wenn fehlend. Max 1.2 für Rifles (Balancing: keine starke Optik ohne Schwäche).*

### Normalisierung

| Parameter | Formel |
|-----------|--------|
| retrigger_time | `(max - wert) / (max - min)` |
| magazine_size | `(wert - min) / (max - min)` |
| accuracy_factor | `(wert - min) / (max - min)` |
| kill_probability | `(wert - min) / (max - min)` |
| projectile_speed | `(wert - min) / (max - min)` |
| sight_range_modifier | `(min(wert, 1.2) - 1.0) / 0.2` (1.0 = Default, Max 1.2) |
| sustained_fire_grow_step | `(max - wert) / (max - min)` |
| sustained_fire_diminish_rate | `(wert - min) / (max - min)` |

### Skalierungsfunktionen

| Parameter | f(norm) |
|-----------|---------|
| retrigger_time | `norm^0.65` |
| magazine_size | `norm^0.7` |
| accuracy_factor | `norm^0.75` |
| kill_probability | `norm^0.8` |
| projectile_speed | `norm^0.5` |
| sight_range_modifier | `norm^0.7` |
| sustained_fire_grow_step | `norm^0.6` |
| sustained_fire_diminish_rate | `norm^0.6` |

### Anker

- **G36**: Preis 14, Standard-Rifle.
- **Basis_Rifle** = 14, α = 0.6.

---

### Rifle-Preiskalkulation (Schritt für Schritt)

**Formel-Pipeline:**

```
1. norm_p = Normalisierung (Rohwert → [0,1])
2. score_p = norm_p^exponent_p
3. Beitrag_p = Gewicht_p × score_p
4. Waffenwert = Σ Beitrag_p
5. Preis = 14 × (Waffenwert / Waffenwert_G36)^0.6
```

**Parameter → norm → score → Beitrag (Beispiel G36):**

| Parameter | Rohwert | norm | score (norm^exp) | Gewicht | Beitrag |
|-----------|---------|------|-------------------|---------|---------|
| retrigger_time | 0.08 | (0.1−0.08)/0.0667 = 0.30 | 0.30^0.65 = 0.43 | 0.22 | 0.09 |
| magazine_size | 30 | (30−25)/23 = 0.22 | 0.22^0.7 = 0.33 | 0.12 | 0.04 |
| accuracy_factor | 0.74 | (0.74−0.70)/0.30 = 0.13 | 0.13^0.75 = 0.22 | 0.20 | 0.04 |
| kill_probability | 0.9 | (0.9−0.85)/0.25 = 0.20 | 0.20^0.8 = 0.28 | 0.18 | 0.05 |
| projectile_speed | 160 | (160−148)/22 = 0.55 | 0.55^0.5 = 0.74 | 0.06 | 0.04 |
| sight_range_modifier | 1.1 | (1.1−1.0)/0.2 = 0.50 | 0.50^0.7 = 0.62 | 0.08 | 0.05 |
| sustained_fire_grow_step | 0.38 | (0.54−0.38)/0.39 = 0.41 | 0.41^0.6 = 0.57 | 0.06 | 0.03 |
| sustained_fire_diminish_rate | 1.15 | (1.15−0.60)/1.4 = 0.39 | 0.39^0.6 = 0.54 | 0.08 | 0.04 |
| **Summe** | | | **Waffenwert** | | **0.38** |

**Preis:** `14 × (0.38 / 0.38)^0.6 = 14` (G36 = Anker)

**Beispiel AK47** (Waffenwert ≈ 0.39): `14 × (0.39/0.38)^0.6 ≈ 14`  
**Beispiel Honey Badger** (Waffenwert ≈ 0.45, +100 % suppressed): `14 × (0.45/0.38)^0.6 × 2.0 ≈ 34`

---

### Skalierungs-Vergleich am G36 (Test)

**G36-Rohdaten:** retrigger 0.08 · mag 30 · accuracy 0.74 · kill 0.9 · proj_speed 160 · sight 1.1 · grow 0.38 · diminish 1.15

**Normalisierte Werte (norm ∈ [0,1]):**

| Parameter | norm | Gewicht |
|-----------|------|---------|
| retrigger_time | 0.30 | 0.22 |
| magazine_size | 0.22 | 0.12 |
| accuracy_factor | 0.13 | 0.20 |
| kill_probability | 0.20 | 0.18 |
| projectile_speed | 0.55 | 0.06 |
| sight_range_modifier | 0.15 | 0.10 |
| sustained_fire_grow_step | 0.41 | 0.06 |
| sustained_fire_diminish_rate | 0.39 | 0.06 |

**Vier Skalierungsfunktionen (einheitlich auf alle Parameter):**

| Variante | f(norm) | Waffenwert G36 | Endgültiger Preis |
|----------|---------|----------------|--------------------|
| **Wurzel** | `√norm` | 0.49 | 14 |
| **Logarithmisch** | `ln(1+9·norm)/ln(10)` | 0.49 | 14 |
| **Potenz a>1** | `norm^1.5` | 0.14 | 14 |
| **Potenz a<1** | `norm^0.7` | 0.40 | 14 |

*\* G36 = Anker → Preis immer 14. Der Waffenwert variiert je nach Skalierung; für relative Preise anderer Rifles ist die Wahl entscheidend.*

**Interpretation:**

- **Wurzel / Log**: Sanfte Skalierung – schwache Parameter werden weniger bestraft, mittlere Waffenwerte (0.4–0.5). Gute Waffen (norm≈1) steigen moderat im Preis.
- **Potenz a>1**: Strenge Skalierung – schlechte Parameter werden stark abgewertet. G36 (viele mittlere norms) → sehr niedriger Waffenwert (0.14). Bessere Waffen würden extrem teuer.
- **Potenz a<1**: Mittlere Skalierung – ähnlich wie v2-Standard. G36 ≈ 0.40. Guter Kompromiss für differenzierte Preise.

**Empfehlung:** Für Rifle weiterhin **Potenz a&lt;1** (0.65–0.8) pro Parameter, wie in der Tabelle oben. Wurzel/Log eignen sich, wenn die Preisspanne kleiner sein soll.

---

### Drei-Waffen-Vergleich: G36 · AK47 · Honey Badger

**Rohdaten:**

| Waffe | retrigger | mag | accuracy | kill | proj_speed | sight | grow | diminish |
|-------|-----------|-----|----------|------|------------|-------|------|----------|
| G36 | 0.08 | 30 | 0.74 | 0.9 | 160 | 1.1 | 0.38 | 1.15 |
| AK47 | 0.10 | 30 | 0.72 | 1.1 | 155 | 1.0 | 0.40 | 1.12 |
| Honey Badger | 0.069 | 40 | 1.0 | 0.5 | 205 | 1.0 | 0.28 | 1.30 |

*\* Honey Badger: kill 0.5 (Subsonic) unter Rifle-Min 0.85 → norm=0; proj_speed 205 über Max 170 → norm=1.0. suppressed=1 → +100 % Aufschlag.*

**Normalisierte Werte (norm):**

| Parameter | G36 | AK47 | Honey Badger |
|-----------|-----|------|--------------|
| retrigger_time | 0.30 | 0.00 | 0.46 |
| magazine_size | 0.22 | 0.22 | 0.65 |
| accuracy_factor | 0.13 | 0.07 | 1.00 |
| kill_probability | 0.20 | 1.00 | 0.00 |
| projectile_speed | 0.55 | 0.32 | 1.00 |
| sight_range_modifier | 0.15 | 0.00 | 0.00 |
| sustained_fire_grow_step | 0.41 | 0.36 | 0.67 |
| sustained_fire_diminish_rate | 0.39 | 0.37 | 0.50 |

**Waffenwert und Preis pro Skalierung (G36 = Anker, Basis 14, α=0.6):**

| Waffe | Wurzel √norm | Log ln(1+9n)/ln(10) | Potenz a>1 norm^1.5 | Potenz a<1 norm^0.7 |
|-------|--------------|---------------------|----------------------|----------------------|
| **G36** | 0.49 → **14** | 0.49 → **14** | 0.14 → **14** | 0.40 → **14** |
| **AK47** | 0.47 → **13** | 0.48 → **14** | 0.23 → **19** | 0.39 → **14** |
| **Honey Badger** | 0.52 → **15** | 0.53 → **15** | 0.22 → **28** | 0.45 → **17** |

*\* Preis = 14 × (Waffenwert / Waffenwert_G36)^0.6, gerundet.*

**Fazit:**

- **Wurzel/Log**: G36 ≈ AK47 ≈ Honey Badger (8–10 RP) – kaum Differenzierung.
- **Potenz a>1**: AK47 steigt durch Kill-Bonus (12 RP), Honey Badger deutlich teurer (18 RP) – starke Spanne.
- **Potenz a<1**: G36 = AK47 = 9, Honey Badger 11 – moderate Differenzierung, AK47-Kill-Bonus vs. langsame Feuerrate gleicht sich aus.

*\* Honey Badger: suppressed + burst → +100 % Aufschlag auf Basispreis.*

---

### Rifle-Übersicht (berechnete Waffenwerte → Preise)

| Rifle | Waffenwert | Preis (formel) | Preis (aktuell) |
|-------|------------|-----------------|-----------------|
| G36 | (Anker) | 14 | 14 |
| M16A4 | ähnlich | 15 | 15 |
| HK416 | ähnlich | 14 | 14 |
| AK47 | mittel (kill 1.1) | 13 | 13 |
| F2000 | hoch (acc 1.0, schnell) | 18 | 18 |
| FAMAS | hoch (schnell) | 16 | 16 |
| Steyr AUG | hoch (acc, mag 42, sight) | 19 | 19 |
| L85A2 | mittel (sight 1.2 cap) | 16 | 16 |
| SG552 | mittel | 15 | 15 |
| XM8 | hoch (acc 1.0) | 18 | 18 |
| G36 w/ AG36 | wie G36 + GL (+25 %) | 18 | 18 |
| M16A4 w/ M203 | wie M16 + GL (+25 %) | 19 | 19 |
| M16A4 Support | hoch (mag 48) | 17 | 17 |
| QBZ95 | mittel | 15 | 15 |
| AKS74u | niedrig (acc 0.7) | 13 | 13 |
| AN94 | sehr hoch (schnell) | 18 | 18 |
| AK47 w/ GP25 | wie AK47 + GL (+25 %) | 16 | 16 |
| Honey Badger | suppressed (+100 %) | 34 | 34 |

*\* GL-Varianten: +20–30 % Aufschlag für Granatwerfer-Option. F2000/Steyr/XM8: Formel unterschätzt aktuellen Premium-Preis; Gewichte oder Zusatzfaktoren anpassbar.*

---

## DMR (Designated Marksman Rifle)

**Formel:** `Preis = 45 × (Waffenwert / Waffenwert_M14_EBR)^0.65`

**Anker:** M14 EBR, Basis 45, α = 0.65. Zielbereich: 45–180 RP (Preisspanne wie Sniper, Start ab 45).

### Parameter-Range (aus Waffenpool)

| Parameter | Min | Max | Richtung | Gewicht |
|-----------|-----|-----|----------|---------|
| sight_range_modifier | 1.1 | 2.25 | **höher = besser** | **0.22** |
| accuracy_factor | 0.77 | 1.0 | **höher = besser** | **0.20** |
| retrigger_time | 0.098 | 1.1 | **niedriger = besser** (Semi vs Bolt) | **0.18** |
| magazine_size | 5 | 30 | **höher = besser** | **0.18** |
| kill_probability | 1.1 | 1.2 | **höher = besser** | **0.12** |
| sustained_fire_grow_step | 0.36 | 4.2 | **niedriger = besser** (Streukontrolle) | 0.05 |
| sustained_fire_diminish_rate | 0.5 | 2.5 | **höher = besser** (Rückstoß-Rückgang) | 0.05 |
| projectile_speed | 160 | 225 | **höher = besser** | 0.05 |

*\* retrigger + sustained_fire: Schnelle Feuerrate bei guter Streukontrolle (SCAR SSR: grow 4.2 = schlecht; G28: grow 1.2, diminish 1.3 = gut) → starke DMRs.*  
*\* sight, accuracy, mag, kill: Dominante Parameter für Präzisions-DMRs.*

### Normalisierung

| Parameter | Formel (norm ∈ [0,1]) |
|-----------|------------------------|
| sight_range_modifier | `(wert - 1.1) / 1.15` (1.0 wenn fehlend) |
| accuracy_factor | `(wert - min) / (max - min)` |
| retrigger_time | `(max - wert) / (max - min)` |
| magazine_size | `(wert - min) / (max - min)` |
| kill_probability | `(wert - 1.1) / 0.1` |
| sustained_fire_grow_step | `(max - wert) / (max - min)` |
| sustained_fire_diminish_rate | `(wert - min) / (max - min)` |
| projectile_speed | `(wert - min) / (max - min)` |

### Skalierungsfunktionen

| Parameter | f(norm) |
|-----------|---------|
| sight_range_modifier | `norm^0.6` |
| accuracy_factor | `norm^0.75` |
| retrigger_time | `norm^0.5` |
| magazine_size | `norm^0.6` |
| kill_probability | `norm^0.7` |
| sustained_fire_grow_step | `norm^0.6` |
| sustained_fire_diminish_rate | `norm^0.6` |
| projectile_speed | `norm^0.5` |

---

## SNIPER (Bolt-Action & Präzisionsgewehre)

**Formel:** `Preis = 80 × (Waffenwert / Waffenwert_PSG90)^0.65`

**Anker:** PSG90 (G22), Basis 80, α = 0.65. Zielbereich: 72–448 RP.

### Parameter-Range (aus Waffenpool)

| Parameter | Min | Max | Richtung | Gewicht |
|-----------|-----|-----|----------|---------|
| kill_probability | 1.8 | 3.0 | **höher = besser** | **0.35** |
| sight_range_modifier | 2.15 | 2.7 | **höher = besser** | **0.35** |
| projectile_speed | 230 | 280 | **höher = besser** | 0.12 |
| accuracy_factor | 0.97 | 1.2 | **höher = besser** | 0.10 |
| magazine_size | 7 | 10 | **höher = besser** | 0.05 |
| retrigger_time | 1.0 | 2.2 | **niedriger = besser** (Bolt-Zyklus) | 0.03 |

### Normalisierung

| Parameter | Formel (norm ∈ [0,1]) |
|-----------|------------------------|
| kill_probability | `(wert - 1.8) / 1.2` |
| sight_range_modifier | `(wert - 2.15) / 0.55` |
| projectile_speed | `(wert - 230) / 50` |
| accuracy_factor | `(wert - 0.97) / 0.23` |
| magazine_size | `(wert - 7) / 3` |
| retrigger_time | `(2.2 - wert) / 1.2` |

### Skalierungsfunktionen

| Parameter | f(norm) |
|-----------|---------|
| kill_probability | `norm^0.5` |
| sight_range_modifier | `norm^0.6` |
| projectile_speed | `norm^0.5` |
| accuracy_factor | `norm^0.7` |
| magazine_size | `norm^0.6` |
| retrigger_time | `norm^0.6` |

*\* kill_prob + sight_range je 0.35 → Barrett (kill 3.0, sight 2.7) und M200 (kill 2.0, sight 2.6, proj 280) dominieren.*

### Sniper-Übersicht (Formelpreise angewendet)

| Sniper | kill_prob | sight | proj_speed | accuracy | mag | retrigger | Waffenwert | Preis |
|--------|-----------|-------|------------|----------|-----|-----------|------------|-------|
| PSG90 (Anker) | 1.8 | 2.4 | 240 | 0.97 | 10 | 1.48 | 0.361 | 80 |
| Barrett M107 | **3.0** | **2.7** | 230 | **1.0** | 10 | **1.0** | 0.807 | **143** |
| Lahti L-39 | **3.0** | **2.7** | **300** | **1.0** | 10 | **−1** | 0.927 | **150** |
| M200 | 2.0 | 2.6 | **280** | **1.2** | 7 | 2.2 | 0.671 | 110 |
| Gepard M6 Lynx | **3.0** | 2.0 | 155 | **1.0** | 5 | **1.0** | 0.407 | 87 |
| Truvelo AMRIS | **3.0** | 2.0 | 165 | **1.0** | 6 | **−1** | 0.407 | 87 |
| M24-A2 | 1.8 | 2.2 | 245 | 0.99 | 10 | 1.48 | 0.27 | 63 |
| SV-98 | 1.8 | 2.15 | 235 | 1.0 | 10 | 1.48 | 0.137 | 39 |

*\* Höchstwerte pro Spalte fett. Lahti/Truvelo: blast-Projektil, kill ≈ 3.0 angenommen. Formel: 80 × (Waffenwert / 0.361)^0.65*

*\* SCAR SSR, M14 EBR, G28: DMRs (Semi-Auto) → DMR-Formel, nicht Sniper.*

---

## MP (Maschinenpistole / PDW)

**Formel:** `Preis = 19 × (Waffenwert / Waffenwert_MP7)^0.58`

**Anker:** MP7, Basis 19, α = 0.58. Zielbereich: 10–32 RP.

### Parameter-Range (aus Waffenpool)

| Parameter | Min | Max | Richtung | Gewicht |
|-----------|-----|-----|----------|---------|
| retrigger_time | 0.07 | 0.093 | **niedriger = besser** (RPM) | **0.30** |
| magazine_size | 25 | 50 | **höher = besser** | **0.25** |
| projectile_speed | 90 | 192 | **höher = besser** | 0.18 |
| accuracy_factor | 0.88 | 1.0 | **höher = besser** | 0.14 |
| kill_probability | 0.75 | 0.80 | **höher = besser** | 0.13 |

### Normalisierung

| Parameter | Formel (norm ∈ [0,1]) |
|-----------|------------------------|
| retrigger_time | `(max - wert) / (max - min)` |
| magazine_size | `(wert - min) / (max - min)` |
| projectile_speed | `(wert - 90) / 102` (min 90 für Sichtbarkeit) |
| accuracy_factor | `(wert - min) / (max - min)` |
| kill_probability | `(wert - 0.75) / 0.05` |

### Skalierungsfunktionen

| Parameter | f(norm) |
|-----------|---------|
| retrigger_time | `norm^0.5` |
| magazine_size | `norm^0.6` |
| projectile_speed | `norm^0.5` |
| accuracy_factor | `norm^0.75` |
| kill_probability | `norm^0.7` |

---

## PISTOLE

**Formel:** `Preis = 3 × (Waffenwert / Waffenwert_Glock17)^0.55`

**Anker:** Glock 17, Basis 3, α = 0.55. Zielbereich: 2–29 RP.

### Parameter-Range (aus Waffenpool)

| Parameter | Min | Max | Richtung | Gewicht |
|-----------|-----|-----|----------|---------|
| retrigger_time | 0.066 | 0.34 | **niedriger = besser** (RPM) | **0.30** |
| magazine_size | 6 | 20 | **höher = besser** | **0.25** |
| kill_probability | 0.85 | 0.95 | **höher = besser** | 0.18 |
| accuracy_factor | 0.938 | 1.0 | **höher = besser** | 0.14 |
| projectile_speed | 140 | 190 | **höher = besser** | 0.13 |

### Normalisierung

| Parameter | Formel (norm ∈ [0,1]) |
|-----------|------------------------|
| retrigger_time | `(max - wert) / (max - min)` |
| magazine_size | `(wert - min) / (max - min)` |
| kill_probability | `(wert - 0.85) / 0.1` |
| accuracy_factor | `(wert - min) / (max - min)` |
| projectile_speed | `(wert - min) / (max - min)` |

### Skalierungsfunktionen

| Parameter | f(norm) |
|-----------|---------|
| retrigger_time | `norm^0.5` |
| magazine_size | `norm^0.6` |
| kill_probability | `norm^0.7` |
| accuracy_factor | `norm^0.75` |
| projectile_speed | `norm^0.5` |

*\* Beretta 93r, M712: Schnelle Feuerrate (niedriger retrigger) → teurer. Desert Eagle, Model 29: Hoher kill, aber langsam.*

---

## Nächste Schritte

1. **Skript**: Node.js/Python-Skript, das alle Waffen einliest, Waffenwert berechnet und Preis vorschlägt.
2. **Kalibrierung**: Basis und α so wählen, dass Anker-Waffen exakt getroffen werden.
3. **Manuelle Overrides**: Für Sonderfälle (MG42, F2000) feste Preis-Korrekturen oder Zusatzfaktoren.
4. **Shotgun**: Gewichtungen analog zu anderen Waffentypen ergänzen.
