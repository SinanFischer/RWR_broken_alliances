# Bericht: Neue Westen in RWR (am Beispiel Project Apocalypse)

## 1. Überblick

- **Westen** sind **tragbare Gegenstände** vom Typ **carry_item** mit **slot="1"** (Vest-Slot).
- Project Apocalypse nutzt die gleiche Vest-Logik wie Vanilla, fügt aber eigene Westen über neue `.carry_item`-Dateien und Fraktions-Resources hinzu.
- **Quelle:** Vanilla `vest1.carry_item` / `vest2.carry_item` (slot="1"); Project Apocalypse `vest2.carry_item`, `camo_vest.carry_item`, `ss_vest.carry_item`, `vest_snake.carry_item`.

---

## 2. Kerndateien und Pfade

| Was | Projekt | Pfad |
|-----|--------|------|
| Vest-Definitionen | Project Apocalypse | `Project_Apocalypse/items/*.carry_item` (z. B. vest2, camo_vest, ss_vest, vest_snake) |
| Vest-Modelle | Vanilla / PA | `vanilla/models/vest.xml`, `Project_Apocalypse/models/camo_vest.xml`, `vest_ss.xml`, `vest_snake.xml` |
| Fraktions-Pool (welche Westen verfügbar) | Project Apocalypse | `Project_Apocalypse/factions/*.resources` → `<carry_item key='...' />` |
| Spawn-Item (drop bei Tod → echte Weste) | Project Apocalypse | `Project_Apocalypse/items/vest_ss_spawn.carry_item` |
| Basis für „Spawn-Item“ | Project Apocalypse | `Project_Apocalypse/items/base_valuable.carry_item` |
| HUD-Icons | PA / Vanilla | z. B. `hud_vest.png`, `hud_camo_vest.png`, `hud_ss_vest.png` (in textures/ oder items-relevant) |
| Sprachtexte (Name der Weste) | Project Apocalypse | `languages/<lang>/misc_text_vanilla.xml` → `<text key="Vest, type II" text="..."/>` |

---

## 3. Aufbau einer Weste: `.carry_item`

### 3.1 Pflichtattribute pro Eintrag

- **key** – Eindeutige ID, z. B. `meine_vest.carry_item` oder `meine_vest_2` (Zustände).
- **name** – Anzeigename (wird für Sprachkeys genutzt, z. B. `"Vest, type II"`).
- **slot="1"** – Immer **1** für Westen (Vest-Slot).
- **transform_on_consume** – Nächster Zustand nach „Verbrauch“ (ein Treffer); letzter Zustand hat kein `transform_on_consume`.
- **time_to_live_out_in_the_open** – Sekunden, wie lange die Weste am Boden liegt (z. B. 120.0).

**Quelle:**  
`Project_Apocalypse/items/vest2.carry_item` (Zeilen 3, 23, 42), `camo_vest.carry_item` (Zeilen 3, 24, 46, 66, 86), `ss_vest.carry_item` (Zeilen 3, 21, 43, …).

### 3.2 Typische Kindelemente

- **`<hud_icon filename="hud_vest.png" />`** – Icon in der HUD.
- **`<capacity value="1" source="rank" source_value="0.0" />`** (evtl. mehrere) – Wer darf es tragen (Rank).
- **`<inventory encumbrance="…" price="…" />`** – Erschwernis, Preis (Armory); optional `buy_price`/`sell_price`.
- **`<model mesh_filename="vest.xml" />`** – 3D-Modell (relativ zu `models/`).
- **`<commonness value="…" in_stock="…" can_respawn_with="…" />`** – Gewichtung/Spawn/Respawn.

**Quelle:**  
`Project_Apocalypse/items/vest2.carry_item`, `camo_vest.carry_item`, `ss_vest.carry_item`.

### 3.3 Modifier (Treffer → Zustand)

Bestimmen, was bei **projectile_hit**, **projectile_blast** und **melee_hit** passiert:

- **input_character_state** – Ausgangszustand: `death`, `wound`, `stun`.
- **output_character_state** – Ergebnis: `none` (Treffer absorbiert), `stun`, `wound`, `death`.
- **consumes_item="0"** – Weste wird bei diesem Treffer nicht „verbraucht“ (Zustand wechselt nicht).

Klassische Kette (3-Stufen-Weste):

1. **Voll:** `death` → `none` (erster Treffer wird absorbiert, Weste wechselt zu Zustand 2).
2. **Beschädigt:** `death` → `stun` (zweiter Treffer = Stun, Weste wechselt zu Zustand 3).
3. **Kaputt:** `death` → `wound` (nächster Treffer = verwundet).

**Quelle:**  
`Project_Apocalypse/items/vest2.carry_item` (Zeilen 13–19, 33–38, 53–55), `camo_vest.carry_item` (analog), `ss_vest.carry_item`, `vest_snake.carry_item` (z. B. Zeilen 12–17, 133–137, 155–159).

### 3.4 Optionale Modifier

- **`<modifier class="speed" value="-0.05" />`** – Bewegungsmalus.
- **`<modifier class="detectability" value="-0.20" />`** – Tarnung (camo_vest, vest_snake).

**Quelle:**  
`Project_Apocalypse/items/vest2.carry_item` (Zeile 20), `camo_vest.carry_item` (Zeilen 21, 43, 64, 83), `vest_snake.carry_item` (Zeilen 18–19).

---

## 4. Transform-Kette („Hits“ pro Weste)

Jede Weste ist eine **Kette von carry_item-Einträgen** in **einer** `.carry_item`-Datei:

- Erster Eintrag: key z. B. `meine_vest.carry_item`, `transform_on_consume="meine_vest_2"`.
- Folgende: key `meine_vest_2`, `meine_vest_3`, …; der **letzte** hat **kein** `transform_on_consume` (Endzustand, z. B. „wound“).

Beispiele:

- **vest2:** 3 Stufen (vest2.carry_item → vest2_2 → vest2_3).  
  **Quelle:** `Project_Apocalypse/items/vest2.carry_item`.
- **camo_vest:** 5 Stufen (camo_vest.carry_item → camo_1 → camo_2 → camo_3 → camo_4).  
  **Quelle:** `Project_Apocalypse/items/camo_vest.carry_item`.
- **vest_snake:** 10 Stufen (vest_snake.carry_item → snake1 … → snakedeath).  
  **Quelle:** `Project_Apocalypse/items/vest_snake.carry_item` (Zeilen 4–176).
- **ss_vest:** 8 Stufen (ss_vest.carry_item → ss_vest_1 … → ss_vest_death).  
  **Quelle:** `Project_Apocalypse/items/ss_vest.carry_item`.

---

## 5. Fraktionen: Weste verfügbar machen

Welche Westen eine Fraktion nutzen kann, steht in **`.resources`**:

```xml
<carry_item key='vest2.carry_item' enabled="1" />
<carry_item key='camo_vest.carry_item' enabled="1"/>
```

- **Normale Fraktion (mit Vanilla-Pool):** Eintrag in den passenden `supply_*.resources` ergänzen.
- **Eigene Fraktion (nur bestimmte Weste):** `clear_carry_items="1"` und dann nur die gewünschten carry_items angeben.

**Quelle:**  
`Project_Apocalypse/factions/supply_common.resources` (Zeilen 75–83), `ss.resources` (Zeilen 2, 8–9), `orange_bodyguards.resources` (Zeilen 2, 5–6), `rambo.resources` (Zeilen 2, 5–6).

---

## 6. Eigene Optik: Modell und HUD-Icon

- **Modell:** `<model mesh_filename="meine_vest.xml" />` – Datei unter `models/meine_vest.xml`.  
  Vanilla-Modelle sind Voxel-XML (z. B. `vanilla/models/vest.xml`). Du kannst ein bestehendes Modell kopieren und anpassen oder ein neues erstellen.
- **HUD-Icon:** `<hud_icon filename="hud_meine_vest.png" />` – Icon z. B. in `textures/` oder dem vom Spiel erwarteten Pfad für HUD-Icons.

**Quelle:**  
`Project_Apocalypse/items/vest2.carry_item` (mesh `vest.xml`), `camo_vest.carry_item` (`camo_vest.xml`), `vest_snake.carry_item` (`vest_snake.xml`), `vest_ss_spawn.carry_item` (`vest_ss.xml`, `hud_ss_vest.png`).

---

## 7. Optional: „Spawn-Item“ (Weste droppt bei Tod)

Wenn ein **getragener Gegenstand** beim Tod eine **frische Weste** droppen soll (wie bei SS):

- **Spawn-Item:** Ein carry_item mit **slot="1"**, das wie eine Weste getragen wird, aber bei Tod **ein anderes carry_item spawnt** (die echte Weste).
- **drop_on_death_result:**  
  `class="spawn"`, `instance_class="carry_item"`, `instance_key="ss_vest.carry_item"`, `min_amount="1" max_amount="1"`.

**Quelle:**  
`Project_Apocalypse/items/vest_ss_spawn.carry_item`: erbt von `base_valuable.carry_item`, key `vest_ss_spawn.carry_item`, spawnt `ss_vest.carry_item` (Zeilen 2–15, 12–14).

Für eine eigene Weste: analog ein „meine_vest_spawn.carry_item“ anlegen, das bei Tod `meine_vest.carry_item` spawnt, und dieses Spawn-Item in der Fraktion führen.

---

## 8. Sprachen (Anzeigename)

Der **name** im carry_item wird als **key** für Übersetzungen verwendet. In z. B. `languages/de/misc_text_vanilla.xml` (oder en/ru/pt wie in PA):

```xml
<text key="Vest, type II" text="Weste Typ II"/>
<text key="Camouflaged Vest" text="Tarnweste"/>
```

**Quelle:**  
`Project_Apocalypse/languages/ru/misc_text_vanilla.xml` (Zeilen 82–84, 90–94, 302–303, 411, 448–451).

---

## 9. Checkliste: Eigene Weste im Mod

1. **Neue Datei** im Mod: `items/meine_vest.carry_item` mit `<carry_items>` und allen Zuständen (key, name, slot="1", transform_on_consume, modifier-Kette, model, capacity, inventory, commonness, ggf. speed/detectability).
2. **Modell:** `models/meine_vest.xml` (von `vest.xml` oder `camo_vest.xml` kopieren/anpassen) und in jedem Zustand `mesh_filename="meine_vest.xml"` referenzieren.
3. **HUD-Icon:** `hud_meine_vest.png` bereitstellen und in jedem Zustand `<hud_icon filename="hud_meine_vest.png" />` (evtl. pro Stufe andere Icons).
4. **Fraktion:** In den gewünschten `factions/*.resources` eintragen: `<carry_item key='meine_vest.carry_item' enabled="1" />`.
5. **Optional – Spawn-Item:** Eigenes carry_item (z. B. `meine_vest_spawn.carry_item`) mit `drop_on_death_result` → spawn `meine_vest.carry_item`; nur dieses Spawn-Item in der Fraktion führen, wenn Soldaten beim Tod die Weste droppen sollen.
6. **Optional – Sprache:** In `languages/<lang>/misc_text_vanilla.xml` Einträge für jeden `name`-Wert der Westen-Zustände hinzufügen.
7. **Optional – Invasion/Gamemode:** Wenn dein Mod einen eigenen `item_delivery_configurator` oder ähnliches hat, dort die neue Weste als `ScoredResource("meine_vest.carry_item", "carry_item", …)` eintragen, damit sie in Crates/Armory vorkommt (siehe z. B. `Project_Apocalypse/scripts/gamemodes/invasion/item_delivery_configurator_invasion.as` für camo_vest, vest3, vest_exo).

---

## 10. Kurzreferenz: Wichtige Quellstellen

| Thema | Datei (Project Apocalypse) |
|-------|----------------------------|
| Einfache 3-Stufen-Weste | `items/vest2.carry_item` |
| Weste mit Tarnung + 5 Stufen | `items/camo_vest.carry_item` |
| Viele Stufen (8–10), Sonderverhalten | `items/ss_vest.carry_item`, `items/vest_snake.carry_item` |
| Spawn-Item (drop bei Tod) | `items/vest_ss_spawn.carry_item` |
| Fraktion nur mit einer Weste | `factions/ss.resources`, `factions/orange_bodyguards.resources` |
| Fraktion mit mehreren Westen | `factions/supply_common.resources` (carry_item-Zeilen) |
| Vest-Repair (Reparatur-Werkzeug) | `weapons/vest_repair.weapon`; Referenzen in `factions/supply_*.resources` und `scripts/.../item_delivery_configurator_invasion.as` |

---

## 11. Im Mod integrierte Default-Weste

Im Total-Conversion-Mod ist eine **Default-Weste** (`vest_default.carry_item`) integriert:

- **Verhalten:** Fängt keinen Schuss ab. Beim **ersten** tödlichen Treffer (Projektil, Explosion, Nahkampf) geht der Soldat in den **wounded**-Zustand (Medic kann heilen); die Weste wechselt in den Zustand „verbraucht“. Beim nächsten Treffer stirbt er.
- **Wer bekommt sie:** Alle Default-Soldaten (Brown, Grey, Green) haben Slot 1 mit Wahrscheinlichkeit **1.0** und nutzen `default_vests.resources`, in dem nur `vest_default.carry_item` im Pool ist – also bekommt jeder diese Weste, sofern keine andere (bessere) Weste aus einem anderen Soldier-Typ gewählt wird.
- **Relevante Dateien:**
  - `items/vest_default.carry_item` – Definition (2 Zustände: `vest_default.carry_item` → `vest_default_used`)
  - `factions/default_vests.resources` – Pool nur mit vest_default
  - `factions/brown.xml`, `grey.xml`, `green.xml` – `item_class_existence` für Slot 1 mit probability 1.0 für default/default_ai
  - `factions/brown_default.models`, `grey_default.models`, `green_default.models` – Modellzuordnung für vest_default/vest_default_used (soldier_c1_vest / ger_army_1_3 / soldier_a1_vest)
  - `items/all_carry_items.xml`, `items/invasion_all_carry_items.xml` – Eintrag `vest_default.carry_item` für das Laden

---

Mit diesem Aufbau und den genannten Dateien kannst du eine eigene Weste definieren, optisch anpassen (Modell + Icon), über Resources einer Fraktion zuweisen und optional als Spawn-Item und in der Invasion-Logik einbinden.

---

## 12. Waffenkammer: Westen anzeigen (dieser Mod)

**Problem:** In der Westen-Kategorie der Waffenkammer erschienen nur die Default-Weste.

**Ursache:** Die Waffenkammer bezieht die anzeigbaren Slot-1-Items aus dem **Ressourcen-Pool der Default-Soldatengruppe** (nicht aus der supply-Gruppe und nicht aus per Script gesendeten `faction_resources`-Befehlen).

**Lösung:**

1. **`factions/armory_vests.resources`** – Liste aller Westen (vest1–4, eodvest, camouflage_suit, sf_suit, vest_blackops) **ohne** `clear_carry_items`, damit der Pool ergänzt wird.
2. **Fraktionen (green/brown/grey.xml):** In der **default-** und **default_ai-**Soldatengruppe **nach** `default_vests.resources` einbinden: `<resources file="armory_vests.resources" />`.
3. **Spawn-Verhalten:** In den Mod-`carry_item`-Dateien (vest1–4, camouflage_suit, sf_suit) für den **ersten Zustand** `commonness value="0.0"` und `in_stock="1"` setzen. So erscheinen die Westen in der Waffenkammer, werden aber für Default-Spawns nicht gewichtet (nur vest_default mit commonness 1.0 wird gezogen).
4. **sf_suit:** Zusätzlich `in_stock="1"` setzen (vorher 0), damit die Weste in der Waffenkammer angeboten wird.

---

## 13. Erkenntnisse – Wichtig für zukünftige Implementierungen

Diese Punkte fassen Wissen aus der Mod-Entwicklung zusammen (Waffenkammer, Anzeige, Spawn). Bei neuen Westen oder Änderungen an der Armory-Anzeige darauf achten.

### 13.1 Woher bekommt die Waffenkammer ihre Westen-Liste?

| Quelle | Wird für Waffenkammer genutzt? |
|--------|--------------------------------|
| **Ressourcen der Default-Soldatengruppe** (default / default_ai) aus den in der Fraktion-XML geladenen `.resources`-Dateien | **Ja** – das ist die maßgebliche Quelle. |
| supply-Soldatengruppe (z. B. `supply_common.resources`) | **Nein** – erscheint nicht in der Waffenkammer-Liste. |
| Per Script gesendete `faction_resources`-Befehle (`getFriendlyFactionResourceChanges()` etc.) | **Nein** – die Waffenkammer-UI baut die Liste offenbar beim initialen Laden der Fraktion (XML/Resources); nachträgliche Script-Befehle reichen nicht für die Anzeige. |

**Folgerung:** Damit eine Weste in der Waffenkammer erscheint, muss sie in einer `.resources`-Datei stehen, die von der **default-** bzw. **default_ai-**Soldatengruppe der Spielerfraktion geladen wird (z. B. `armory_vests.resources` nach `default_vests.resources`).

### 13.2 Doppelte Einträge in der Waffenkammer

- Die **Anzeige** in der Waffenkammer orientiert sich am **`name`-Attribut** des carry_item (bzw. an dessen Übersetzungs-Key).
- Zwei **verschiedene** carry_items (z. B. `vest4.carry_item` und `sf_suit.carry_item`) mit **demselben** `name="Vest, type IV"` erscheinen als **zwei getrennte Zeilen mit identischem Text** („Weste 4“ zweimal).
- **Lösung:** Jeder Westen-Typ braucht einen **eindeutigen Anzeigenamen**. Beispiel: sf_suit von `"Vest, type IV"` auf `"SF Vest"` umstellen (und ggf. in `languages/…/misc_text_vanilla.xml` übersetzen).

### 13.3 commonness vs. in_stock (carry_item)

| Attribut | Wirkung |
|----------|--------|
| **commonness** | Gewichtung beim **Spawn** und in Pools (z. B. Crates). `0.0` = wird für Default-Soldaten praktisch nicht gezogen; `1.0` = normale Gewichtung. Beeinflusst **nicht** direkt, ob die Weste in der Waffenkammer steht. |
| **in_stock** | Steuert, ob die Weste **in der Waffenkammer** angeboten wird. `in_stock="1"` = anzeigen; `in_stock="0"` = nicht in der Waffenkammer (z. B. nur als Spawn/Loot). |

**Typisches Setup für „Weste in Waffenkammer, aber nicht als Default-Spawn“:**  
`commonness value="0.0"` und `in_stock="1"` im **ersten** Zustand der Weste; die Default-Gruppe lädt zusätzlich `default_vests.resources` mit nur `vest_default` (commonness 1.0), damit weiter nur die Default-Weste gespawnt wird.

### 13.4 Reihenfolge der Resources in der Default-Gruppe

- **Zuerst** `default_vests.resources` mit `clear_carry_items="1"` und nur `vest_default` → Slot-1-Pool = { vest_default }.
- **Danach** `armory_vests.resources` **ohne** `clear_carry_items` → Pool wird ergänzt (vest_default + vest1, vest2, …).
- So sind alle Westen in der Waffenkammer sichtbar; durch commonness wird beim Spawn weiter nur vest_default gewählt.

### 13.5 Kurz-Checkliste: Neue Weste soll in der Waffenkammer erscheinen

1. **carry_item:** `slot="1"`, `in_stock="1"`, eigener **eindeutiger** `name` (kein Duplikat zu anderer Weste).
2. **Default-Gruppe:** Weste in einer Resource-Datei, die von default/default_ai geladen wird (z. B. in `armory_vests.resources` eintragen und diese Datei in green/brown/grey.xml nach `default_vests.resources` einbinden).
3. **Spawn:** Wenn Default-Soldaten diese Weste **nicht** bekommen sollen: `commonness value="0.0"` im ersten Zustand; vest_default weiter mit commonness 1.0 in `default_vests.resources`.
4. **Sprache (optional):** In `languages/<lang>/misc_text_vanilla.xml` (oder Mod-Äquivalent) Eintrag für den `name`-Key, falls Übersetzung gewünscht.
