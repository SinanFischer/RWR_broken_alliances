# Haltungsbonus – Konzept (Trickle nur AUS + Auszahlung beim Öffnen)

## Übersicht

- **Nur während Spawn AUS:** Jede gehaltene Basis zahlt alle **10 s** in einen **Akkumulator** (Kommawerte).
- **Beim Öffnen (AUS→AN):** Der Akkumulator wird dem Nachschub-Pool gutgeschrieben, Commander-Meldung („Reinforcements arrived. +X added to supply.“), Akkumulator auf 0.
- **Pool mit Kommarest:** Der Pool ist intern eine Fließkommazahl. Beim Spawnen wird 1 abgezogen; Rest bleibt (z. B. 15,2 → 15 Soldaten ausgegeben, 0,2 bleibt im Pool).

---

## Wertetabelle (pro 10 s, nur während AUS)

| Basistyp  | Beitrag pro 10 s |
|-----------|-------------------|
| **Side**  | 0,5               |
| **Outpost** | 0,8             |
| **HQ**    | 1,5               |

Konstanten in `reinforcement_pool_tracker.as`:  
`DEFENDER_TRICKLE_INTERVAL = 10.0f`, `DEFENDER_TRICKLE_SIDE/MEDIUM/STRONG`.

---

## Beispiel 6 Basen (1 HQ + 2 Outpost + 3 Side)

- Pro 10 s: 1,5 + 1,6 + 1,5 = **4,6**
- AUS 120 s → 12×10 s → **~55** Verstärkung beim Öffnen

---

## Tabelle: 5 Side + 2 Outpost + 1 HQ (pro 10 s = 5,6 Verstärkung)

| AUS-Dauer   | Ticks (×10 s) | Verstärkung beim Öffnen |
|-------------|----------------|---------------------------|
| **10 s**    | 1              | **~6**                    |
| **60 s**    | 6              | **~34**                   |
| **72 s**    | 7 (min AUS)    | **~40**                   |
| **90 s**    | 9              | **~50**                   |
| **120 s**   | 12             | **~67**                   |
| **180 s**   | 18             | **~101**                  |
| **252 s**   | 25 (max AUS)   | **~141**                  |

*AUS-Dauer hängt von der Kapazität ab (72–252 s, siehe `SPAWN_CLOSED_DURATION.md`).*

---

## Technik

- Trickle-Logik läuft nur, wenn `!m_spawnWindowOpen`; Zähler `m_defenderAccum` alle 10 s, dann pro Basis `addHoldingAccumulator(ownerId, trickle)`.
- Beim Wechsel AUS→AN (in `update()`): für jede Fraktion Pool += Akkumulator, Meldung, `resetHoldingAccumulator(fid)`.
- Savegame: `pool` (Ganzzahl), `pool_frac` (Nachkomma × 100), `acc_x100` (Akkumulator × 100). Alte Savegames ohne `pool_frac`/`acc_x100` laden weiter (Nachkomma = 0, Akkumulator = 0).
