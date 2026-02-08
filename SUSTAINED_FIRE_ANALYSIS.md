# Sustained-Fire-Analyse – Total Conversion Mod

## Parameter-Erklärung

- **sustained_fire_grow_step**: Wie stark die Genauigkeits-Strafe **pro Schuss** während des Feuerns wächst. Höher = schnellerer Verlust.
- **sustained_fire_diminish_rate**: Wie schnell die Strafe **sinkt**, wenn nicht geschossen wird. Höher = schnellere Erholung zwischen Bursts.

## Burst-Kontext

Typische AI-Bursts: **0,3–1,5 Sekunden**. In 1 Sekunde:
- G36 (RT 0,088): ~11 Schüsse
- M16A4 (RT 0,115): ~9 Schüsse
- Kriss Vector (RT 0,071): ~14 Schüsse

## Fraktions-Infanteriewaffen (vor Anpassung)

| Waffe | Fraktion | grow | diminish | Schüsse/1s | Bewertung |
|-------|----------|------|----------|------------|-----------|
| G36 | EU | 0,43 | 1,62 | ~11 | OK |
| HK416 | EU | 0,29 | 1,15 | ~14 | OK |
| M16A4 | US | 0,48 | 1,41 | ~9 | grow etwas hoch |
| M4A1 Scope | US | 0,28 | 1,15 | ~13 | OK |
| AK-74M | RU | 0,26 | 1,05 | ~11 | diminish niedrig |
| AKS-74U | RU | 0,26 | 1,18 | ~14 | OK |
| AEK-919k | RU | 0,35 | 1,1 | ~11 | diminish niedrig |
| Steyr TMP | alle | 0,3 | 1,0 | ~11 | diminish niedrig |
| Kriss Vector | alle | 0,82 | 3,0 | ~14 | grow hoch (SMG) |
| MP7 | alle | 0,7 | 2,0 | ~13 | grow hoch |
| VSS Vintorez | RU | **3,0** | 3,0 | ~5 | **grow extrem** |
| G28 | EU | 1,65 | 1,0 | ~2 | DMR – OK |
| M14 EBR | US | 1,65 | 1,0 | ~2 | DMR – OK |
| Dragunov SVD | RU | 2,8 | 0,74 | ~2 | diminish niedrig |

## Anpassungsstrategie (umgesetzt)

**Nur folgende Waffen angepasst – grow_step/diminish_rate gesenkt:**

| Waffe | grow alt→neu | diminish alt→neu |
|-------|--------------|------------------|
| VSS Vintorez | 3.0→1.6 | 3.0→2.5 |
| Kriss Vector | 0.82→0.55 | 3.0→2.5 |
| MP7 | 0.7→0.50 | 2.0→1.8 |
| M16A4 (US) | 0.48→0.35 | 1.41→1.2 |
| M4A1 Scope (US) | 0.28→0.22 | 1.15→1.0 |
| G36 (EU) | 0.43→0.40 | 1.62→1.55 |
| HK416 (EU) | 0.29→0.27 | 1.15→1.08 |

**DMRs (G28, M14 EBR, Dragunov SVD):** Unverändert – waren OK.
**MGs/LMGs:** Unverändert – keine Erhöhung.
