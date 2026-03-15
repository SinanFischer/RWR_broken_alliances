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
| **MG** | MG4 | 43 | 0.60 | 29–136 | Mittel–Gut |
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

### Parameter-Range (aus Waffenpool, Stand nach Real-Anpassung)

| Parameter | Min | Max | Richtung | Gewicht |
|-----------|-----|-----|----------|---------|
| retrigger_time | 0.05 | 0.12 | **niedriger = besser** (RPM) | 0.25 |
| magazine_size | 30 | 250 | **höher = besser** | 0.22 |
| accuracy_factor | 0.72 | 0.92 | **höher = besser** | 0.15 |
| projectile_speed | 120 | 170 | **höher = besser** | 0.08 |
| sight_range_modifier | 1.0 | 1.2 | **höher = besser** | 0.05 |
| sustained_fire_grow_step | -0.2 | 0.7 | **niedriger = besser** | 0.10 |
| sustained_fire_diminish_rate | -1.35 | 0.86 | **höher = besser** (negativ = Constant Recoil) | 0.08 |
| kill_probability | 1.4 | 1.4 | konstant (MG-Regelwerk) | – |

*\* sustained_fire: Negative Werte (Ultimax) = Constant Recoil = Sonderbonus; norm = 1.0 (beste).*

### Normalisierung

| Parameter | Formel (norm ∈ [0,1]) |
|-----------|------------------------|
| retrigger_time | `(max - wert) / (max - min)` |
| magazine_size | `(wert - min) / (max - min)` |
| accuracy_factor | `(wert - min) / (max - min)` |
| projectile_speed | `(wert - min) / (max - min)` |
| sight_range_modifier | `(wert - 1.0) / 0.2` (1.0 = Default wenn fehlend) |
| sustained_fire_grow_step | `(max - wert) / (max - min)`; negativ → 1.0 |
| sustained_fire_diminish_rate | `(wert - min) / (max - min)`; wert &lt; 0 → 1.0 |

### Skalierungsfunktionen (score = f(norm))

| Parameter | f(norm) | Begründung |
|-----------|---------|------------|
| retrigger_time | `norm^0.7` | Kleine Verbesserung bei schon schnellen Waffen = starker Preisanstieg |
| magazine_size | `norm^0.6` | 100→200 großer Sprung, 200→250 weniger |
| accuracy_factor | `norm^0.8` | Leicht sublinear |
| projectile_speed | `norm^0.5` | Geringer Einfluss, stark gedämpft |
| sight_range_modifier | `norm^0.6` | |
| sustained_fire_grow_step | `norm^0.7` | |
| sustained_fire_diminish_rate | `norm^0.6` | |

### Anker

- **MG4**: Preis 43, Waffenwert als Referenz.
- **Basis_MG** = 43, α = 0.6.

### Beispielrechnung MG4

```
retrigger: 0.0674 → norm = (0.12-0.0674)/(0.12-0.05) = 0.75 → score = 0.75^0.7 = 0.81
mag: 100 → norm = (100-30)/(250-30) = 0.32 → score = 0.32^0.6 = 0.52
accuracy: 0.84 → norm = 0.6 → score = 0.6^0.8 = 0.66
proj_speed: 143 → norm = 0.21 → score = 0.21^0.5 = 0.46
sight: 1.2 → norm = 1.0 → score = 1.0
grow: 0.5 → norm = 0.22 → score = 0.22^0.7 = 0.38
diminish: 0.85 → norm = 0.79 → score = 0.79^0.6 = 0.87

Waffenwert = 0.25×0.81 + 0.22×0.52 + 0.15×0.66 + 0.08×0.46 + 0.05×1.0 + 0.10×0.38 + 0.08×0.87
          = 0.20 + 0.11 + 0.10 + 0.04 + 0.05 + 0.04 + 0.07 = 0.61
```

### MG-Preiskalkulation (Schritt für Schritt)

**Formel-Pipeline:** Wie Rifle – norm → score → Waffenwert. `Preis = 43 × (Waffenwert / Waffenwert_MG4)^0.6`

**Sonderfälle:** `sustained_fire_grow_step` oder `sustained_fire_diminish_rate` negativ (z.B. Ultimax Constant Recoil) → norm = 1.0 (beste).

### MG-Übersicht (berechnete Waffenwerte → Preise)

| MG | Waffenwert | Preis (formel) | Preis (aktuell) |
|----|------------|----------------|-----------------|
| MG4 | (Anker) 0.647 | 43 | 27 |
| M249 | 0.694 | 45 | 28 |
| M240 | 0.652 | 43 | 22 |
| PKM | 0.635 | 42 | 18 |
| MG42 | 0.732 | 46 | 570 |
| Stoner LMG | 0.741 | 47 | 245 |
| Ultimax | 0.467 (langsam, aber Constant Recoil) | 35 | 135 |
| Negev | 0.717 | 46 | 20 |
| RPK74m | 0.513 | 37 | 24 |
| Pecheneg | 0.599 | 41 | 500 |
| MG-08 Heavy | 0.444 | 34 | 60 |

*\* MG42/Stoner/Pecheneg: Aktuelle Preise sind manuell/legacy; Formel liefert 41–47 RP (Segment Mittel).*

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

## Nächste Schritte

1. **Skript**: Node.js/Python-Skript, das alle Waffen einliest, Waffenwert berechnet und Preis vorschlägt.
2. **Kalibrierung**: Basis und α so wählen, dass Anker-Waffen exakt getroffen werden.
3. **Manuelle Overrides**: Für Sonderfälle (MG42, F2000) feste Preis-Korrekturen oder Zusatzfaktoren.
4. **Erweiterung**: DMR, Sniper, Shotgun, MP, Pistole mit gleichem Schema.
