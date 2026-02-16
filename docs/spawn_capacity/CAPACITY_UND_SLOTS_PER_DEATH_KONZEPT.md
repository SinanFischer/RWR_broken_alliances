# Respawn-Slot-Delay & Slots-per-Death

---

## Ziel

Kills sollen im Spiel **spürbare Auswirkungen** haben. In Vanilla spawnen getötete Soldaten sofort nach, wenn Capacity frei ist — ein Kill bringt fast keinen taktischen Vorteil. Dieses System macht jeden Kill wertvoll:

- Getötete Einheiten **blockieren** ihre Spawn-Slots für eine begrenzte Zeit.
- Stärkere Fraktionen verlieren pro Tod **mehr Slots** und werden **länger** blockiert.
- Schwächere Fraktionen (≤2 Basen) sind **komplett vom Slotblock befreit** (Vanilla-Spawn).
- Medic-Revives verhindern den Tod → kein Slot wird blockiert → Revives werden wichtiger.

---

## Spielverhalten

### Was passiert wenn ein Soldat stirbt?

1. Die **sterbende Fraktion** verliert für X Sekunden mehrere Capacity-Slots.
2. Die Engine sieht weniger verfügbare Capacity → weniger/keine Spawns bis Slots frei werden.
3. Nach Ablauf des Delays werden die Slots automatisch freigegeben.

### Was sieht der Spieler?

- Spawns dauern nach großen Verlusten spürbar länger.
- `/stats` zeigt pro Fraktion: **C** (verfügbare Capacity) und **B** (aktuell blockierte Slots).
- Eine Fraktion mit vielen Toden in kurzer Zeit hat deutlich reduzierte Capacity.

### Schwächste Fraktion (Underdog-Schutz)

Wenn eine Fraktion die **wenigsten Basen** hat **UND ≤2 Basen** besitzt:
- **Kein Slotblock** — volle Capacity, Vanilla-Spawn.
- Keine Timestamps werden gespeichert (auch keine versteckten).
- Sobald sie eine 3. Base erobert, greift das Slot-System wieder.

---

## 1. Slots pro Tod

Pro Tod werden **so viele Slots** blockiert, wie die Tabelle für die **eigene** soldier_capacity angibt:

| Capacity der sterbenden Fraktion | Slots pro Tod (Basis) |
|----------------------------------|----------------------|
| < 70                             | 1                    |
| 70 – 120                         | 2                    |
| 121 – 200                        | 3                    |
| 201 – 250                        | 4                    |
| 251 – 299                        | 5                    |
| ≥ 300                            | 6                    |

**Führer-Bonus:** Die Fraktion mit den meisten lebenden Truppen (ermittelt alle 15 s) verliert **+2 Slots zusätzlich** pro Tod.

**Beispiel:** Fraktion mit Capacity 250 (Führer): `4 + 2 = 6 Slots` pro Tod blockiert.

---

## 2. Dauer der Blockade (Delay)

Wie lange jeder Slot blockiert bleibt, hängt von der **Basenanzahl der sterbenden Fraktion** ab:

| Basen der Fraktion | Basis-Delay |
|--------------------|-------------|
| 1 Basis            | 2 s         |
| 2 Basen            | 5 s         |
| 3+ Basen           | 15 s        |

**Extra-Delay bei Truppenüberlegenheit:** Hat eine Fraktion mehr lebende Truppen als die zweitstärkste:

```
extraDelay = (Vorsprung / 25) × 4 s
```

Beispiel: 50 Truppen Vorsprung → +8 s extra → effektives Delay = 15 + 8 = 23 s.

**Effektives Delay** = Basis-Delay + Extra-Delay. Wird zum Todeszeitpunkt festgelegt und ändert sich nachträglich nicht (Ablaufzeitpunkt wird gespeichert).

---

## 3. Technische Umsetzung

### Timestamps = Ablaufzeitpunkte

Beim Tod wird **nicht** der Todeszeitpunkt gespeichert, sondern der **Ablaufzeitpunkt** (`expireTime = now + effectiveDelay`). Dadurch:

- Slots verfallen exakt nach dem Delay, das zum Todeszeitpunkt galt.
- Spätere Delay-Änderungen (durch Basenverlust/-gewinn) beeinflussen bestehende Slots **nicht**.
- Kein "Zombie-Timestamp"-Problem: Ein Slot, der nach 2 s verfallen sollte, bleibt auch bei Delay-Erhöhung weg.

### Capacity-Cache (robust)

Die Basis-Capacity (`soldier_capacity` aus Config) wird als **höchster beobachteter Wert** pro Fraktion gecacht (monoton steigend, nie nach unten überschrieben):

- Startwert wird früh gesetzt (Fallback/Live-Read möglich).
- Bei späteren Map-/Stage-Anhebungen wird der Cache automatisch nach oben korrigiert.
- Reduzierte Laufzeitwerte durch `capacity_multiplier` überschreiben den Basiswert **nicht**.

Damit bleibt `Cap` in `/stats` stabil korrekt (z.B. 250 statt festhängend bei 30).

### Schwächste Fraktion

In `flushPendingDeaths()` wird geprüft: Hat diese Fraktion die wenigsten Basen UND ≤2 Basen? Wenn ja:
- `pendingDeaths` werden gelöscht, aber **keine Timestamps** erzeugt.
- `totalSlotSecondsBlocked` wird nicht erhöht.
- `applyCapacityWithReservedSlots()` setzt `mult = 1.0` (volle Capacity).

---

## 4. Ablauf (pro Frame/Update)

1. **`character_die`-Event** → `addPendingDeath(factionId)` (Zähler pro Fraktion).
2. **Jedes update** → `flushPendingDeaths()`:
   - Schwächste Fraktion: pendingDeaths löschen, **keine Timestamps**.
   - Sonst: `slotsPerDeath` berechnen (Tabelle + Führer-Bonus), `expireTime = now + effectiveDelay`, pro Tod × slotsPerDeath viele Expire-Einträge speichern.
3. **Alle 15 s** → `refreshAliveBasedExtraDelay()`:
   - Alive-Zahlen, Basen, Extra-Delay pro Fraktion aktualisieren.
   - Führer-Fraktion (meiste Alive) bestimmen.
4. **Alle 1 s** → `applyCapacityWithReservedSlots()`:
   - Pro Fraktion: `reserved = Anzahl Expire-Einträge mit expireTime > now`.
   - `effective = baseCapacity − reserved`, `mult = effective / baseCapacity`.
   - `change_game_settings` mit `capacity_multiplier` pro Fraktion an Engine senden.
   - Abgelaufene Einträge entfernen (Prune).

---

## 5. /stats-Anzeige

```
EU: A-K-D: 50-100-80 C-B: 65-5 B(s): 150
```

| Kürzel | Bedeutung |
|--------|-----------|
| A      | Alive (lebende Einheiten) |
| K      | Kills (durch diese Fraktion getötet) |
| D      | Deaths (Tode dieser Fraktion) |
| C      | Effektive Capacity (baseCapacity − B) |
| B      | Aktuell blockierte Slots (Summe; ein Tod = 1–8 Slots je nach Capacity + Führer) |
| B(s)   | Kumulierte Slot-Sekunden (Impact über die Runde: Summe aller Slots × Delay) |

---

## 6. Konfiguration (Konstanten)

| Konstante | Wert | Bedeutung |
|-----------|------|-----------|
| `RESPAWN_SLOT_DELAY` | 15 s | Basis-Delay bei 3+ Basen |
| `RESPAWN_SLOT_DELAY_2_BASES` | 5 s | Basis-Delay bei 2 Basen |
| `RESPAWN_SLOT_DELAY_1_BASE` | 2 s | Basis-Delay bei 1 Basis |
| `ALIVE_CHECK_INTERVAL` | 15 s | Wie oft Alive/Basen/Extra-Delay aktualisiert |
| `TROOPS_PER_EXTRA_BLOCK` | 25 | Pro 25 Truppen Vorsprung … |
| `EXTRA_SECONDS_PER_BLOCK` | 4 s | … +4 s Extra-Delay |
| `APPLY_INTERVAL` | 1 s | Wie oft capacity_multiplier gesendet wird |
| `CAPACITY_MULTIPLIER_NEAR_ZERO` | 0.00001 | Min-Mult (Engine ignoriert 0.0) |

---

## 7. Relevante Dateien

| Datei | Zweck |
|-------|-------|
| `scripts/trackers/respawn_slot_delay_tracker.as` | Hauptlogik: Slot-Delay, Capacity-Multiplier |
| `scripts/trackers/stats_command_tracker.as` | `/stats`-Command: zeigt A-K-D, C-B, B(s) |
| `scripts/trackers/capacity_debug_hud_tracker.as` | Debug-HUD: Alive/Capacity pro Fraktion (optional) |
| `scripts/gamemode_quick_match.as` | Einbindung aller Tracker |

---

## 8. Behobene Bugs (Changelog)

1. **Capacity-Auslese driftete nach unten (z.B. 250 → 30):** Zu frühes/zu statisches Caching konnte zu niedrige Basiswerte festhalten. Fix: `m_baseCapacity` wird als Maximum pro Fraktion geführt (nur nach oben aktualisiert), inkl. Fallback-Live-Read.
2. **Zombie-Timestamps:** Delay-Änderung (z.B. Basenverlust) konnte abgelaufene Timestamps wiederbeleben. Fix: Gespeichert wird jetzt `expireTime` (Ablaufzeitpunkt), nicht Todeszeitpunkt.
3. **Schwächste Fraktion sammelte Timestamps:** Obwohl `mult = 1.0` gesetzt wurde, wurden Timestamps gespeichert. Bei Basis-Rückeroberung (3+ Basen) wurden alle plötzlich aktiv → massiver Capacity-Drop. Fix: `flushPendingDeaths()` speichert keine Timestamps für schwächste Fraktion.
