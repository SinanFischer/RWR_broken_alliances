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

## Erkenntnisse / Fallstricke (nicht erneut machen)

1. **`in_stock="0"` in carry_item**: Weste wird per faction_resources freigeschaltet, Unlock-Meldung erscheint – aber die Weste **nicht** in der Waffenkammer. Ursache: Die Engine filtert Items mit `in_stock="0"` aus der Waffenkammer-Anzeige. Fix: `in_stock="1"` in der `.carry_item`-Datei.

2. **`MultiGroupResource` mit "supply"**: Waffenkammer nutzt nur die Gruppe `"default"`. Unlock für "supply" allein führt nicht zur Anzeige. Fix: `Resource` verwenden (nur default).

3. **green_boss / grey_boss ohne armory_vests**: Quick Match nutzt diese Fraktionen. Ohne `default_vests` und `armory_vests` in der default-Gruppe kennt die Waffenkammer die Westen nicht.

4. **Ähnliche IDs (vest_blackops vs vest_blackops3)**: Sind verschiedene IDs – kein Konflikt. Beide können dasselbe Mesh nutzen (`vest_black.xml`).

5. **Falsche Fraktion (EU/UN-Maps)**: Unlock landete bei faction_id=0 – bei mehreren Fraktionen (EU, UN, …) ist 0 oft nicht die Spielerfraktion. Fix: `PlayerFactionResourceUnlocker` nutzt die Fraktion des liefernden Charakters (`getCharacterInfo` → `faction_id`).

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

### 5. Westen: in_stock in der carry_item-Definition ⚠️ KRITISCH

**Häufiger Fehler:** Weste wird freigeschaltet (Meldung kommt), erscheint aber **nicht** in der Waffenkammer.

**Ursache:** In der `*.carry_item`-Datei steht `in_stock="0"`. Die Engine blendet damit Items aus der Waffenkammer aus – unabhängig davon, ob die Fraktion sie besitzt.

**Lösung:** In der Westen-Definition (z.B. `items/vest_blackops3.carry_item`) muss stehen:

```xml
<commonness value="0.0" in_stock="1" can_respawn_with="0" />
```

- `in_stock="0"` → **nie** in Waffenkammer anzeigen (z.B. Admin-Only, Drops)
- `in_stock="1"` → in Waffenkammer anzeigen, **wenn** die Fraktion die Weste hat

**Bei Transform-States** (z.B. vest_blackops3 → bo3_2 → bo3_3 → bo3_4): Alle Einträge in derselben Datei auf `in_stock="1"` setzen, falls die Basis-Weste in der Waffenkammer erscheinen soll. Die Transform-States werden nicht einzeln ausgewählt – nur die Basis-Weste.

**Beispiel Fall:** vest_blackops3 hatte ursprünglich `in_stock="0"` (für Admin-Test-Spawns gedacht) → nach Unlock erschien sie nicht in der Waffenkammer. Fix: `in_stock="1"`.

---

### 6. Westen: green_boss.xml und grey_boss.xml (Quick Match)

Die **default**-Soldatengruppe muss `default_vests` und `armory_vests` laden, sonst kennt die Waffenkammer die Westen nicht:

```xml
<resources file="default_vests.resources" />
<resources file="armory_vests.resources" />
```

**Campaign** (green.xml, grey.xml, brown.xml) hat das bereits. Für Quick Match sind `green_boss` und `grey_boss` relevant.

---

### 7. Waffen: all_weapons.xml

Mod-Waffen müssen geladen werden:

```xml
<weapon file="mein_item.weapon" />
```

Falls die Waffe auskommentiert war, Zeile aktivieren.

---

### 8. Waffen-Definition (falls neu)

Neue Waffe: `weapons/mein_item.weapon` anlegen, in `all_weapons.xml` referenzieren.  
Neue Weste: `items/mein_vest.carry_item` anlegen, in `armory_vests.resources` und `common.resources` eintragen. **Nicht vergessen:** `in_stock="1"` in `<commonness>`.

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

items/
└── *.carry_item                               # Westen-Definitionen (in_stock=1 für Waffenkammer!)
```

---

## Häufige Fehler

| Problem | Ursache | Lösung |
|---------|---------|--------|
| Unlock-Meldung, Item nicht in Waffenkammer | `MultiGroupResource` mit "supply" | `Resource` (nur default) verwenden |
| **Weste: Unlock-Meldung, aber nicht in Waffenkammer** | **`in_stock="0"` in carry_item-Definition** | **`in_stock="1"` in `items/xxx.carry_item` setzen** |
| Weste erscheint nie | `armory_vests` nicht in green_boss/grey_boss | `default_vests` + `armory_vests` in default-Gruppe laden |
| Waffe erscheint nie | Waffe nicht in all_weapons.xml | `<weapon file="id.weapon" />` aktivieren |
| Item nicht im Pool | Fehlender Eintrag in common.resources | Eintrag mit `enabled="0"` hinzufügen |
| **Unlock bei falscher Fraktion (EU liefert, UN bekommt)** | **Hardcoded faction_id=0** | **`PlayerFactionResourceUnlocker` statt `ResourceUnlocker` (nutzt Charakter-Fraktion)** |

---

## Schnellreferenz: Neues Unlock-Item hinzufügen

### Waffe

1. **item_delivery_configurator_quickmatch.as**: `m_laptopUnlockList` oder `m_briefcaseUnlockList`:
   ```angelscript
   m_laptopUnlockList.push_back(Resource("id.weapon", "weapon"));
   ```
2. **common.resources**: `<weapon key='id.weapon' enabled="0" />`
3. **all_weapons.xml**: `<weapon file="id.weapon" />` (falls neue Waffe: Definition anlegen)

### Weste (alle Schritte erforderlich)

1. **item_delivery_configurator_quickmatch.as**: Unlock-Liste erweitern (s.o.)
2. **common.resources**: `<carry_item key='id.carry_item' enabled="0" />`
3. **armory_vests.resources**: `<carry_item key="id.carry_item" enabled="0" />`
4. **green_boss.xml / grey_boss.xml**: `default_vests` + `armory_vests` in default-Gruppe laden (falls noch nicht vorhanden)
5. **items/id.carry_item**: `in_stock="1"` in `<commonness>` – **sonst erscheint die Weste trotz Unlock nicht in der Waffenkammer**

---

## Vorgehensweise im Überblick

| Schritt | Waffe | Weste |
|---------|-------|-------|
| Unlock-Liste (AngelScript) | ✓ | ✓ |
| common.resources, enabled=0 | ✓ | ✓ |
| armory_vests.resources | – | ✓ |
| green_boss/grey_boss: armory_vests | – | ✓ (Quick Match) |
| all_weapons.xml | ✓ | – |
| **carry_item: in_stock=1** | – | **✓** |
