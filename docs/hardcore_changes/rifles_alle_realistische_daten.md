# Alle Rifles im Mod – Reale Daten & RWR-Parameter

Recherche aller **Sturmgewehre (Rifles)** in RWR Broken Alliances. Analog zu `mg_alle_realistische_daten.md`.

---

## Übersicht: Rifles im Mod

| Waffe | Kaliber | Fraktion | Datei |
|-------|---------|----------|-------|
| G36 | 5.56×45 NATO | Green | g36.weapon |
| HK416 | 5.56×45 NATO | Green | hk416.weapon |
| M16A4 | 5.56×45 NATO | Green | m16a4.weapon |
| M16A4 Support | 5.56×45 NATO | Green | m16a4_support.weapon |
| M16A4 w/M203 | 5.56×45 NATO | Green | m16a4_w_m203.weapon |
| F2000 | 5.56×45 NATO | Green | f2000.weapon |
| FAMAS G1 | 5.56×45 NATO | Green | famasg1.weapon |
| Steyr AUG | 5.56×45 NATO | Green | steyr_aug.weapon |
| L85A2 | 5.56×45 NATO | Green | l85a2.weapon |
| SG552 | 5.56×45 NATO | Green | sg552.weapon |
| XM8 | 5.56×45 NATO | Green | xm8.weapon |
| G36 w/ AG36 | 5.56×45 NATO | Green | g36_w_ag36.weapon |
| Honey Badger | .300 BLK subsonic | Green | honey_badger.weapon |
| M1 Garand Modern | .30-06 | Green | m1_garand_m.weapon |
| Gilboa DBR | 5.56×45 NATO | Green | gilboa_dbr.weapon |
| AK-74M | 5.45×39 | Brown | ak47.weapon |
| AKS-74U | 5.45×39 | Brown | aks74u.weapon |
| AN-94 | 5.45×39 | Brown | an94_burst.weapon |
| AK-74 GP25 | 5.45×39 | Brown | ak47_w_gp25.weapon |
| QBZ-95 | 5.8×42 | Grey | qbz95.weapon |

*Hinweis: ak47.weapon nutzt Modell AK-74M (ak74m.xml) und 5.45×39 – nicht 7.62×39.*

---

## Reale Daten (Recherche)

| Waffe | Kaliber | Mündungsgeschw. (m/s) | Reichweite (m) | Gewicht (kg) | Kadenz (RPM) | Magazin |
|-------|---------|------------------------|----------------|--------------|--------------|---------|
| G36 | 5.56 NATO | 920 | 600 | 3.63 | 750 | 30 |
| HK416 | 5.56 NATO | 790–917 | 300–800 | 3.12–3.85 | 850 | 30 |
| M16A4 | 5.56 NATO | 948 | 600 | 3.4 | 700–950 | 30 |
| F2000 | 5.56 NATO | 900 | 500 | 3.6 | 850 | 30 |
| FAMAS | 5.56 NATO | 925–930 | 300–450 | 3.61–3.8 | 900–1100 | 25/30 |
| Steyr AUG | 5.56 NATO | 970 | 300 | 3.6 | 680–750 | 30/42 |
| L85A2 | 5.56 NATO | 930–940 | 400 | 4.98 | 610–775 | 30 |
| SG552 | 5.56 NATO | ~880 | 100–400 | ~3.2 | ~700 | 20/30 |
| XM8 | 5.56 NATO | ~900 | 500 | 3.4 | 750 | 30 |
| AK-74M | 5.45×39 | 900 | 400 | 3.25 | 600 | 30 |
| AKS-74U | 5.45×39 | 735 | 300–400 | 2.7 | 700 | 20/30 |
| AN-94 | 5.45×39 | 900 | 800 | 3.85 | 600 (1800 burst) | 30 |
| QBZ-95 | 5.8×42 | 930 | 400–600 | 3.25 | 650 | 30 |
| Honey Badger | .300 BLK | ~300 (subsonic) | ~150 | 2.04 | Semi | 30 |
| M1 Garand | .30-06 | 853 | 457 | 4.31–5.3 | 40–50 | 8 |
| Gilboa DBR | 5.56 NATO | ~900 | ~400 | 4.9–5.15 | Semi | 2×30 |

---

## RWR-Parameter-Mapping

### projectile_speed (RWR-Skala ≈ real m/s ÷ 5.5)

| Real (m/s) | RWR |
|------------|-----|
| 735 | 148 |
| 853 | 155 |
| 880–900 | 158 |
| 920–930 | 160 |
| 948–970 | 165 |
| 300 (subsonic) | 55 |

### retrigger_time (60 ÷ RPM)

| RPM | retrigger_time |
|-----|----------------|
| 600 | 0.10 |
| 650 | 0.092 |
| 700 | 0.0857 |
| 750 | 0.08 |
| 850 | 0.0706 |
| 900–1000 | 0.06–0.067 |
| 40–50 (semi) | 1.2–1.5 |

### encumbrance (Gewicht-basiert)

| Gewicht (kg) | encumbrance |
|--------------|-------------|
| 2.0–2.5 | 2 |
| 2.7–3.2 | 3 |
| 3.2–3.9 | 4 |
| 4.0–5.0 | 5 |
| + GL/Shield | +1 bis +6 |

### modifier speed (Gewicht-basiert)

| Gewicht (kg) | speed modifier |
|--------------|----------------|
| ~2 | -0.01 bis -0.02 |
| 2.7–3.2 | -0.02 bis -0.03 |
| 3.2–4.0 | -0.03 bis -0.05 |
| 4.0–5.0 | -0.05 bis -0.06 |
| 5+ | -0.06 bis -0.08 |

### kill_probability (nach Kaliber, siehe kill_probability_regelwerk.md)

| Kaliber | kill_prob |
|---------|-----------|
| 5.56 NATO | 0.90 |
| 5.45×39 | 1.0 |
| 7.62×39 | 1.1 |
| .30-06 | 1.1 |
| .300 BLK subsonic | 0.50 |

### sight_range_modifier (Rifle-Cap: max 1.2)

---

## Angewendete Änderungen (Zusammenfassung)

| Waffe | Änderungen |
|-------|------------|
| **AK-74M** | kill_prob 1.1 → 1.0 (5.45×39, nicht 7.62×39) |
| **AK-74 GP25** | kill_prob 1.1 → 1.0 |
| **L85A2** | sight_range_modifier 1.65 → 1.2 (Cap) |
| **Steyr AUG** | sight_range_modifier 1.3 → 1.2 (Cap) |
| **Honey Badger** | projectile_speed 205 → 55 (subsonic), enc 5 → 2 |
| **M1 Garand** | kill 0.9 → 1.1, enc 10 → 5, proj_speed 145 → 158, retrigger 0.28 → 1.33 |
| **QBZ95** | enc 10 → 4, speed -0.08 → -0.04 |
| **AN94** | enc 10 → 4 |
| **Gilboa DBR** | enc 10 → 5 |
| **HK416** | retrigger 0.08 → 0.0706 (850 RPM) |
| **M16A4** | retrigger 0.075 → 0.07, proj_speed 157 → 160 |
| **L85A2** | enc 3 → 5 (4.98 kg), retrigger 0.0923 → 0.08 |
| **Steyr AUG** | enc 5 → 4, sight 1.3 → 1.2 |
| **FAMAS** | retrigger 0.0632 → 0.06, enc 3 → 4 |
| **G36 w/AG36** | enc 4 → 5 (+GL) |
| **M16A4 w/M203** | enc 4 → 5 (+GL), proj_speed 157 → 160 |

---

## Preisformel (waffenwert_formeln_v2.md)

**Formel:** `Preis = 14 × (Waffenwert / Waffenwert_G36)^0.6`  
**Anker:** G36, Basis 14, α = 0.6  
**Zusätze:** GL-Varianten +25 %, Honey Badger (suppressed) +100 %, Gilboa (projectiles_per_shot=2) +280 %

### Parameter-Ranges

| Parameter | Min | Max | Richtung |
|-----------|-----|-----|----------|
| retrigger_time | 0.0333 | 0.1 | niedriger = besser |
| magazine_size | 25 | 48 | höher = besser |
| accuracy_factor | 0.70 | 1.0 | höher = besser |
| kill_probability | 0.85 | 1.1 | höher = besser |
| projectile_speed | 148 | 170 | höher = besser |
| sight_range_modifier | 1.0 | 1.2 | höher = besser |
| sustained_fire_grow_step | 0.15 | 0.54 | niedriger = besser |
| sustained_fire_diminish_rate | 0.60 | 2.0 | höher = besser |

### Vollständige Wertetabelle (nach Waffenwert sortiert)

| Rifle | retrig | mag | acc | kill | proj | sight | grow | dim | Waffenwert | Preis (Formel) | Preis (aktuell) |
|-------|--------|-----|-----|------|------|-------|------|-----|------------|---------------|-----------------|
| Steyr AUG | 0.083 | 42 | 1.00 | 0.90 | 165 | 1.20 | 0.26 | 1.10 | 0.661 | 19 | 19 |
| F2000 | 0.071 | 30 | 1.00 | 0.90 | 158 | 1.18 | 0.30 | 2.00 | 0.660 | 19 | 19 |
| AN-94 | 0.033 | 30 | 0.93 | 1.00 | 158 | 1.00 | 0.15 | 0.60 | 0.645 | 18 | 18 |
| XM8 | 0.08 | 30 | 1.00 | 0.90 | 165 | 1.15 | 0.37 | 1.53 | 0.609 | 18 | 18 |
| L85A2 | 0.08 | 30 | 0.97 | 0.90 | 158 | 1.20 | 0.22 | 1.20 | 0.597 | 18 | 18 |
| M16A4 Support | 0.07 | 48 | 0.80 | 0.85 | 160 | 1.20 | 0.26 | 1.22 | 0.561 | 17 | 17 |
| FAMAS G1 | 0.06 | 25 | 0.97 | 0.90 | 155 | 1.00 | 0.28 | 1.60 | 0.537 | 16 | 16 |
| Honey Badger | 0.069 | 40 | 1.00 | 0.50 | 55 | 1.00 | 0.28 | 1.30 | 0.522 | 32 | 32 |
| M1 Garand | 1.33 | 8 | 0.95 | 1.10 | 158 | 1.05 | 2.50 | 2.80 | 0.505 | 16 | 48 |
| M16A4 | 0.07 | 30 | 0.80 | 0.90 | 160 | 1.10 | 0.26 | 1.22 | 0.501 | 16 | 16 |
| SG552 | 0.086 | 30 | 0.97 | 0.90 | 155 | 1.10 | 0.54 | 1.34 | 0.493 | 16 | 16 |
| M16A4 w/M203 | 0.07 | 30 | 0.80 | 0.90 | 160 | 1.10 | 0.26 | 1.22 | 0.487 | 19 | 19 |
| QBZ-95 | 0.092 | 30 | 0.95 | 0.90 | 160 | 1.00 | 0.42 | 1.30 | 0.447 | 15 | 15 |
| HK416 | 0.071 | 30 | 0.75 | 0.90 | 165 | 1.05 | 0.32 | 1.18 | 0.445 | 15 | 15 |
| Gilboa DBR | 0.145 | 30 | 1.00 | 0.90 | 158 | 1.00 | 0.27 | 1.20 | 0.428 | 55 | 55 |
| G36 | 0.08 | 30 | 0.74 | 0.90 | 160 | 1.10 | 0.38 | 1.15 | 0.410 | 14 | 14 |
| G36 w/AG36 | 0.08 | 30 | 0.74 | 0.90 | 160 | 1.10 | 0.38 | 1.15 | 0.410 | 18 | 18 |
| AKS-74U | 0.086 | 30 | 0.70 | 1.00 | 148 | 1.05 | 0.40 | 1.10 | 0.348 | 13 | 13 |
| AK-74M | 0.10 | 30 | 0.72 | 1.00 | 158 | 1.00 | 0.40 | 1.12 | 0.304 | 12 | 12 |
| AK-74 GP25 | 0.10 | 30 | 0.72 | 1.00 | 158 | 1.00 | 0.40 | 1.12 | 0.304 | 15 | 15 |

*\* Gilboa: Basis 14 × 3.8 (+280 % für projectiles_per_shot=2) = 55 RP.*  
*\* M1 Garand (48 RP): Manueller Preis – Sammler/Stil, Formel würde 16 liefern.*

### Dominanz-Check (Waffenwert > 0.45 = starke Rifles)

| Dominante Rifles | Waffenwert |
|------------------|------------|
| Steyr AUG, F2000, AN-94, XM8, L85A2, M16A4 Support, FAMAS, Honey Badger, M1 Garand, M16A4, SG552, M16A4 w/M203 | 0.487–0.661 |

**Schwächere Rifles (Waffenwert < 0.4):** G36, G36 w/AG36, AKS-74U, AK-74M, AK-74 GP25 (langsamer retrigger, geringere accuracy)

### Preisanpassungen (Formel angewendet)

| Waffe | Alt | Neu |
|-------|-----|-----|
| L85A2 | 16 | 18 |
| M16A4 | 15 | 16 |
| SG552 | 15 | 16 |
| HK416 | 14 | 15 |
| F2000 | 18 | 19 |
| AK-74M | 13 | 12 |
| AK-74 GP25 | 16 | 15 |
| Honey Badger | 34 | 32 |
| Gilboa DBR | 105 | **55** (+280 % für Doppelschuss) |
| M1 Garand | 48 | *(unverändert, manuell)* |

### Ausführung

```powershell
cd scripts
node rifle-price-formula.js
```

---

## Sonderfälle

- **TTI Combat Shield**: Kein klassisches Rifle (Shield + Shotgun), unverändert.
- **M16A4 Support**: enc 10 durch Schild; sight 1.2 bereits am Cap.
- **Gilboa DBR**: projectiles_per_shot=2 (Doppelläufig), mag 30 = 15 Doppelschüsse. +280 % Aufschlag → 55 RP.
- **AN-94**: Burst-Modus (1800 RPM) separat modelliert; Vollauto 600 RPM.
- **M1 Garand**: Semi, 8 Schuss – Formel bewertet niedrig; aktueller Preis 48 (Sammler/Stil).
