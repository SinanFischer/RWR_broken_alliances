# Dateiname: IMPLEMENTATION_NEW_WEAPON_ARMORY.md

# Implementierung neuer Waffen & Deployables (inkl. Waffenkammer-Anzeige)
**Ziel:** Korrekte Erstellung eines neuen Items (hier: Deployable "Heavy Artillery Gun") und Sicherstellung der Verfügbarkeit in der Waffenkammer (Armory) für den Spieler.

## Voraussetzungen & Referenzen
- Zugriff auf den Mod-Overlay-Ordner (`media/packages/[ModName]/`).
- Vorhandene Basis-Assets (Meshes, Texturen, Sounds) oder Verweise auf Vanilla-Assets.
- XML-Editor (VS Code, Notepad++, Cursor).

## Schritt-für-Schritt-Anleitung

### Schritt 1: Erstellung der Definitions-Dateien
Erstelle die notwendigen XML-Dateien für das Item, das Fahrzeug (bei Deployables) und die Waffe.

**A. Das Kauf-Item (Deployable)**
Pfad: `weapons/heavy_artillery_deploy.weapon`
```xml
<weapon file="base_secondary.weapon" key="heavy_artillery_deploy.weapon">
    <specification 
        name="Heavy Artillery Gun" 
        slot="1" 
        spawn_instance_class="vehicle" 
        spawn_instance_key="heavy_artillery_gun.vehicle" 
        consume="1" 
        deployment="1" 
    />
    <!-- WICHTIG FÜR WAFFENKAMMER: -->
    <commonness value="0.0001" in_stock="1" can_respawn_with="0" />
    <inventory price="2000.0" encumbrance="15.0" />
    <hud_icon filename="hud_coastal_gun_deploy.png" />
    <!-- ... weitere Parameter (Animationen, Model) ... -->
</weapon>
```

**B. Das Fahrzeug (Vehicle)**
Pfad: `vehicles/heavy_artillery_gun.vehicle`
```xml
<vehicle key="heavy_artillery_gun.vehicle" ... >
    <!-- Referenz auf die Waffe des Fahrzeugs -->
    <turret weapon_key="heavy_artillery_gun.weapon" ... />
    <!-- ... Physics, Visuals, Sounds ... -->
</vehicle>
```

**C. Die Fahrzeug-Waffe (Turret)**
Pfad: `weapons/heavy_artillery_gun.weapon`
```xml
<weapon key="heavy_artillery_gun.weapon">
    <specification retrigger_time="15.0" sight_range_modifier="3.0" ... />
    <projectile file="coastal_gun.projectile" />
    <!-- ... Model, Sound, Effekte ... -->
</weapon>
```

### Schritt 2: Globale Registrierung (Engine-Load)
Damit die Engine die Dateien überhaupt kennt, müssen sie in den `all_*.xml`-Listen eingetragen werden. Ohne diesen Schritt werden die Dateien ignoriert.

**Datei:** `weapons/all_weapons.xml`
```xml
<weapons>
    ...
    <weapon file="heavy_artillery_gun.weapon" />    <!-- Die Waffe auf dem Turm -->
    <weapon file="heavy_artillery_deploy.weapon" /> <!-- Das Item für den Spieler -->
</weapons>
```

**Datei:** `vehicles/all_vehicles.xml`
```xml
<vehicles>
    ...
    <vehicle file="heavy_artillery_gun.vehicle" />
</vehicles>
```

### Schritt 3: Verfügbarkeit im Match (Resources)
Registriere die Objekte in `factions/common.resources` (oder einer spezifischen Fraktions-Ressource), damit sie im Match geladen werden.

**Datei:** `factions/common.resources`
```xml
<resources>
    ...
    <vehicle key="heavy_artillery_gun.vehicle" />
    <weapon key="heavy_artillery_gun.weapon" />
    <weapon key="heavy_artillery_deploy.weapon" />
</resources>
```

### Schritt 4: Anzeige in der Waffenkammer (Armory)
Damit das Item im Shop (Armory) erscheint, müssen **beide** Bedingungen erfüllt sein:

**A. Ressourcen-Pool:** Das Item muss in einer Ressourcen-Datei stehen, die der Default-Soldat lädt (z. B. `armory_common.resources` oder `*_secondaries.resources`), und in brown/green/grey.xml beim `default`-Soldaten eingebunden sein.

**B. in_stock und price in der .weapon-Datei:** Die Engine zeigt nur Items mit **`in_stock="1"`** und **`<inventory price="..." />`** in der Waffenkammer an. Vanilla-Waffen haben oft `in_stock="0"`. Dann muss der Mod eine **eigene .weapon-Datei** bereitstellen (Kopie der Vanilla-Datei mit `in_stock="1"`), damit die Mod-Version geladen wird und das Item im Shop erscheint.

**Datei:** `factions/brown_secondaries.resources` (Beispiel für Brown/Russia)
*(Füge es analog auch in `green_secondaries.resources` und `grey_secondaries.resources` ein)*

```xml
<resources>
    <weapon key='medikit.weapon' />
    <weapon key='rpg-7.weapon' />
    ...
    <!-- NEU HINZUGEFÜGT: -->
    <weapon key='heavy_artillery_deploy.weapon' />
</resources>
```

### Waffenkammer für alle (Testing)
**Ressourcen:** `factions/armory_common.resources` – enthält alle Stash-Waffen und Carry-Items; wird in brown/green/grey.xml beim Default-Soldaten nach `armory_vests.resources` geladen.  
**in_stock:** Vanilla-Waffen haben meist `in_stock="0"`. Im Mod liegen daher **Override-.weapon-Dateien** (taser_medic, tti, truvelo_amris, ultimax, ultimax_m, sabre, m16a4_support, sbl, camo_shield, golden_knife, gilboa_dbr, gun_tommy, m1_garand_m, origin_12, origin_12_s, compound_bow, compound_bow_alt, rpk16, rpk16_long, m200, m16a4_w_m203, m16a4_w_m203_g, g36_w_ag36, g36_w_ag36_g, ak47_w_gp25, ak47_w_gp25_g, an94_burst, qbz95, qbz95_us, qlz87_b, fhj01): identisch zu Vanilla, nur `in_stock="1"`. So erscheinen alle in der Waffenkammer.

### Quick Match & Stash (init_match-Timing)
**Problem:** `init_match.xml` wird beim Quick Match bereits im Fraktionsmenü ausgeführt – `character_id="1"` existiert noch nicht, Stash-Befehle greifen nicht.

**Lösung (Admin-Befehl):** Im **Spiel-Root** (dort wo `rwr_game.exe` liegt) liegt `admin_stash.xml`. Nach dem Spawn im Match Chat öffnen (Enter) und eingeben:
```text
/_execute admin_stash.xml
```
Damit wird der Stash für den lokalen Spieler (character_id 1) mit der definierten Waffen- und Carry-Item-Liste gefüllt. Befehl bei Bedarf wiederholbar.

**Wenn nichts passiert:** (1) Dateinamenerweiterungen in Windows anzeigen – die Datei muss `admin_stash.xml` heißen (nicht `admin_stash.xml.txt`). (2) XML muss mit `<commands>` umschlossen sein (siehe Datei im Spiel-Root). (3) Fehlerkontrolle: `%appdata%\Running with rifles\rwr_game.log` öffnen und nach dem Befehl die letzten Zeilen prüfen (`Failed to load` / `file not found` = Name oder Ort; `XML validation error` = Format/Syntax).

### Checkliste zur Fehlerbehebung
1.  **Item fehlt im Shop?**
    *   Steht **`in_stock="1"`** in der `.weapon`-Datei? (Vanilla nutzt oft `in_stock="0"` → Mod-Override mit `in_stock="1"` nötig.)
    *   Ist ein **`<inventory price="..." />`** definiert?
    *   Ist das Item in einer geladenen Ressourcen-Datei (z. B. `armory_common.resources` oder `*_secondaries.resources`) und wird diese beim Default-Soldaten der Fraktion geladen?
2.  **Absturz / Item funktioniert nicht?**
    *   Wurde das Item in `weapons/all_weapons.xml` registriert?
    *   Wurde das Vehicle in `vehicles/all_vehicles.xml` registriert?
3.  **KI spawnt ständig damit?**
    *   Setze `commonness value="0.0001"` (sehr niedrig) oder `0.0`.
    *   Stelle sicher, dass es NICHT in `default_vests.resources` oder ähnlichen Standard-Loadouts als einziges Item steht.
