# Map-Marker in RWR AngelScript implementieren

Anleitung zur Implementierung von Live-Update-Markern auf der Karte (z.B. Captain-Position).

---

## 1. Grundprinzip

Der Befehl **`set_marker`** setzt oder aktualisiert einen Marker. Um einen Marker zu verfolgen (z.B. einer Figur):

1. **Marker setzen** - mit Position, Symbol, Fraktion
2. **`update()` nutzen** - jeden Frame die Position abfragen und `set_marker` erneut senden
3. **Marker entfernen** - wenn die Figur stirbt oder nicht mehr relevant ist

---

## 2. set_marker-Befehl

```xml
<command class='set_marker' 
  id='70001' 
  faction_id='0' 
  atlas_index='17' 
  size='0.75' 
  range='0.0' 
  enabled='1' 
  position='x y z' 
  text='Captain' 
  type_key='default'
  show_in_map_view='true' 
  show_in_game_view='false' 
  show_at_screen_edge='true' />
```

### Wichtige Attribute

| Attribut | Typ | Bedeutung |
|----------|-----|-----------|
| **id** | int | Eindeutige Marker-ID im Spiel (z.B. 70001, 70002) |
| **faction_id** | int | Fraktion, die den Marker **sieht**. Nur diese Fraktion sieht ihn auf der Karte |
| **atlas_index** | int | Symbol-Index im Atlas (siehe Tabelle unten) |
| **position** | string | `"x y z"` - wird bei jedem Update neu gesetzt |
| **text** | string | Label (z.B. "Captain", "Ziel") |
| **enabled** | 0/1 | 0 = Marker ausblenden, 1 = anzeigen |
| **show_in_map_view** | bool | Auf der Karte sichtbar |
| **show_in_game_view** | bool | In der 3D-Spielwelt sichtbar |
| **show_at_screen_edge** | bool | Am Bildschirmrand anzeigen |

### Atlas-Indizes (Symbole)

| atlas_index | Verwendung |
|-------------|------------|
| 3 | Santa reward |
| 4 | A10 / Gunship |
| 5 | Intel: „to investigate" (zu scouten) |
| 15 | Intel: „capture" (gescoutet) – kein Lupe-Index in RWR |
| 6-9 | Mortar, Cluster, Artillery |
| 10-14 | Paradrop, Humvee, Supply, Tank |
| 16 | VIP (Spieler-Symbol) |
| 17 | **VIP-Ziel** |
| 18 | Enemy Commander |
| 19 | Evil Commander |

---

## 3. Implementierung mit Live-Updates

### Schritt 1: Variablen

```cpp
protected int m_markerId = 70001;        // Eindeutige Marker-ID
protected int m_trackedCharacterId = -1; // Character-ID der verfolgten Figur
protected int m_factionId = -1;          // Fraktion (für Sichtbarkeit)
protected bool m_tracking = false;       // Ob gerade getrackt wird
```

### Schritt 2: update() - Position aktualisieren

```cpp
void update(float time) {
  if (!m_tracking) return;

  if (m_trackedCharacterId < 0) {
    findTrackedCharacter();  // Figur suchen (z.B. nach Spawn)
    return;
  }

  const XmlElement@ info = getCharacterInfo2(m_metagame, m_trackedCharacterId);
  if (info is null) {
    removeMarker();
    m_trackedCharacterId = -1;
    m_tracking = false;
    return;
  }

  string pos = info.getStringAttribute("position");
  addMarker(pos);
}
```

### Schritt 3: Marker setzen (addMarker)

```cpp
void addMarker(string position) {
  XmlElement c("command");
  c.setStringAttribute("class", "set_marker");
  c.setIntAttribute("id", m_markerId);
  c.setIntAttribute("faction_id", m_factionId);
  c.setIntAttribute("atlas_index", 17);
  c.setFloatAttribute("size", 0.75f);
  c.setFloatAttribute("range", 0.0f);
  c.setIntAttribute("enabled", 1);
  c.setStringAttribute("position", position);
  c.setStringAttribute("text", "Captain");
  c.setStringAttribute("type_key", "default");
  c.setBoolAttribute("show_in_map_view", true);
  c.setBoolAttribute("show_in_game_view", false);
  c.setBoolAttribute("show_at_screen_edge", true);
  m_metagame.getComms().send(c);
}
```

### Schritt 4: Marker entfernen (removeMarker)

```cpp
void removeMarker() {
  XmlElement c("command");
  c.setStringAttribute("class", "set_marker");
  c.setIntAttribute("id", m_markerId);
  c.setIntAttribute("enabled", 0);
  c.setIntAttribute("faction_id", m_factionId);
  m_metagame.getComms().send(c);
}
```

### Schritt 5: Tracking starten

Nach dem Spawn (oder anderen Auslöser):

```cpp
// Alten Marker entfernen, falls vorhanden
if (m_factionId >= 0) {
  removeMarker();
}
m_trackedCharacterId = -1;
m_factionId = factionId;
m_tracking = true;
```

---

## 4. Figuren finden (findTrackedCharacter)

Beispiel: Captain in einer Fraktion suchen

```cpp
void findTrackedCharacter() {
  array<const XmlElement@>@ characters = getCharacters(m_metagame, m_factionId);
  if (characters is null) return;
  for (uint i = 0; i < characters.length(); ++i) {
    int charId = characters[i].getIntAttribute("id");
    const XmlElement@ info = getCharacterInfo(m_metagame, charId);
    if (info !is null && info.getStringAttribute("soldier_group_name") == "captain") {
      m_trackedCharacterId = charId;
      return;
    }
  }
}
```

---

## 5. Marker-ID-Konvention

Verwende **eindeutige IDs** pro Marker-Typ, um Konflikte zu vermeiden:

| ID-Bereich | Verwendung |
|------------|------------|
| 20000-20001 | VIP Manager (Vanilla) |
| 70000 | Kill Commander (Vanilla) |
| 70001 | Captain (Mod) - VIP-Ziel für eigene Fraktion |
| 70010+ | Captain-Feind-Marker (70010 + factionId) - Enemy Commander für spotternde Fraktion |
| 70020+ | Weitere Mod-Marker |

---

## 6. Referenz-Implementierung

Siehe: `scripts/trackers/captain_spawn_command_tracker.as`

- Captain-Position wird mit VIP-Ziel-Symbol (atlas 17) angezeigt
- Nur für die eigene Fraktion sichtbar (`faction_id`)
- Live-Updates über `update()`
- Marker wird entfernt, wenn der Captain stirbt
