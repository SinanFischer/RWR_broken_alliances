# Kill-Probability-Regelwerk

**kill_probability** = Wahrscheinlichkeit, dass ein Treffer sofort tötet (1.0 = 100 %). Werte > 1.0 = garantierter Tod + Überpenetration (Westen, leichte Deckung).

**Referenz:** Realistische Werte nach Kaliber. 7.62×51/54R durchschlagen Westen zuverlässig → Werte oben lassen oder leicht erhöhen. 12.7 mm tötet definitiv → kill_prob 3.0 (hit) bzw. blast damage 1.0 (QJZ-89).

---

## Referenz: Kill-Probability nach Kaliber (realistisch)

| Kaliber | Rifle/DMR | MG | Sniper/Blast | Begründung |
|---------|-----------|-----|--------------|------------|
| **9×19 mm** | 0.70–0.85 | – | – | Geringe Energie |
| **5.56×45 NATO** | 0.85–0.95 | 1.3–1.4 | – | Kleinkaliber, Tumbling |
| **5.45×39** | 0.90–1.0 | 1.3–1.4 | – | Ähnlich 5.56 |
| **7.62×39** | 1.0–1.1 | – | – | Höhere Energie |
| **7.62×51 NATO** | 1.1–1.2 | 1.4–1.5 | 1.8 | Westen-Durchschlag |
| **7.62×54R** | 1.1–1.2 | 1.4–1.5 | 1.8 | Westen-Durchschlag |
| **7.92×57 Mauser** | – | 1.4–1.5 | – | MG-42 |
| **.30-06** | – | 1.4 | – | M1917 Lewis |
| **12.7×108 / .50 BMG** | – | – | **3.0** (hit) / **1.0** (blast) | Definitiv tödlich |

---

## Übersicht (angepasste Zielwerte)

| Kategorie | Bereich | Beschreibung |
|-----------|---------|--------------|
| **MP** | 0.65–1.0 | Maschinenpistolen/PDWs |
| **Rifles (5.56)** | 0.85–0.95 | NATO-Sturmgewehre |
| **Rifles (5.45)** | 0.90–1.0 | AK-74-Familie |
| **Rifles (7.62×39)** | 1.0–1.1 | AK-47 |
| **DMR** | 1.1–1.2 | Semi-Auto-Sniper |
| **MG (5.56)** | 1.3–1.4 | Leichte MGs |
| **MG (7.62)** | 1.4–1.5 | GPMG, Westen-Durchschlag |
| **Sniper (7.62)** | 1.8 | Bolt-Action |
| **Sniper (12.7)** | **3.0** | Barrett, Truvelo – definitiv tödlich |
| **12.7 Blast (QJZ-89)** | damage **1.0** | Splash statt hit |

---

## MP (0.65–1.0)

| Kaliber | kill_prob | Waffen |
|---------|-----------|-------|
| 9 mm | 0.70–0.80 | Glock, Beretta, MP5, UMP |
| 5.7 mm | 0.75–0.85 | P90 |
| .300 BLK subsonic | 0.50 | Honey Badger |
| .45 ACP | 0.75–0.85 | Tommy Gun |

---

## Rifles (0.85–1.1)

### 5.56 NATO (0.85–0.95)

- HK416, G36, M16A4, F2000, FAMAS, Steyr AUG, L85A2, SG552, XM8: **0.90**
- M16A4_support: **0.85**
- QBZ95, Gilboa DBR, TTI: **0.90**

### 5.45×39 (0.90–1.0)

- AKS74u, AN94, AK-74M (ak47.weapon), AK-74 GP25 (ak47_w_gp25.weapon): **1.0**
- RPK-74M (MG): siehe MG

### 7.62×39 (1.0–1.1)

- AK-47 (falls echtes 7.62×39): **1.1**

### Shotguns

- CAWS: **0.80** | Benelli_m4_supp, UTS15: **0.85**
- Benelli_m4, Mossberg, SPAS-12: **0.90**
- AA-12, Jackhammer, Origin-12: **0.85**

### Pistolen

- Glock17, Beretta, M712, Model_29: **0.85**
- Desert Eagle: **0.90**
- PB: **0.95**

---

## DMR (1.1–1.2)

- VSS Vintorez (9×39): **1.1**
- SCAR SSR, APR, G28, M14 EBR, Dragunov SVD, M4A1 Scope: **1.2**

---

## MG (1.3–1.5)

| Kaliber | kill_prob | Waffen |
|---------|-----------|-------|
| 5.56 NATO | 1.3–1.4 | MG4, M249, Negev, Stoner, Ultimax |
| 5.45×39 | 1.3–1.4 | RPK74m, RPK16 |
| 7.62×51 | 1.4–1.5 | M240 |
| 7.62×54R | 1.4–1.5 | PKM, Pecheneg |
| 7.92×57 | 1.4–1.5 | MG-42 |
| .30-06 | 1.4 | M1917 Savage-Lewis |

*7.62-MGs: Westen-Durchschlag → Werte oben lassen oder 1.5.*

---

## Sniper (1.8–3.0)

| Kaliber | kill_prob | Waffen |
|---------|-----------|-------|
| 7.62 NATO | 1.8 | PSG90, M24, SV98 |
| .338 / 8.6 mm | 1.8 | NS2000 |
| 20 mm | 1.5 (blast) | Truvelo AMR |
| **12.7×108 / .50 BMG** | **3.0** | Barrett M107 |

*12.7 mm: Definitiv tödlich → kill_prob 3.0 (oder höher).*

---

## 12.7 mm – Sonderfall QJZ-89 (Blast)

QJZ-89 nutzt `result class="blast"` statt `hit`. Tödlichkeit über **damage**, nicht kill_probability.

| Parameter | Aktuell | Ziel (realistisch) |
|-----------|---------|---------------------|
| blast damage | 0.4 | **1.0** |
| blast radius | 2.2 | 2.2 (bleibt) |

*12.7 mm trifft → definitiv tödlich. damage 1.0 = garantierter Kill bei Treffer.*

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
