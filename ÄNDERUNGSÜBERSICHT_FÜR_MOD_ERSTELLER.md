# Änderungsübersicht - Modifikationen am RWR Total Conversion Mod

**Hinweis:** Diese Datei dient als **genereller Mod-Überblick** - alle wesentlichen Änderungen und Systeme an einem Ort.

**Basis & Assets:** Dieser Mod baut auf dem **RWR Total Conversion Mod** auf und nutzt Assets aus **Project Apocalypse**. Der Mod-Ersteller ist ausschließlich Programmierer, kein Designer - es wurden keine eigenen Assets erstellt oder in Auftrag gegeben. Die Arbeit beschränkt sich auf die Implementierung, Anpassung und Erweiterung von **Logik** (Scripts, Balancing, Konfiguration).

**Zweck:** Anfrage an den Mod-Ersteller um Erlaubnis zur Veröffentlichung mit prominenten Credits.

**Zeitraum:** 03.02.2026 - 13.02.2026 | **~130 Commits** | **462 geänderte Dateien**

---

## 1. NEUE GAMEPLAY-SYSTEME (AngelScript)

| System | Beschreibung |
|--------|--------------|
| **Respawn Slot Delay / Slot-Block-System** | Jeder Tod blockiert X Capacity-Slots für X Sekunden; starke Fraktionen verlieren mehr Slots pro Kill; Underdog-Bonus (siehe Abschnitt 1a) |
| **Faction Alive HUD** | HUD-Anzeige lebender Soldaten pro Fraktion (inkl. 100m/150m/200m Radius) |
| **Stats Command** | In-Game-Befehl für Fraktions-Statistiken (Alive, Capacity, Blocked Slots) |
| **Vehicle Interval Spawn** | Intervall-basierter Fahrzeug-Spawn (Leicht 2-4 min, Mittel 5-8 min, Schwer 12-15 min); **führende Fraktion (meiste Basen) erhält keinen Schwer-Spawn** - siehe Abschnitt 1b |
| **Defender Tank** | Verteidiger erhalten Panzer bei 2 Basenverlust |
| **Squad Equipment Kit** | Ausrüstungskit für Trupps |
| **Bullet Flyby Effect** | Akustischer Effekt bei nahen Projektilen |

### 1a. Slot-Block-System & Underdog-Skalierung (Detail)

**Slot-Block bei jedem Kill:** Wenn ein Soldat stirbt, werden **X Capacity-Slots** seiner Fraktion für **X Sekunden** blockiert - kein Respawn in diesen Slots. **Auch Verwundete blockieren** ihren Slot (solange sie am Boden liegen). Stirbt ein Verwundeter, kommt die zusätzliche Blockade durch den Tod obendrauf. Kills und Revives haben dadurch spürbaren Einfluss. **Medics sind deutlich wertvoller**, da ein Revive die Slot-Blockade vermeidet und die Capacity sofort wieder verfügbar macht.

- **Slots pro Tod:** Hängen von der eigenen Fraktions-Capacity ab (1-6 Slots); starke Fraktionen verlieren mehr pro Kill.
- **Block-Dauer:** 1 Basis → 2 s, 2 Basen → 5 s, 3+ Basen → 15 s. **Schwächere Fraktionen (weniger Basen) haben kürzeres Respawn-Delay.**
- **Truppenüberlegenheit:** Hat eine Fraktion mehr lebende Truppen als die zweitstärkste, verlängert sich die Blockade pro Kill (+4 s pro 25 Truppen Vorsprung). Die führende Fraktion verliert zusätzlich +2 Slots pro Tod.

**Underdog-Vorteil:** Die schwächste Fraktion (weniger Basen, weniger lebende Truppen) erhält kürzere Slot-Blockaden und verliert weniger Slots pro Tod - sie hat eine bessere Chance, sich zu erholen und zurückzuschlagen.

**Wert des Systems:** Anders als „begrenzte Soldaten“ (die oft zu leerer Map und Frust führen) erzeugt das Slot-Block-System eine **temporäre Schwächephase** statt endgültiger Niederlage. Kills schaffen echte Zeitfenster zum Sturm - kein sofortiger Nachspawn. Medics werden **kriegsentscheidend**, da Revives die Slot-Blockade vermeiden. Underdog-Bonus verhindert Snowballing. Ergebnis: taktischer Flow, belohnende Kills, Survival-Anstrich ohne harten Frust.

### 1b. Vehicle Interval Spawn - Intervalle, Führende Fraktion, Fahrzeuglisten (Detail)

**Intervalle:** Pro Fraktion eigene Timer. Leicht alle **2-4 min**, Mittel **5-8 min**, Schwer **12-15 min**. Spawn an zufälliger eigener Basis (Mittelpunkt + Offset).

**Vehicle-Command:** `/vehicle`, `/vehicle_spawn` oder `/fahrzeug` (für alle Spieler) zeigt den Status **nur für die eigene Fraktion**: Restzeiten (ab 60 s in Minuten, darunter in Sekunden) bis zum nächsten Spawn inkl. Basis- und Fahrzeugname (light, medium, heavy). Überschrift: *Upcoming vehicle spawns*. Ist die Fraktion führend, erscheint bei heavy *blocked (leading faction)*. **`/vehicle test`** spawnt sofort ein Leicht-Fahrzeug und ist **nur für Admins**.

**Spionage-Sicherheit:** Zugriff auf den Vehicle-Status ist nur möglich, wenn der Spieler **mindestens 4 Minuten** in der aktuellen Fraktion kämpft. Wechselt jemand die Fraktion und ruft sofort `/vehicle` ab, wird der Zugriff verwehrt; die **gesamte Fraktion** erhält eine Commander-Meldung (*Vehicle intel access denied. [Name] must be in faction for 4 min. X remaining.*). So sieht das Team, dass jemand den Intel abrufen wollte, und schnelles Ausspähen durch Fraktionswechsel wird verhindert.

**Führende Fraktion erhält keinen Schwer-Spawn:** Die Fraktion mit den **meisten Basen** gilt als führend. Läuft der Schwer-Timer für diese Fraktion ab, wird **kein** Heavy-Fahrzeug gespawnt - der Timer wird nur neu gestartet (12-15 min). Nur die zurückliegenden Fraktionen bekommen Schwer-Verstärkung; verhindert Snowballing und hält die Wertigkeit „Call-Panzer = Premium, Intervall-Schwer = für Underdogs“.

**Fahrzeuge pro Intervall (vollständige Liste - Auswahl aus Zufallspool):**

| Intervall | Zeit | Fahrzeuge (alle) |
|-----------|------|------------------|
| **Leicht** | 2-4 min | Humvee, Jeep, Jeep 1, Jeep 2, VFS Sport, Willys MB, Wiesel TOW, Wiesel MK20, ATV Base, ATV Armory (Quad), VFS Base, Truck, Truck 1, Truck 2 |
| **Mittel** | 5-8 min | Humvee, Wiesel TOW, Wiesel MK20, APC, APC 1, APC 2, Vulcan Tank, Noxe, Hovercraft, Cargo Truck, SEV90, Radio Jammer |
| **Schwer** | 12-15 min | Tank Alt, Tank 1 Alt, Tank 2 Alt, M551 (Sheriff), FV101 (Scorpion), Legion, M528, Flamer Tank (Croc) |

*(Call-Panzer tank/tank_1/tank_2 bleiben exklusiv über Calls - erscheinen nicht im Intervall-Spawn.)*

---

## 2. NEUE TRUPPENTYPEN & AI

| Typ | Beschreibung |
|-----|--------------|
| **Cover Troop** | Deckungstruppe mit Sandsäcken |
| **EOD Light** | Leichte EOD-Einheit mit Panzerabwehr |
| **Grenadier** | Granatwerfer-Spezialist |
| **Mortar Operator** | Mörser-Bediener |
| **Shotgun** | Schrotflinten-Trupp |
| **Sniper** | Sniper-Einheit (nur liegend/wand) |
| **Support** | Unterstützungstrupp |
| **Medic AI** | Überarbeitete Medic-Logik, folgt Spieler; deutlich wertvoller durch Slot-Block-System (Revive vermeidet temporäre Slot-Deaktivierung) |
| **Hunde** | Im Total Conversion Mod deaktiviert - **wieder aktiviert**. Spawnen für alle Fraktionen (Spieler + Feinde) mit ~4 % Chance (spawn_score 0,04). Vanilla-Assets (dog.ai, dog.character, dog.weapon, dog_heal.weapon, dog.carry_item). |

**AI-Anpassungen:** Erhöhte Aggression, Sichtweite, Reaktionsfähigkeit; größere Squads; Minibosse führen volle Trupps; **MGs nur in Prone-Stellung** - ideal für Deckungsfeuer, sehr tödlich; Nachteil: Hinlegen nötig, eingeschränkte Beweglichkeit.

**Sicht/FOV-Anpassungen:** Deutlich erhöhte Sichtweite für Spieler und AI. Wenn gleich Spieler weiter sehen kann um Schüsse aus dem Bildschirm so gut es geht zu vermeiden. Erweiterte MG- und Sniper-Sicht (`sight_range_modifier`); MGs mit erhöhter Sichtreichweite. Ermöglicht **weitere Gefechtsdistanzen** - näher an realistischem Gefechts-Bereich.

---

## 3. FAHRZEUGE & FAHRZEUG-ANPASSUNGEN

- **Fahrzeug-Despawn:** Zerstörte Fahrzeuge bleiben **20 Minuten** sichtbar, bevor sie despawnen (Vanilla: 40 s). Über `vehicle_base.vehicle` mit `time_to_live_unsteerable="1200"` - mehr Trümmer auf dem Schlachtfeld, bessere Orientierung.

**Neue/übernommene Fahrzeuge (Auswahl):**

| Fahrzeug | Beschreibung |
|----------|--------------|
| **Wiesel MK20** | Leichter Schützenpanzer mit 20mm |
| **Wiesel TOW** | Wiesel mit Panzerabwehrrakete |
| **Willys MB** | Jeep-Variante |
| **Guntruck (VFS)** | Bewaffneter LKW |
| **Coastal Gun** | Küstengeschütz (Bofors) |
| **Dogcrate** | Fallschirm-Dogcrate |

**Weitere Fahrzeug-/Command-Anpassungen:**

| Anpassung | Beschreibung |
|-----------|--------------|
| **Alt-Tanks (tank_alt, tank_1_alt, tank_2_alt)** | Eigene Mod-Definitionen **ohne** `access_tag supporter` - alle Spieler können einsteigen (nicht nur Supporter-DLC). Erben von Mod-Panzern, nutzen Alt-Kanonen und Alt-Skins. |
| **Alt-Tank-Kanonen** | Vanilla-Alt-Kanonen im Mod übernommen; **Blast/Damage/Push verdoppelt** (Radius 7, Damage 6,02, Push 2). Bleiben schwächer als Call-Panzer-Kanonen (Radius 8, Damage 10), klare Wertigkeit: Auto-Spawn-Alt vs. Call-Premium. |
| **Cargo Truck (/cargo)** | `cargo_truck.vehicle` in `all_vehicles.xml` aktiviert (zuvor auskommentiert) - Command `/cargo` spawnt nun den Cargo-LKW. |
| **Truck-Commands (/truck, /1truck, /2truck)** | Alias-Fahrzeuge `truck.vehicle`, `truck_1.vehicle`, `truck_2.vehicle` hinzugefügt (erben von transport_truck*), in `all_vehicles.xml` eingetragen - Vanilla-Command `/truck` funktioniert. |
| **Noxe MG (Passagier)** | Schwenkbereich des MG-Turms auf **linke Fahrzeugseite** begrenzt (Rotation −1,57 rad, Range 1,57 rad) - von hinten-links bis vorne-links, nicht über Fahrzeugmitte nach rechts. |

---

## 4. NEUE WAFFEN & WERFOBJEKTE

| Objekt | Beschreibung |
|--------|--------------|
| **Flares** | For vehicle spawns |
| **Healnade** | Heilungs-Granate |
| **Cluster Grenade** | Streumunition |
| **AT Grenade** | Panzerabwehr-Granate |
| **Coastal Gun** | Küstengeschütz als Waffe |
| **Squad Equipment Kit** | Trupp-Ausrüstung |
| **Dogbone** | Hundefutter (Gimmick) |

---

## 5. WESTEN-SYSTEM

- **Default Weste** (`vest_default.carry_item`): Standard-Weste, die **alle** tragen (100 %). Führt dazu, dass Soldaten bei Treffern zuerst **verwundet** werden statt sofort zu sterben. Effekt: Deutlich mehr Verwundete auf dem Schlachtfeld - wirkt realitätsnäher und brutaler.
- **Synergie mit Slot-Block:** Ein Verwundeter blockiert bereits den Capacity-Slot (kein Nachspawn, solange er am Boden liegt). Stirbt er, blockiert der Tod **noch mehr** Slots für X Sekunden. **Lazarett-Dilemma:** 10 Verwundete = 10 fehlen an der Front UND verhindern 10 frische Soldaten. **Double-Punish:** Retten → Slot sofort frei, Soldat kampfbereit. Ignorieren → Slot blockiert während Verbluten, danach dicke Blockade durch Tod. Erzeugt Dringlichkeit: „Wenn ich den da nicht hole, bricht unsere Verstärkung zusammen!“ - Combat-Sim-Feeling.
- Westen in Waffenkammer für alle Fraktionen

---

## 6. WAFFEN-BALANCING

- **ARs:** AK47, HK416, G36, M16A4, M4A1, SG552, XM8, FAMAS etc. - schnelle Feuerrate, teilweise gut genau; Nachteil: Magazingröße fordert häufiges Nachladen.
- **MGs:** Negev, M240, M249, MG4, MG42, PKM, RPK74M - nur im Liegen einsetzbar; ideal für Deckungsfeuer, sehr tödlich. Nachteil: Hinlegen nötig, eingeschränkte Beweglichkeit; Stärke liegt im statischen Deckungsfeuer.
- **Feste MGs (Deployables):** Deutlich stärker als Vanilla
- **Sniper:** APR, Barrett, Dragunov, Lahti, M14 EBR, M24, PSG90, SCAR SSR, SV98, VSS - langsam beim Schießen, aber verdammt lange Sicht; **sehr hohe Kill-Ratio**, bei Treffer fast immer garantiert.
- **Shotguns:** Sehr tödlich auf kurzer Distanz; verlieren schnell Effektivität auf mittlere und höhere Distanz.
- **Anti-Panzer:** Carl Gustav, LAW, RPG-7, SMAW - deutlich tödlicher (größerer Sprengradius, mehr Schaden; auch gegen Infanterie)
- **Panzer:** Deutlich tödlicher - größerer Sprengradius und mehr Schaden der Kanonen
- **Projektile:** Erhöhte Geschwindigkeit für viele Waffen

**Fraktionen:** Jede Fraktion hat Vor- und Nachteile in ihren Waffen; diese bleiben aus Balancing-Gründen relativ gering.

---

## 7. CALLS (Befehle)

- **Geändert:** Humvee (mit MG), Tank, APC, Paratroopers, Artillery, Mines (aktiviert), Mortar, Vulcan

---

## 8. FRAKTIONEN & MAPS

- **Brown, Green, Grey:** Balancing, neue Trupptypen, Ränge, Ressourcen
- **Maps:** `init_match.xml` für vanilla-Maps (lobby, map1-21) angepasst
- **FOV:** Alle Quick-Match-Maps haben `fov="1"` in `init_match.xml` - erweiterter Sichtbereich (Field of View) aktiviert

---

## 9. SPRACHE & UI

- **default_shared.character:** Deutsche und englische Texte für alle neuen Features
- **Fraktionsspezifische Kommentare:** Jede Fraktion hat eigene Voice-Lines (z. B. russische Soldaten: Sanitar!, Tovarishch, Blyat; US/EU eigene Varianten)
- **Medic-Rufe:** Viele neue Verwundeten-Rufe („Medic!“, „Hold on!“, „I feel good!“ etc.) - mehr Variation und Immersion

---

## 10. MODELS & ASSETS

- **Neue Skins:** soldier_5stars, soldier_fm (brown/green/grey), soldier_fsb, soldier_riotgear, soldier_usf_assault, soldier_blackops
- **Neue Meshes:** Wiesel, Willys, Guntruck, Coastal Gun, Flare, Healnade, etc.
- **Textures & Sounds:** Für alle neuen Fahrzeuge und Waffen

---

## 11. DOKUMENTATION (MD-Dateien)

Dokumentation zu Konzepten und Balancing (intern, nicht zwingend für Veröffentlichung):
- CAPACITY_UND_SLOTS_PER_DEATH_KONZEPT, RESPAWN_SLOT_DELAY_SYSTEM
- WEAPON_COMPARISON, WEAPON_ACCURACY_REFACTOR, ANTITANK_COMPARISON
- WESTEN_MODDING, VEHICLE_BALANCING_RULES, TROOP_RANK_BALANCE, etc.
