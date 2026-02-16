# Fire-Mission-Funkspruch (Broken Alliances) – Implementierungsplan

## 1. Ziel

- **Feature:** Artillerie-Call läuft nicht sofort, sondern startet eine **5-Sekunden-Funksequenz**. Koordinaten werden beim ersten Klick gelesen, der Dialog wird vom Script abgespult.
- **Effekt:** Taktische Verwundbarkeit (Spieler ist gebunden), Transparenz fürs Team, optional Abbruch bei Tod + Refund.

---

## 2. Architektur (Schatten-Call)

- **UI-Trigger:** Ein Call in `calls/` + `all_calls.xml` mit **normalen Kosten** (z. B. 400 RP), **leerer `<round>`** (wie `gps.call`), **`notify_metagame="1"`**.
- **Kein** zweiter Weg (Dummy-Projektil + `on_item_delivery_*`): Dieser Callback existiert in der Codebasis nicht. Stattdessen: Engine sendet **call_event** mit phase **"queue"** → Script startet dort.
- **Ablauf:** Spieler wählt Call (H) → klickt Ziel → RP werden abgezogen → Engine sendet `call_event` (phase `queue`) mit `character_id`, `target_position`, `faction_id`, `id` → Tracker startet 5‑s‑Sequenz → nach 5 s: Einschlag per `create_instance` (grenade/artillery_shell).

---

## 3. Ablauf der 5-Sekunden-Sequenz

| Zeit | Quelle | Aktion |
|------|--------|--------|
| 0 s | Spieler | "Command, this is **[Rang] [Nachname]**, requesting fire mission, over!" – Identifikation = **der gerade gespielte Soldat** (Rang + Name des Soldaten), **nicht** der Player-Account-Name. |
| 1.5 s | Commander | "Send coordinates, [Rang] [Nachname]. Over." (sendFactionMessageKey) |
| 3 s | Spieler | "Target coordinates: [X-Y-Z]. Requesting 105mm barrage!" (Koordinaten aus target_position) |
| 5 s | Commander | "Coordinates confirmed. Shot, over!" → Einschlag (create_instance) |

---

## 4. Vanilla-APIs nutzen (KISS)

- **Tracker:** `handleCallEvent` bei phase `"queue"` für unseren Call-Key; `update(float time)` für Timer (0 → 1.5 → 3 → 5 s).
- **Daten aus event:** `event.getIntAttribute("character_id")`, `event.getStringAttribute("target_position")`, `event.getIntAttribute("faction_id")`, `event.getIntAttribute("id")`.
- **Identifikation (Rang + Name):** Siehe Abschnitt 12. Es zählt der **Soldat**, der gerade gespielt wird (hat i. d. R. Vor- und Nachname + einen Rang). **Nicht** der Player-/Steam-Namen verwenden.
- **Spieler „sprechen“:**
  - **Sprechblase (position):** `sendPrivateMessage(metagame, playerId, text, position)` mit Character-Position als `pos` (siehe query_helpers: `position`-Attribut am chat-Command).
  - **Faktion als Charakter:** `sendFactionMessageKeySaidAsCharacter(metagame, factionId, characterId, key, dictionary(), priority)` (Keys in Dict anlegen).
- **Commander:** `sendFactionMessageKey(metagame, factionId, key, replacements, priority)`.
- **Koordinaten-String:** `target_position` aus Event (z. B. "x y z"); für Anzeige formatieren (z. B. "X-Y-Z").
- **Einschlag:** Wie gunship_run: `create_instance` mit `instance_class='grenade'`, `instance_key='artillery_shell.projectile'` (oder eurer Key), `position=target_position`, `faction_id`, `character_id`.

---

## 5. Optionale Features

- **Bewegungssperre:** In .call `acknowledge_time="5.0"` setzen → Engine könnte Bewegung während Acknowledge-Phase sperren (wie bei Artillerie kurz).
- **Abbruch bei Tod:** In Tracker `handleCharacterDieEvent` implementieren; wenn `character_id == gespeicherter Anforderer` und Sequenz noch nicht bei „Shot, over“ → Sequenz ungültig, kein create_instance.
- **Refund:** Siehe Abschnitt 8 – per `rp_reward` (positiver Wert) an character_id; bei Tod vor „Shot, over“ Refund + Abbruch.

---

## 6. Dateien / Schritte

1. **Call-XML (Schatten-Call):** Neue .call-Datei (z. B. `fire_mission_radio.call`) – leere `<round>`, `notify_metagame="1"`, Preis (z. B. 400), `acknowledge_time="5.0"` optional.
2. **all_calls.xml:** Eintrag für diesen Call.
3. **Tracker (AngelScript):** Neuer Tracker (z. B. `fire_mission_radio_tracker.as`):
   - Includes: `tracker.as`, `query_helpers.as`, `query_helpers2.as`, `helpers.as`, `log.as`.
   - `handleCallEvent`: bei `call_key == "fire_mission_radio.call"` und phase `"queue"` → Daten speichern, Sequenz starten (Timer = 0).
   - `update(time)`: Timer akkumulieren; bei 0 / 1.5 / 3 / 5 s passende Nachrichten senden; bei 5 s create_instance, Sequenz beenden.
   - Optional: `handleCharacterDieEvent` → bei Tod des Anforderers laufende Sequenz abbrechen (kein Schlag).
4. **Gamemode:** Tracker in Invasion-Gamemode registrieren (wie CallMarkerTracker / GpsLaptop).
5. **Dict-Keys:** Für Commander- und ggf. Charakter-Texte Keys anlegen (oder erstmal feste Texte per sendFactionMessage).

---

## 7. Sprechblase vs. Chat

- **Sprechblase:** Chat-Command mit **`position`** (sendPrivateMessage mit `pos` = Character-Position) – nur für nahe Spieler sichtbar, immersiver.
- **Chat-Log:** sendFactionMessage/sendFactionMessageKey ohne position – alle Faktion, dauerhaft im Log.
- Empfehlung: Sprechblase für „Spieler spricht“ (mit position), Commander wie gewohnt Faction-Message.

---

## 8. Refund (gelöst)

- **API:** `<command class='rp_reward' character_id='X' reward='400' />` – positiver Wert = RP gutschreiben (z. B. intel_manager.as, escort_reward_handler.as, repair_crane.as). mrl_manager.as nutzt negativen Wert zum Abzug.
- **Refund bei Abbruch:** Bei Tod vor „Shot, over“ → `rp_reward` mit Call-Kosten (z. B. 400) an `character_id` des Anforderers senden; danach „Communication lost! Fire mission aborted. RP refunded.“ (notify oder sendFactionMessage).

---

## 9. Nächste Schritte

1. Schatten-Call anlegen und in all_calls eintragen.
2. Tracker skizzieren (handleCallEvent + update + optional handleCharacterDieEvent).
3. Dict-Keys oder feste Texte für Commander/Spieler definieren.
4. Im Spiel testen: Call auslösen → Sequenz + Einschlag; Tod vor 5 s → Abbruch.
5. Optional: acknowledge_time und Refund (falls API gefunden) ergänzen.

---

## 10. Offene Punkte – für 100 % Erfolgsrate klären

Diese Punkte **vor oder während** der Implementierung prüfen, damit das System wie gewünscht funktioniert:

| # | Thema | Frage / Risiko | Wie klären |
|---|--------|-----------------|------------|
| 1 | **Sprechblase (position)** | Wird `chat` mit `position` wirklich als Sprechblase nur für nahe Spieler gerendert, oder als normaler Chat? | In-Game-Test: sendPrivateMessage(..., pos=characterPosition) mit zweitem Spieler in Reichweite / außer Reichweite beobachten. |
| 2 | **Chat „als Spieler“ für alle** | sendPrivateMessage geht nur an einen player_id. Sollen **alle** Teammitglieder den Funkspruch sehen? Dann: sendFactionMessage mit said_as_character_id oder festen Text; oder Engine-Doku, ob chat mit player_id + faction_id = Faction-Chat als Spieler. | Entscheidung: Nur Anforderer vs. ganze Faktion; ggf. sendFactionMessageKeySaidAsCharacter für „Spieler spricht“ (Key mit %name%, %coords%). |
| 3 | **Commander-/Chat-Keys** | Wo liegen die Keys für sendFactionMessageKey / sendFactionMessageKeySaidAsCharacter? (Lokalisierung/Spieldaten.) | In Vanilla-Paketen nach „key“/„dict“/„comment“ suchen; oder erstmal **sendFactionMessage(metagame, factionId, "fester Text")** ohne Keys nutzen, bis Keys gefunden. |
| 4 | **character_id → player_id** | call_event liefert character_id, kein player_id. Für sendPrivateMessage brauchen wir player_id. | Lookup: getPlayers(metagame) durchlaufen, wo player.getIntAttribute("character_id") == ourCharacterId → player.getIntAttribute("player_id"). Bei AI-Charakteren character_id ohne Spieler → Abbruch oder Skip. |
| 5 | **Spielername für Anforderer** | Name für „[Name]“ im Dialog: Character hat ggf. keinen name, Player schon. | getPlayerInfo nach obigem player_id → getStringAttribute("name"); Fallback: "Soldier" wenn kein Spieler. |
| 6 | **acknowledge_time = Bewegungssperre** | Sperrt acknowledge_time="5.0" tatsächlich die Bewegung für 5 s? | In-Game-Test: Call mit acknowledge_time="5.0" anlegen, auslösen, Bewegung in den 5 s probieren. |
| 7 | **create_instance Artillerie** | Welcher instance_key für 105mm/Artillerie in Broken Alliances? (artillery_shell.projectile vs. eigener Key.) | In RWR_broken_alliances/calls oder projectiles nach passendem Projektil suchen; sonst vanilla artillery_shell.projectile. |
| 8 | **Mehrere gleichzeitige Funksprüche** | Zwei Spieler starten kurz nacheinander den Call → zwei Sequenzen laufen parallel. | Tracker: Array/Liste laufender Sequenzen (pro callId oder character_id), in update() alle abarbeiten; handleCharacterDieEvent nur eigene Sequenz abbrechen. |
| 9 | **Event-Reihenfolge** | Wird „queue“ vor oder nach „acknowledge“ gesendet? Reicht es, nur auf „queue“ zu reagieren? | In Tracker loggen: beide Phasen ausgeben; Sequenz nur einmal pro call_id starten (z. B. nur bei „queue“). |
| 10 | **Soldatenname (nicht Player-Name)** | Hat der Character ein Attribut für den Soldatennamen (Vorname + Nachname)? Funk-ID = **Soldat**, nicht Steam-Name. | getCharacterInfo-Response loggen / Engine-Doku. Primär: Soldatenname vom Character; Fallback: Player-Name oder „Soldier“. Rang immer aus Character-XP. |

---

## 10b. Verifikation aus Mod-Paketen (geprüft: vanilla, RWR_broken_alliances, Project_Apocalypse, minimodes, full_campaign_template, deathmatch, vanilla.desert, vanilla.winter)

Antworten bzw. Referenzen, die sich in den Paketen finden:

| # | Thema | Befund in den Paketen |
|---|--------|------------------------|
| **1** | **Sprechblase (position)** | `query_helpers.as`: `sendPrivateMessage(metagame, playerId, text, pos)` und `sendPrivateMessageKey(..., pos)` setzen bei `pos != ""` das Attribut **`position`** am chat-Command (`command.setStringAttribute("position", pos)`). Ob die Engine das als Sprechblase nur für nahe Spieler rendert, steht im Script nicht – **In-Game-Test nötig**. |
| **2** | **Chat „als Spieler“ für alle** | **Antwort:** `sendFactionMessageKeySaidAsCharacter(metagame, factionId, characterId, key, replacements, priority)` sendet Chat mit **`said_as_character_id`** → Faktion sieht die Meldung **als von diesem Charakter gesprochen**. Verwendet in `squad_equipment_kit_navy.as`, `squad_equipment_kit.as`, `intel_manager_quickmatch.as`, `xmas_trap.as` (vanilla). Für „Spieler spricht, alle Faktion sehen“: diese API nutzen. |
| **3** | **Commander-/Chat-Keys** | Keys sind **reine Strings** (z. B. `"squad_equipment_kit, equip"`, `"VIP briefing"`, `"aircraft coming"`, `"Enemy Commander elimiated, part 1"`). Texte liegen in **`vanilla/languages/<lang>/misc_text_vanilla.xml`** als `<text key="...">` (teilweise mit Attribut `text="..."` für Übersetzung). Kein separates „dict“-File – Keys werden vom Spiel aus den Sprach-XML-Dateien aufgelöst. Für Fire Mission: Keys in z. B. `RWR_broken_alliances/languages/de/` anlegen oder feste Texte mit `sendFactionMessage(metagame, factionId, "fester Text")`. |
| **4** | **character_id → player_id** | **Lookup vorhanden:** `getPlayers(metagame)` liefert Player-Liste; jeder Eintrag hat `getIntAttribute("character_id")` und `getIntAttribute("player_id")`. Expliziter Helper „getPlayerIdFromCharacterId“ existiert nicht; Pattern z. B. in `vip_manager.as` (573–576): `getPlayers()` durchlaufen, `players[i].getIntAttribute("character_id") == characterId` → dann `players[i].getIntAttribute("player_id")` und `getStringAttribute("name")`. |
| **5** | **Spielername für Anforderer** | Siehe #4: Nach Player-Lookup `getPlayerInfo(metagame, playerId)` oder direkt aus dem gefundenen Player-Element `getStringAttribute("name")`. Für **Soldatenname** (Punkt 10): kein `comment`/`name` am Character in den durchsuchten Scripts gefunden. |
| **6** | **acknowledge_time** | **Befund:** In **RWR_broken_alliances/calls/** wird `acknowledge_time` in mehreren .call-Dateien genutzt: z. B. `tow_drop.call` (`acknowledge_time="1.4"`), `heavy_artillery.call` (`acknowledge_time="1.0"`). Bestätigt, dass das Attribut von der Engine gelesen wird. Ob es Bewegung sperrt, steht in den Paketen nicht – **weiterhin In-Game-Test**. |
| **7** | **create_instance Artillerie** | In **RWR_broken_alliances/weapons/all_throwables.xml** sind u. a. definiert: `artillery_shell.projectile`, `heavy_artillery_shell.projectile`, `railway_artillery_shell.projectile`. Für 105mm/klassische Artillerie: **`artillery_shell.projectile`** oder **`heavy_artillery_shell.projectile`** (je nach gewünschter Wirkung). Vanilla `gunship_run.as` nutzt `instance_class='grenade'` + `instance_key` (z. B. `gunship_105mm.projectile`) + `position`, `faction_id`, `character_id`. |
| **8** | **Mehrere gleichzeitige Funksprüche** | **Referenz:** `gunship_run.as` (vanilla): mehrere Calls werden in einer **Queue** (`AC130Queue`) gehalten; pro Call werden `callId`, `characterId`, Zielposition etc. gespeichert; `update()` iteriert über alle Einträge. Dasselbe Pattern für Fire-Mission-Tracker empfohlen: Array/Liste pro `call_id` (oder character_id), in `update()` alle abarbeiten. |
| **9** | **Event-Reihenfolge** | **Befund:** In `gunship_run.as` und `call_marker_tracker.as` wird auf **`phase == "queue"`** reagiert (Daten übernehmen/starten); in `gunship_run` zusätzlich auf **`phase == "launch"`** (Feuer frei). `tracker.as` leitet `call_event` an `handleCallEvent(event)` weiter. Reaktion nur auf `"queue"` für den Fire-Mission-Start ist konsistent mit Vanilla; „launch“ kommt vermutlich nach acknowledge – für reine Script-Sequenz reicht „queue“. |
| **10** | **Soldatenname** | In **keinem** der durchsuchten .as-Dateien wird `getCharacterInfo(...).getStringAttribute("comment")` oder ein `"name"`-Attribut am Character gelesen. Player hat `name` (Spielername). **Fazit:** Soldatenname (Vorname + Nachname) vom Character in den Mod-Paketen nicht belegt – weiterhin Engine-Log/Doku prüfen oder Fallback (Player-Name / „Soldier“) nutzen. |

---

## 11. Checkliste vor Implementierung & Verifikation

- [ ] **Entscheidung:** Sprechblase (nur nahe) vs. Faction-Chat (alle) für Spieler-Zeilen.
- [ ] **Entscheidung:** Keys + Dict vs. feste Texte für Commander/Spieler (für MVP: feste Texte).
- [ ] **Identifikation:** Rang aus Character-XP; Name = **Soldatenname** (Character-Attribut prüfen), **nicht** Player-Name. Fallback siehe Abschnitt 12.
- [ ] **Lookup:** Helper character_id → player_id + Spielername aus getPlayers/getPlayerInfo implementieren oder in Plan notieren.
- [ ] **Projektil-Key:** instance_key für Einschlag in RWR_broken_alliances festlegen.
- [ ] **Test 1:** Schatten-Call anlegen, auslösen, call_event "queue" im Log prüfen (character_id, target_position, faction_id).
- [ ] **Test 2:** Nach Implementierung: Vollablauf 0 s → 5 s → Einschlag; dann Tod vor 5 s → Abbruch + Refund (rp_reward).
- [ ] **Test 3:** Optional acknowledge_time – Bewegung in den 5 s testen.
- [ ] **Dokumentation:** Nach Verifikation Einträge in Abschnitt 10 abhaken bzw. „geklärt: …“ in MD ergänzen.

---

## 12. Identifikation wie in echt: Rang + Name des Soldaten

**Wichtig:** In der Funkmeldung soll **nicht** der Player-Name (Steam/Account) genannt werden, sondern **der Soldat, der gerade gespielt wird**. Dieser Soldat hat in der Regel:
- **Vor- und Nachname** (von der Engine/Faction generiert, z. B. aus firstnames_file + lastnames_file),
- **einen Rang** (aus der XP des Soldaten → Faction rank-Tabelle; es gibt nur diesen einen Rang pro Soldaten).

**Ziel:** Meldung z. B. „Command, this is **Sergeant Müller**, requesting fire mission, over!“ = Rang + Name **des aktuell gesteuerten Soldaten**.

### Datenquellen (API)

| Teil | Quelle | Hinweis |
|------|--------|--------|
| **Rang (Titel)** | **Character:** `getCharacterInfo(metagame, characterId).getFloatAttribute("xp")`. **Faction-XML:** Rang-Name aus `<rank xp="…" name="…">` (z. B. `factions/grey.xml`). Siehe `TROOP_RANK_BALANCE.md`. | Der Soldat hat genau **einen** Rang (abgeleitet aus seiner XP). Rang = Name des größten `<rank>` mit `rank.xp <= character.xp`. |
| **Name (Vorname + Nachname)** | **Idealfall:** Character/Soldat hat ein Attribut mit dem generierten Soldatennamen (z. B. `comment`, `name`). In Vanilla-Scripts nicht eindeutig belegt – **muss verifiziert werden**. | **Nicht** `getPlayerInfo(…).getStringAttribute("name")` (Player-Name) für die Funkidentifikation verwenden. Fallback, falls Soldatenname nicht verfügbar: letztes Wort des Player-Namens oder nur „Soldier“ / nur Rang. |

### Implementierung (KISS)

1. **Rang:** Helper z. B. `getRankNameForXp(metagame, factionId, float xp)` – Faction rank-Tabelle (oder feste XP→Rang-Tabelle), größtes `rank.xp <= xp` → `rank.name`.
2. **Soldatenname:** Zuerst prüfen, ob `getCharacterInfo(…).getStringAttribute("comment")` bzw. `"name"` den Soldatennamen (Vor- und Nachname) liefert. Wenn ja → für Anzeige nutzen (ggf. nur Nachname extrahieren). Wenn nein → Fallback (z. B. letztes Wort Player-Name oder „Soldier“).
3. **Anzeige:** Dialog = `rankName + " " + soldierNameOrLastname` (z. B. „Sergeant Müller“). Keys z. B. `%caller_id%` oder `%rank_name%` / `%soldier_name%`.

### Offener Punkt (für 100 %)

- **Soldatenname am Character:** In Engine-Doku oder per Log prüfen, ob das Character-Objekt ein Attribut für den generierten Soldatennamen (Vorname + Nachname) hat. Das ist die **bevorzugte** Quelle für die Funkidentifikation; Player-Name nur als Fallback.

---

## Test-Tabelle (sinnvolle Reihenfolge)

Tests in dieser Reihenfolge durchführen – zuerst Einzelbausteine, dann integrierte Abläufe. **Ergebnis:** `[ ]` = offen, `[OK]` / `[FAIL]` / `[~]` (eingeschränkt) eintragen.

| # | Was wird getestet? | Erwartung | Ergebnis | Notizen |
|---|--------------------|-----------|----------|--------|
| **1** | **Schatten-Call + call_event** | Call anlegen (leere round, notify_metagame=1), in all_calls eintragen, im Spiel auslösen. Im Log erscheint call_event mit phase `"queue"`, character_id, target_position, faction_id, id. | [ ] | Log-Ausgabe von call_event prüfen; ggf. in Tracker kurz loggen. |
| **2** | **character_id → player_id** | getPlayers() durchlaufen, character_id abgleichen → player_id und name. (Kleiner Test-Tracker oder in bestehendem Script einmal ausgeben.) | [ ] | player_id für sendPrivateMessage; name für Fallback-Anzeige. |
| **3** | **Sprechblase (position)** | sendPrivateMessage(metagame, playerId, "Test", characterPosition) mit gesetztem position-Attribut. Zweiter Spieler: in Reichweite vs. außer Reichweite – erscheint Text als Sprechblase nur nahe? | [ ] | Wenn nein: Faction-Chat (said_as_character) als Alternative nutzen. |
| **4** | **Faction-Chat „als Soldat“** | sendFactionMessageKeySaidAsCharacter(metagame, factionId, characterId, "key", dictionary(), 1.0) mit einem Test-Key. Faktion sieht Meldung als von diesem Soldaten gesprochen. | [ ] | Key in languages/ anlegen oder existierenden Key (z. B. squad_equipment_kit) nutzen. |
| **5** | **acknowledge_time** | Call mit acknowledge_time="5.0" anlegen, auslösen. Während der ~5 s Bewegung versuchen – wird sie gesperrt? | [ ] | Nur relevant, wenn Bewegungssperre gewünscht. |
| **6** | **create_instance Einschlag** | Einmalig create_instance (instance_class='grenade', instance_key='artillery_shell.projectile', position=target, faction_id, character_id) senden – z. B. aus Test-Tracker bei call_event "queue". Einschlag an Zielposition. | [ ] | Prüfen: artillery_shell.projectile vs. heavy_artillery_shell.projectile. |
| **7** | **Vollablauf 5-Sekunden-Sequenz** | Fire-Mission-Tracker: bei "queue" Timer starten; bei 0 / 1.5 / 3 / 5 s passende Nachrichten (Spieler + Commander) + bei 5 s create_instance. Alles in richtiger Reihenfolge und Zeit. | [ ] | Erst mit festen Texten; Keys optional nachziehen. |
| **8** | **Abbruch bei Tod + Refund** | Während laufender Sequenz (vor 5 s) Anforderer töten. Kein Einschlag; rp_reward an character_id; Meldung „Communication lost / refunded“. | [ ] | handleCharacterDieEvent; nur eigene Sequenz abbrechen. |
| **9** | **Zwei Calls gleichzeitig** | Zwei Spieler starten kurz nacheinander den Fire-Mission-Call. Beide Sequenzen laufen parallel, beide Einschläge an den jeweiligen Zielen. | [ ] | Queue/Array pro call_id in Tracker. |
| **10** | **Rang + Name in Meldung** | Rang aus Character-XP + Faction-Tabelle; Name = Soldatenname (wenn Character-Attribut) oder Fallback (letztes Wort Player-Name / „Soldier“). Anzeige z. B. „Sergeant Müller“ in erster Spieler-Zeile. | [ ] | Optional: getCharacterInfo-Attribute loggen für Soldatenname-Check. |
