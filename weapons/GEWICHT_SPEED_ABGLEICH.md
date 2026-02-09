# Gewicht (Encumbrance) & Speed – Abgleich

**Regel:** Encumbrance ≈ realistisches Gewicht (kg). Speed-Malus skaliert mit Gewicht – **ca. 1,2 % Laufverlust pro kg** (bezogen auf Soldat 70–90 kg). Schwere Waffen bremsen spürbar.

---

## Sturmgewehre (leicht)

| Waffe      | Real ~kg | Enc | Speed  | ≈ % langsamer |
|-----------|----------|-----|--------|----------------|
| AKS-74U   | 2,7      | 3   | -0.035 | ~3,5 %        |
| AK-74M    | 3,4      | 3   | -0.035 | ~3,5 %        |
| G36       | 3,6      | 4   | -0.05  | ~5 %          |
| M16A4     | 4,0      | 4   | -0.05  | ~5 %          |
| HK416     | 4,0      | 4   | -0.05  | ~5 %          |

**AK so leicht?** Ja – die **AK-74M** (5.45×39) wiegt leer ~3,4 kg, mit Magazin ~3,8 kg und gehört zu den leichteren Sturmgewehren. Die alte AK-47 (7.62×39) wäre ~4,3 kg; im Mod ist es die 74M.

---

## DMRs (mittel)

| Waffe      | Real ~kg | Enc | Speed  | ≈ % langsamer |
|-----------|----------|-----|--------|----------------|
| SVD       | 4,3      | 4   | -0.05  | ~5 %           |
| M14 EBR   | 5,2      | 5   | -0.06  | ~6 %           |
| G28       | 5,5      | 6   | -0.07  | **~7 %**       |

5,5 kg (G28) → **7 %** langsamer statt 3 %: Gewicht wirkt jetzt klar auf die Geschwindigkeit.

---

## Leicht-MGs (5.56/5.45)

| Waffe    | Real ~kg | Enc | Speed   | ≈ % langsamer |
|----------|----------|-----|---------|----------------|
| RPK-74M  | 5,1      | 5   | -0.06   | ~6 %           |
| IMI Negev| 7,5      | 8   | -0.095  | ~9,5 %         |
| MG4      | 8,5      | 9   | -0.11   | ~11 %          |
| M249     | 10       | 10  | -0.12   | **~12 %**      |

---

## Schwer-MGs (7.62)

| Waffe            | Real ~kg | Enc | Speed   | ≈ % langsamer  |
|------------------|----------|-----|---------|-----------------|
| Pecheneg Bullpup| ~8       | 8   | -0.095  | ~9,5 %          |
| PKP Pecheneg     | 8,2      | 9   | -0.11   | ~11 %           |
| M240             | 12,5     | 13  | **-0.16** | **~16 %**     |

**12,5 kg Waffe, Soldat 70–90 kg:** 12,5 kg sind ~15–18 % des Körpergewichts → **16 %** Laufverlust ist plausibel (vorher 10 % war zu wenig).

---

## Faustformel

| Enc (≈ kg) | Speed (ca.) | ≈ % langsamer |
|------------|-------------|----------------|
| 3          | -0.035      | ~3,5 %         |
| 4          | -0.05       | ~5 %           |
| 5          | -0.06       | ~6 %           |
| 6          | -0.07       | ~7 %           |
| 8          | -0.095      | ~9,5 %         |
| 9          | -0.11       | ~11 %          |
| 10         | -0.12       | ~12 %          |
| 13         | -0.16       | ~16 %          |

**Formel:** Speed ≈ **-0.012 × Enc** (gerundet); leichte Waffen wenig Malus, schwere MGs (z. B. M240) deutlich langsamer.
