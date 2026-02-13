# Panzer-Vergleich: Normale Tanks + Heavy (Heavy-Spawn-Pool)

**Zweck:** Balance prüfen – pro Zeile ist der **stärkste** Wert **fett**.  
**Metriken:** **Leben** = max_health (Fahrzeug-HP) | **Proj. Speed** = projectile_speed der Hauptkanone | **Damage** = Blast-Damage des Projektils | **Radius** = Blast-Radius (m).  
Quellen: Mod `.vehicle` / `.weapon` / `.projectile`; Vanilla für M551, FV101, Legion, M528, Flamer.

---

## 1. Normale Tanks (Fraktions-Hauptpanzer)

| Metrik | RWR1a1 (tank) | Leopold II (tank_1) | TroX-80 (tank_2) |
|--------|---------------|---------------------|------------------|
| **Leben** | 25.35 | **26.2** | 25.95 |
| **Proj. Speed** | **226** | 175 | 165 |
| **Damage** | **10** | **10** | **10** |
| **Radius** | **8** | **8** | **8** |

→ **Balance:** Alle drei gleicher Schaden (10) und Radius (8). Leopold II höchstes Leben (26.2). RWR1a1 schnellstes Projektil (226). TroX-80 langsamstes Projektil (165).

---

## 2. Heavy-Pool (alle im Heavy-Intervall-Spawn)

*Heavy-Keys aus `vehicle_interval_spawn.as`: tank_alt, tank_1_alt, tank_2_alt, m551, fv101, legion, m528, flamer_tank.*

| Metrik | tank_alt | tank_1_alt | tank_2_alt | M551 Sheriff | FV101 Scorpio | Legion | M528 | FT-CROC (Flamer) |
|--------|----------|------------|-------------|--------------|---------------|--------|------|------------------|
| **Leben** | 25.35 | 26.2 | 25.95 | 9.6 | 8.8 | **34** | 8.4 | 6.4 |
| **Proj. Speed** | **226** | 175 | 165 | 42 | 55 | 40 | 90 (HMG) | 140 |
| **Damage** | 6.02 | 6.02 | 6.02 | 4.01 | 2.01 | **12** | – (HMG) | 0.02 |
| **Radius** | 7 | 7 | 7 | 4.5 | 3.3 | **10** | – | 1.8 |

→ **Hinweise:**  
- **Alt-Tanks** (tank_alt, tank_1_alt, tank_2_alt): Gleiche Leben wie normale Tanks, schwächeres Projektil (6.02 / 7) als Haupttanks (10 / 8).  
- **M551:** Vanilla-Werte (42 speed, 4.01 damage, 4.5 radius); geringes Leben (9.6).  
- **FV101 Scorpio:** Leichtes Leben (8.8), niedrigster Schaden (2.01), Radius 3.3.  
- **Legion:** **Höchstes Leben (34)**, **stärkster Schaden (12)** und **größter Radius (10)** im Heavy-Pool (Mod-Override); langsames Projektil (40).  
- **M528:** HMG (speed 90) + AP-Submunitionen (kein Einzel-Blast; Sub 0.16/2.5). Damage/Radius für „Hauptwaffe“ nicht vergleichbar → „–“.  
- **FT-CROC:** Flamethrower (speed 140, viele Treffer); Einzel-Blast 0.02 / 1.8; niedrigstes Leben (6.4).

---

## 3. Leicht-Pool (alle im Light-Intervall-Spawn)

*Light-Keys aus `vehicle_interval_spawn.as`: humvee, jeep, jeep_1, jeep_2, vfs_sport, willys_mb, wiesel_tow, wiesel_mk20, atv_base, atv_armory, vfs_base, truck, truck_1, truck_2.*

| Metrik | Humvee | Jeep | Jeep_1 | Jeep_2 | VFS Sport | Willys MB | Wiesel TOW | Wiesel Mk20 | ATV Base | ATV Armory | VFS Base | Truck | Truck_1 | Truck_2 |
|--------|--------|------|--------|--------|-----------|------------|------------|-------------|----------|------------|----------|-------|--------|--------|
| **Leben** | **7.2** | 2.4 | 2.4 | 2.4 | 4.2 | 2.4 | 6.0 | 6.0 | 5.5 | 5.5 | 4.2 | 6.8 | 6.8 | 6.8 |

→ **Hinweise:** Leichte Fahrzeuge haben keine Blast-Kanonen; Bewaffnung ist MG (Humvee, VFS, Willys), TOW-Rakete (Wiesel TOW), Mk20 (Wiesel Mk20) oder keine (Jeep, Truck, ATV). Vergleich nur über **Leben** sinnvoll. **Höchstes Leben:** Humvee (7.2), danach Truck/Truck_1/Truck_2 (6.8), Wiesel TOW/Mk20 (6.0). **Niedrigstes:** Jeep/Varianten und Willys (2.4).

---

## 4. Leicht-Pool – Kurzüberblick & Stärken

| Metrik | Stärkster (Leicht) | Wert |
|--------|--------------------|------|
| **Leben** | Humvee | **7.2** |
| **Leben (ohne MG)** | Truck / Truck_1 / Truck_2 | **6.8** |
| **Leben (Kampfleicht)** | Wiesel TOW / Wiesel Mk20 | **6.0** |

| Fahrzeugtyp | Stärken (Leicht) | Trade-off |
|-------------|-------------------|-----------|
| **Humvee** | Höchstes Leben (7.2), MG | Langsamere Klasse als Jeeps |
| **Truck / Truck_1 / Truck_2** | Hohes Leben (6.8), Transport | Unbewaffnet |
| **Wiesel TOW / Mk20** | Leben 6.0, TOW/Mk20-Bewaffnung | Leicht gepanzert |
| **ATV Base / Armory** | Leben 5.5, mobil | Unbewaffnet / Armory |
| **VFS Base / Sport** | Leben 4.2, MG (Base) | Geringeres Leben |
| **Jeep / Pigeon / TroX / Willys** | Schnell, wendig | Niedrigstes Leben (2.4) |

---

## 5. Kurzüberblick: Stärkster Wert pro Metrik (nur kampfrelevante Panzer)

| Metrik | Stärkster | Wert |
|--------|-----------|------|
| **Leben** | Leopold II / tank_1_alt | **26.2** |
| **Proj. Speed** | RWR1a1 / tank_alt | **226** |
| **Damage** | Normale Tanks (tank, tank_1, tank_2) | **10** |
| **Radius** | Legion (Mod) | **10** |

---

## 6. Stärken-Matrix Heavy-Pool

| Fahrzeug | Stärken (kampfrelevant) | Trade-off |
|----------|-------------------------|-----------|
| **tank_alt / tank_1_alt / tank_2_alt** | Höchstes Leben (25–26), schnellste/schnelle Projektile (165–226), guter Radius (7), Damage 6.02 | Weniger Damage/Radius als normale Mod-Tanks |
| **Legion** | Höchstes Leben (34), stärkster Damage (12), größter Radius (10) | Langsamstes Projektil (40) |
| **M551** | Mittlerer Vanilla-Schaden (4.01), Radius 4.5 | Geringes Leben (9.6), langsames Projektil (42) |
| **FV101** | Schnelleres Projektil (55) als M551/Legion | Niedrigster Schaden (2.01), geringes Leben (8.8) |
| **M528** | HMG speed 90, AP-Submunitionen | Kein klassischer Blast; Leben 8.4 |
| **FT-CROC** | Höchste Projektil-Geschwindigkeit unter Vanilla (140), Flamethrower | Sehr niedriges Leben (6.4), Einzel-Blast minimal (0.02/1.8) |

---

**Hinweis für Mod-Ersteller (Health/Leben anpassen):**  
Wenn du **max_health** (Leben) eines Fahrzeugs änderst, solltest du in derselben `.vehicle`-Datei auch die **Health-Effekt-Schwellen** anpassen. Diese legen fest, ab welchem verbleibenden Leben Schadens-Partikel (Rauch, Funken) angezeigt werden – z. B. `<effect event_key="health" value="12.5" ref="SmallSmokeVehicle" />`. Die `value`-Werte sind **absolute** Lebenspunkte (nicht Prozent). Pass sie an das neue max_health an, damit „leicht beschädigt“ / „stark beschädigt“ optisch zum neuen Leben passen (z. B. proportional skalieren: alter_value × neues_max_health / altes_max_health). Beispiel: Legion mit max_health 34 nutzt u. a. 12.5, 7.7, 3.7 für SmallSmokeVehicle und BrokenSparkle.

---

*Stand: Aus Mod- und Vanilla-.vehicle-, .weapon- und .projectile-Dateien. Leben = physics max_health. Proj. Speed = projectile_speed der Hauptkanone (.weapon). Damage/Radius = result class="blast" im Hauptprojektil (.projectile). „–“ = nicht als Einzel-Blast definiert (z. B. M528 HMG).*
