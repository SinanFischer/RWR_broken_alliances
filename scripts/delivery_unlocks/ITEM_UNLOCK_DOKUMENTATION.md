# Item-Freischaltungen (Laptop/Briefcase → Waffenkammer)

Dokumentation für das Unlock-System: Laptop oder Briefcase (Aktenkoffer) in der Waffenkammer abgeben → zufälliges Item wird für die Fraktion freigeschaltet und erscheint in der Waffenkammer.

---

## Übersicht

| Modus      | Configurator                          | Liefer-Items     | Unlock-Quelle                 |
|-----------|----------------------------------------|------------------|-------------------------------|
| Quick Match | `ItemDeliveryConfiguratorQuickMatch`  | Laptop, Briefcase | `item_delivery_configurator_quickmatch.as` |
| Campaign/Invasion | `MyItemDeliveryConfigurator`        | Laptop, Briefcase | `item_delivery_configurator.as` |
| Vehicle   | `vehicle_delivery_configurator.as`     | Fahrzeuge         | separater Configurator        |

**Verwendung:** `gamemode_quick_match.as` lädt den Quick-Match-Configurator, `my_gamemode.as` den Campaign-Configurator.

---

## Architektur

```
Spieler liefert Laptop/Briefcase in Waffenkammer
    → ItemDeliveryOrganizer erkennt Abgabe
    → ResourceUnlocker.handleItemDeliveryCompleted()
    → changeFactionResources() sendet faction_resources-Command
    → Engine aktiviert Resource für Fraktion (soldier_group "default")
    → Item erscheint in Waffenkammer
```

**Wichtig:** Die Waffenkammer liest nur die **default**-Soldatengruppe. `MultiGroupResource` mit `"supply"` führt in Quick Match nicht zum Erscheinen in der Waffenkammer – nur `Resource` (default) verwenden.

---

## Neue Items integrieren – Checkliste

### 1. AngelScript: Unlock-Liste erweitern

**Quick Match** (`item_delivery_configurator_quickmatch.as`):

```angelscript
void buildUnlockLists() {
    // Laptop-Unlocks
    m_laptopUnlockList.push_back(Resource("mein_item.weapon", "weapon"));
    // oder
    m_laptopUnlockList.push_back(Resource("mein_vest.carry_item", "carry_item"));

    // Briefcase-Unlocks
    m_briefcaseUnlockList.push_back(Resource("mein_item.weapon", "weapon"));
}
```

**Campaign** (`item_delivery_configurator.as`): analog in `getUnlockWeaponList()` / `getUnlockWeaponList2()`.

---

### 2. Resource-Typ und Key-Format

| Typ          | Key-Format           | Beispiel                 |
|-------------|----------------------|--------------------------|
| Waffe       | `id.weapon`          | `mk23.weapon`, `xm25.weapon` |
| Weste/Item  | `id.carry_item`      | `vest_blackops3.carry_item`  |
| Granate     | `id.grenade`         | (falls verwendet)            |

**Immer `Resource(key, type)` verwenden**, nicht `MultiGroupResource` mit `"supply"` – die Waffenkammer berücksichtigt nur die `default`-Gruppe.

---

### 3. factions/common.resources

Item muss im Pool der Fraktion sein, **enabled="0"** für Unlock-only:

```xml
<!-- Unlock-Items: enabled="0" = Fraktion hat es erst nach Laptop/Briefcase-Abgabe -->
<weapon key='mein_item.weapon' enabled="0" />
<carry_item key='mein_vest.carry_item' enabled="0" />
```

Ohne Eintrag in `common.resources` kann die Fraktion das Item nicht erhalten.

---

### 4. Westen: armory_vests.resources

**Nur für Carry-Items (Vesten) nötig.** Neue Westen für die Waffenkammer:

```xml
<carry_item key="mein_vest.carry_item" enabled="0" />
```

`enabled="0"` → Fraktion bekommt es erst nach Unlock.  
`enabled="1"` → wäre sofort verfügbar (nicht für Unlock-Items).

---

### 5. Westen: green_boss.xml und grey_boss.xml (Quick Match)

Die **default**-Soldatengruppe muss `default_vests` und `armory_vests` laden, sonst kennt die Waffenkammer die Westen nicht:

```xml
<resources file="default_vests.resources" />
<resources file="armory_vests.resources" />
```

**Campaign** (green.xml, grey.xml, brown.xml) hat das bereits. Für Quick Match sind `green_boss` und `grey_boss` relevant.

---

### 6. Waffen: all_weapons.xml

Mod-Waffen müssen geladen werden:

```xml
<weapon file="mein_item.weapon" />
```

Falls die Waffe auskommentiert war, Zeile aktivieren.

---

### 7. Waffen-Definition (falls neu)

Neue Waffe: `weapons/mein_item.weapon` anlegen, in `all_weapons.xml` referenzieren.  
Neue Weste: `carry_items/mein_vest.carry_item` anlegen, in `armory_vests.resources` und `common.resources` eintragen.

---

## faction_resources Command-Format

Intern sendet `changeFactionResources()` z.B.:

```xml
<command class="faction_resources" faction_id="0" soldier_group_name="default">
  <weapon key="mk23.weapon" enabled="true" />
</command>
```

- `class`: `faction_resources`
- `faction_id`: Spielerfraktion (0 = erste Fraktion)
- `soldier_group_name`: `"default"` (Waffenkammer)
- Child-Element: `<weapon>` oder `<carry_item>` mit `key` und `enabled`

---

## Dateistruktur (relevant für Unlocks)

```
scripts/delivery_unlocks/
├── item_delivery_configurator_quickmatch.as   # Quick Match: Laptop/Briefcase
├── item_delivery_configurator.as              # Campaign: Laptop/Briefcase
├── vehicle_delivery_configurator.as           # Fahrzeug-Unlocks
└── ITEM_UNLOCK_DOKUMENTATION.md               # diese Datei

factions/
├── common.resources                           # Pool: Waffen, Westen (enabled=0/1)
├── armory_vests.resources                     # Westen für Waffenkammer
├── default_vests.resources                    # Basis-Pool (vest_default)
├── green_boss.xml                             # Quick Match: Green (default + armory_vests!)
├── grey_boss.xml                              # Quick Match: Grey (default + armory_vests!)
├── green.xml, grey.xml, brown.xml             # Campaign: haben armory_vests

weapons/
└── all_weapons.xml                            # Zu ladende Waffen
```

---

## Häufige Fehler

| Problem | Ursache | Lösung |
|---------|---------|--------|
| Unlock-Meldung, Item nicht in Waffenkammer | `MultiGroupResource` mit "supply" | `Resource` (nur default) verwenden |
| Weste erscheint nie | `armory_vests` nicht in green_boss/grey_boss | `default_vests` + `armory_vests` in default-Gruppe laden |
| Waffe erscheint nie | Waffe nicht in all_weapons.xml | `<weapon file="id.weapon" />` aktivieren |
| Item nicht im Pool | Fehlender Eintrag in common.resources | Eintrag mit `enabled="0"` hinzufügen |

---

## Schnellreferenz: Neues Unlock-Item hinzufügen

1. **item_delivery_configurator_quickmatch.as**: `m_laptopUnlockList` oder `m_briefcaseUnlockList` erweitern:
   ```angelscript
   m_laptopUnlockList.push_back(Resource("id.weapon", "weapon"));
   ```

2. **common.resources**: Eintrag mit `enabled="0"`:
   ```xml
   <weapon key='id.weapon' enabled="0" />
   ```

3. **Falls Weste**: `armory_vests.resources`:
   ```xml
   <carry_item key="id.carry_item" enabled="0" />
   ```

4. **Falls Weste + Quick Match**: Prüfen, ob green_boss/grey_boss `armory_vests` laden.

5. **Falls neue Waffe**: `all_weapons.xml` und Waffen-Definition anlegen/aktivieren.
