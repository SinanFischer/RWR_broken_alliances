# Snipers, MPs, DMRs & Vehicle/Deployable MGs – Reale Daten & RWR-Parameter

Recherche und Anpassung analog zu `mg_alle_realistische_daten.md` und `rifles_alle_realistische_daten.md`.

**Ausnahmen:** Shotguns, Anti-Tank-Waffen (RPG, Javelin, etc.)

---

## 1. SNIPER (Bolt-Action & Präzisionsgewehre)

| Waffe | Kaliber | Mündungsgeschw. (m/s) | Gewicht (kg) | Magazin | kill_prob | Änderungen |
|-------|---------|------------------------|--------------|---------|-----------|------------|
| Barrett M107 | .50 BMG | 853 | 14 | 10 | 3.0 | ✓ bereits korrekt |
| PSG90 (G22) | 7.62 NATO | ~850 | 5.5 | 10 | 1.8 | ✓ |
| M24-A2 | 7.62 NATO | ~850 | 5.4 | 10 | 1.8 | ✓ |
| SV-98 | 7.62×54R | ~830 | 5.5 | 10 | 1.8 | enc 12→6 |
| CheyTac M200 | .408 CheyTac | 838 | 12 | 7 | 2.0 | ✓ |

---

## 2. DMR (Designated Marksman Rifle)

| Waffe | Kaliber | kill_prob | Änderungen |
|-------|---------|-----------|------------|
| SCAR SSR | 7.62 NATO | 1.2 | ✓ |
| M14 EBR | 7.62 NATO | 1.2 | ✓ |
| G28 | 7.62 NATO | 1.2 | ✓ |
| APR | .338 Lapua | 1.2 | ✓ |
| Dragunov SVD | 7.62×54R | 1.2 | ✓ |
| M4A1 Scope | 5.56 NATO | 1.2 | ✓ |
| VSS Vintorez | 9×39 subsonic | 1.1 | ✓ |

---

## 3. MP (Maschinenpistolen / PDW)

| Waffe | Kaliber | kill_prob | proj_speed | enc | Änderungen |
|-------|---------|-----------|------------|-----|------------|
| MP7 | 4.6×30mm | 0.80 | 131 | 2 | kill 0.80, proj 131, enc 2 |
| MP5SD | 9×19 subsonic | 0.75 | **90** (min) | 2 | kill 0.75, proj min 90 |
| P90 | 5.7×28mm | 0.80 | 130 | 2 | kill 0.80, proj 130 |
| Scorpion Evo III | 9×19 | 0.75 | **90** (min) | 2 | kill 0.75, proj min 90 |
| KRISS Vector | .45 ACP | 0.80 | **90** (min) | 3 | kill 0.80, proj min 90 |
| Tommy Gun | .45 ACP | 0.80 | **90** (min) | 5 | kill 0.80, proj min 90 |
| AEK-919K | 9×18 Makarov | 0.75 | **90** (min) | 2 | kill 0.75, proj min 90 |
| QCW-05 | 5.8×21 subsonic | 0.75 | **90** (min) | 2 | kill 0.75, proj min 90 |

*proj_speed mind. 90 für visuell akzeptable Fluggeschwindigkeit (Kugeln nicht sichtbar fliegend).*

*RWR projectile_speed Skala: real m/s ÷ 5.5 (analog zu Rifles)*

---

## 4. VEHICLE / DEPLOYABLE MGs

| Waffe | Typ | Kaliber | retrigger (RPM) | kill_prob | proj_speed | Änderungen |
|-------|-----|---------|-----------------|-----------|------------|------------|
| deployable_mg | Deployable | 7.62 NATO | 0.096 (625) | 1.4 | 165 | retrigger 0.07→0.096 |
| humvee_mg | Fahrzeug | 7.62 NATO (M240) | 0.096 (625) | 1.4 | 158 | retrigger 0.08→0.096, proj 153→158 |
| buggy_mg | Fahrzeug | 7.62 NATO | 0.1 (600) | 1.4 | 158 | proj 160→158 |
| tank_mg | Fahrzeug | 7.62 NATO | 0.08 (750) | 1.4 | 158 | retrigger 0.054→0.08, proj 240→158 |
| technical_mg | Fahrzeug | 7.62 NATO | 0.1 (600) | 1.4 | 158 | retrigger 0.12→0.1, proj 160→158 |
| patrol_ship_mg | Schiff | 7.62 NATO (M240) | 0.096 (625) | 1.4 | 158 | retrigger 0.112→0.096, proj 155→158 |
| wiesel_mg3 | Fahrzeug | 7.62 NATO (MG3) | 0.05 (1200) | 1.5 | 158 | retrigger 0.06→0.05, kill 1.5, proj 158 |
| vfs_buggy_mg | Fahrzeug | 12.7 mm (.50) | 0.1 (600) | 2.5 | 155 | kill 2.5, proj 155 |
| tank_mg_1 | Fahrzeug | 7.62 NATO | 0.092 (652) | 1.4 | 158 | proj 160→158 |
| tank_mg_2 | Fahrzeug | 7.62 NATO | 0.08 (750) | 1.4 | 158 | retrigger 0.072→0.08, proj 370→158 |
| vulcan_tank_mg | Fahrzeug | 7.62 NATO (Minigun) | 0.02 (3000) | 1.4 | 155 | retrigger 0.04→0.02 |

**Sonderfall Sniper (manuell getragen):**
| gepard_m6_lynx | Sniper | .50 BMG (M6 Lynx) | 3.0 | 155 | kill 1.4→3.0, proj 150→155 |

*Wiesel MG3: 7.62 NATO (MG3), `bullet.projectile`, kill 1.25.*  
*vfs_buggy_mg: wie Buggy-MG, `bullet.projectile`, kill 1.4 (kein .50).*

**Deployable / Spezial-MGs:**
| deployable_minig | Deployable | 7.62 NATO (Minigun) | 0.02 (3000) | 1.4 | 158 | retrigger 0.0387→0.02, kill 1.4, proj 158 |
| microgun | Infanterie | 5.56 NATO (WB-II) | – | 1.4 | 170 | kill 0.85→1.4 |
| minigun_ai | AI/Fahrzeug | 7.62 NATO (M134/GAU-17) | – | 0.88 | 150 | `bullet.projectile`, kill 0.88, proj 150 |

---

## RWR-Parameter-Mapping (MPs)

### projectile_speed (real m/s ÷ 5.5)

| Kaliber | Real (m/s) | RWR |
|---------|------------|-----|
| 4.6×30 | 720 | 131 |
| 5.7×28 | 715 | 130 |
| 9×19 | 370 | 67 |
| 9×19 subsonic | 285 | 52 |
| 9×18 Makarov | 315 | 57 |
| .45 ACP | 280 | 51 |
| 5.8×21 subsonic | 150 | 27 |

### kill_probability (nach Kaliber)

| Kaliber | kill_prob |
|---------|-----------|
| 4.6 mm | 0.75–0.80 |
| 5.7 mm | 0.75–0.85 |
| 9 mm | 0.70–0.80 |
| 9×18 Makarov | 0.70–0.75 |
| .45 ACP | 0.75–0.85 |
| 5.8 mm subsonic | 0.75 |
