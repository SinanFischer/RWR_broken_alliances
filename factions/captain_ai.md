# Captain/Bodyguard – AngelScript-API für RWR

Referenz für Captain-Spawn, Befehle, Instanz-Tracking und Tod-Events.

---

## 1. Befehle an Captain/Bodyguards senden

### soldier_objective

Gibt einem Soldaten ein Ziel:

```xml
<command class='soldier_objective' 
  character_id='123' 
  target='x y z' 
  objective='defend' />
```

**Bekannte objectives:** `defend`, `protect`

**Beispiel – Basis verteidigen:**
```cpp
m_metagame.getComms().send(
  "<command class='soldier_objective' character_id='" + characterId + 
  "' target='" + basePosition + "' objective='defend' />");
```

---

## 2. Instanzen speichern

**Character-IDs (int)** als Referenz:

```cpp
int m_captainId = -1;
array<int> m_bodyguardIds;
```

### ID nach Spawn ermitteln

**Option A – character_spawn-Event** (create_instance mit `event='1'`):

```xml
<command class='create_instance' instance_class='soldier' instance_key='captain' 
  position='...' faction_id='...' event='1' />
```

Dann `handleCharacterSpawnEvent` überschreiben und `character_id` auslesen.

**Option B – Query nach Spawn** (wie kill_commander):

```cpp
array<const XmlElement@>@ characters = getCharacters(m_metagame, factionId);
for (uint i = 0; i < characters.length(); ++i) {
  const XmlElement@ info = getCharacterInfo(m_metagame, characters[i].getIntAttribute("id"));
  if (info !is null && info.getStringAttribute("soldier_group_name") == "captain") {
    m_captainId = characters[i].getIntAttribute("id");
    break;
  }
}
```

---

## 3. Tod abfragen

### character_die aktivieren

```cpp
m_metagame.getComms().send("<command class='set_metagame_event' name='character_die' enabled='1' />");
```

### Handler überschreiben

```cpp
protected void handleCharacterDieEvent(const XmlElement@ event) {
  const XmlElement@ target = event.getFirstElementByTagName("target");
  int deadId = target.getIntAttribute("id");
  
  if (deadId == m_captainId) {
    m_captainId = -1;
    // Captain gestorben – Respawn, Nachricht etc.
  }
  for (uint i = 0; i < m_bodyguardIds.length(); ++i) {
    if (m_bodyguardIds[i] == deadId) {
      m_bodyguardIds.removeAt(i);
      break;
    }
  }
}
```

**Event-Struktur:**  
`target` (id, position), optional `killer` (faction_id, player_id, position).

---

## 4. Bodyguards dem Captain folgen lassen („Squad ohne expliziten Join“)

Es gibt **keinen** expliziten `join_squad`-Befehl. Stattdessen: periodisch `soldier_objective` mit `objective='protect'` und `target = Captain-Position` senden (wie in kill_commander).

**Ablauf im captain_spawn_command_tracker:**

1. **findBodyguardsNearCaptain(pos)** – `getCharactersNearPosition` + Filter `soldier_group_name == "orange_bodyguards"` → IDs in `m_bodyguardIds`
2. **setBodyguardsToProtectCaptain(captainPosition)** – für jede lebende ID: `soldier_objective character_id=X target=... objective='protect'`; tote IDs entfernen
3. **updateBodyguardObjectives(pos, deltaTime)** – alle ~5 s Timer, dann findBodyguards (falls leer) + setBodyguardsToProtectCaptain

```cpp
// Alle 5 Sekunden:
void setBodyguardsToProtectCaptain(string captainPosition) {
  for (int i = int(m_bodyguardIds.length()) - 1; i >= 0; --i) {
    const XmlElement@ info = getCharacterInfo2(m_metagame, m_bodyguardIds[i]);
    if (info is null) { m_bodyguardIds.removeAt(uint(i)); continue; }
    // soldier_objective character_id=X target=... objective='protect'
  }
}
```

---

## 5. Implementierung für captain_spawn_command_tracker

1. Events aktivieren: `character_spawn` und/oder `character_die`
2. Nach Spawn: `event='1'` oder `findCommander`-Logik nutzen
3. IDs speichern: Captain + Bodyguards in Member-Variablen
4. `soldier_objective` direkt nach Spawn mit `target = Basis-Position`, `objective = "defend"`
5. Bodyguards: `updateBodyguardObjectives` mit `protect` auf Captain-Position (siehe §4)
6. `handleCharacterDieEvent` implementieren für Tod-Benachrichtigung/Respawn

---

## 6. Vanilla-Referenzen

| Datei | Inhalt |
|-------|--------|
| `kill_commander.as` | findCommander, soldier_objective, handleCharacterKillEvent |
| `vip_manager.as` | setVipObjective, handleCharacterDieEvent |
| `phase_controller_map12.as` | soldier_objective mit objective='protect' |
| `tracker.as` | handleCharacterSpawnEvent, handleCharacterDieEvent |
