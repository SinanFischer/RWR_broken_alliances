# Respawn-Slot-Delay – Systembeschreibung & Kritik

## 1. Ablauf des Systems (wie es gedacht ist)

```
[Spieler/KI stirbt]
       │
       ▼
 character_die-Event
       │
       ▼
 handleCharacterDieEvent()  →  addPendingDeath(factionId)
       │                            │
       │                            ▼
       │                    m_pendingDeaths[factionId]++
       │
       ▼
 [nächster update(delta)]
       │
       ▼
 m_timeAccum += time
 flushPendingDeaths()  →  für jede Fraktion: pending → Zeitstempel m_timeAccum an m_deathTimestamps anhängen
       │
       ▼
 m_applyAccum += time
 wenn m_applyAccum >= 1.0s:
       │
       ▼
 applyCapacityWithReservedSlots()
   für jede Fraktion:
     rawCap = getIntAttribute("soldier_capacity")  // aus getFactions()
     reserved = getReservedSlots(fid)              // Anzahl Tode mit (now - t) <= 10s
     effective = rawCap - reserved
     mult = effective / rawCap  (min 0.00001)
     change_game_settings: faction.capacity_multiplier = mult
       │
       ▼
 Engine erhält neuen capacity_multiplier
 → effektive Kapazität = soldier_capacity * mult
 → Spawn nur wenn (lebende Soldaten < effektive Kapazität)
```

**Kernidee:** Jeder Tod „reserviert“ für 10 Sekunden einen Slot (effektive Kapazität −1). Nach 10 s fällt der Zeitstempel aus dem Fenster, der Slot ist wieder frei.

---

## 2. Abgleich mit der Engine (was wir wissen / nicht wissen)

### 2.1 Wann liest die Engine die Kapazität?

- **Unbekannt.** Wir sehen nur die Script-API: `change_game_settings` wird gesendet. Ob die Engine den Befehl sofort verarbeitet, am Ende des Frames, oder beim nächsten „Spawn-Check“, ist **nicht dokumentiert** und nicht aus dem Code ableitbar (Engine ist binär).
- **Annahme:** Die Engine wendet neue Settings beim nächsten Spawn-Entscheid an. Dann hängt die „Altersdauer“ der alten Capacity davon ab, **wie oft** wir `change_game_settings` senden.

### 2.2 Wie lange arbeitet die Engine mit alter Capacity?

| Aspekt | Verhalten im Tracker | Konsequenz |
|--------|----------------------|------------|
| **Apply-Intervall** | Wir senden nur **alle 1 s** (`APPLY_INTERVAL = 1.0f`). | Zwischen zwei Sendungen (bis zu 1 s) nutzt die Engine weiter die **zuletzt gesendete** Capacity. Ein Tod bei t=0 wird bei uns erst bei t=1 s in `reserved` berücksichtigt. In dieser Sekunde kann **theoretisch ein Spawn zu viel** passieren (Slot war für die Engine noch frei). |
| **Tod → Zeitstempel** | Tode werden erst im **nächsten** `update()` mit `m_timeAccum` versehen (`flushPendingDeaths`). | Bis zum nächsten Frame (typisch ~16–50 ms) zählt der Tod noch nicht als „reserved“. Ein Spawn in diesem Frame nutzt noch die alte Capacity – **Randbedingung**, aber konsistent mit „kein nativer Respawn-Delay“. |
| **Kein Apply vor erstem Intervall** | Beim Start wird **sofort** `applyCapacityWithReservedSlots()` in `start()` aufgerufen, danach alle 1 s. | Erste Sekunde nutzt nun unseren Multiplikator (0 reserved). |

**Fazit Abgleich:**  
- Die Engine arbeitet **mindestens bis zum nächsten Apply** (bis zu **1 s**) mit der **alten** Capacity. Ein „exakt 10 s“-Slot ist damit **nicht** garantiert; realistisch ist „ca. 10 s, mit bis zu ~1 s Toleranz nach unten (Slot evtl. schon nach ~9 s nutzbar) und Abweichung durch Framing“.  
- Ob die Engine die Settings **pro Faction mergt** (nur gesetzte Attribute ersetzen) oder **ersetzt** (leere Faction = Reset), wissen wir nicht. Wenn sie ersetzt, könnten unsere Faction-Nodes **ohne** `spawn_interval` andere Werte (z. B. von SpawnTimeHandler) zurücksetzen – **Risiko**, siehe Code-Review unten.

---

## 3. Senior-Code-Review („Hate Review“)

### 3.1 Konzept / Architektur

- **Wir überschreiben global `capacity_multiplier`.** Jeder andere Tracker (Vanilla: SpawnTimeHandler, stage_invasion getChangeSettingsCommand, overtime, phase_controller_map12, comms_capacity_handler), der danach oder davor `change_game_settings` schickt, kann uns überschreiben oder von uns überschrieben werden. **Keine Koordination, keine „Single Source of Truth“** – das ist fragil sobald mehrere Systeme Capacity setzen.
- **Kein `spawn_interval` gesetzt.** Wir senden nur `capacity_multiplier`. Im Tracker steht nun: Engine merged vermutlich pro Attribut; Tracker **nach** anderen einbinden (z. B. SpawnTimeHandler), damit unser Mult greift bzw. spawn_interval erhalten bleibt.

### 3.2 Robustheit / Edge Cases

- **`soldier_capacity` aus getFactions():** Wir lesen `soldier_capacity` aus dem Faction-XML. Ob das zur Laufzeit aktualisiert wird (z. B. bei Basisverlust), ist unklar. Wenn es **statisch** vom Start ist, passt es. Wenn nicht, rechnen wir evtl. mit veralteter Cap – **nicht abgesichert**.
- **`parseFloat(part)`:** Es wird nun validiert: nur gezählt, wenn `t > 0`, `t <= now` und `(now - t) <= RESPAWN_SLOT_DELAY` – ungültige/defekte Einträge werden ignoriert.
- **Anzahl Factions:** Wir iterieren `getFactions()`. Wenn die Engine intern mehr Factions erwartet als wir Faction-Nodes schicken, könnte der Befehl **inkonsistent** sein („faction index 2 fehlt“). Umgekehrt: Wenn wir mehr senden als die Engine kennt, ignoriert sie die vermutlich – weniger kritisch.
- **Save/Load:** `m_deathTimestamps` und `m_timeAccum` werden **nicht** gespeichert. Nach Save/Load sind alle „reservierten“ Slots weg. Der 10s-Effekt ist dann bis zum nächsten Tod nicht mehr vorhanden – **bewusste Lücke**, aber für „jeder Tod zählt 10 s“ inkonsistent.
- **Pause:** Wenn `update(time)` bei Pause nicht aufgerufen wird oder `time == 0`, bleibt `m_timeAccum` stehen. Dann laufen die 10s **nicht** in Echtzeit weiter – reservierte Slots bleiben länger reserviert (Spielzeit vs. Echtzeit unklar dokumentiert).

### 3.3 Implementierungs-Details

- **Mutation in `getReservedSlots()`:** **Behoben.** `getReservedSlots()` zählt nur noch (keine Seiteneffekte). Alte Einträge werden in `pruneDeathTimestamps(fid)` entfernt, aufgerufen am Ende von `applyCapacityWithReservedSlots()`.
- **String-Parsing:** Validierung wie oben; Parsing-Logik doppelt (zählen + prune). Array von Floats wäre sauberer, aber AngelScript/Dictionary-Limits bleiben.
- **Kein Logging:** **Behoben.** Bei `reserved > 0` wird `_log("RespawnSlotDelay: fid=… reserved=… mult=…", 1)` ausgegeben.
- **Magic Number:** Im Tracker als Konstante mit Kommentar „damit Engine Fraktion nicht als tot sieht“ ergänzt.

### 3.4 Was fehlt (nach Verbesserungen)

- **`start()`:** **Behoben.** `start()` ruft `applyCapacityWithReservedSlots()` einmal auf, damit der erste Apply sofort erfolgt.
- **Konfiguration:** Delay und Apply-Intervall bleiben Konstanten; im Tracker als „Konfiguration“-Block kommentiert. User-Settings/XML wäre Aufwand.
- **`rawCap <= 0`:** **Behoben.** Es wird `mult = CAPACITY_MULTIPLIER_NEAR_ZERO` gesetzt (nicht 1.0), und `rawCap` wird auf mindestens 0 geclampt.

---

## 4. Kurzfassung

- **System:** Tode werden mit Zeitstempel gespeichert; alle 1 s wird die effektive Kapazität pro Fraktion um „Tode in den letzten 10 s“ reduziert und per `change_game_settings` an die Engine geschickt. So bleibt der Slot ~10 s „besetzt“.
- **Engine:** Unklar, wann die Engine die neuen Werte anwendet. Konservativ: Sie arbeitet **bis zu 1 s** mit der alten Capacity; „exakt 10 s“ ist nicht garantiert.
- **Code:** Nach Verbesserungen: Getter ohne Side-Effects, `start()` für sofortigen ersten Apply, Validierung der Zeitstempel, Logging bei reserved > 0, `rawCap <= 0` abgesichert, Konfiguration und Tracker-Reihenfolge im Kommentar. Offen: Save/Load der Zeitstempel, Pause-Verhalten, dynamische `soldier_capacity` zur Laufzeit.
