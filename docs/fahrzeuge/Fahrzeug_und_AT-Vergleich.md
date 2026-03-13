# Fahrzeug- & AT-Vergleich: Light, Medium, Heavy, Panzerfäuste

**Zweck:** Balance prüfen - Panzer vs. Anti-Tank in einer Datei. Pro Zeile ist der **stärkste** Wert **fett**.  
**Metriken (Fahrzeuge):** **Leben** = max_health | **Proj. Speed** = projectile_speed der Hauptkanone | **Damage** = Blast-Damage | **Radius** = Blast-Radius (m).  
**Metriken (AT):** **Preis** (RP) | **Schaden** | **Radius** | **Gesamtschaden** (bei Mehrfach-Projektilen).  
Quellen: Mod `.vehicle` / `.weapon` / `.projectile`; Mod-Overrides für M551, FV101, Legion, M528, FT-CROC, Wiesel (Leben/Health-Effekte/Despawn).

---

## 1. Light (Leicht-Pool, Intervall-Spawn 2-4 min)

*Light-Keys aus `vehicle_interval_spawn.as`: humvee, jeep, jeep_1, jeep_2, vfs_sport, willys_mb, wiesel_tow, wiesel_mk20, atv_base, atv_armory, vfs_base, truck, truck_1, truck_2.*

| Metrik | Humvee | Jeep | Jeep_1 | Jeep_2 | VFS Sport | Willys MB | Wiesel TOW | Wiesel Mk20 | ATV Base | ATV Armory | VFS Base | Truck | Truck_1 | Truck_2 |
|--------|--------|------|--------|--------|-----------|------------|------------|-------------|----------|------------|----------|-------|--------|--------|
| **Leben** | **7.2** | 2.4 | 2.4 | 2.4 | 4.2 | 2.4 | **9.5** | **9.5** | 5.5 | 5.5 | 4.2 | 6.8 | 6.8 | 6.8 |

→ **Hinweise:** Leichte Fahrzeuge haben keine Blast-Kanonen; Bewaffnung ist MG (Humvee, VFS, Willys), TOW-Rakete (Wiesel TOW), Mk20 (Wiesel Mk20) oder keine (Jeep, Truck, ATV). Vergleich nur über **Leben** sinnvoll. **Höchstes Leben:** Wiesel TOW/Mk20 (9.5, Mod), danach Humvee (7.2), Truck-Varianten (6.8). **Niedrigstes:** Jeep/Varianten und Willys (2.4).

---

### 1b. Leicht-Pool - Kurzüberblick & Stärken

| Metrik | Stärkster (Leicht) | Wert |
|--------|--------------------|------|
| **Leben** | Humvee | **7.2** |
| **Leben (ohne MG)** | Truck / Truck_1 / Truck_2 | **6.8** |
| **Leben (Kampfleicht)** | Wiesel TOW / Wiesel Mk20 | **9.5** (Mod) |

| Fahrzeugtyp | Stärken (Leicht) | Trade-off |
|-------------|-------------------|-----------|
| **Wiesel TOW / Mk20** | **Höchstes Leben (9.5**, Mod), TOW/Mk20-Bewaffnung | Leicht gepanzert |
| **Humvee** | Leben 7.2, MG | Langsamere Klasse als Jeeps |
| **Truck / Truck_1 / Truck_2** | Hohes Leben (6.8), Transport | Unbewaffnet |
| **ATV Base / Armory** | Leben 5.5, mobil | Unbewaffnet / Armory |
| **VFS Base / Sport** | Leben 4.2, MG (Base) | Geringeres Leben |
| **Jeep / Pigeon / TroX / Willys** | Schnell, wendig | Niedrigstes Leben (2.4) |

---

## 2. Medium-Pool (Mittel-Intervall-Spawn 5-8 min)

*Nur Fahrzeuge, die **nicht** schon im Light-Pool sind. Medium-Keys gesamt: Humvee, Wiesel TOW, Wiesel Mk20 (→ siehe Abschnitt 1), plus unten.*

| Metrik | APC (SIK-AP) | APC 1 (GT-C) | APC 2 (BTX) | SEV90 | Noxe | Vulcan Tank | Radio Jammer | Hovercraft | Cargo Truck |
|--------|--------------|--------------|--------------|-------|------|-------------|--------------|------------|--------------|
| **Leben** | **15.2** | **15.7** | **15.6** | **14.8** | **14.8** | **12.4** | **12.0** | **12** | 4.8 |
| **Bewaffnung** | HMG | HMG | HMG | 40mm (0.45/3.4) | Dual + HMG | HMG | - | MG | - |

→ **APC / APC 1 / APC 2:** Gepanzerte Truppentransporter, HMG-Turm (kein Einzel-Blast). **SEV90** (Mod): Leben 14.8 (Vanilla 8), 40-mm-Autokanone, Speed 100, 0.45/3.4 m. **Noxe** (Mod): Leben 14.8, Fallschirm, Dual-Waffe + HMG. **Vulcan Tank:** 12.4, HMG. **Radio Jammer:** 12 Leben, unbewaffnet. **Hovercraft** (Mod): Leben 12 (Vanilla 5.7), Wasser/Land, MG. **Cargo Truck:** 4.8, Transport.

---

## 3. Heavy (Normale Tanks + Heavy-Intervall-Spawn 12-15 min)

### 3a. Normale Tanks (Fraktions-Hauptpanzer)

| Metrik | RWR1a1 (tank) | Leopold II (tank_1) | TroX-80 (tank_2) |
|--------|---------------|---------------------|------------------|
| **Leben** | 25.35 | **26.2** | 25.95 |
| **Proj. Speed** | **226** | 175 | 165 |
| **Damage** | **10** | **10** | **10** |
| **Radius** | **8** | **8** | **8** |

→ **Balance:** Alle drei gleicher Schaden (10) und Radius (8). Leopold II höchstes Leben (26.2). RWR1a1 schnellstes Projektil (226). TroX-80 langsamstes Projektil (165).

### 3b. Heavy-Pool (alle im Heavy-Intervall-Spawn)

*Heavy-Keys aus `vehicle_interval_spawn.as`: tank_alt, tank_1_alt, tank_2_alt, m551, fv101, legion, m528, flamer_tank.*

| Metrik | tank_alt | tank_1_alt | tank_2_alt | M551 Sheriff | FV101 Scorpio | Legion | M528 | FT-CROC (Flamer) |
|--------|----------|------------|-------------|--------------|---------------|--------|------|------------------|
| **Leben** | 25.35 | 26.2 | 25.95 | 20 | 15 | **34** | 19.2 | 17.8 |
| **Proj. Speed** | **226** | 175 | 165 | 42 | 55 | 40 | 90 (HMG) | 140 |
| **Damage** | 6.02 | 6.02 | 6.02 | 4.01 | **3.01** | **12** | - (HMG) | 0.02 |
| **Radius** | 7 | 7 | 7 | 4.5 | **4** | **10** | - | 1.8 |

→ **Hinweise:**  
- **Alt-Tanks** (tank_alt, tank_1_alt, tank_2_alt): Gleiche Leben wie normale Tanks, schwächeres Projektil (6.02 / 7) als Haupttanks (10 / 8).  
- **M551 Sheriff:** Mod-Override Leben 20 (Vanilla 9.6); 42 speed, 4.01 damage, 4.5 radius.  
- **FV101 Scorpio:** Mod-Override Leben 15, **Damage 3.01**, **Radius 4** (eher anti-Person; Vanilla 2.01 / 3.3).  
- **Legion:** **Höchstes Leben (34)**, **stärkster Schaden (12)** und **größter Radius (10)** im Heavy-Pool (Mod-Override); langsames Projektil (40).  
- **M528:** Mod-Override Leben 19.2 (Vanilla 8.4); HMG (speed 90) + AP-Submunitionen (kein Einzel-Blast) → „-“.  
- **FT-CROC:** Mod-Override Leben 17.8 (Vanilla 6.4); Flamethrower (speed 140); Einzel-Blast 0.02 / 1.8.

---

## 4. Anti-Tank-Waffen (direkter Vergleich zu Panzer-Leben)

*Zum Abgleich: z. B. Legion (34) ≈ 4× Javelin (8.7); FV101 (15) ≈ 2× Javelin; SEV90/Noxe (14.8) ≈ 2× Javelin; M528 (19.2) ≈ 2-3× Javelin; FT-CROC (17.8) ≈ 2× Javelin; Wiesel (9.5) ≈ 1-2× Javelin; Hovercraft (12) ≈ 1-2× Javelin.*

| Waffe | Preis (RP) | Schaden | Radius | Projektile/Schuss | **Gesamtschaden** |
|:------|-----------:|--------:|-------:|-------------------|-------------------|
| M72 LAW | 30 | 3.6 | 5.5 m | 1 | **3.6** |
| RPG-7 | 30 | 4.0 | 6.0 m | 1 | **4.0** |
| M2 Carl Gustav | 50 | 5.2 | 6.0 m | 1 | **5.2** |
| SMAW | 70 | 6.0 | 5.5 m | 1 | **6.0** |
| Javelin | 100 | **8.7** | 5.0 m | 1 | **8.7** |
| M202 Flash | 200 | 3.0 ×4 | 4.5 m | 4 | **12.0** |

**Kurz:**  
- **Schaden relativ (Javelin = 100%):** M72 ~41 %, RPG-7 ~46 %, Carl Gustav ~60 %, SMAW ~69 %, M202 ~138 % (4 Raketen).  
- **Bester Preis/Schaden:** RPG-7 (7.5 RP/Schaden), dann M72 (8.3), Carl Gustav (9.6).  
- **Empfehlung:** Budget 30 → RPG-7; Mittelklasse 50-70 → Carl Gustav / SMAW; Premium Einzelschuss → Javelin; Max. Schaden → M202 (12.0, teuer).

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
| **tank_alt / tank_1_alt / tank_2_alt** | Höchstes Leben (25-26), schnellste/schnelle Projektile (165-226), guter Radius (7), Damage 6.02 | Weniger Damage/Radius als normale Mod-Tanks |
| **Legion** | Höchstes Leben (34), stärkster Damage (12), größter Radius (10) | Langsamstes Projektil (40) |
| **M551** | Leben 20 (Mod), Schaden 4.01, Radius 4.5 | Langsames Projektil (42) |
| **FV101** | Leben 15, Damage 3.01, Radius 4 (anti-Person), Projektil 55 | Leichter als andere Heavies |
| **M528** | Leben 19.2 (Mod), HMG speed 90, AP-Submunitionen | Kein klassischer Blast |
| **FT-CROC** | Leben 17.8 (Mod), Flamethrower speed 140 | Einzel-Blast minimal (0.02/1.8) |

---

**Hinweis für Mod-Ersteller (Health/Leben anpassen):**  
Wenn du **max_health** (Leben) eines Fahrzeugs änderst, solltest du in derselben `.vehicle`-Datei auch die **Health-Effekt-Schwellen** anpassen. Diese legen fest, ab welchem verbleibenden Leben Schadens-Partikel (Rauch, Funken) angezeigt werden - z. B. `<effect event_key="health" value="12.5" ref="SmallSmokeVehicle" />`. Die `value`-Werte sind **absolute** Lebenspunkte (nicht Prozent). Pass sie an das neue max_health an, damit „leicht beschädigt“ / „stark beschädigt“ optisch zum neuen Leben passen (z. B. proportional skalieren: **alter_value × neues_max_health / altes_max_health**). Beispiele: Legion (34), M528 (19.2), FV101 (15), M551 (20), FT-CROC (17.8), SEV90 (14.8), Noxe (14.8), Hovercraft (12) haben in den Mod-Overrides skalierte Werte.

**Hinweis für Mod-Ersteller (Despawn defekter Fahrzeuge):**  
**Alle** Fahrzeuge sollen, wenn sie defekt/zerstört sind, erst nach **20 Minuten** automatisch despawnen. Dafür in der `.vehicle`-Datei **time_to_live_unsteerable="1200"** setzen (1200 Sekunden = 20 Min). Die Mod-Basis `vehicle_base.vehicle` hat bereits 1200; Fahrzeuge, die das Attribut überschreiben (z. B. Legion, Noxe, M528, FV101, M551, FT-CROC), müssen explizit **1200** verwenden, damit sie nicht früher verschwinden.

---

## Update 1.1.0 – Leben-Erhöhungen & Radius-Erhöhungen

### Leben

| Fahrzeug | Alt | Neu |
|----------|-----|-----|
| **RWR1a1 (tank)** | 25.35 | **32.35** |
| **Leopold II (tank_1)** | 26.2 | **33.2** |
| **TroX-80 (tank_2)** | 25.95 | **32.95** |
| **tank_alt / tank_1_alt / tank_2_alt** | (wie Basis) | **(wie Basis)** |
| **FV101 Scorpio** | 15 | **20** |
| **M551 Sheriff** | 20 | **24** |
| **Legion** | 34 | **40** |
| **M528** | 19.2 | **23.2** |
| **FT-CROC (Flamer)** | 17.8 | **20.8** |

### Radius (Blast-Radius in m)

| Fahrzeug | Alt | Neu |
|----------|-----|-----|
| **RWR1a1 / Leopold II / TroX-80** | 8 | **10** |
| **tank_alt / tank_1_alt / tank_2_alt** | 7 | **9** |
| **M551 Sheriff** | 4.5 | **5.2** |
| **FV101 Scorpio** | 4 | **4.7** |
| **Legion** | 10 | **13** |

---

*Stand: Mod- und Vanilla-.vehicle-, .weapon-, .projectile-Dateien. Fahrzeuge: Leben = physics max_health; Proj. Speed = projectile_speed (.weapon); Damage/Radius = result class="blast" (.projectile). AT: Schaden/Radius aus jeweiligen `.projectile`; „-“ = kein Einzel-Blast (z. B. M528 HMG).*
