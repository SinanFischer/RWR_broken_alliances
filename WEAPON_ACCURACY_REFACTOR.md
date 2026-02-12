# Accuracy-Refaktor: Vanilla-nahe Logik (factor + grow/diminish, weniger Stances)

**Ziel:** Wie Vanilla – accuracy_factor höher (0.95–1.0), sustained_fire_grow/diminish für Differenzierung, Stance-Overrides nur bei Spezialwaffen entfernen.

---

## 1. Standard-Sturmgewehre (G36, M16A4, AK-74M)

### VORHER (aktuell)

| Metrik | G36 | M16A4 | AK-74M |
|--------|-----|-------|--------|
| **acc_factor** | 0.88 | 0.90 | 0.88 |
| **sustained_fire_grow_step** | 0.20 | 0.20 | 0.20 |
| **sustained_fire_diminish_rate** | 1.12 | 1.12 | 1.12 |
| **standing** | 0.75 | 0.78 | 0.74 |
| **crouching** | 0.8 | 0.82 | 0.8 |
| **prone** | 0.925 | 0.94 | 0.90 |
| **walking** | 0.60 | 0.578 | 0.60 |
| **crouch_moving** | 0.62 | 0.618 | 0.62 |
| **running** | 0.48 | 0.448 | 0.48 |
| **prone_moving** | 0.56 | 0.538 | 0.56 |
| **Stance-Overrides** | 7 | 7 | 7 |

### NACHHER (Vanilla-nahe)

| Metrik | G36 | M16A4 | AK-74M |
|--------|-----|-------|--------|
| **acc_factor** | **0.98** | **1.0** | **0.96** |
| **sustained_fire_grow_step** | **0.26** | **0.16** | **0.22** |
| **sustained_fire_diminish_rate** | **1.18** | **1.25** | **1.15** |
| **standing** | (base 0.85) | (base 0.85) | (base 0.85) |
| **crouching** | (base 0.9) | (base 0.9) | (base 0.9) |
| **prone** | (base 0.93) | (base 0.93) | (base 0.93) |
| **Stance-Overrides** | **0** | **0** | **0** |

**Logik:**
- **G36:** Faktor 0.98, hoher grow (0.26) = schnelles Feuer → schnell ungenau bei Dauerfeuer; diminish 1.18 = schnelle Erholung.
- **M16A4:** Faktor 1.0, niedriger grow (0.16) = bleibt länger präzise; diminish 1.25 = beste Erholung.
- **AK-74M:** Faktor 0.96, mittlerer grow (0.22); Stärke bleibt Kill 0.92.

**Unverändert:** kill, RT, mag, sight, com, Preis.

---

## 2. Pool-Sturmgewehre (HK416, M4A1, AKS-74U)

### VORHER (aktuell)

| Metrik | HK416 | M4A1 | AKS-74U |
|--------|-------|------|---------|
| **acc_factor** | 0.88 | 0.88 | 0.84 |
| **sustained_fire_grow_step** | 0.18 | 0.28 | 0.22 |
| **sustained_fire_diminish_rate** | 1.15 | 1.4 | 1.1 |
| **standing** | 0.76 | 0.80 | 0.72 |
| **crouching** | 0.85 | 0.82 | 0.80 |
| **prone** | 0.93 | 0.90 | 0.88 |
| **walking** | 0.62 | 0.70 | 0.62 |
| **crouch_moving** | 0.65 | 0.70 | 0.64 |
| **running** | 0.45 | 0.50 | 0.50 |
| **prone_moving** | 0.60 | 0.65 | 0.58 |
| **Stance-Overrides** | 7 | 7 | 7 |

### NACHHER (Vanilla-nahe)

| Metrik | HK416 | M4A1 | AKS-74U |
|--------|-------|------|---------|
| **acc_factor** | **0.96** | **0.98** | **0.92** |
| **sustained_fire_grow_step** | **0.20** | **0.24** | **0.24** |
| **sustained_fire_diminish_rate** | **1.20** | **1.35** | **1.12** |
| **standing** | (base 0.85) | (base 0.85) | (base 0.85) |
| **crouching** | (base 0.9) | (base 0.9) | (base 0.9) |
| **prone** | (base 0.93) | (base 0.93) | (base 0.93) |
| **Stance-Overrides** | **0** | **0** | **0** |

**Logik:**
- **HK416:** Faktor 0.96, mäßiger grow (0.20), gute diminish (1.20) – präziser Pool-AR.
- **M4A1:** Faktor 0.98, grow 0.24 (M4 neigt zu Streuung bei Dauerfeuer), diminish 1.35 = stärkste Erholung.
- **AKS-74U:** Faktor 0.92 (Kurzkarabin), grow 0.24, diminish 1.12; Stärke = Kadenz + Mag 38.

**Unverändert:** kill, RT, mag, sight, com, Preis.

---

## Basis-Stances (base_primary.weapon, Mod)

Wenn keine Overrides: standing 0.85, crouching 0.9, prone 0.93, walking 0.675, crouch_moving 0.75, running 0.3, prone_moving 0.3.
