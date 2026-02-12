# Recherche: Gameplay-Tweaks für RWR Mods

**Ziel:** Prüfung aller Workspace-Ordner und Vanilla-Dateien auf Einstellungsmöglichkeiten für:
1. Verlängerung der Wounded States (Zeit bis Verwundeter stirbt/Respawn)
2. Erhöhung der Despawn-Dauer kaputter Fahrzeuge
3. Wounded Soldiers verlieren Blut (Blutpartikel über Zeit)
4. Leichen-Limit über UI-Maximum hinaus erhöhen

---

## 1. WOUNDED STATE – Verlängerung der Zeit, in der ein Soldat Hilfe braucht

### Gefundene Parameter

| Parameter | Datei | Aktueller Wert | Bedeutung |
|-----------|-------|----------------|-----------|
| `wounded_auto_death_time` | `vanilla/factions/default_base.character` | **60.0** | Sekunden bis ein verwundeter Soldat automatisch stirbt (ohne Medic) |
| `wounded_medic_call_time` | `vanilla/factions/default_base.character` | **5.0** | Cooldown für Medic-Ruf |
| `wounded_max_dot_to_move` | `vanilla/factions/default_base.character` | -0.5 | Bewegungseinschränkung |
| `wounded_moving_steer_amount` | `vanilla/factions/default_base.character` | 0.06 | Steuerung beim Kriechen |
| `check_wounded_time` | `vanilla/factions/default.ai` | **3.0** | Intervall (Sek), in dem KI nach Verwundeten sucht |
| `consider_someone_already_healing_wounded_distance` | `vanilla/factions/default.ai` | 10.0 | Abstand, ab dem KI annimmt, jemand heilt bereits |

### Referenz-Dateien

- **Vanilla:** `vanilla/factions/default_base.character` → `wounded_auto_death_time` = 60.0
- **RWR_total_conversion_mod:** Eigene `factions/default_base.character` mit **90.0** Sek (implementiert)
- **Project_Apocalypse:** Nutzt Vanilla-Karaktere

### Implementierung (Status)

**RWR_total_conversion_mod:** Vollständige Kopie von Vanilla `default_base.character` mit Override:

```xml
<parameter class="wounded_auto_death_time" value="90.0" />
```

**Hinweis:** `check_wounded_time` in `default.ai` steuert nur das KI-Intervall zum Prüfen auf Verwundete, nicht die Dauer des Wounded-States. Für längere Wounded-Zeit entscheidend ist `wounded_auto_death_time`.

---

## 2. FAHRZEUG-DESPAWN – Dauer bis kaputte Fahrzeuge verschwinden

### Gefundene Parameter

| Parameter | Datei | Vanilla-Wert | Bedeutung |
|-----------|-------|--------------|-----------|
| `time_to_live_unsteerable` | `vanilla/vehicles/vehicle_base.vehicle` | **40** | Sekunden, die ein zerstörtes Fahrzeug sichtbar bleibt, bevor es despawned |
| `time_to_live_unsteerable` | Einzelne Fahrzeuge (z.B. m551.vehicle) | 85–105 | Fahrzeugspezifische Overrides |

### Referenz-Dateien

- **Vanilla Base:** `vanilla/vehicles/vehicle_base.vehicle` → `time_to_live_unsteerable="40"`
- **Beispiele mit Override:**
  - `m551.vehicle`: 95
  - `fv101.vehicle`: 105
  - `vfs_base.vehicle`: 85
  - `dukw.vehicle`, `luchs.vehicle`: 60

### Implementierung

**Option A – Global für alle Fahrzeuge:**  
Eine eigene `vehicle_base.vehicle` im Mod mit höherem Wert:

```xml
<vehicle time_to_live_unsteerable="120" >
    <tag name="vehicle" />
</vehicle>
```

**Option B – Pro Fahrzeug:**  
In jeder `.vehicle`-Datei, die `vehicle_base.vehicle` nutzt, den Parameter setzen:

```xml
<vehicle file="vehicle_base.vehicle" time_to_live_unsteerable="180" ... />
```

**RWR_total_conversion_mod:** `vehicles/vehicle_base.vehicle` mit `time_to_live_unsteerable="1200"` (20 Min) – **implementiert**.

---

## 3. WOUNDED BLEEDING – Blutpartikel bei liegenden Verwundeten

### Aktueller Stand

- **Blut-Effekte** werden bei **Treffern** ausgelöst (in Projektilen/Waffen via `effect class="result"` oder `effect class="stab"` mit `ref="BloodSplat"` etc.).
- **Character-Definition:** `default_base.character` enthält:
  ```xml
  <effect class="blood" ref="BloodSplat" />
  <effect class="blood" type="splat_map" size="2.0" atlas_index="3" layer="3" additive="1" apply_gore_factor="1" />
  ```

### Keine Mod-Unterstützung für „Wounded-Bleeding“

- **Kein Parameter** wie `wounded_bleed_interval`, `wounded_blood_particle_rate` o.ä. in den durchsuchten Dateien.
- Blutpartikel werden nur bei **Hits** (Treffer) gespawnt, nicht zeitbasiert für liegende Verwundete.

### Versuch: AngelScript-Tracker (entfernt)

- **Implementiert war:** `WoundedBleedingTracker` + `wounded_bleed.projectile` – Tracker lauschte auf `player_wound`, spawnte alle 10 Sek ein Projektil mit BloodSplat-Effekten.
- **Problem:** Funktionierte nicht zuverlässig (z.B. in Quickmatches kein sichtbares Bluten); `player_wound`/create_instance-Logik passte nicht zum gewünschten Verhalten.
- **Status:** Feature entfernt – Script, Projektil und alle Tracker-Referenzen gelöscht.

**Fazit:** „Wounded-Bleeding“ über AngelScript ist theoretisch möglich, aber die aktuelle Mod-API liefert kein zuverlässiges Ergebnis. Empfehlung: RWR-Wiki/Forum oder Modding-Discord prüfen.

---

## 4. LEICHEN-LIMIT (Corpse Limit) – Über UI-Maximum hinaus

### Gefundene Referenzen

- **UI-Schlüssel:** `Clear bodies threshold` in `vanilla/languages/*/ui.xml`
- **Deutsche Übersetzung:** „Leichen löschen Grenzwert“ (bzw. ähnlich)
- **Keine XML/Mod-Konfiguration** für den konkreten Maximalwert in den durchsuchten Paketen.

### Vermutung

- Der Wert ist eine **Spieleinstellung** (inkl. UI-Slider).
- Das **Maximum** des Sliders ist vermutlich in der **Engine** (C++/binär) definiert.
- Mod-Pakete stellen keine sichtbare Konfiguration für diesen Wert bereit.

### Web-Recherche (AngelScript / Config)

- **AngelScript:** Keine API gefunden, die das Leichen-Limit oder die „Clear bodies threshold“-Einstellung beeinflusst. `getCharacterInfo`, `character_die`, `character_kill` usw. dienen der Character-Logik, nicht der Engine-Rendering-/Cleanup-Logik.
- **Config:** Laut RWR-Wiki existiert `settings.xml` im ProgramData-Ordner; keine dokumentierte Option für „clear bodies“ oder „corpse limit“.
- **AngelScript-Perspektive:** Scripts können keine Leichen löschen oder das Limit überschreiben. Das Entfernen von Leichen erfolgt in der Engine; es gibt keine `remove_corpse`- oder `set_body_limit`-Kommandos in der Mod-API.

### Mögliche Ansätze

1. **rwr_config.exe:** Prüfen, ob es dort eine Option oder eine Config-Datei gibt.
2. **Spieler-Config:** Typischer Ort: `%USERPROFILE%\Documents\RunningWithRifles\` oder `%ProgramData%\` – nach XML/INI mit „bodies“, „corpse“, „threshold“ suchen.
3. **Command-Line:** Laut RWR-Wiki gibt es Switches wie `debugmode`, `no_simulation` – ob einer davon das Leichen-Limit beeinflusst, ist unklar.
4. **Community:** RWR-Forum, Steam-Discussion, Modding-Discord – nach Feature-Request oder Engine-Hack fragen.

**Fazit:** Weder über Mod-Pakete noch über AngelScript lässt sich das Leichen-Limit über das UI-Maximum hinaus erhöhen. Die Logik liegt in der Engine; die Mod-API stellt dafür keine Schnittstelle bereit.

---

## 5. Datei-Übersicht (alle relevanten Funde)

### Wounded / Character

| Pfad | Inhalt |
|------|--------|
| `vanilla/factions/default_base.character` | `wounded_auto_death_time`, `wounded_medic_call_time`, etc. |
| `vanilla/factions/default.ai` | `check_wounded_time`, `consider_someone_already_healing_wounded_distance` |
| `vanilla/factions/medic.ai` | `check_wounded_time` = 2.0 (Medics prüfen öfter) |
| `vanilla/factions/snowman.character`, `dog.character`, `elf.character`, `chicken_base.character` | Char-spezifische Overrides |
| `RWR_total_conversion_mod/factions/default_base.character` | `wounded_auto_death_time` = 90.0 (Mod-override) |
| `RWR_total_conversion_mod/factions/default.ai` | `check_wounded_time` = 2.0 |

### Vehicles / Despawn

| Pfad | Inhalt |
|------|--------|
| `vanilla/vehicles/vehicle_base.vehicle` | `time_to_live_unsteerable="40"` |
| `vanilla/vehicles/m551.vehicle`, `fv101.vehicle`, `vfs_base.vehicle` | Höhere Overrides (85–105) |
| `RWR_total_conversion_mod/vehicles/vehicle_base.vehicle` | `time_to_live_unsteerable="1200"` (20 Min) |

### Blood / Effects

| Pfad | Inhalt |
|------|--------|
| `vanilla/factions/default_base.character` | `<effect class="blood" ref="BloodSplat" />` |
| `vanilla/particles/bloodsplat2.particle` | Partikel-Definition |
| `vanilla/weapons/*.projectile`, `*.weapon` | `effect class="result"` / `effect class="stab"` mit BloodSplat |

### Corpse Limit

| Pfad | Inhalt |
|------|--------|
| `vanilla/languages/*/ui.xml` | Text-Key „Clear bodies threshold“ |
| Keine Mod-Konfiguration gefunden | – |

### Scripts (Wounded-Referenzen)

| Pfad | Inhalt |
|------|--------|
| `vanilla/scripts/trackers/self_heal.as` | `handlePlayerWoundEvent`, `getIntAttribute("wounded")` |
| `vanilla/scripts/trackers/basic_command_handler.as` | Admin-Command `wound` |
| `vanilla/scripts/internal/tracker.as` | Event `player_wound` |

---

## 6. Zusammenfassung

| Thema | Modding möglich? | Status RWR_total_conversion_mod |
|-------|------------------|----------------------------------|
| **1. Wounded-Zeit verlängern** | Ja | ✓ `default_base.character` mit 90 Sek |
| **2. Fahrzeug-Despawn verlängern** | Ja | ✓ `vehicle_base.vehicle` mit 1200 Sek (20 Min) |
| **3. Wounded-Bleeding (Blut über Zeit)** | Nein (zuverlässig) | ✗ Versuch entfernt – AngelScript-Ansatz funktionierte nicht |
| **4. Leichen-Limit erhöhen** | Nein | Engine/Config; keine Mod-API |

---

## 7. Mögliche Quellen für weitere Infos

- [RWR Wiki – Handling mods](https://runningwithrifles.fandom.com/wiki/Handling_mods)
- [RWR Wiki – Command line switches](https://runningwithrifles.fandom.com/wiki/Command_line_switches)
- [RWR Wiki – Manual](https://runningwithrifles.fandom.com/wiki/Manual)
- RWR-Forum / Steam-Discussion für Modding
- Spieler-Config in `%USERPROFILE%\Documents\` oder unter Steam-Installation
