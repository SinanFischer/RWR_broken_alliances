# Spawn AUS-Dauer (capacity-basiert)

Die Dauer der **Spawn-AUS-Phase** haengt von der eingestellten Soldier-Capacity ab: mehr Soldaten → laengere AUS-Phase → mehr Push/Fight, Siege zaehlen mehr.

## Formel

- **Referenz:** 200 Soldaten (max) → 102 s AUS
- **Skalierung:** +0,5 s pro Soldat ueber 200
- **Clamp:** mind. 72 s, max. 192 s

`closedDuration = clamp(72, 102 + (maxSoldiers - 200) * 0.5, 192)`

`maxSoldiers` = sumCapacity / CAPACITY_SUM_TO_MAX_SOLDIERS_RATIO (≈ 1,28)

## Tabelle (Beispielwerte)

| sumCapacity (ca.) | maxSoldiers (≈) | Spawn AUS (s) | Spawn AN (s) |
|-------------------|-----------------|---------------|--------------|
| 128               | 100             | 72 (Min)      | 30           |
| 192               | 150             | 72 (Min)      | 30           |
| 256               | 200             | 102           | 30           |
| 320               | 250             | 127           | 30           |
| 384               | 300             | 152           | 30           |
| 448               | 350             | 177           | 30           |
| 512               | 400             | 192 (Max)     | 30           |

Berechnung einmal beim ersten Abruf von `getSpawnClosedDuration()` (aus Factions-Capacity).
