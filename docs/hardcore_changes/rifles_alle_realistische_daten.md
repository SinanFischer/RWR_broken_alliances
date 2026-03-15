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

## Sonderfälle

- **TTI Combat Shield**: Kein klassisches Rifle (Shield + Shotgun), unverändert.
- **M16A4 Support**: enc 10 durch Schild; sight 1.2 bereits am Cap.
- **Gilboa DBR**: projectiles_per_shot=2 (Doppelläufig), mag 30 = 15 Doppelschüsse.
- **AN-94**: Burst-Modus (1800 RPM) separat modelliert; Vollauto 600 RPM.
