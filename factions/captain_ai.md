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

## 4. Bodyguards dem Captain folgen lassen (wie kill_commander)

Es gibt **keinen** expliziten `join_squad`-Befehl. **Kill_commander-Pattern:** periodisch `soldier_objective` mit `objective='defend'` senden:
- **Captain:** `target = Spawn-Position` → bleibt in Base
- **Bodyguards:** `target = Captain-Position` → folgen ihm

**Ablauf im captain_spawn_command_tracker:**

1. **m_captainSpawnPosition** – beim Spawn speichern; Captain erhält `defend` darauf
2. **findBodyguardsNearCaptain(pos)** – `getCharactersNearPosition` (105m Radius) + Filter `soldier_group_name == "orange_bodyguards"`
3. **setBodyguardsOnDefend(captainPosition, "defend")** – für jede lebende ID: `soldier_objective ... objective='defend' target=Captain-Position`
4. Alle 5 s: `setCaptainObjective(m_captainSpawnPosition, "defend")` + `setBodyguardsOnDefend(captainPos, "defend")`

**Marker bei Captain-Tod entfernen:** `handleCharacterKillEvent` → wenn `target.id == m_captainId`, `cleanupOnCaptainGone()` (Marker aus, State zurückgesetzt).

---

## 5. Implementierung für captain_spawn_command_tracker (kill_commander-Pattern)

1. **character_kill** aktivieren (Constructor)
2. Nach Spawn: `findCaptain()` (Query), `m_captainSpawnPosition` speichern
3. **Captain:** alle 5 s `soldier_objective defend` auf Spawn-Position (bleibt in Base)
4. **Bodyguards:** alle 5 s `soldier_objective defend` auf Captain-Position (folgen)
5. `handleCharacterKillEvent`: bei Captain-Tod → `cleanupOnCaptainGone()` (Marker weg)

---

## 6. Captain darf kein Fahrzeug benutzen

In `captain.character` (vererbt von `default_miniboss_male`):

```xml
<parameter class="can_use_vehicles" value="0" />
```

Analog: `evil_commander_base.character`, `easterbunny.character`, `snowman.character`.

---

## 7. Enemy-Sighting → Marker für Feinde

**Einschränkung:** Die RWR AngelScript-API bietet **kein Event** für „Spieler hat Gegner mit Mauszeiger gesichtet“. Es gibt u.a. `character_spawn`, `character_die`, `character_kill` – kein `character_spotted` oder `target_changed`.

**Folge:** Ein Marker, der **nur nach Sichtung** für die entdeckende Fraktion erscheint, ist per Script **nicht umsetzbar**.

**Möglicher Workaround:** Zusätzlichen Marker mit `faction_id = Feindfraktion` und `atlas_index = 18` (Enemy Commander) setzen – der Captain wäre dann **dauerhaft** auf der Feindkarte sichtbar, nicht erst nach Sichtung.

---

## 8. Vanilla-Referenzen

| Datei | Inhalt |
|-------|--------|
| `kill_commander.as` | findCommander, soldier_objective, handleCharacterKillEvent |
| `vip_manager.as` | setVipObjective, handleCharacterDieEvent |
| `phase_controller_map12.as` | soldier_objective mit objective='protect' |
| `tracker.as` | handleCharacterSpawnEvent, handleCharacterDieEvent |
