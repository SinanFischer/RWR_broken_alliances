# Shotguns – Reale Daten & RWR-Parameter

**Referenz:** 12 Gauge 00 Buckshot ~385 m/s, effektive Reichweite ~35–40 m. Slugs ~450 m/s, Reichweite ~100 m.

**kill_decay-Formel (projektilgeschwindigkeitsbasiert):**
- `kill_decay_start_time = 14 / projectile_speed` (volle Lethalität bis ~35 m)
- `kill_decay_end_time = 28 / projectile_speed` (Abfall bis ~70 m)
- Suppressed/Subsonic (proj 95–100): längere Decay-Zeiten (langsameres Projektil = gleiche Distanz in mehr Zeit)

**kill_probability:** 12 Gauge 00 Buck 0.90, reduzierte Ladung (3–5 Pellets) 0.85, CAWS Flechette 0.80.

---

## Übersicht: Angepasste Werte

| Waffe | proj_speed | kill_prob | decay_start | decay_end | Begründung |
|-------|------------|-----------|-------------|-----------|------------|
| Mossberg 500 | 145 | 0.90 | 0.10 | 0.20 | Standard 00 Buck |
| SPAS-12 | 140 | 0.90 | 0.10 | 0.20 | 12 Gauge |
| Benelli M4 | 144 | 0.90 | 0.10 | 0.20 | 12 Gauge |
| Benelli M4 supp | 140 | 0.85 | 0.10 | 0.20 | Subsonic, weniger Energie |
| UTS-15 | 150 | 0.85 | 0.09 | 0.19 | 12 Gauge |
| Saiga-12K | 145 | 0.90 | 0.10 | 0.20 | 12 Gauge |
| AA-12 | 145 | 0.85 | 0.10 | 0.20 | Auto, reduzierte Ladung |
| Jackhammer | 148 | 0.85 | 0.09 | 0.19 | 3 Pellets/Schuss |
| CAWS | 145 | 0.80 | 0.12 | 0.25 | Flechette, bessere Reichweite |
| Origin-12 | 95 | 0.85 | 0.15 | 0.30 | Subsonic |
| Origin-12 S | 96 | 0.85 | 0.15 | 0.29 | Suppressed |
| TTI Shield | 90 | 0.90 | 0.16 | 0.31 | Langsamer, CQB |
| Sawn-off | 136 | 0.85 | 0.10 | 0.21 | Kurzer Lauf |
| NS2000 | 140 | 0.90 | 0.10 | 0.20 | 12 Gauge |
| QBS-09 | 136 | 0.90 | 0.10 | 0.21 | 12 Gauge |
| QBZ-95 Shotgun | 95 | 0.85 | 0.15 | 0.29 | Subsonic |

---

## Shotgun-Preise (Formel: 14 × (W/W_Mossberg)^0.58)

| Waffe | retrigger | mag | proj | proj/shot | Preis |
|-------|-----------|-----|------|-----------|-------|
| Mossberg 500 (Anker) | 0.51 | 6 | 145 | 8 | **14** |
| Saiga-12K | 0.25 | 10 | 145 | 11 | **17** |
| AA-12 | 0.33 | 20 | 145 | 8 | **17** |
| CAWS | 0.25 | 10 | 145 | 11 | **17** |
| Benelli M4 | 0.333 | 12 | 144 | 5 | **15** |
| UTS-15 | 0.48 | 14 | 150 | 6 | **15** |
| Jackhammer | 0.25 | 10 | 148 | 3 | **15** |
| Origin-12 | 0.18 | 30 | 95 | 3 | **15** |
| Sawn-off | 0.21 | 2 | 136 | 10 | **15** |
| QBS-09 | 0.40 | 10 | 136 | 5 | **14** |
| SPAS-12 | 1.0 | 8 | 140 | 6 | **10** |
| NS2000 | 1.0 | 10 | 140 | 4 | **11** |
| Benelli M4 supp | 0.333 | 8 | 140 | 5 | **35** (suppr. +20) |
| Origin-12 S | 0.18 | 30 | 96 | 3 | **35** (suppr. +20) |
| TTI Shield | 1.0 | 3 | 90 | 6 | **55** (Override: Schild) |
| QBZ-95 Shotgun | 0.18 | 4 | 95 | 4 | **18** |
