# Waffenwert-Formeln nach Waffentyp

Basis für die Preis-Kalkulation. Jeder Waffentyp hat eigene Gewichtungen.

---

## Gemeinsame Faktoren (alle Typen)

| Faktor | Beschreibung | Einheit |
|--------|--------------|---------|
| accuracy_factor | Präzision | 0–1 |
| retrigger_time | Sekunden zwischen Schüssen | s |
| kill_probability | Lethalität pro Treffer | 0–2+ |
| projectile_speed | Geschossgeschwindigkeit | m/s |
| sight_range_modifier | Zielbereich-Multiplikator | 1.0+ |
| magazine_size | Magazingröße | Schuss |
| sustained_fire_grow_step | Streuungszuwachs beim Dauerfeuer | – |
| sustained_fire_diminish_rate | Erholung der Genauigkeit | – |
| kill_decay_start_time | Start des Kill-Decays (Shotguns) | s |
| kill_decay_end_time | Ende des Kill-Decays (Shotguns) | s |

---

## SNIPER

**Wichtigste Faktoren:**
- **sight_range_modifier** (Hauptfaktor)
- **kill_probability** (Hauptfaktor)

**Weniger wichtig:**
- retrigger_time (Bolt-Action = langsam, kaum relevant)
- magazine_size (klein, wenig Einfluss)
- projectile_speed (leicht)
- accuracy_factor (mittlere Rolle)

**Formel:**
```
Waffenwert = 
  sight_range_modifier^1.2 
  × kill_probability^1.0 
  × accuracy_factor^0.5 
  × (projectile_speed/280)^0.2 
  × (magazine_size/10)^0.2
```

---

## SNIPER-Preisberechnung bei echten Verhältnissen

**Gewichtsfaktoren Sniper:** sight_range_modifier · kill_probability · magazine_size

| Sniper | Faktoren (real) | Aktuell | Real | Preis | Neu |
|--------|-----------------|---------|------|-------|-----|
| **M200** | 2.6 · 2.0 · 7 | 2.6, 2.0, 7 | 2.6, 2.0, 7 | 440 | ~440 |
| **Barrett M107** | 2.7 · 1.8 · 10 | 2.7, 1.8, 10 | 2.7, 1.8, 10 | 500 | ~500 |
| **PSG90** | 2.4 · 1.8 · 10 | 2.4, 1.8, 10 | 2.4, 1.8, 10 | 21 | ~21 |
| **SV98** | 2.15 · 1.8 · 10 | 2.15, 1.8, 10 | 2.15, 1.8, 10 | 12 | ~12 |
| **M24 A2** | 2.2 · 1.8 · 10 | 2.2, 1.8, 10 | 2.2, 1.8, 10 | 21 | ~21 |
| **NS2000** | 1.1 · 1.8 · 10 | 1.1, 1.8, 10 | 1.1, 1.8, 10 | 55 | ~55 |
| **Lahti L39** | 2.7 · 1.8 · 10 | 2.7, 1.8, 10 | 2.7, 1.8, 10 | 570 | ~570 |
| **Truvelo AMRIS** | 2.0 · 1.8 · 6 | 2.0, 1.8, 6 | 2.0, 1.8, 6 | 648 | ~648 |

*\* Bolt-Action: retrigger/RPM kaum relevant; sight_range und kill_prob dominieren. Werte meist bereits realistisch.*

**Referenz:** Basis PSG90 (21). α=0.6.

---

## MG (Maschinengewehr)

**Wichtigste Faktoren:**
- **kill_probability**
- **retrigger_time** (RPM)
- **magazine_size**

**Weniger wichtig:**
- projectile_speed (leicht)
- sustained_fire_grow_step / diminish_rate (Streckfeuer-Verhalten)
- accuracy_factor (mittlere Rolle)
- sight_range_modifier (gering)

**Formel:**
```
Waffenwert = 
  kill_probability^0.9 
  × (60/retrigger_time)^0.7 
  × (magazine_size/100)^0.5 
  × (projectile_speed/150)^0.2 
  × accuracy_factor^0.4 
  × (1/(1+sustained_fire_grow_step))^0.3 
  × sustained_fire_diminish_rate^0.2
```

---

## MG-Preisberechnung bei echten Verhältnissen

Wenn MGs auf reale RPM und Magazingrößen angepasst werden, ergeben sich folgende Preiswerte (Formel: `Preis = Basis × (W_real/W_aktuell)^0.6`).

**Gewichtsfaktoren MG:** kill_probability · retrigger (RPM) · magazine_size

| MG | Faktoren (real) | Aktuell | Real | Preis | Neu |
|----|-----------------|---------|------|-------|-----|
| **MG4** | 1.4 · 890 · 100 | 759 RPM, 100 | 890, 100 | 24 | ~27 |
| **M249** | 1.4 · 800 · 200 | 652 RPM, 130 | 800, 200 | 24 | ~28 |
| **M240** | 1.4 · 750 · 100 | 500 RPM, 90 | 750, 100 | 18 | ~22 |
| **PKM** | 1.4 · 700 · 100 | 500 RPM, 100 | 700, 100 | 15 | ~18 |
| **MG42** | 1.4 · 1200 · 250 | 1500 RPM, 150 | 1200, 250 | 600 | ~570 |
| **Stoner LMG** | 1.4 · 1000 · 150 | 1000 RPM, 150 | 1000, 150 | 245 | ~245 |
| **Ultimax** | 1.4 · 500 · 100 | 667 RPM, 145 | 500, 100 | 145 | ~135 |
| **Negev** | 1.4 · 950 · 150 | 833 RPM, 150 | 950, 150 | 18 | ~20 |
| **RPK74m** | 1.4 · 600 · 60 | 600 RPM, 60 | 600, 60 | 24 | ~24 |
| **Pecheneg** | 1.4 · 700 · 100 | 500 RPM, 100 | 700, 100 | 430 | ~500 |
| **MG-08 Heavy** | 1.4 · 800 · 100 | 857 RPM, 60 | 800, 100 | 54 | ~60 |

*\* MG42/Ultimax: Real-RPM niedriger oder Mag kleiner → Wert sinkt leicht.*

**Referenz:** Basis MG4 (24) als Anker. α=0.6 für moderate Preisanpassung.

---

## DMR (Semi-Auto Sniper)

**Wichtigste Faktoren:**
- **sight_range_modifier**
- **kill_probability**
- **accuracy_factor**

**Weniger wichtig:**
- retrigger_time (mittlere Rolle)
- magazine_size
- projectile_speed (leicht)

**Formel:**
```
Waffenwert = 
  sight_range_modifier^1.0 
  × kill_probability^0.9 
  × accuracy_factor^0.7 
  × (60/retrigger_time)^0.4 
  × (magazine_size/20)^0.3 
  × (projectile_speed/220)^0.2
```

---

## DMR-Preisberechnung bei echten Verhältnissen

**Gewichtsfaktoren DMR:** sight_range_modifier · kill_probability · retrigger (RPM) · magazine_size

| DMR | Faktoren (real) | Aktuell | Real | Preis | Neu |
|-----|-----------------|---------|------|-------|-----|
| **SCAR SSR** | 1.9 · 1.2 · 65 · 20 | 65 RPM, 20 | 65, 20 | 105 | ~105 |
| **M14 EBR** | 1.95 · 1.2 · 70 · 20 | 70 RPM, 20 | 70, 20 | 12 | ~12 |
| **VSS Vintorez** | 1.6 · 1.1 · 300 · 20 | 300 RPM, 20 | 300, 20 | 320 | ~320 |
| **Dragunov SVD** | 2.0 · 1.2 · 68 · 10 | 68 RPM, 16 | 68, 10 | 15 | ~14 |
| **M4A1 Scope** | 1.1 · 1.2 · 612 · 30 | 612 RPM, 30 | 612, 30 | 12 | ~12 |
| **G28** | 1.95 · 1.2 · 92 · 20 | 92 RPM, 20 | 92, 20 | 12 | ~12 |
| **APR** | 2.25 · 1.2 · 55 · 5 | 55 RPM, 5 | 55, 5 | 315 | ~315 |

*\* DMR: sight_range und kill_prob dominieren; RPM/Mag bei Semi-Auto oft bereits realistisch.*

**Referenz:** Basis M14 EBR (12). α=0.6.

---

## RIFLE (Sturmgewehr)

**Wichtigste Faktoren:**
- **accuracy_factor**
- **retrigger_time** (RPM)
- **kill_probability**

**Weniger wichtig:**
- magazine_size
- sight_range_modifier
- sustained_fire_grow_step / diminish_rate
- projectile_speed (leicht)

**Formel:**
```
Waffenwert = 
  accuracy_factor^0.8 
  × (60/retrigger_time)^0.6 
  × kill_probability^0.8 
  × (magazine_size/30)^0.3 
  × sight_range_modifier^0.3 
  × (1/(1+sustained_fire_grow_step))^0.2 
  × sustained_fire_diminish_rate^0.2 
  × (projectile_speed/165)^0.15
```

---

## RIFLE-Preisberechnung bei echten Verhältnissen

Wenn Sturmgewehre auf reale RPM und Magazingrößen angepasst werden, ergeben sich folgende Preiswerte (Formel: `Preis = Basis × (W_real/W_aktuell)^0.6`).

**Gewichtsfaktoren Rifle:** kill_probability · retrigger (RPM) · magazine_size

| Rifle | Faktoren (real) | Aktuell | Real | Preis | Neu |
|-------|-----------------|---------|------|-------|-----|
| **G36** | 0.9 · 750 · 30 | 632 RPM, 30 | 750, 30 | 8 | ~9 |
| **M16A4** | 0.9 · 800 · 30 | 556 RPM, 30 | 800, 30 | 8 | ~9 |
| **HK416** | 0.9 · 750 · 30 | 577 RPM, 36 | 750, 30 | 12 | ~13 |
| **AK47** | 1.1 · 600 · 30 | 536 RPM, 30 | 600, 30 | 8 | ~9 |
| **F2000** | 0.9 · 850 · 30 | 682 RPM, 42 | 850, 30 | 98 | ~105 |
| **FAMAS** | 0.9 · 950 · 25 | 652 RPM, 27 | 950, 25 | 30 | ~34 |
| **Steyr AUG** | 0.9 · 720 · 42 | 488 RPM, 42 | 720, 42 | 85 | ~97 |
| **L85A2** | 0.9 · 650 · 30 | 750 RPM, 27 | 650, 30 | 36 | ~34 |
| **SG552** | 0.9 · 700 · 30 | 556 RPM, 36 | 700, 30 | 24 | ~26 |
| **XM8** | 0.9 · 750 · 30 | 522 RPM, 30 | 750, 30 | 60 | ~68 |
| **G36 w/ AG36** | 0.9 · 750 · 30 | 632 RPM, 30 | 750, 30 | 24 | ~26 |
| **M16A4 w/ M203** | 0.9 · 800 · 30 | 556 RPM, 30 | 800, 30 | 24 | ~27 |
| **M16A4 Support** | 0.85 · 800 · 48 | 556 RPM, 48 | 800, 48 | 40 | ~46 |
| **QBZ95** | 0.9 · 650 · 30 | 500 RPM, 35 | 650, 30 | 73 | ~79 |
| **AKS74u** | 1.0 · 700 · 30 | 667 RPM, 38 | 700, 30 | 12 | ~12 |
| **AN94** | 1.0 · 1800 · 30 | 1714 burst, 45 | 1800, 30 | 60 | ~58 |

**Sonderfälle:**
- **L85A2**: Real-RPM niedriger (650 vs. 750) → Preis sinkt leicht.
- **AN94**: Burst-Mode bereits nah an Realität; Mag 30 statt 45 → leichter Rückgang.
- **M1 Garand**: Semi-Auto (~45 RPM real vs. 214 im Spiel) – Formel nicht sinnvoll; Preis bleibt manuell.

**Referenz:** Basis G36/M16 (8) als Anker. α=0.6.

---

## SHOTGUN

**Wichtigste Faktoren:**
- **kill_probability**
- **kill_decay_start_time** und **kill_decay_end_time** (Lethalitätsfenster)
- **retrigger_time**
- **magazine_size**

**Weniger wichtig:**
- accuracy_factor (Streuung oft fest)
- projectile_speed (leicht)
- sight_range_modifier (gering)

**Kill-Decay:** Längeres Fenster (große Differenz end–start) = höherer Wert.

**Formel:**
```
kill_decay_window = kill_decay_end_time - kill_decay_start_time
Waffenwert = 
  kill_probability^0.9 
  × (1 + kill_decay_window)^0.4 
  × (60/retrigger_time)^0.5 
  × (magazine_size/8)^0.4 
  × accuracy_factor^0.3 
  × (projectile_speed/95)^0.15
```

---

## SHOTGUN-Preisberechnung bei echten Verhältnissen

**Gewichtsfaktoren Shotgun:** kill_probability · kill_decay_window · retrigger (RPM) · magazine_size

| Shotgun | Faktoren (real) | Aktuell | Real | Preis | Neu |
|---------|-----------------|---------|------|-------|-----|
| **SPAS-12** | 0.9 · 0.1 · semi · 8 | semi, 8 | semi, 8 | 9 | ~9 |
| **Mossberg 500** | 0.9 · 0.1 · 117 · 6 | 117 RPM, 6 | 117, 6 | 9 | ~9 |
| **Benelli M4** | 0.9 · 0.07 · 180 · 7 | 180 RPM, 12 | 180, 7 | 70 | ~65 |
| **Benelli M4 supp** | 0.85 · 0.06 · 180 · 7 | 180 RPM, 8 | 180, 7 | 105 | ~100 |
| **AA-12** | 0.85 · 0.16 · 300 · 20 | 300 RPM, 20 | 300, 20 | 57 | ~57 |
| **UTS-15** | 0.85 · 0.135 · 125 · 14 | 125 RPM, 14 | 125, 14 | 45 | ~45 |
| **CAWS** | 0.8 · 0.7 · 240 · 10 | 240 RPM, 10 | 240, 10 | 15 | ~15 |
| **NS2000** | 1.8 · 0.13 · pump · 10 | pump, 10 | pump, 10 | 55 | ~55 |
| **Jackhammer** | 0.85 · 0.18 · 240 · 10 | 240 RPM, 10 | 240, 10 | 125 | ~125 |
| **Origin-12** | 0.85 · 0.03 · 333 · 30 | 333 RPM, 30 | 333, 30 | 210 | ~210 |
| **Saiga-12K** | 1.0 · 0.9 · 240 · 10 | 240 RPM, 10 | 240, 10 | 15 | ~15 |

*\* Pump/Semi: RPM variiert stark; kill_decay_window (end−start) ist zentral für Lethalität.*

**Referenz:** Basis Mossberg (9). α=0.6.

---

## MP (Maschinenpistole / PDW)

**Wichtigste Faktoren:**
- **retrigger_time** (RPM)
- **magazine_size**
- **accuracy_factor**

**Weniger wichtig:**
- kill_probability (niedrig, bewusst)
- projectile_speed (leicht)
- sight_range_modifier (gering)

**Formel:**
```
Waffenwert = 
  (60/retrigger_time)^0.6 
  × (magazine_size/40)^0.5 
  × accuracy_factor^0.6 
  × kill_probability^0.5 
  × sight_range_modifier^0.2 
  × (projectile_speed/200)^0.15
```

---

## MP-Preisberechnung bei echten Verhältnissen

**Gewichtsfaktoren MP:** retrigger (RPM) · magazine_size · accuracy_factor · kill_probability

| MP | Faktoren (real) | Aktuell | Real | Preis | Neu |
|----|-----------------|---------|------|-------|-----|
| **P90** | 857 · 50 · 0.99 · 0.48 | 857 RPM, 60 | 857, 50 | 130 | ~125 |
| **MP7** | 659 · 40 · 0.91 · 0.45 | 659 RPM, 40 | 659, 40 | 110 | ~110 |
| **KRISS Vector** | 845 · 25 · 0.96 · 0.48 | 845 RPM, 25 | 845, 25 | 70 | ~70 |

*\* MP: kill_prob bewusst niedrig; RPM und Mag dominieren. P90: Real-Mag 50 statt 60.*

**Referenz:** Basis MP7 (110). α=0.6.

---

## PISTOLE

**Wichtigste Faktoren:**
- **retrigger_time**
- **kill_probability**
- **accuracy_factor**

**Weniger wichtig:**
- magazine_size
- projectile_speed (leicht)

**Formel:**
```
Waffenwert = 
  (60/retrigger_time)^0.5 
  × kill_probability^0.7 
  × accuracy_factor^0.6 
  × (magazine_size/15)^0.3 
  × (projectile_speed/400)^0.1
```

---

## PISTOLE-Preisberechnung bei echten Verhältnissen

**Gewichtsfaktoren Pistole:** retrigger (RPM) · kill_probability · accuracy_factor · magazine_size

| Pistole | Faktoren (real) | Aktuell | Real | Preis | Neu |
|---------|-----------------|---------|------|-------|-----|
| **Glock 17** | 300 · 0.85 · 0.95 · 17 | 300 RPM, 17 | 300, 17 | 2 | ~2 |
| **Beretta M9** | 240 · 0.85 · 0.95 · 15 | 240 RPM, 15 | 240, 15 | 3 | ~3 |
| **Desert Eagle** | 200 · 0.9 · 1.0 · 7 | 200 RPM, 7 | 200, 7 | 5 | ~5 |
| **M712** | 909 · 0.85 · 0.95 · 20 | 909 RPM, 20 | 909, 20 | 125 | ~125 |
| **Model 29** | 176 · 0.85 · 0.95 · 6 | 176 RPM, 6 | 176, 6 | 36 | ~36 |
| **Beretta 93R** | 857 · 0.85 · 0.95 · 15 | 857 RPM, 15 | 857, 15 | 30 | ~30 |
| **PB** | 280 · 0.95 · 0.9 · 8 | 280 RPM, 8 | 280, 8 | – | – |

*\* Pistolen: RPM meist realistisch; M712 (C96) und 93R (Burst) sind Ausnahmen. Desert Eagle: Mag 7 real. PB: Brown-Pistole.*

**Referenz:** Basis Glock (2). α=0.6.

---

## Preis-Berechnung (alle Typen)

```
Preis = Basis_Typ × Waffenwert^α
```

- **α = 0.5–0.65** (Dämpfung)
- **Basis_Typ**: Referenzpreis pro Waffentyp (z.B. Rifle 8, MG 24, Sniper 21)
