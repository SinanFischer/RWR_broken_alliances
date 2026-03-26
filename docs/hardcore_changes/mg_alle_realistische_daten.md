# Alle MGs im Mod – Reale Daten & RWR-Parameter

Recherche aller **Infanterie-MGs** in RWR Broken Alliances. Ausgeschlossen: microgun, minigun_ai (Fahrzeugwaffen), qlz87_b (Granatwerfer).

---

## Übersicht: MGs im Mod

| Waffe | Kaliber | Fraktion | Datei |
|-------|---------|----------|-------|
| MG4 | 5.56×45 NATO | Green | mg4.weapon |
| M249 Para | 5.56×45 NATO | Green | m249.weapon |
| M240 | 7.62×51 NATO | Green | m240.weapon |
| IMI Negev | 5.56×45 NATO | Green | imi_negev.weapon |
| Stoner LMG | 5.56×45 NATO | Green | stoner_lmg.weapon |
| Ultimax 100 | 5.56×45 NATO | Green | ultimax.weapon |
| M1917 Savage-Lewis | .30-06 | Green | m1917_savage_lewis.weapon |
| PKP Pecheneg | 7.62×54R | Brown | pkm.weapon |
| Pecheneg Bullpup | 7.62×54R | Brown | pecheneg_bullpup.weapon |
| MG-42 | 7.92×57 Mauser | Brown | mg42.weapon |
| RPK-74M | 5.45×39 | Brown | rpk74m.weapon |
| RPK16 / RPK16 long | 5.45×39 | Brown | rpk16.weapon, rpk16_long.weapon |
| QJZ-89 Volk | 12.7×108 | Brown | qjz89_volk.weapon |
| MG-08 Heavy CustoM22 | 5.56×45 (Ares Shrike) | Grey | mg08_heavy_custom22.weapon |

---

## 1. MG4 (HK123)

**Reale Daten:**

| Merkmal | Realwert |
|---------|----------|
| Kaliber | 5.56×45 mm NATO |
| Feuerrate | 890 (±60) Schuss/min |
| Mündungsgeschwindigkeit | 920 m/s |
| Leergewicht | 8,15 kg |
| Effektive Reichweite | ~1.000 m |
| Magazin | M27-Gurt (100–200 Schuss) |
| Besonderheiten | Schnellwechsel-Lauf, luftgekühlt |

**RWR aktuell:** retrigger 0.0674 · mag 100 · accuracy 0.84 · proj_speed 143 · enc 9 · speed -0.11 · Preis 27

**Abweichung:** projectile_speed 143 vs. real 920 m/s (RWR-Skalierung). retrigger ≈ 710 RPM (real 890).

---

## 2. M249 Para (FN Minimi)

**Reale Daten:**

| Merkmal | Realwert |
|---------|----------|
| Kaliber | 5.56×45 mm NATO |
| Feuerrate | 750–850 Schuss/min |
| Mündungsgeschwindigkeit | 915 m/s |
| Leergewicht | 7,5 kg |
| Effektive Reichweite | 800–1.000 m |
| Magazin | 200-Schuss-Gurt, STANAG-Magazine |
| Besonderheiten | Leichtes SAW, offener Verschluss |

**RWR aktuell:** retrigger 0.075 · mag 200 · accuracy 0.84 · proj_speed 142 · enc 10 · speed -0.12 · Preis 28

---

## 3. M240 (FN MAG)

**Reale Daten:**

| Merkmal | Realwert |
|---------|----------|
| Kaliber | 7.62×51 mm NATO |
| Feuerrate | 600–650 Schuss/min |
| Mündungsgeschwindigkeit | 853 m/s |
| Leergewicht | 12,3 kg |
| Effektive Reichweite | 800 m (Punkt), 1.800 m (Fläche) |
| Magazin | Gurt 100–200 Schuss |
| Besonderheiten | GPMG, schwer, hohe Wirkung pro Treffer |

**RWR aktuell:** retrigger 0.08 · mag 100 · accuracy 0.86 · proj_speed 158 · enc 13 · speed -0.16 · Preis 22

---

## 4. IMI Negev

**Reale Daten:**

| Merkmal | Realwert |
|---------|----------|
| Kaliber | 5.56×45 mm NATO |
| Feuerrate | 850–1.050 Schuss/min (wählbar) |
| Mündungsgeschwindigkeit | 915 m/s |
| Leergewicht | 7,4–7,65 kg |
| Effektive Reichweite | 600–1.000 m |
| Magazin | Gurt, STANAG |
| Besonderheiten | Leicht, hohe Kadenz |

**RWR aktuell:** retrigger 0.0632 · mag 150 · accuracy 0.85 · proj_speed 143 · enc 8 · speed -0.095 · Preis 20

---

## 5. Stoner LMG (Stoner 63 / Mk 23 Mod 0)

**Reale Daten:**

| Merkmal | Realwert |
|---------|----------|
| Kaliber | 5.56×45 mm NATO |
| Feuerrate | 700–1.000 Schuss/min (LMG/MMG); XM207 mit Rate Regulator ~800 RPM |
| Mündungsgeschwindigkeit | 991 m/s (20″ Lauf) |
| Leergewicht | 5,3 kg (LMG) |
| Effektive Reichweite | 200–1.000 m |
| Magazin | 75–150 Schuss Gurt/Trommel |
| Besonderheiten | Modulares System, offener Verschluss, SEALs Vietnam |

**RWR aktuell:** retrigger 0.06 · mag 150 · accuracy 0.92 · proj_speed 160 · enc 5 · speed -0.07 · Preis 245

**Besonderheit:** Höchste accuracy_factor (0.92), leichtestes MG (enc 5), kann kniend schießen.

---

## 6. Ultimax 100

**Reale Daten:**

| Merkmal | Realwert |
|---------|----------|
| Kaliber | 5.56×45 mm NATO |
| Feuerrate | 400–600 Schuss/min (520 typisch) |
| Mündungsgeschwindigkeit | 970 m/s |
| Leergewicht | 4,7–4,9 kg |
| Effektive Reichweite | 460 m (Standard), 600 m (Langlauf) |
| Magazin | 100-Schuss-Trommel, 20/30 STANAG |
| Besonderheiten | **Constant Recoil** (patentiert), sehr leicht, geringe Kadenz |

**RWR aktuell:** retrigger 0.12 · mag 100 · accuracy 0.85 · proj_speed 158 · sustained_fire_grow_step **-0.15** · sustained_fire_diminish_rate **-1.2** · enc 10 · speed -0.1 · Preis 135

**RWR-Sonderfall:** Negative sustained_fire = Constant Recoil (Genauigkeit bleibt beim Dauerfeuer). Kann stehend/kniend schießen.

---

## 7. M1917 Savage-Lewis

**Reale Daten:**

| Merkmal | Realwert |
|---------|----------|
| Kaliber | .30-06 Springfield |
| Feuerrate | 500–600 Schuss/min |
| Mündungsgeschwindigkeit | 744 m/s |
| Leergewicht | ~13 kg (ohne Magazin) |
| Effektive Reichweite | 880 yards (~805 m) |
| Magazin | 47- oder 97-Schuss-Panmagazin |
| Besonderheiten | Gasbetrieben, offener Verschluss, WWI |

**RWR aktuell:** retrigger 0.10 · mag 165 · accuracy 0.82 · proj_speed 100 · sustained_fire 0.02/0.12 · cooldown 0.64/0 · enc 11 · speed -0.20 · Preis 58

**Besonderheit:** Kaum Streuungsanstieg (grow 0.02), Cooldown (Überhitzung), flexibel in allen Stances.

---

## 8. PKP Pecheneg (pkm.weapon)

**Reale Daten:**

| Merkmal | Realwert |
|---------|----------|
| Kaliber | 7.62×54 mm R |
| Feuerrate | 600–800 Schuss/min |
| Mündungsgeschwindigkeit | 825 m/s |
| Leergewicht | 8,2 kg (ohne Zweibein 8,7 kg) |
| Effektive Reichweite | 1.500 m |
| Magazin | 100/200/250-Schuss-Gurt |
| Besonderheiten | Verbesserte PKM, luftgekühlt mit Rippenlauf, kein Laufwechsel nötig (25.000 Schuss Lebensdauer) |

**RWR aktuell:** retrigger 0.0857 · mag 100 · accuracy 0.86 · proj_speed 158 · enc 9 · speed -0.11 · Preis 18

*Hinweis: Mod nutzt PKP-Modell (pkp.xml), Name „PKP Pecheneg“.*

---

## 9. Pecheneg Bullpup

**Reale Daten:** Bullpup-Variante des PKP Pecheneg – kompakter, gleiches Kaliber 7.62×54R. Keine offizielle Serienproduktion bekannt; Konzept/Prototyp.

**RWR aktuell:** retrigger 0.0857 · mag 100 · accuracy 0.88 · proj_speed 158 · sustained_fire 0.22/0.52 · enc 8 · speed -0.095 · Preis 500

**Besonderheit:** Kann kniend/liegend präzise schießen, bessere sustained_fire als Standard-PKP.

---

## 10. MG-42

**Reale Daten:**

| Merkmal | Realwert |
|---------|----------|
| Kaliber | 7.92×57 mm Mauser |
| Feuerrate | 1.200–1.500 Schuss/min |
| Mündungsgeschwindigkeit | 755 m/s (Standard) |
| Leergewicht | 11,6 kg |
| Effektive Reichweite | 1.000 m (Zweibein), 2.000 m (Lafette) |
| Magazin | 50-Schuss-Gurt, 250-Schuss-Trommel |
| Besonderheiten | **Schnellfeuer**, Laufwechsel nach 150–250 Schuss (Hitze) |

**RWR aktuell:** retrigger 0.05 · mag 250 · accuracy 0.72 · proj_speed 170 · sustained_fire 0.25/0.65 · enc 10 · speed -0.12 · Preis 570

**Besonderheit:** Schnellstes MG (0.05 retrigger ≈ 1.200 RPM), hohe Kadenz, Hocke ungenau (0.32), Liegen präzise (0.72).

---

## 11. RPK-74M

**Reale Daten:**

| Merkmal | Realwert |
|---------|----------|
| Kaliber | 5.45×39 mm |
| Feuerrate | 600–650 Schuss/min |
| Mündungsgeschwindigkeit | 960 m/s |
| Leergewicht | 4,76 kg |
| Effektive Reichweite | 1.000 m |
| Magazin | 45-Schuss-Magazin (kein Gurt) |
| Besonderheiten | Magazin-LMG, leichter als Gurt-MGs |

**RWR aktuell:** retrigger 0.10 · mag 60 · accuracy 0.84 · proj_speed 150 · enc 5 · speed -0.06 · Preis 24

**Abweichung:** Mod nutzt 60-Schuss-Magazin (real 45); leichtestes MG mit G36-Standard (enc 5).

---

## 12. RPK-16

**Reale Daten:**

| Merkmal | Realwert |
|---------|----------|
| Kaliber | 5.45×39 mm |
| Feuerrate | 700 Schuss/min |
| Mündungsgeschwindigkeit | 900 m/s (550 mm Lauf) |
| Leergewicht | 4,5 kg (ohne Magazin) |
| Effektive Reichweite | 800 m |
| Magazin | 30-Schuss-Box, 95–96-Schuss-Trommel |
| Besonderheiten | Wechselbare Läufe (550 mm / 370 mm), modernes LMG |

**RWR aktuell (Kurz):** retrigger 0.085 · mag 74 · accuracy 0.9 · proj_speed 146 · enc 10 · speed -0.06 · Preis 64

**RWR aktuell (Lang):** retrigger 0.085 · mag 96 · sustained_fire 0.15/0.7 · proj_speed 148 · enc 10 · speed -0.12 · Preis 78

**Besonderheit:** next_in_chain = Laufwechsel (Kurz ↔ Lang). Kann stehend/kniend schießen.

---

## 13. QJZ-89 „Volk“

**Reale Daten:**

| Merkmal | Realwert |
|---------|----------|
| Kaliber | 12,7×108 mm |
| Feuerrate | 450–600 Schuss/min |
| Mündungsgeschwindigkeit | 825–850 m/s |
| Leergewicht | 17,5 kg |
| Effektive Reichweite | 1.500 m |
| Magazin | 50-Schuss-Gurt |
| Besonderheiten | Leichtestes 12,7-mm-HMG, Leichtlauf überhitzt bei Dauerfeuer |

**RWR aktuell:** retrigger 0.15 · mag 100 · proj_speed 115 · **blast** damage 0.4 radius 2.2 · cooldown 2.0/0.5 · enc 10 · speed -0.55 · Preis 55

**RWR-Sonderfall:** Nutzt `result class="blast"` (Splash), nicht `hit`. Tödlichkeit über `damage`, nicht `kill_probability`. Siehe [qjz89_volk_realistische_daten.md](./qjz89_volk_realistische_daten.md).

---

## 14. MG-08 Heavy CustoM22

**Mod-Kontext:** Nutzt **Ares Shrike**-Modell (5.56 mm), nicht das historische MG 08 (7.92 mm). Fiktive Mischung aus historischem Namen und moderner Technik.

**Ares Shrike (reale Referenz):**

| Merkmal | Realwert |
|---------|----------|
| Kaliber | 5.56×45 mm NATO |
| Feuerrate | 625–1.000 Schuss/min |
| Mündungsgeschwindigkeit | ~915 m/s |
| Leergewicht | ~3,4 kg (Oberteil) |
| Magazin | M27-Gurt, STANAG, Beta C-Mag |
| Besonderheiten | AR-Oberteil-Umrüstung, Gurtzuführung |

**RWR aktuell:** retrigger 0.075 · last_burst_retrigger 0.1 · mag 100 · accuracy 0.92 · burst_shots 6 · proj_speed **120** · sustained_fire 0.7/0.5 · enc 10 · speed -0.07 · Preis 60

**Besonderheit:** Burst-Modus (6 Schuss), next_in_chain zu ares_shrike_s.weapon. Niedrige projectile_speed (120) = Balancing.

---

## Zusammenfassung: Real → RWR Mapping

| Parameter | Real | RWR-Skalierung |
|-----------|------|----------------|
| **retrigger_time** | 60 / RPM (Sekunden) | Direkt: 0.05 (1200 RPM) … 0.15 (400 RPM) |
| **projectile_speed** | m/s | RWR: 100–170 (nicht 1:1; Engine-Skalierung) |
| **magazine_size** | Schuss | Direkt |
| **encumbrance** | kg × ~0.8–1.2 | Grobe Orientierung |
| **modifier speed** | Gewicht/Mobilität | -0.06 (leicht) … -0.55 (sehr schwer) |
| **sustained_fire** | Rückstoß/Kontrolle | grow_step niedriger = besser; diminish höher = besser |
| **cooldown** | Laufüberhitzung | start/end in Sekunden |

---

## Preisübersicht (Formel v2 vs. aktuell)

| MG | Waffenwert (Formel) | Preis (formel) | Preis (aktuell) | Anmerkung |
|----|---------------------|----------------|-----------------|-----------|
| MG4 | (Anker) 0.647 | 43 | 27 | Anker |
| M249 | 0.694 | 45 | 28 | |
| M240 | 0.652 | 43 | 22 | |
| PKP Pecheneg | 0.635 | 42 | 18 | |
| MG42 | 0.732 | 46 | **570** | Legacy-Preis |
| Stoner LMG | 0.741 | 47 | **245** | Legacy-Preis |
| Ultimax | 0.467 | 35 | 135 | Constant Recoil-Bonus |
| Negev | 0.717 | 46 | 20 | |
| RPK74m | 0.513 | 37 | 24 | |
| RPK16 | – | – | 64 | next_in_chain |
| RPK16 long | – | – | 78 | next_in_chain |
| Pecheneg Bullpup | 0.599 | 41 | **500** | Legacy-Preis |
| MG-08 Heavy | 0.444 | 34 | 60 | Burst, niedrige proj_speed |
| QJZ-89 Volk | – | – | 55 | 12,7 mm, blast, eigener Pool |
| M1917 Savage-Lewis | – | – | 58 | Cooldown, Suppression-Master |

---

## Angewendete Änderungen (Stand)

| MG | kill_prob | enc | retrigger | mag | speed | cooldown | Gewicht (kg) |
|----|-----------|-----|-----------|-----|-------|----------|--------------|
| Ultimax | 1.35 | 5 | 0.12 | 100 | **-0.05** | – | 4.7 |
| RPK74m | 1.35 | 5 | 0.10 | 60 | **-0.05** | – | 4.76 |
| RPK16 | 1.35 | 6 | 0.085 | 74 | **-0.05** | – | 4.5 |
| Stoner | 1.35 | 5 | 0.06 | 150 | **-0.06** | – | 5.3 |
| MG-08 Heavy | 1.35 | 10 | 0.075 | 100 | **-0.06** | – | ~5 (Shrike) |
| RPK16 long | 1.35 | 6 | 0.085 | 96 | **-0.08** | – | ~5.5 |
| M249 | 1.35 | 8 | 0.075 | 200 | **-0.09** | – | 7.5 |
| Negev | 1.35 | 8 | 0.0632 | 150 | **-0.09** | – | 7.4 |
| Pecheneg Bullpup | 1.45 | 8 | 0.0857 | 100 | **-0.09** | – | 8.2 (kompakt) |
| MG4 | 1.35 | 8 | 0.0674 | 100 | -0.11 | – | 8.15 |
| PKP Pecheneg | 1.45 | 9 | 0.0857 | 100 | -0.11 | – | 8.2 |
| MG42 | 1.45 | 10 | 0.05 | 250 | **-0.14** | 1.5/0.5 | 11.6 |
| M240 | 1.45 | 13 | 0.08 | 100 | **-0.17** | – | 12.3 |
| M1917 | 1.4 | 11 | 0.10 | 165 | **-0.18** | 0.64/0 | 13 |
| QJZ-89 | blast 1.0 | 18 | 0.11 | 50 | -0.55 | 2.0/0.5 | 17.5 |

**Speed-Modifier:** Gewicht + Handlichkeit. Leichteste MGs (Ultimax, RPK) -0.05; schwerste (M240, M1917) -0.17 bis -0.18; QJZ-89 -0.55.

---

## Nächste Schritte

1. **Preisanpassung:** MG42, Stoner, Pecheneg Bullpup – Formel liefert 41–47 RP; aktuelle Preise sind Legacy.
2. **QJZ-89:** projectile_speed 115 vs. real 850 – RWR-Skalierung prüfen.
3. **MG-08 Heavy:** Mod nutzt Shrike-Modell (5.56 mm).
