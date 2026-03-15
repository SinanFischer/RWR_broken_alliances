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

Wenn MGs auf reale RPM und Magazingrößen angepasst werden, ergeben sich folgende Preiswerte (Formel: `Preis = Basis × (W_real/W_aktuell)^0.6`):

| MG | Aktuell | Real RPM | Real Mag | Aktuell Preis | W_real/W_curr | Neuer Preis |
|----|---------|----------|----------|---------------|---------------|-------------|
| **MG4** | 759 RPM, 100 | 890, 100 | 1.17 | 24 | ~27 |
| **M249** | 652 RPM, 130 | 800, 200 | 1.23 | 24 | ~28 |
| **M240** | 500 RPM, 90 | 750, 100 | 1.50 | 18 | ~22 |
| **PKM** | 500 RPM, 100 | 700, 100 | 1.40 | 15 | ~18 |
| **MG42** | 1500 RPM, 150 | 1200, 250 | 0.95* | 600 | ~570 |
| **Stoner LMG** | 1000 RPM, 150 | 1000, 150 | 1.0 | 245 | ~245 |
| **Ultimax** | 667 RPM, 145 | 500, 100 | 0.88* | 145 | ~135 |
| **Negev** | 833 RPM, 150 | 950, 150 | 1.14 | 18 | ~20 |
| **RPK74m** | 600 RPM, 60 | 600, 60 | 1.0 | 24 | ~24 |
| **Pecheneg** | 500 RPM, 100 | 700, 100 | 1.40 | 430 | ~500 |
| **MG-08 Heavy** (Ares Shrike) | 857 RPM, 60 | 800, 100 | 1.25 | 54 | ~60 |

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

## Preis-Berechnung (alle Typen)

```
Preis = Basis_Typ × Waffenwert^α
```

- **α = 0.5–0.65** (Dämpfung)
- **Basis_Typ**: Referenzpreis pro Waffentyp (z.B. Rifle 8, MG 24, Sniper 21)
