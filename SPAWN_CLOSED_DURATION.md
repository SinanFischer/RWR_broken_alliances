# Spawn AUS-Dauer (capacity-basiert)

Die Dauer der **Spawn-AUS-Phase** haengt von der eingestellten Soldier-Capacity ab: mehr Soldaten → laengere AUS-Phase → mehr Push/Fight, Siege zaehlen mehr.

## Formel

- **Referenz:** 200 Soldaten (max) → 90 s AUS
- **Skalierung:** +0,5 s pro Soldat ueber 200
- **Clamp:** mind. 60 s, max. 180 s

`closedDuration = clamp(60, 90 + (maxSoldiers - 200) * 0.5, 180)`

`maxSoldiers` = sumCapacity / CAPACITY_SUM_TO_MAX_SOLDIERS_RATIO (≈ 1,28)

## Tabelle (Beispielwerte)

| sumCapacity (ca.) | maxSoldiers (≈) | Spawn AUS (s) | Spawn AN (s) |
|-------------------|-----------------|---------------|--------------|
| 128               | 100             | 60 (Min)      | 30           |
| 192               | 150             | 60 (Min)      | 30           |
| 256               | 200             | 90            | 30           |
| 320               | 250             | 115           | 30           |
| 384               | 300             | 140           | 30           |
| 448               | 350             | 165           | 30           |
| 512               | 400             | 180 (Max)     | 30           |

Berechnung einmal beim ersten Abruf von `getSpawnClosedDuration()` (aus Factions-Capacity).
