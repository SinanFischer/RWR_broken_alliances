# Capacity-Multiplikatoren (Reinforcement Pool)

## Warum mehr als 321 Soldaten?

Die Engine nutzt **nicht** direkt deinen Wert „max_soldiers“ (z. B. 321) als harte Obergrenze für lebende Soldaten. Stattdessen:

- **Basis:** `sum(soldier_capacity)` über alle Fraktionen = **max_soldiers × 2.5** (Konstante `CAPACITY_SUM_TO_MAX_SOLDIERS_RATIO`).
- Bei 321 → Summe Capacity ≈ **802**. Diese Summe wird auf die Fraktionen verteilt (nach Basen/Spielregeln).
- Unser Tracker sendet pro Fraktion einen **capacity_multiplier** (und optional spawn_interval) per `change_game_settings`. Die Engine multipliziert die **Basis-Capacity** der Fraktion mit diesem Faktor.
- **Effektive Obergrenze** = Summe über alle Fraktionen von `(soldier_capacity × capacity_multiplier)`.

Dadurch können z. B. **Großangriff (2x)** oder **Surge (1.2x)** die effektive Cap deutlich anheben → 600 lebende Soldaten bei „321 max“ sind möglich (z. B. 2x während Großangriff oder Aufschaukelung durch Surge + viele Basen).

---

## Alle verwendeten Multiplikatoren

| Konstante | Wert | Wo wirkt es | Bedeutung |
|-----------|------|-------------|-----------|
| **CAPACITY_SUM_TO_MAX_SOLDIERS_RATIO** | 2.5 | Pool-Berechnung, AUS-Dauer | Engine: Summe soldier_capacity = max_soldiers × 2.5. Wir leiten daraus max_soldiers und initialen Pool ab. **Erhöht die Gesamt-Capacity**, wird von uns nicht als Multiplikator gesendet. |
| **GROSSANGRIFF_CAPACITY_MULTIPLIER** | 2.0 | `applySpawnWindowState(open=true, grossangriff=true)` | Während der 30 s Großangriff: **2× Capacity** für alle Fraktionen (die spawnen dürfen). |
| **BOOST_CAPACITY_MULTIPLIER** (Surge) | **1.2** | `applySpawnWindowState` pro Fraktion mit `getBoostActive(fid)` | Wenn Surge aktiv: **1.2× Capacity** für diese Fraktion (z. B. bei 100 Cap → +20). |
| **CAPACITY_NERF_ABOVE_AVG** | 0.8 | `applySpawnWindowState` für Fraktionen mit überdurchschnittlicher soldier_capacity | Fraktionen mit **mehr Basen** (Capacity > Durchschnitt): **0.8×** → weniger Dominanz großer Fraktionen. |
| **CAPACITY_MULTIPLIER_NEAR_ZERO** | 0.00001 | `applySpawnWindowState` wenn `!canSpawn` | Spawn aus (oder Nachschub 0): Cap fast 0, damit die Engine die Fraktion nicht als „tot“ behandelt (Capture-Timer bleibt gültig). |

**Reihenfolge in `applySpawnWindowState`:**  
`capMult = 1.0` oder (bei Großangriff) `2.0` → bei Surge `× 1.2` → bei Nerf (überdurchschnittliche Cap) `× 0.8` → an Engine als `capacity_multiplier` (oder bei !canSpawn `CAPACITY_MULTIPLIER_NEAR_ZERO`).

---

## Wann wird die maximale Soldatenanzahl erhöht / nicht erhöht?

- **Erhöht (Boost):**
  - **Großangriff:** 30 s Fenster mit **2× Capacity** für alle (die spawnen können).
  - **Surge (Attack-Boost):** Pro Zyklus 25 % Chance pro Fraktion; dann **1.2× Capacity** und 1.5× Spawn-Rate für diese Fraktion in diesem Spawn-Fenster.

- **Nicht erhöht / begrenzt:**
  - **Normales Spawn-Fenster:** cap_mult = 1.0 (kein Großangriff, kein Surge).
  - **Capacity-Nerf:** Fraktion mit überdurchschnittlicher soldier_capacity bekommt **0.8×** (wird mit obigen Multiplikatoren kombiniert).
  - **Spawn aus oder Nachschub 0:** cap_mult = 0.00001 (praktisch kein Spawn).

Pool und AUS-Dauer hängen von der **Basis-Capacity** (sum/2.5) ab, nicht von diesen gesendeten Multiplikatoren.
