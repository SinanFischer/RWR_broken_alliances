# Capacity & Slots-per-Death – faires Konzept (8 Formel-Varianten)

---

## Slots per Death nach **eigener** Capacity der sterbenden Fraktion (aktuell implementiert)

**Idee:** Pro Tod verliert eine Fraktion Slots gemäß **ihrer eigenen** soldier_capacity – nicht der Gesamt-Capacity. Starke Fraktion (z. B. 250 Cap) verliert mehr pro Tod (4), schwache (z. B. 99 Cap) weniger (2). → Natürliche Penalty für „zu stark sein“; Underdog kann den Führenden pro Kill deutlich ausbluten.

| Eigene Capacity der Fraktion (sterbend) | Slots pro Tod |
|----------------------------------------|----------------|
| ≥ 350 | 6 |
| ≥ 300 | 5 |
| ≥ 250 | 4 |
| ≥ 200 | 3 |
| ≥ 100 | 2 |
| &lt; 100 | 1 |

- **99 vs 250:** Jeder Kill an der 250er-Fraktion kostet sie 4 Slots; die 99er-Fraktion verliert pro eigenem Tod nur 2 Slots.
- Implementierung: In `flushPendingDeaths()` pro Fraktion `rawCap = factions[fid].getIntAttribute("soldier_capacity")`, dann `slotsPerDeath = getSlotsPerDeathForCapacity(rawCap)`.

---

## Slots per Death nach Gesamt-Capacity (verworfen zugunsten eigener Cap)

**Idee (alt):** Eine Stufe für alle aus Summe aller Fraktionen. Nachteil: 99 vs 250 → beide verlieren gleich viele Slots pro Tod; keine stärkere Bestrafung des Führenden.

| Gesamt-Capacity (Summe aller Fraktionen) | Slots pro Tod |
|----------------------------------------|----------------|
| ≥ 350 | 6 | … (Stufen wie oben) |

Vorteil damals: Eine Kennzahl, keine Basen-Logik. Heute: durch **eigene Capacity pro Fraktion** ersetzt (siehe Abschnitt oben).

---

**Ziele (ursprüngliche Varianten):**
- **Führer-Vorteil:** Mehr Basen → höhere effektive Capacity (mehr Soldaten-Slots).
- **Verteidiger-Vorteil:** Den Führenden zu killen soll mehr „weh tun“ (mehr Slots pro Death für die führende Fraktion), damit Unterlegene den Leader länger ausschalten können.
- **Nicht zu extrem:** z. B. 9 Slots/Death × 10 Tote = −90 Capacity ist zu viel; Formeln begrenzen.

**Eingangsgrößen (alle Formeln):**
- `max_soldiers` = erlaubte Max-Soldaten auf dem Feld (z. B. aus Stage/start_game oder Summe der `soldier_capacity` aller Fraktionen bei Start, skaliert).
- `bases_f` = Anzahl Basen der Fraktion `f` (z. B. aus `getBases()` + Filter `owner_id == f`, **Cache 30 s**).
- `leader` = Fraktion mit den meisten Basen; `bases_leader`, `bases_second` = Basen der führenden und der zweitplatzierten Fraktion.
- `base_lead` = `bases_leader - bases_second` (Vorsprung des Führenden).

---

## Tabelle 1: Fixe Capacity pro Basis, fixe Slots pro Death (Baseline)

| Größe | Formel | Beispiel (9 vs 5 Basen) |
|-------|--------|--------------------------|
| Capacity (Bonus) | `cap_bonus_f = bases_f × 25` | A: 225, B: 125 |
| Effektive Capacity | `raw_cap_f + cap_bonus_f` (oder nur Bonus, wenn Engine nur Mult kennt) | — |
| Slots per Death | `1` für alle | Jeder Tod = −1 Slot |
| Führer-Vorteil | Nur über mehr Capacity | A hat mehr Truppen |
| Unterlegenen-Vorteil | Keiner | — |

**Pro:** Einfach, stabil. **Contra:** Kein Extra-Nachteil für den Führer bei Toden.

---

## Tabelle 2: Capacity pro Basis abhängig von max_soldiers (20–40 Band)

| Größe | Formel | Beispiel (max_soldiers = 400, 9 vs 5 Basen) |
|-------|--------|---------------------------------------------|
| Capacity pro Basis | `cap_per_base = 20 + 20 × (sum_cap / max_soldiers_ref)` mit `max_soldiers_ref` z. B. 500 → Skalierung | z. B. 36 pro Basis |
| Cap-Bonus Fraktion f | `cap_bonus_f = round(bases_f × cap_per_base)` | A: 324, B: 180 |
| Slots per Death | `1` für alle | — |
| Führer-Vorteil | Mehr Basen → mehr Capacity, skaliert mit Map-Größe | — |
| Unterlegenen-Vorteil | Keiner | — |

**Pro:** Capacity skaliert mit erlaubten Soldaten. **Contra:** Kein „Führer stärker bestrafen“.

---

## Tabelle 3: Slots per Death steigen mit eigener Basenanzahl (Führer verliert mehr pro Tod)

| Größe | Formel | Beispiel (9 vs 5 Basen) |
|-------|--------|--------------------------|
| Slots per Death (Fraktion f) | `slots_f = round(1 + 0.7 × bases_f)` | A: 7, B: 4 |
| Cap (wie Tabelle 1 oder 2) | Beliebig (z. B. fix 25 pro Basis) | A: 225, B: 125 |
| Führer-Vorteil | Höhere Capacity | A hat mehr Slots |
| Unterlegenen-Vorteil | Wenn B einen von A killt: A verliert 7 Slots → A wird schneller gedrückt | 10 Kills = −70 für A |

**Pro:** Führer „blutet“ pro Tod stärker. **Contra:** 9 Basen → 7 Slots/Death kann groß sein (10 Tote = −70). → **Cap nötig** (siehe Tabelle 4).

---

## Tabelle 4: Slots per Death = Basis + 0.7 × Basen, mit Obergrenze (gedeckelt)

| Größe | Formel | Beispiel (Cap bei 4), 9 vs 5 Basen |
|-------|--------|-------------------------------------|
| Slots per Death (f) | `slots_f = min(SLOTS_CAP, round(1 + 0.7 × bases_f))` mit z. B. `SLOTS_CAP = 4` | A: 4, B: 4 |
| Mit SLOTS_CAP = 5 | | A: 5, B: 4 |
| Cap-Bonus | z. B. 25 pro Basis | A: 225, B: 125 |
| Führer-Vorteil | Mehr Capacity; pro Tod verliert er mehr (aber gedeckelt) | Max −4 bzw. −5 pro Tod |
| Unterlegenen-Vorteil | Kills gegen A kosten A mehr als Kills gegen B | Begrenzt, aber spürbar |

**Pro:** Kein extremes −90 durch viele Kills. **Contra:** Bei vielen Basen schnell an der Cap.

---

## Tabelle 5: Nur Führer hat erhöhte Slots per Death (Vorsprung = stärkere Bestrafung)

| Größe | Formel | Beispiel (9 vs 5 → base_lead = 4) |
|-------|--------|------------------------------------|
| Slots per Death (f) | Wenn `f == leader`: `slots_f = 1 + round(0.5 × base_lead)`, sonst `1` | Leader: 3, andere: 1 |
| Cap | z. B. 25 pro Basis | A: 225, B: 125 |
| Führer-Vorteil | Mehr Capacity | A hat mehr Slots |
| Unterlegenen-Vorteil | Jeder Kill gegen den Leader kostet ihn 3 Slots; Kills gegen B nur 1 | Verteidiger können A gezielt „ausbluten“ |

**Pro:** Klar führer-spezifisch, gut steuerbar. **Contra:** Nur zwei Stufen (Leader vs Rest).

---

## Tabelle 6: Capacity pro Basis 20–40 (von max_soldiers), Slots per Death nach Rang

| Größe | Formel | Beispiel (max_soldiers ≈ 350, 9 / 5 / 2 Basen) |
|-------|--------|-------------------------------------------------|
| cap_per_base | `20 + 20 × min(1, total_capacity / 500)` | z. B. 34 |
| cap_bonus_f | `round(bases_f × cap_per_base)` | 306 / 170 / 68 |
| Rang | 1 = meiste Basen, 2 = zweitmeiste, … | A=1, B=2, C=3 |
| Slots per Death (f) | `slots_f = min(5, 1 + rang_bonus)` mit `rang_bonus = 0.5 × (max_bases - bases_f)` (gerundet) | A: 4, B: 2, C: 1 |
| Führer-Vorteil | Höchste Capacity, aber höchste Slots/Death | — |
| Unterlegenen-Vorteil | Schwächste Fraktion verliert pro Tod am wenigsten Slots | — |

**Pro:** Skalierung + Rangabstufung. **Contra:** Formel etwas komplexer.

---

## Tabelle 7: Symmetrisch – alle nach Basen, hart gedeckelt

| Größe | Formel | Beispiel |
|-------|--------|----------|
| Slots per Death (f) | `slots_f = min(4, max(1, round(1 + 0.4 × bases_f)))` | 9→4, 5→3, 1→1 |
| Cap-Bonus | `round(bases_f × 28)` | 252 / 140 / 28 |
| Führer-Vorteil | Mehr Capacity, mehr Slots/Death (gedeckelt) | — |
| Unterlegenen-Vorteil | Weniger Basen → weniger Slots/Death → weniger Selbst-Schaden bei Toden | — |

**Pro:** Einfach, symmetrisch, keine Sonderlogik für „Leader“. **Contra:** Kein expliziter „Führer-Nachteil“.

---

## Tabelle 8: Empfohlenes Mischmodell (fair, begrenzt)

| Größe | Formel | Beispiel (max_soldiers 350, 9 vs 5 Basen) |
|-------|--------|-------------------------------------------|
| **Capacity pro Basis** | `cap_per_base = 20 + 20 × min(1, sum_raw_cap / 500)`; `cap_bonus_f = round(bases_f × cap_per_base)` | z. B. 34; A: 306, B: 170 |
| **Slots per Death (f)** | Basis: `base_slots = 1`. Zuschlag nur für **Führer:** `leader_slots = min(4, 1 + round(0.6 × base_lead))`. Nicht-Führer: `1`. | base_lead=4 → Leader: 3; B: 1 |
| **Obergrenze Slots/Death** | Immer `≤ 4` (oder 5) | 10 Kills vs Leader = −30 statt −90 |
| **Führer-Vorteil** | Deutlich mehr Capacity (mehr Basen). | A: 306 vs B: 170 |
| **Verteidiger-Vorteil** | Jeder Kill gegen den Leader kostet ihn 3 Slots; Leader-Capacity sinkt schneller. | B kann A mit Kills gezielt unter Druck setzen |

**Kernformeln zum Implementieren:**
- `bases_f` = Basen der Fraktion f (Cache 30 s).
- `leader` = Fraktion mit `max(bases_f)`; `base_lead = bases_leader - bases_second` (oder 0 wenn nur eine Fraktion).
- `slots_per_death_f = (f == leader) ? min(4, 1 + round(0.6 × base_lead)) : 1`.
- `cap_bonus_f` wie in Tabelle 2/6 (optional; wenn Engine nur `capacity_multiplier` kennt, bleibt die Basis-Capacity aus der Stage und wir reduzieren nur um `reserved` wie bisher).

**Fairness:** Führer hat mehr Ressource (Capacity), zahlt aber pro verlorenen Soldaten mehr (Slots/Death). Unterlegene können durch Kills den Führer überproportional treffen, ohne dass die Zahlen explodieren (Cap 4).

---

## Technik-Hinweis

- **Basen pro Fraktion:** Über `getBases()` + Filter `owner_id == faction_id`, z. B. alle 30 s cachen.
- **max_soldiers / sum_cap:** Beim Start aus Stage oder aus `getFactions()` (Summe `soldier_capacity`) ableiten und einmalig oder bei Stage-Wechsel setzen.
- **Führer:** Pro Update (oder mit 30 s Cache) `argmax(bases_f)`; `base_lead` = Differenz zur zweitplatzierten Fraktion.

Wenn du dich für eine Tabelle entscheidest, kann die konkrete Implementierung (Konstanten, Caching, Anbindung an den bestehenden Tracker) als Nächstes ausgearbeitet werden.
