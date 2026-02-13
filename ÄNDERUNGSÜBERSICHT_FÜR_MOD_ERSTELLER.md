# Änderungsübersicht – Modifikationen am RWR Total Conversion Mod

**Zweck:** Anfrage an den Mod-Ersteller um Erlaubnis zur Veröffentlichung mit prominenten Credits.

**Zeitraum:** 03.02.2026 – 13.02.2026 | **~130 Commits** | **462 geänderte Dateien**

---

## 1. NEUE GAMEPLAY-SYSTEME (AngelScript)

| System | Beschreibung |
|--------|--------------|
| **Reinforcement Pool** | Nachschub-System mit Spawn-Intervallen, Basis-Eroberungsboni, Großangriff alle 4 Zyklen |
| **Respawn Slot Delay** | Verzögerter Respawn bei Überzahl einer Fraktion (Capacity-Konzept) |
| **Faction Alive HUD** | HUD-Anzeige lebender Soldaten pro Fraktion (inkl. 100m/150m/200m Radius) |
| **Stats Command** | In-Game-Befehl für Fraktions-Statistiken (Alive, Capacity, Blocked Slots) |
| **Vehicle Interval Spawn** | Intervall-basierter Fahrzeug-Spawn statt rein zufällig |
| **Defender Tank** | Verteidiger erhalten Panzer bei 2 Basenverlust |
| **Squad Equipment Kit** | Ausrüstungskit für Trupps |
| **Bullet Flyby Effect** | Akustischer Effekt bei nahen Projektilen |

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
| **Medic AI** | Überarbeitete Medic-Logik, folgt Spieler |

**AI-Anpassungen:** Erhöhte Aggression, Sichtweite, Reaktionsfähigkeit; größere Squads; Minibosse führen volle Trupps; MGs nur in Prone-Stellung.

---

## 3. NEUE FAHRZEUGE

| Fahrzeug | Beschreibung |
|----------|--------------|
| **Wiesel MK20** | Leichter Schützenpanzer mit 20mm |
| **Wiesel TOW** | Wiesel mit Panzerabwehrrakete |
| **Willys MB** | Jeep-Variante |
| **Guntruck (VFS)** | Bewaffneter LKW |
| **Coastal Gun** | Küstengeschütz (Bofors) |
| **Dogcrate** | Fallschirm-Dogcrate |

---

## 4. NEUE WAFFEN & WERFOBJEKTE

| Objekt | Beschreibung |
|--------|--------------|
| **Flares** | Signalraketen (mehrere Farben) |
| **Healnade** | Heilungs-Granate |
| **Cluster Grenade** | Streumunition |
| **AT Grenade** | Panzerabwehr-Granate |
| **Coastal Gun** | Küstengeschütz als Waffe |
| **Squad Equipment Kit** | Trupp-Ausrüstung |
| **Dogbone** | Hundefutter (Gimmick) |

---

## 5. WESTEN-SYSTEM

- **Default Weste** (`vest_default.carry_item`): Erhöhte Chance auf Verwundung statt Tod (25 % direkt verwundet)
- Westen in Waffenkammer für alle Fraktionen

---

## 6. WAFFEN-BALANCING

- **ARs:** AK47, HK416, G36, M16A4, M4A1, SG552, XM8, FAMAS etc. (Genauigkeit, Feuerrate, Schaden)
- **MGs:** Negev, M240, M249, MG4, MG42, PKM, RPK74M (Sichtweite, Rotation, Feuerrate)
- **Sniper:** APR, Barrett, Dragunov, Lahti, M14 EBR, M24, PSG90, SCAR SSR, SV98, VSS
- **Anti-Panzer:** Carl Gustav, LAW, RPG-7, SMAW (stärker, auch gegen Infanterie)
- **Projektile:** Erhöhte Geschwindigkeit für viele Waffen

---

## 7. CALLS (Befehle)

- **Neu:** `cover_troop_drop`, `sniper_drop`, `wiesel_drop`
- **Geändert:** Humvee (mit MG), Tank, APC, Paratroopers, Artillery, Mines (aktiviert), Mortar, Vulcan

---

## 8. FRAKTIONEN & MAPS

- **Brown, Green, Grey:** Balancing, neue Trupptypen, Ränge, Ressourcen
- **Maps:** `init_match.xml` für vanilla-Maps (lobby, map1–21) angepasst

---

## 9. SPRACHE & UI

- **default_shared.character:** Deutsche und englische Texte für alle neuen Features
- **defender_tank_mod.character:** Texte für Verteidiger-Panzer

---

## 10. MODELS & ASSETS

- **Neue Skins:** soldier_5stars, soldier_fm (brown/green/grey), soldier_fsb, soldier_riotgear, soldier_usf_assault, soldier_blackops
- **Neue Meshes:** Wiesel, Willys, Guntruck, Coastal Gun, Flare, Healnade, etc.
- **Textures & Sounds:** Für alle neuen Fahrzeuge und Waffen

---

## 11. DOKUMENTATION (MD-Dateien)

Dokumentation zu Konzepten und Balancing (intern, nicht zwingend für Veröffentlichung):
- CAPACITY_UND_SLOTS_PER_DEATH_KONZEPT, RESPAWN_SLOT_DELAY_SYSTEM, REINFORCEMENT_POOL
- WEAPON_COMPARISON, WEAPON_ACCURACY_REFACTOR, ANTITANK_COMPARISON
- WESTEN_MODDING, VEHICLE_BALANCING_RULES, TROOP_RANK_BALANCE, etc.

---

## ZUSAMMENFASSUNG FÜR ANFRAGE

> **An den Mod-Ersteller:**
>
> Ich habe den RWR Total Conversion Mod umfangreich erweitert und angepasst. Die Änderungen umfassen:
>
> - **Neue Gameplay-Systeme:** Nachschub/Reinforcement, Respawn-Delay, HUD-Tracker, Stats-Befehl, Fahrzeug-Intervall-Spawn, Verteidiger-Panzer
> - **Neue Trupptypen:** Cover Troop, EOD Light, Grenadier, Mortar Operator, Shotgun, Sniper, Support, verbesserte Medic-AI
> - **Neue Fahrzeuge:** Wiesel MK20/TOW, Willys MB, Guntruck, Coastal Gun, Dogcrate
> - **Neue Waffen/Werfobjekte:** Flares, Healnade, Cluster-Granate, AT-Granate, Coastal Gun, Squad Kit
> - **Westen-System:** Default-Weste mit Verwundungs-Chance statt Tod
> - **Umfangreiches Waffen-Balancing** für alle Fraktionen
> - **AI-Anpassungen:** Aggression, Sichtweite, Squad-Größe
> - **Neue Calls** und **Sprachdateien** (DE/EN)
>
> **Darf ich diese Modifikationen veröffentlichen (z.B. als Submod oder Fork) mit prominenten Credits für dich als Original-Mod-Ersteller?**
