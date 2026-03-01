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
Damit das Item im Shop (Armory) erscheint, muss es dem **Ressourcen-Pool des Default-Soldaten** der Spielerfraktion hinzugefügt werden.

**Logik:**
1.  Der `default`-Soldat (in `factions/brown.xml`, `green.xml`, etc.) lädt Ressourcen-Dateien.
2.  Üblicherweise sind Sekundärwaffen in `*_secondaries.resources` organisiert.
3.  Das Item muss dort gelistet sein UND `in_stock="1"` haben.

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

### Checkliste zur Fehlerbehebung
1.  **Item fehlt im Shop?**
    *   Steht `in_stock="1"` in der `.weapon`-Datei?
    *   Ist ein `price="..."` definiert?
    *   Ist das Item in der `*_secondaries.resources` der Fraktion eingetragen, die du spielst?
2.  **Absturz / Item funktioniert nicht?**
    *   Wurde das Item in `weapons/all_weapons.xml` registriert?
    *   Wurde das Vehicle in `vehicles/all_vehicles.xml` registriert?
3.  **KI spawnt ständig damit?**
    *   Setze `commonness value="0.0001"` (sehr niedrig) oder `0.0`.
    *   Stelle sicher, dass es NICHT in `default_vests.resources` oder ähnlichen Standard-Loadouts als einziges Item steht.
