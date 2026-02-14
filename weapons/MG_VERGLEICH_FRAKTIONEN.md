# MG-Vergleich: 2 MGs pro Fraktion

Jede Fraktion hat **1 Leicht-MG** (5.56/5.45) und **1 Schwer-MG** (7.62). EU hat im Mod nur MG4 als Standard-MG (kein 7.62 eigener Bauart).

---

## Tabelle 1 - Leichtes MG (5.56 / 5.45)

| Eigenschaft        | **EU - MG4**   | **US - M249 Para** | **RU - RPK-74M**   |
|--------------------|----------------|--------------------|--------------------|
| **Kaliber**        | 5.56×45        | 5.56×45            | 5.45×39            |
| **retrigger_time** | **0.075**      | 0.092              | 0.10               |
| **Kadenz (rpm)**   | **~800**       | ~652               | ~600               |
| **accuracy_factor**| 0.88           | 0.88               | 0.86               |
| **magazine_size**  | 100            | **130**            | 60                 |
| **kill_probability** | **0.52**    | 0.58               | 0.56               |
| **projectile_speed** | 93            | 92                 | 100                |
| **encumbrance**    | **9**          | 10                 | **5**              |
| **speed modifier** | **-0.11**     | -0.12              | **-0.06**          |
| **prone accuracy** | 0.95           | 0.95               | 0.92               |

**Gefühl:** MG4 feuert **deutlich schneller** (800 vs. 652/600 rpm); Kill-Wahrscheinlichkeit leicht reduziert (0.52) zur Balance. M249 kompensiert mit **mehr Magazin** (130), ist aber am schwersten (enc 10, -12 % Lauf). RPK-74M **am leichtesten** (enc 5, -6 % Lauf) und damit am mobilsten, bei kürzeren Garben (60 Schuss).


---

## Tabelle 2 - Schweres MG (7.62)

| Eigenschaft        | **EU**      | **US - M240** | **RU - PKP Pecheneg** |
|--------------------|------------|---------------|------------------------|
| **Kaliber**        | -          | 7.62 NATO     | 7.62×54R               |
| **retrigger_time** | -          | 0.12          | 0.12                   |
| **Kadenz (rpm)**   | -          | ~500          | ~500                   |
| **accuracy_factor**| -          | 0.90          | 0.90                   |
| **magazine_size**  | -          | 90            | 100                    |
| **kill_probability** | -        | **0.89**      | 0.82                   |
| **projectile_speed** | -        | 108           | 108                    |
| **encumbrance**    | -          | **13**        | **9**                   |
| **speed modifier** | -          | **-0.16**     | **-0.11**               |
| **prone accuracy** | -          | 1.0           | 1.0                    |

**Gefühl:** M240 ist **deutlich schwerer** (enc 13, **-16 % Lauf**) und bremst stark; PKP leichter (enc 9, -11 % Lauf) und mobiler. M240 hat **mehr Kill-Wahrscheinlichkeit** (0.89 vs. 0.82), PKP größeres Magazin (100 vs. 90). EU hat im Mod kein eigenes 7.62-MG.

---

## Warum die MG4 sich stark anfühlt

- **Höchste Kadenz** unter den Leicht-MGs: 0.075 s → ~800 rpm (M249 ~652, RPK ~600).
- **kill_probability** leicht unter M249 (0.52 vs. 0.58), **accuracy_factor** (0.88) gleich.
- **Sustained fire** identisch mit M249 (0.09 / 0.78) → Dauerfeuer verzeihend.
- **Magazin 100** reicht für lange Garben; nur M249 hat mehr (130), feuert aber langsamer.

**Fazit:** Die MG4 war die DPS-stärkste Option; **Kill-Wahrscheinlichkeit auf 0.52 reduziert** → mehr Treffer nötig, weniger Dominanz trotz hoher Kadenz.

---

## Vorschlag Balance (optional)

- **MG4** etwas entschärfen: `retrigger_time` **0.075 → 0.085** (~705 rpm), damit sie zwischen M249 und Negev liegt und nicht alle übertrifft.
- Oder **M249** etwas anheben: `retrigger_time` **0.092 → 0.085**, damit US/EU-Leicht-MGs gefühlt gleichauf sind und die MG4 nicht allein durch RoF dominiert.

Wenn du willst, kann ich eine der beiden Varianten konkret in den Weapon-Dateien umsetzen.
