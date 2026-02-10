# Sniper/DMR – Balance-Referenz

**retrigger_time** = Sekunden zwischen Schüssen (höher = langsamer).  
**sight_range_modifier** = Faktor für Sichtreichweite (höher = weiter sehen).  
**accuracy_factor** = Genauigkeit (0–1); Stances (stehend/kniend/liegend) in `base_primary_sniper.weapon`.

## Nach Balance-Anpassung (Stand)

| Waffe        | Preis | retrigger_time | accuracy | sight_range | Rolle |
|-------------|-------|----------------|----------|-------------|-------|
| SV-98       | 40    | 1.48s          | 1.0      | 2.15        | Billig, Bolzen, gute Sicht |
| M14 EBR     | 40    | **0.85s**      | 0.95     | 1.95        | DMR, verlangsamt |
| Dragunov SVD| 50    | **0.88s**      | 0.93     | 2.0         | DMR, verlangsamt |
| M24-A2      | 70    | 1.48s          | 0.99     | 2.2         | Mittel, Bolzen |
| PSG90 (G22) | 70    | 1.48s          | 0.97     | 2.4         | Mittel, Bolzen, hohe Sicht |
| SCAR SSR    | 150   | **0.92s**      | 1.0      | **2.0**     | Teuer DMR, war 0.362s (unfair) |
| APR         | 450   | 1.1s           | 1.0      | **2.25**    | Stealth-Sniper |
| Barrett M107| 500   | 1.0s           | 1.0      | **2.4**     | Top-Sniper, hohe Sicht |
| Lahti L-39  | 800   | -1 (Einzel)    | 1.0      | **2.5**     | Anti-Material, beste Sicht |
| VSS Vintorez| 500   | 0.2s           | 0.9      | 1.3         | Kein Sniper (Stealth-MG) |

- **Fire Rate:** SCAR SSR und DMRs (SVD, M14) wurden verlangsamt, damit bei Reichweite nicht zu schnell gefeuert wird.
- **Sicht:** Teure (Barrett, Lahti, APR) haben hohe Sicht; mittlere (PSG90, M24) und billige (SV-98, SVD, M14) staffeln nach Preis.
- **ai_sight_range_modifier:** Bei allen Snipers/DMRs (+ VSS) gesetzt, immer **0,1 unter** dem Spieler (`sight_range_modifier − 0.1`), damit die KI etwas kürzere Sicht hat.
