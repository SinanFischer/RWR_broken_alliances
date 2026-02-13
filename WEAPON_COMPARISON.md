# Waffen-Vergleich der 3 Fraktionen (EU / US / Russia)

**Zweck:** Balance prüfen – pro Zeile ist der **beste** Wert **fett**.  
**Legende:** kill = kill_probability | RT = retrigger_time (s, niedriger = schneller) | **mag** = magazine_size (Schuss/Magazin) | com = commonness | **sight** = sight_range_modifier | **acc_factor** = Basis-Genauigkeit (höher = genauer) | **grow** = sustained_fire_grow_step (niedriger = bleibt länger präzise) | **diminish** = sustained_fire_diminish_rate (höher = schneller Erholung). Standard-AR/Pool-AR: Stances = base (0.85/0.9/0.93). Shotguns: kill_decay_start/end = Reichweite, ab der Schaden fällt (kürzer = weniger tödlich auf Distanz).

---

## 1. Standard-Sturmgewehre (Hauptwaffe Infanterie)

| Metrik | EU (G36) | US (M16A4) | RU (AK-74M) |
|--------|----------|------------|-------------|
| **kill** | 0.65 | 0.65 | **0.82** |
| **RT** (s) | **0.095** | 0.108 | 0.112 |
| **mag** | 30 | 30 | 30 |
| **com** | 0.22 | 0.22 | 0.22 |
| **sight** | 1.1 | 1.1 | – |
| **acc_factor** | 0.74 | **0.80** | 0.72 |
| **grow** | 0.38 | **0.26** | 0.40 |
| **diminish** | 1.15 | **1.22** | 1.12 |
| **Preis** | 16 | 16 | **15** |

→ **Balance:** **RU-Stärke:** AK-74M Kill 0.92. EU G36 schnellstes Feuer (0.095); M16 beste Accuracy (factor 0.80, niedrigster grow 0.26). Alle deutlich ungenauer als vorher; Stances = base.

---

## 2. Zusätzliche Sturmgewehre (Pool, ~40 RP)

| Metrik | EU (HK416) | US (M4A1) | RU (AKS-74U) |
|--------|------------|-----------|---------------|
| **kill** | **0.65** | **0.65** | 0.62 |
| **RT** (s) | 0.104 | 0.098 | **0.09** |
| **mag** | 36 | 30 | **38** |
| **com** | 0.025 | **0.3** | 0.046 |
| **sight** | 1.05 | **1.1** | 1.05 |
| **acc_factor** | 0.75 | **0.77** | 0.70 |
| **grow** | **0.32** | 0.36 | 0.40 |
| **diminish** | 1.18 | **1.28** | 1.10 |
| **Preis** | 40 | 40 | 40 |

→ **Balance:** HK416 niedrigster grow (0.32), Mag 36, Sight 1.05. M4A1 beste Accuracy (0.77), beste diminish (1.28). RU AKS-74U schnellstes Feuer (0.09), Mag 38. Alle deutlich ungenauer.

---

## 3. Premium-AR (teure Pool-Waffen, 100–150 RP)

| Metrik | EU (FAMAS G1) | US (XM8) | RU (SG 552) |
|--------|----------------|----------|-------------|
| **kill** | 0.65 | 0.72 | **0.95** |
| **RT** (s) | **0.092** | 0.115 | **0.108** |
| **mag** | 27 | **30** | **36** |
| **com** | **0.049** | 0.043 | 0.024 |
| **sight** | – | **1.15** | 1.1 |
| **standing** | 0.788 | **0.85** | 0.818 |
| **crouching** | 0.898 | **0.90** | 0.888 |
| **prone** | **0.938** | 0.92 | 0.948 |
| **Preis** | **100** | 150 | **80** |

→ **Balance:** RU SG 552 höchste kill (0.95), Sight 1.1; Stances reduziert. US XM8 kill 0.72, Sight 1.15. EU FAMAS schnellstes Feuer, höchste Commonness. RU SG 552: jetzt Vollauto (war Einzelschuss), schneller RT (0.108), Mobilität (walking/crouch_moving), CQB-Karabin.

---

## 4. Leicht-MG (5.56 / 5.45)

| Metrik | EU (MG4) | US (M249) | RU (RPK-74M) |
|--------|----------|-----------|--------------|
| **kill** | 0.52 | **0.58** | 0.56 |
| **RT** (s) | **0.075** | 0.092 | 0.10 |
| **mag** | 100 | **130** | 60 |
| **com** | 0.05 | 0.05 | 0.05 |
| **sight** | 1.2 | 1.2 | 1.2 |
| **standing** | 0.60 | 0.60 | **0.64** |
| **crouching** | **0.85** | **0.85** | 0.84 |
| **prone** | **0.95** | **0.95** | 0.92 |
| **Preis** | 80 | 80 | 80 |

→ **Balance:** EU MG4 schnellstes MG (0.075), US M249 höchste kill. MG4/M249 gleiche Stance-Accuracy; RPK-74M etwas bessere standing (0.64), geringere prone (0.92). **Sight-Bonus 1.2** für alle Leicht-MG (nur Liegen).

---

## 5. Schwer-MG (7.62) – EU ohne eigenes 7.62-MG

| Metrik | EU (IMI Negev) | US (M240) | RU (PKM) |
|--------|----------------|-----------|----------|
| **kill** | 0.58 | **0.89** | 0.82 |
| **RT** (s) | **0.072** | 0.12 | 0.12 |
| **mag** | **150** | 90 | 100 |
| **com** | 0.028 | 0.029 | **0.031** |
| **sight** | 1.2 | 1.2 | 1.2 |
| **standing** | **0.62** | – | 0.58 |
| **crouching** | 0.86 | **0.87** | **0.87** |
| **prone** | 0.94 | **1.0** | **1.0** |
| **Preis** | 60 | 60 | **50** |

→ **Balance:** US M240 mit Abstand höchste kill (0.89). M240/PKM nur crouch/prone (kein Stehend). EU Negev einziger mit standing (0.62); M240/PKM beste prone (1.0). **Sight-Bonus 1.2** für alle Schwer-MG (nur Liegen).

---

## 6. Scharfschützengewehre (Bolt-Action)

| Metrik | EU (G22/PSG90) | US (M24-A2) | RU (SV-98) |
|--------|----------------|-------------|------------|
| **kill** | **1.0** | **1.0** | **1.0** |
| **RT** (s) | 1.48 | 1.48 | 1.48 |
| **mag** | 10 | 10 | 10 |
| **com** | **0.038** | **0.038** | 0.01 |
| **sight** | **2.4** | 2.2 | 2.15 |
| **standing** | 0.92 | **0.96** | **0.96** |
| **crouching** | **0.96** | **0.98** | 0.97 |
| **prone** | 0.90 | **1.0** | **1.0** |
| **Preis** | 70 | 70 | **40** |

→ **Balance:** Alle drei One-Hit-Bolt (1.0). US M24 beste Stance-Werte (crouch 0.98, prone 1.0). EU G22 stärkster crouch (0.96), prone niedriger (0.90). RU SV-98 günstigster (40 RP).

---

## 7. DMR / Semi-Auto-Scharfschützen

| Metrik | EU (G28) | US (M14 EBR) | RU (Dragunov SVD) |
|--------|----------|--------------|-------------------|
| **kill** | **0.90** | **0.90** | **0.90** |
| **RT** (s) | **0.65** | 0.85 | 0.88 |
| **mag** | **20** | **20** | 16 |
| **com** | 0.01 | 0.01 | **0.04** |
| **sight** | 1.95 | 1.95 | **2.0** |
| **standing** | **0.92** | 0.80 | 0.78 |
| **crouching** | **0.95** | 0.85 | 0.88 |
| **prone** | **1.0** | 0.95 | 0.95 |
| **Preis** | 40 | 40 | 50 |

→ **Balance:** Alle drei gleiche kill (0.90). EU G28 schnellster Nachschuss (RT 0.65) und beste Stance-Accuracy (0.92 / 0.95 / 1.0). RU SVD höchste Commonness (0.04).

---

## 8. Shotguns

| Metrik | EU (SPAS-12) | US (Mossberg 500) | RU (QBS-09) |
|--------|--------------|-------------------|--------------|
| **kill** | **0.78** | **0.75** | **0.75** |
| **RT** (s) | – (Pump) | 0.51 | **0.40** |
| **mag** | 8 | 6 | **10** |
| **com** | **0.029** | **0.029** | 0.01 |
| **sight** | 1.0 | 1.0 | 1.0 |
| **acc_factor** | **0.42** | 0.40 | **0.42** |
| **standing** | **0.62** | 0.60 | **0.62** |
| **crouching** | **0.70** | 0.68 | **0.70** |
| **prone** | **0.76** | 0.74 | **0.76** |
| **Preis** | 30 | 30 | **2** |

→ **Balance:** EU SPAS-12 höchste kill (0.78), beste Accuracy (acc 0.42, Stances 0.62/0.70/0.76). US Mossberg niedrigster acc_factor (0.40) = stärkste Streuung. RU QBS-09 schnellstes Feuer (0.40), Mag 10, extrem günstig (2 RP). **Konzept:** Kurze Distanz tödlicher (kill 0.75–0.78), mittlere Distanz ungenauer (acc_factor 0.40–0.42 vs AR 0.72–0.80).

---

## 9. Kurzüberblick: Wer führt wo?

| Metrik | EU | US | RU |
|--------|----|----|-----|
| **Standard-AR Kill** | 0.65 | 0.65 | **0.92** (AK-74M) |
| **Standard-AR Preis** | 16 | 16 | **15** |
| **Höchste AR-Kill (Pool)** | 0.65 | 0.72 | **0.95** (SG 552) |
| **Höchste AR-Commonness** | 0.22 | **0.3** (M4A1) | 0.22 |
| **Günstigstes MG** | 60 | 60 | **50** |
| **Günstigster Sniper** | 70 | 70 | **40** |
| **Stärkster Bolt-Sniper (kill)** | **1.0** | **1.0** (M24) | **1.0** (SV-98) |
| **Stärkster DMR (kill)** | 0.90 | 0.90 | 0.90 |
| **Günstigste Shotgun** | 30 | 30 | **2** |

---

## 10. Stärken-Matrix: Gleichen sich die Fraktionen aus?

**Wichtig:** Preise (RP) betreffen nur den **Spieler-Shop**. Die **KI spawnt nach Fraktions-Pool**, nicht nach Preis – für **Kampf-/AI-Balance** zählen nur kill, RT, commonness (Drop-Häufigkeit), Reichweite etc. Preise daher **nicht** als Ausgleich für kampfschwächere Fraktionen zählen.

**Kurzantwort:** Ja – jede Fraktion hat 2–3 **kampfrelevante** Stärken.

| Fraktion | Stärken (kampfrelevant) | Nur Spieler (Preis) | Trade-off |
|----------|-------------------------|---------------------|-----------|
| **EU** | Schnellstes Standard-AR (G36), schnellstes Leicht-MG (MG4), **One-Hit Bolt (G22)**, schnellster DMR (G28 RT), beste Shotgun-Kill (SPAS) | – | Kein 7.62-MG; Premium-AR nicht stärkste Kill (SG 552 RU) |
| **US** | **One-Hit Bolt (M24)**, stärkstes Schwer-MG (M240), beste Leicht-MG-Kill (M249), höchste AR-Commonness (M4A1) | – | Standard-AR etwas langsamer als G36; DMR nicht schnellster; Premium-AR (XM8) nicht stärkste |
| **RU** | **Höchste Kill Standard-AR (AK-74M 0.92)**, **stärkste Premium-AR (SG 552 0.95)**, One-Hit Bolt (SV-98), schnellstes Pool-AR (AKS-74U), DMR am häufigsten (SVD), PKM stark (0.82 kill) | Günstigere Shop-Preise (für Menschen) | Pool-AR AKS-74U niedrigere Kill (0.62); langsamere Kadenz Standard-AR |

**Fazit:** Alle drei haben einen One-Hit-Bolt (EU G22, US M24, RU SV-98). RU-Stärken sind damit **kampfrelevant** (Bolt, schnellstes Pool-AR, SVD-Commonness, PKM), nicht nur „günstig im Shop“.

---

*Stand: aus den .weapon-Dateien des RWR Total Conversion Mod. RT = Sekunden zwischen Schüssen (kleiner = schneller). mag = magazine_size (Schuss pro Magazin). sight = sight_range_modifier (höher = weitere Sicht). Accuracy: acc_factor = Basis-Streuung (höher = genauer), Stances = Genauigkeit pro Haltung (standing/crouching/prone). „–“ = in .weapon nicht gesetzt (Basis-Standard).*
