# Finale Datengrundlage: HP, Schaden, Retrigger (Rebalanced)

Diese Tabelle enthält die **finalen** Balancing-Werte für Lebenspunkte (HP) und Waffenschaden. Die Werte ersetzen die alten Engine-Roheinträge und folgen streng dem neuen exponentiellen Tiersystem.

---

## Tabelle 1 — Fahrzeuge & Emplacements (HP-Skalierung)

Die Einheiten sind innerhalb ihrer Tier-Klasse nach Robustheit gestaffelt (z.B. Jeep am unteren, LKW am oberen Rand von Klasse 1).

| Fahrzeug / Einheit | Tier-Klasse | Neue Ziel-HP | Anmerkung / Realismus-Begründung |
|--------------------|-------------|--------------|----------------------------------|
| **ATV / Quad** | T1 (Soft) | **30** | Absolut ungeschützt, Blech & Rahmen. |
| **Rubber Boat** | T1 (Soft) | **30** | Schlauchboot, reißt sofort. |
| **Tractor** | T1 (Soft) | **35** | Motorblock bietet minimalen Schutz. |
| **Jeep / Buggy** | T1 (Soft) | **40** | Offene Karosserie. |
| **Technical / Guntruck** | T1 (Soft) | **50** | Etwas Blechverstärkung an der Lafette. |
| **Cargo / Transport Truck** | T1 (Soft) | **60** | Große Masse schluckt etwas Schrapnell. |
| **VFS Familie** | T2 (Light) | **130** | Leichte Panzerwagen-Karosserie. |
| **Hovercraft** | T2 (Light) | **140** | |
| **Humvee / Humvee GL** | T2 (Light) | **160** | Gepanzerte Patrouillen-Türen & Glas. |
| **M120 / Deployable MGs** | *Emplacement* | **100 - 200** | Lafetten ohne Panzerung. |
| **Coastal / Heavy Art. Gun** | T3 (Medium)* | **450** | Robuste Eisen/Stahl-Konstruktion. Hält Granaten stand, stirbt an C4/AT. |
| **Radar Tank** | T3 (Medium) | **650** | Leichtes Chassis, schwerer Aufbau. |
| **Wiesel / TOW** | T3 (Medium) | **700** | Extrem kompakter Waffenträger. |
| **Noxe / SEV-90** | T3 (Medium) | **750 - 800**| Schützenpanzer. |
| **Patrol Ship** | T3 (Medium) | **800** | Massiver Rumpf, robuster als APCs. |
| **APC (Alle Varianten)** | T3 (Medium) | **850** | Klassischer Truppentransport (M113 etc.). |
| **Vulcan Tank** | T3 (Medium) | **850** | Flak-Panzerung. |
| **FV101 Scorpio** | T4 (Heavy) | **1.600** | Leichter Spähpanzer, unteres T4-Niveau. |
| **Flamer Tank** | T4 (Heavy) | **1.800** | |
| **M528 / M551 Sheriff** | T4 (Heavy) | **2.000 - 2.100**| Schwere Sturmgeschütze. |
| **Tank / Tank 1 / Tank 2** | T5 (Battle) | **5.000 - 5.200**| Main Battle Tanks. |
| **Doublecannon Tank** | T5 (Battle) | **4.800** | Separat gebalanced. |
| **Legion** | T6 (Superheavy)| **10.000** | Der Endboss. |

---

## Tabelle 2 — Anti-Tank & Explosivwaffen (Projektil-Schaden)

| Waffe / Projektil | Typ-Klasse | Neuer Schaden | Radius | Zielwirkung / Realismus |
|-------------------|------------|---------------|--------|-------------------------|
| **Lahti L-39 (20mm AP)** | AT Extrem-Leicht | **20** | 0.5 | Zerstört T1 in 2-3 Treffern. Nutzlos gegen Panzer. |
| **RPG-7 / M72 LAW** | AT Leicht | **400** | 6.0 | Instakill für T1/T2. Mückenstich für MBTs. |
| **M202 FLASH** | AT Leicht | **100** (x4) | 4.0 | 4er-Salve macht kombiniert 400 Schaden. |
| **SMAW / Carl Gustaf M2** | AT Mittel | **800** | 7.0 | Zerstört jeden APC (T3) mit 1-2 Treffern. |
| **Javelin / TOW** | AT Schwer | **1.300** | 8.0 | Zerstört T4 in 2 Hits, MBT in 3-4 Hits. |
| **Javelin Captain** | AT Schwer | **1.800** | 9.0 | Zerstört T4 sofort. |
| **Javelin Elite** | AT Top | **2.600** | 10.0 | Killt MBTs in exakt 2 Hits. |
| **Tank Cannon (Vanilla)** | Panzerkanone | **1.200 - 1.400**| 8.0 | Standardkampf Pz. vs Pz. |
| **Legion Cannon** | Superheavy | **2.000** | 12.0 | Zerstört T4 in 1 Hit, halbiert MBT-Leben. |
| **FHJ-01 (FAE Cluster)** | Submunition | Parent: **20** / Sub: **3** | Sub: 3.0 | Infantrie überlebt Sub-Treffer knapp (4 HP max). Tödlich gegen weiche Ziele, 0 Effekt auf Tanks. |
| **M528 APJ (Cluster)** | Submunition | Parent: **50** / Sub: **5** | Sub: 4.0 | Etwas stärkere Cluster für Fahrzeug-Montage. |
| **AT-Mine** | Sprengsatz | **1.000** | 6.0 | Zerstört T3 sofort, verkrüppelt T4 schwer. |

---

## Tabelle 3 — Infanterie-Explosiva & Autokanonen

| Waffe / Projektil | Fraktion / Typ | Neuer Schaden | Radius | Wirkung |
|-------------------|----------------|---------------|--------|---------|
| **Handgranate / Impact** | Granate | **15** | 4.0 | Zerstört Jeeps in 3 Treffern. Killt Infanterie. |
| **AT-Granate** | Granate | **500** | 3.5 | 1 Hit T1, 2 Hits T3. |
| **C4 Sprengladung** | Sprengsatz | **1.700** | 5.0 | 1 C4 killt Emplacements (Coastal Gun), 3 killen MBT. |
| **40mm HE (APC HMG/GL)**| Granatwerfer | **20** | 4.5 | Zerstört T1 in 2-3 Hits. Betäubt Panzerbesatzung. |
| **Wiesel Mk20 (20mm)** | Kinetisch AP | **5.0** pro Hit | 1.0 | 15 DPS. Zerlegt Humvee in ~10s. |
| **Vulcan Minigun** | Kinetisch AP | **0.5** pro Hit | 0.5 | 25 DPS (50 Schuss/s). Zerlegt Humvee in ~6s. |
| **Portable Mortar** | Indirekt | **150** | 12.0 | Tödlich für Jeeps/Soft-Targets. |
| **M120 Heavy Mortar** | Indirekt | **600** | 18.0 | 1 Hit pulverisiert T2, beschädigt T3 schwer. |
