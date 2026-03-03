# RWR Waffen-Balancing: Regelwerk (Broken Alliances)

**Zweck:** Strikte Leitplanken für asymmetrisches Fraktions-Balancing nach dem **Schere-Stein-Papier-Prinzip**. Keine Waffe darf in allen Kategorien stark sein; jede extreme Stärke wird durch einen festgelegten XML-Malus ausgeglichen.

---

## RWR-Basisregeln (technisch)

- **Case-Sensitivity:** Alle Dateinamen und Referenzen in **Kleinbuchstaben**.
- **Pfade:** Ausschließlich **Forward Slashes** (`/`).

---

## Die 10 Balancing-Constraints

### 1. Fraktions-Arsenal (Schere-Stein-Papier)

- Jede der drei Fraktionen (USA, EU, RU) hat ihr Grund-Arsenal.
- **Asymmetrie-Pflicht:** Hat Fraktion A ein **Schild** (blockt Kugeln), MUSS Fraktion B eine **Explosivwaffe** (ignoriert Schilde) erhalten.
- Verteilung: USA = Präzision/Mobilität, EU = Phalanx/Unterdrückung, RU = Fläche/Explosiv.

### 2. Bewegungs-Strafe (Speed Modifier Matrix)

Nutze zwingend `<modifier class="speed" value="..." />` nach Waffenklasse:

| Klasse | Beschreibung | value (negativ) |
|--------|--------------|------------------|
| Standard | ARs, SMGs | `-0.02` bis `-0.08` |
| Mittel | Sniper, LMGs | `-0.08` bis `-0.15` |
| Schwer (Nahkampf/Defensiv) | TTI Schild | **exakt** `-0.35` |
| Schwer (Explosiv) | QLZ-87, MRL, FHJ-01 | `-0.40` bis `-0.45` |

### 3. Tödlichkeit vs. Handhabung (Kill Probability & Recoil)

- **WENN** `kill_probability > 1.0` (garantierter Kill):  
  **DANN** muss die Feuerrate langsam sein (`retrigger_time` > 0,5 s) **ODER** der Rückstoß massiv erhöht werden (`sustained_fire_grow_step` deutlich erhöhen).
- **WENN** die Waffe Dauerfeuer besitzt (hohe RPM):  
  **DANN** darf `kill_probability` maximal **0,5 bis 0,6** betragen.

### 4. Spawn-Raten-Ökonomie (Commonness)

Nutze `<commonness value="..." />` strikt nach Stärke:

| Stufe | Beschreibung | value |
|-------|--------------|--------|
| Kanonenfutter | Standard-Waffen | `0.1` bis `0.5` |
| Spezialisten | Mörser, leichte Sniper | `0.01` bis `0.05` |
| Absolute Elite | Kreissägen, QLZ-87, Truvelo | `0.0001` bis `0.005` (nur Offiziere/Bosse) |

### 5. Fahrzeug-Schaden (Die 17er-Grenze)

- **WENN** `damage < 17.0`: Reine **Anti-Infanterie**-Waffe.
- **WENN** `damage ≥ 17.0` (Fahrzeugschaden):  
  **DANN** muss `price > 150` **UND** `commonness < 0.005` gesetzt werden.

### 6. Motor-Limitierungen (Engine Constraints)

- **Stealth** ist eine reine Spielermechanik. KI kann nicht schleichen. Keine reinen Stealth-Waffen für die KI generieren (außer thematische Elite).
- **KI schaltet keine Feuermodi um.** Hat eine Waffe alternative Modi (z. B. Shotgun beim QBZ-95), **zwingend zwei separate** `.weapon`-Dateien anlegen.

### 7. Entfernungs- & Ballistik-Regeln (Range & Decay)

**projectile_speed:** Verbindliche Werte und Kategorien → **`docs/waffen-balancing/PROJEKTILGESCHWINDIGKEIT_REGELN.md`** (Spiel-Skala + Real-Referenz).

| Waffentyp | projectile_speed | kill_decay_start_time | kill_decay_end_time | sight_range_modifier |
|-----------|------------------|------------------------|---------------------|----------------------|
| Nahkampf (Shotgun/SBL) | 80–95 (siehe Regeln) | sehr kurz (z. B. 0,20) | max. 0,30 | — |
| Sturmgewehre | 155–165 (Referenz) | ca. 0,35 | ca. 0,70 | — |
| Sniper/DMR | 165–220 (siehe Regeln) | > 0,80 | entsprechend | **1,3–1,65** (Pflicht) |

### 8. Haltungs-Zwang für schwere Waffen (Stances)

- **WENN** schweres Dauerfeuer (LMG) **ODER** massiver Explosivschaden (z. B. QLZ-87):  
  Setze `can_shoot_standing="0"`, damit KI in Hocke/Liegen schießt.

### 9. Magazin-Ökonomie & Nachladen

- **WENN** `kill_probability > 1.0`:  
  **DANN** darf `magazine_size` maximal **5 bis 10** betragen.
- **BEI** Pump-Action-Shotguns oder Rohrmörsern:  
  Zwingend `<reload_one_at_a_time value="1" />` setzen.

### 10. Rucksack-Gewicht (Encumbrance)

- Für **jede** Waffe zwingend `<inventory encumbrance="..." />` passend zum Gewicht setzen (keine Waffe ohne Encumbrance).

---

## Workflow: Neue Waffe erstellen / Bestehende bewerten

1. **Denkprozess:**  
   Öffne einen `<denkprozess>`-Block. Prüfe die Waffe **systematisch gegen alle 10 Regeln**. Notiere: Welcher mathematische Trade-off (Schaden vs. Speed-Malus vs. Rückstoß) muss angewendet werden?

2. **Output:**  
   Liefere danach den exakten, **Ready-to-Use** XML-Code für die Waffe(n). Markiere jede Balancing-Entscheidung mit **Inline-Kommentaren**, z. B.  
   `<!-- Rule 2: Heavy Speed Penalty -->`  
   `<!-- Rule 3: kill_prob > 1.0 → retrigger_time > 0.5 -->`

---

## Schnell-Checkliste (vor Commit)

- [ ] Regel 1: Fraktion zugeordnet, Asymmetrie (Schild ↔ Explosiv) beachtet?
- [ ] Regel 2: Speed-Modifier gesetzt und in der richtigen Klasse?
- [ ] Regel 3: kill_prob vs. retrigger_time / sustained_fire_grow_step konsistent?
- [ ] Regel 4: commonness zur Stärke passend?
- [ ] Regel 5: Bei Fahrzeugschaden: price > 150 und commonness < 0,005?
- [ ] Regel 6: Keine KI-untauglichen Stealth-Only-Waffen; bei Modus-Wechsel zwei .weapon-Dateien?
- [ ] Regel 7: projectile_speed und Decay-Zeiten zum Waffentyp; Sniper sight_range_modifier 1,3–1,65?
- [ ] Regel 8: Schwere Waffen can_shoot_standing="0"?
- [ ] Regel 9: Bei kill_prob > 1,0 Magazin max. 5–10; Pump/Rohr reload_one_at_a_time="1"?
- [ ] Regel 10: encumbrance gesetzt?
- [ ] RWR-Basis: Kleinbuchstaben, Forward Slashes?
