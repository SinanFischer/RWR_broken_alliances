# Haltungsbonus – Konzept (Trickle nur AUS + Auszahlung beim Öffnen)

## Übersicht

- **Nur während Spawn AUS:** Jede gehaltene Basis zahlt alle **10 s** in einen **Akkumulator** (Kommawerte).
- **Beim Öffnen (AUS→AN):** Der Akkumulator wird dem Nachschub-Pool gutgeschrieben, Commander-Meldung („Reinforcements arrived. +X added to supply.“), Akkumulator auf 0.
- **Pool mit Kommarest:** Der Pool ist intern eine Fließkommazahl. Beim Spawnen wird 1 abgezogen; Rest bleibt (z. B. 15,2 → 15 Soldaten ausgegeben, 0,2 bleibt im Pool).

---

## Wertetabelle (pro 10 s, nur während AUS)

| Basistyp  | Standard (pro 10 s) | Nach MajorAttack (pro 10 s) |
|-----------|----------------------|------------------------------|
| **Side**  | 1,6                  | 8,96 (1,6 × 5,6)             |
| **Outpost** | 2,56                | 14,34 (2,56 × 5,6)           |
| **HQ**    | 4,8                  | 26,88 (4,8 × 5,6)            |

- **Standard:** Haltungsbonus in jeder AUS-Phase (2× Basiswerte, dann +1,6×).
- **Nach MajorAttack:** Die **eine** AUS-Phase direkt nach dem 30-s-MajorAttack (Spawn AN) hat **5,6×** Trickle auf die obigen Werte.

Konstanten in `reinforcement_pool_tracker.as`:  
`DEFENDER_TRICKLE_INTERVAL = 10.0f`, `DEFENDER_TRICKLE_SIDE/MEDIUM/STRONG`, `TRICKLE_MULTIPLIER_AFTER_MAJOR_ATTACK = 5.6f`.

---

## Beispiel 6 Basen (1 HQ + 2 Outpost + 3 Side)

- **Standard** pro 10 s: 4,8 + 2×2,56 + 3×1,6 = **12,32**
- AUS 120 s → 12×10 s → **~148** Verstärkung beim Öffnen
- **Nach MajorAttack** (5,6×): pro 10 s = 12,32 × 5,6 = **~69**; z. B. 72 s AUS → **~497** in dieser einen Phase

---

## Tabelle: 5 Side + 2 Outpost + 1 HQ

**Standard:** pro 10 s = 5×1,6 + 2×2,56 + 1×4,8 = **17,92**

| AUS-Dauer   | Ticks (×10 s) | Verstärkung beim Öffnen (Standard) |
|-------------|----------------|-------------------------------------|
| **10 s**    | 1              | **~18**                             |
| **60 s**    | 6              | **~107**                            |
| **72 s**    | 7 (min AUS)    | **~125**                            |
| **90 s**    | 9              | **~161**                            |
| **120 s**   | 12             | **~215**                            |
| **180 s**   | 18             | **~322**                            |
| **252 s**   | 25 (max AUS)   | **~448**                            |

**Nach MajorAttack (5,6×):** pro 10 s = 17,92 × 5,6 = **~100**; z. B. 72 s AUS → **~700** in dieser einen Phase.

*AUS-Dauer hängt von der Kapazität ab (72–252 s, siehe `SPAWN_CLOSED_DURATION.md`).*

---

## Technik

- Trickle-Logik läuft nur, wenn `!m_spawnWindowOpen`; Zähler `m_defenderAccum` alle 10 s, dann pro Basis `addHoldingAccumulator(ownerId, trickle)`.
- Beim Wechsel AUS→AN (in `update()`): für jede Fraktion Pool += Akkumulator, Meldung, `resetHoldingAccumulator(fid)`.
- Savegame: `pool` (Ganzzahl), `pool_frac` (Nachkomma × 100), `acc_x100` (Akkumulator × 100). Alte Savegames ohne `pool_frac`/`acc_x100` laden weiter (Nachkomma = 0, Akkumulator = 0).
