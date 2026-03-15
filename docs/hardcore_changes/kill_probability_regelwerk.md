# Kill-Probability-Regelwerk

**kill_probability** = Wahrscheinlichkeit, dass ein Treffer sofort tötet (1.0 = 100 %).

---

## Übersicht

| Kategorie | Bereich | Beschreibung |
|-----------|---------|--------------|
| **MP** | 0.6–1.0 | Maschinenpistolen/PDWs – unverändert, je nach Waffe |
| **Rifles** | 0.8–1.1 | Sturmgewehre, Shotguns – Green/Grey im mittleren Bereich |
| **Brown-Rifles** | 1.0–1.1 | Russen im oberen Bereich (Ausgleich für langsamere retrigger) |
| **DMR** | 1.1–1.2 | Semi-Auto-Sniper |
| **MG** | 1.4 | Maschinengewehre inkl. Fahrzeug-MGs |
| **Sniper** | 1.8–2.0 | Bolt-Action, .50 cal |
| **Rest** | 0.85 | Pistolen, Sonstiges |

---

## MP (0.6–1.0)

Unverändert – Werte bleiben waffenabhängig.

- p90, mp7, mp5sd, kriss_vector, scorpion-evo, steyr_tmp, mini_uzi
- qcw-05, aek_919k, bizon, ump40, mx4_storm, honey_badger, gun_tommy

---

## Rifles (0.8–1.1)

### Brown (oberer Bereich 1.0–1.1)

| Waffe | kill_prob | Begründung |
|-------|-----------|------------|
| AK47, AK47_w_gp25 | 1.1 | Ausgleich für retrigger 0.112 (vs G36 0.095) |
| AKS74u, AN94, Saiga12k | 1.0 | |
| PB (Pistole) | 0.95 | |

### Green/Grey (0.85–0.9)

- HK416, G36, M16A4, F2000, FAMAS, Steyr AUG, L85A2, SG552, XM8: **0.9**
- M16A4_support: **0.85**
- QBZ95, QBZ95_us, QBZ95_shotgun, QBS-09, Gilboa DBR, TTI: **0.9**

### Shotguns

- CAWS: **0.8** | Benelli_m4_supp, UTS15: **0.85**
- Benelli_m4, Mossberg, SPAS-12: **0.9**
- AA-12, Jackhammer, Origin-12: **0.85**

### Pistolen

- Glock17, Beretta, M712, Model_29: **0.85**
- Desert Eagle: **0.9**

---

## DMR (1.1–1.2)

- VSS Vintorez: **1.1**
- SCAR SSR, APR, G28, M14 EBR, Dragunov SVD, M4A1 Scope: **1.2**

---

## MG (1.4)

MG4, Stoner, Ultimax, PKM, M249, M240, Negev, MG42, RPK74m, RPK16, Pecheneg, etc.  
Fahrzeug-MGs: Buggy, Humvee, Tank, Technical, Wiesel, VFS, Patrol Ship.

---

## Sniper (1.8–2.0)

- M200: **2.0**
- Barrett M107: **1.8**
- PSG90, SV98, Lahti L39, M24 A2, Truvelo, NS2000: **1.8**

---

## Ausnahmen

- **taser_medic**, **pepperdust**: Unverändert (Stun-Mechanik)

---

## Anwendung

Skript: `scripts/apply-kill-probability.js`

```powershell
cd scripts
node apply-kill-probability.js
```
