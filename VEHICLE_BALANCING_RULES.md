# Fahrzeug-Balancing-Regeln

**Zweck:** Faire, nachvollziehbare Regeln für dynamischen Vehicle-Spawn - spannenderes Spiel ohne Map-Anpassung.

---

## 1. Fraktionsbasierte Fahrzeuge

### Klarstellung

| Fraktion | Typische Fahrzeuge | Panzer |
|----------|--------------------|--------|
| **Green (0)** | tank.vehicle | US/USMC-Stil |
| **Grey (1)** | tank_1.vehicle | EU-Stil |
| **Brown (2)** | tank_2.vehicle | RU-Stil |

- **Fahrzeuge pro Fraktion** kommen aus den `*.resources` / `factions/*.xml` des jeweiligen Mods.
- **Ermittlung:** `getFactionInfo(metagame, factionId)` → `file` oder `name` → passender Vehicle-Key.
- **Fallback:** Unbekannte Fraktion → `tank.vehicle`.
- **Einfache Fahrzeuge** (Jeep, Buggy, Quad, Transport): Oft **gemeinsam** in `common.resources`; schwere Fahrzeuge (Panzer, APC) können **fraktionsspezifisch** sein.

### Wichtig

- **KI-Spawn** nutzt den Fraktions-Pool, nicht den Spieler-Shop-Preis.
- **Balancing** für Fahrzeuge: gleiche Kategorien (leicht/mittel/schwer) pro Fraktion annähernd gleichwertig halten.

---

## 2. Wann Spawnen?

### Übersicht

| Fahrzeug-Typ | Spawn-Modus | Intervall / Bedingung |
|--------------|-------------|------------------------|
| **Einfache Fahrzeuge** (Jeep, Buggy, Quad, Transport) | Intervall | z.B. alle 2-4 min |
| **APC / mittlere Fahrzeuge** | Intervall | z.B. alle 5-8 min |
| **Panzer** | Sehr selten / Event | z.B. alle 10-15 min oder nur bei Verlierer-Bonus |
| **Verlierer-Team** | Bedingt | Wenn nur noch 1 Basis → erleichterter Spawn oder Bonus-Fahrzeug |

### Konkrete Regeln

#### 2.1 Einfache Fahrzeuge - Intervall-Spawn

- **Trigger:** `update(float time)` - Zeit akkumulieren.
- **Intervall:** 120-240 s (2-4 min) pro einfachem Fahrzeug.
- **Pro Basis:** 1 Fahrzeug pro Intervall, oder Rotation über alle Basen.
- **Limit:** Max. X Fahrzeuge pro Fraktion gleichzeitig (optional).

#### 2.2 Panzer - Sehr selten

- **Option A:** Langes Intervall (z.B. 600-900 s / 10-15 min).
- **Option B:** Nur über **Verlierer-Bonus** (kein Basis-Intervall).
- **Option C:** Mix - Basis-Intervall + Verlierer-Bonus (z.B. 2 Basen verloren → 1 Panzer).

#### 2.3 Verlierer-Team - Bonus-Spawn

- **Bedingung:** `getBasesForFaction(metagame, factionId) == 1` (nur noch 1 Basis).
- **Effekt:** Solange Verlierer, z.B.:
  - Kürzeres Intervall für einfache Fahrzeuge.
  - Oder: 1 Panzer- / APC-Bonus nach X Sekunden.
  - Oder: Nach 2 Basen in Folge verloren → 1 Panzer (wie `DefenderTankHelp`).
- **Cooldown:** Verhindert Spam (z.B. 600 s Cooldown).

---

## 3. Wo wird gespawnt? - Spawn-Position finden

### Dynamisch, ohne Map-Anpassung

1. **Basen holen:** `getBases(metagame)`.
2. **Filtern:** Nur Basen mit `owner_id == factionId`.
3. **Position:** `base.getStringAttribute("position")` = **Basenmittelpunkt** (Capture-Point).
4. **Offset:** Kleiner Versatz (z.B. +8 m in X/Z, +5 m in Y) damit Fahrzeuge nicht übereinander spawnen.

### Code-Logik (Pseudocode)

```
für jede Basis mit owner_id == factionId:
    pos = base.position
    pos += Offset (8, 5, 0) oder (0, 5, 8)  // je nach Basis-Index
    create_instance(vehicle_key, pos, faction_id)
```

### Alternativen

- **getStartingBase():** Erste Basis der Fraktion (Hauptbasis) - für einzelne Bonus-Spawns.
- **getClosestBase():** Nächste Basis zu einer Position - z.B. wenn spawn near player gewünscht.

---

## 4. Implementierungs-Checkliste

| Schritt | Beschreibung |
|---------|--------------|
| 1 | Tracker mit `update(time)` für Intervall-Logik |
| 2 | `handleBaseOwnerChangeEvent` für Verlierer-Erkennung |
| 3 | `getBasesForFaction()` für „nur noch 1 Basis“ |
| 4 | `getBases()` + Filter `owner_id` für Spawn-Positionen |
| 5 | `getFactionInfo()` für fraktionsspezifischen Vehicle-Key |
| 6 | `create_instance` mit `position`, `faction_id`, `instance_key` |

---

## 5. Empfohlene Default-Werte

| Parameter | Wert | Begründung |
|-----------|------|------------|
| Einfache Fahrzeuge Intervall | 180 s | Ca. 3 min - regelmäßig, nicht überwältigend |
| APC Intervall | 360 s | 6 min - seltener als Jeep |
| Panzer Intervall | 600 s | 10 min - selten, impactful |
| Verlierer-Bonus Cooldown | 600 s | 10 min - kein Spam bei Base-Rush |
| Spawn-Offset von Basenmitte | 8 m | Platz für mehrere Fahrzeuge pro Basis |

---

## 6. Implementierung (vehicle_interval_spawn.as)

**Status:** Implementiert.

- **Einfache Fahrzeuge:** 2-4 min Intervall, zufällig pro Fraktion, Timer unabhängig.
- **Mittlere Fahrzeuge:** 5-8 min Intervall, gleiche Logik.
- **Basis-Auswahl:** Zufällige Basis der Fraktion (von denen, die `owner_id == factionId`).
- **Spawn-Position:** Basenmittelpunkt + Offset (8 m X/Z, 5 m Y).
- **Basis unter Beschuss:** RWR-API exponiert diesen Status nicht - Spawn erfolgt unabhängig davon.

---

*Stand: Basierend auf RWR-Script-API (query_helpers, getBases, getBasesForFaction, create_instance).*
