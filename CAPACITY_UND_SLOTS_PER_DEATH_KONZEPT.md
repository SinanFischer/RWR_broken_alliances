# Respawn-Slot-Delay & Slots-per-Death - aktuelles System

---

## Überblick

- **Effekt:** Jeder Tod einer Fraktion „blockiert“ für eine begrenzte Zeit mehrere Capacity-Slots dieser Fraktion. Effektive Capacity = `rawCap − reserved`; die Engine erhält das über `capacity_multiplier` (alle 1 s). Kills und Revives haben dadurch spürbaren Einfluss.
- **Slots pro Tod** hängen von der **eigenen** soldier_capacity der **sterbenden** Fraktion ab (starke Fraktion verliert mehr pro Tod; Underdog kann den Führenden pro Kill stärker ausbluten).
- **Zusätzlicher Delay bei Truppenüberlegenheit:** Hat eine Fraktion mehr lebende Truppen als die zweitstärkste, verlängert sich die Slot-Blockade für ihre Tode um eine berechnete Extra-Zeit.

---

## 1. Slots pro Tod (nach eigener Capacity + Führer-Bonus)

Pro Tod einer Fraktion werden **so viele** Slots für die Dauer des Delays als „reserviert“ gezählt, wie die folgende Tabelle für die **eigene** soldier_capacity dieser Fraktion angibt. **Zusätzlich:** Die **führende** Fraktion (meiste lebende Truppen) erhält **+2 Slots** pro Tod.

| Eigene Capacity der Fraktion (sterbend) | Slots pro Tod (Basis) |
|----------------------------------------|------------------------|
| &lt; 70 | 1 |
| 70 - 120 | 2 |
| 121 - 200 | 3 |
| 201 - 250 | 4 |
| 251 - 299 | 5 |
| ≥ 300 | 6 |

**Führer-Bonus:** Führende Fraktion (ermittelt alle 15 s via Alive-Zahl) +2 Slots → verliert pro Tod 2 Slots mehr als die Tabelle.

- **Beispiel 99 vs 250, 250 ist führend:** 250er-Fraktion: 4 + 2 = 6 Slots pro Tod; 99er-Fraktion (70-120): 2 Slots (ohne Führer).
- **Implementierung:** `getSlotsPerDeathForCapacity(factionCap)`; in `flushPendingDeaths()` Basis + ggf. `+2` wenn `fid == m_leaderFactionId`.

---

## 2. Slot-Blockade (Delay)

- **Basis (pro Fraktion):** Die **Basis-Dauer** der Blockade hängt von der **Anzahl Basen** der Fraktion ab (nur für diese Fraktion):  
  **1 Basis** → 2 s, **2 Basen** → 5 s, **3+ Basen** → `RESPAWN_SLOT_DELAY` (z. B. 15 s).  
  So haben stark unterlegene Fraktionen (nur noch 1-2 Basen) kürzeres Respawn-Delay.
- **Extra bei Überlegenheit:** Alle 15 s wird pro Fraktion ermittelt, ob sie mehr lebende Truppen hat als die zweitstärkste. Wenn ja:  
  `extraDelay = (Vorsprung / TROOPS_PER_EXTRA_BLOCK) × EXTRA_SECONDS_PER_BLOCK`  
  (z. B. alle 25 Truppen Vorsprung = 4 s länger).  
  Die **effektive** Blockade-Dauer pro Slot ist dann `getBaseDelaySeconds(factionId) + getExtraDelaySeconds(factionId)` (Basis aus Basenanzahl, alle 15 s gecacht).
- **Reserved Slots:** Anzahl der Zeitstempel (pro Tod × slotsPerDeath) die innerhalb dieser effektiven Dauer vor „now“ liegen. Diese Anzahl wird von der raw Capacity abgezogen.

---

## 3. Anwendung auf die Engine

- **Effektive Capacity:** `effective = max(0, rawCap − reserved)`.
- **capacity_multiplier:** `effective / rawCap` (bzw. Mindestwert nahe 0, damit die Fraktion nicht als tot gilt).
- **Intervall:** Alle 1 s (`APPLY_INTERVAL`) wird `change_game_settings` mit den capacity_multipliern pro Fraktion gesendet.

---

## 4. Ablauf (kurz)

1. **character_die** → `addPendingDeath(factionId)` (Zähler pro Fraktion).
2. **Jedes update:** `flushPendingDeaths()` - pro Fraktion mit Toden: `slotsPerDeath = getSlotsPerDeathForCapacity(rawCap)`; wenn Fraktion = Führer, `slotsPerDeath += 2`; für jeden Tod werden `slotsPerDeath` viele Zeitstempel angehängt.
3. **Alle 15 s:** Alive-Zahlen pro Fraktion; Führer = erste Fraktion mit max Alive (`m_leaderFactionId`); für jede Fraktion mit mehr Alive als die zweitstärkste wird `extraDelaySeconds` gesetzt.
4. **Alle 1 s:** `getReservedSlots(fid)` = Anzahl Zeitstempel mit `(now - t) ≤ RESPAWN_SLOT_DELAY + getExtraDelaySeconds(fid)`; dann `effective = rawCap − reserved`, `capacity_multiplier = effective/rawCap` → `change_game_settings`.
5. **Prune:** Alte Zeitstempel außerhalb des effektiven Delays werden periodisch entfernt, damit die Liste nicht unbegrenzt wächst.

---

## 5. Relevante Dateien / Konstanten

- **Tracker:** `scripts/trackers/respawn_slot_delay_tracker.as`
- **Konstanten (Auszug):** `RESPAWN_SLOT_DELAY`, `ALIVE_CHECK_INTERVAL`, `TROOPS_PER_EXTRA_BLOCK`, `EXTRA_SECONDS_PER_BLOCK`, `APPLY_INTERVAL`, `CAPACITY_MULTIPLIER_NEAR_ZERO`
- **Debug-HUD (optional):** `scripts/trackers/capacity_debug_hud_tracker.as` zeigt pro Fraktion Alive / effektive Capacity; Einbindung über `gamemode_quick_match.as` (`CAPACITY_DEBUG_HUD`).
