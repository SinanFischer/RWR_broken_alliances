# Skins von Project_Apocalypse übernehmen

Diese Anleitung listet alle Dateien, die aus **Project_Apocalypse** in den **RWR_total_conversion_mod** kopiert werden müssen, damit die empfohlenen Soldaten-Skins (inkl. Support + Supporter) funktionieren.

---

## Skin-Matrix & Einheiten-Zuordnung (Farbkonsistenz)

### Welche Einheit nutzt welche Skins?

Im RWR-Mod teilen sich **dieselbe Skin-Liste** (`.models`-Dateien) alle Soldatentypen, die keine festen Einzelmodelle haben:

| Einheit            | Nutzt .models-Dateien              | Erhält Skins aus … |
|--------------------|-----------------------------------|----------------------------------------|
| **default**        | `*_default_basic.models` + `*_default.models` | Basis-Pool + Vest/Tarn/EOD/BlackOps/HighRank |
| **support** (MG)   | wie default                      | wie default |
| **mortar_operator**| wie default                      | wie default |
| **cover_troop**    | wie default                      | wie default |
| **grenadier**      | wie default                      | wie default |

**Feste Einzelmodelle (kein Pool):**

| Einheit         | Grey              | Green             | Brown             |
|-----------------|-------------------|-------------------|-------------------|
| **eod**         | soldier_b1eod.xml | soldier_a1eod.xml | soldier_c1eod.xml  |
| **specialforces**| gerops.xml        | (blackops)        | rusops.xml        |
| **miniboss**    | ger_office.xml    | (miniboss)        | (miniboss)        |
| **miniboss_female** | soldier_elite_b2.xml | –              | –                 |
| **prisoner**    | soldier_prison.xml (ein Skin für alle) | | |

**Wichtig:** Es gibt **keine** getrennte Skin-Liste pro Einheitstyp. Mehr Abwechslung = mehr Modelle in `*_default_basic.models` und `*_default.models` pro Fraktion. Die Engine wählt anhand **Rank** und **getragener Weste/Ausrüstung** (carry_item) ein Model aus. Farbkonsistenz: **Nur** Grey-Skins in Grey-Fraktion, **nur** Green-Skins in Green-Fraktion, **nur** Brown-Skins in Brown-Fraktion.

### Aktueller Stand im Mod (vor PA-Übernahme)

| Fraktion | Basis-Pool (basic)        | Zusätzlich (default): Vest, Tarn, EOD, BlackOps, HighRank |
|----------|---------------------------|------------------------------------------------------------|
| **Grey** | ger_army_1, ger_army_1_1, ger_army_1_2 | ger_army_1_3, soldier_b1_camouflage_suit, soldier_b1eod, gerops, soldier_5stars_grey |
| **Green**| us_army_1, us_army_2, us_army_3 | us_army_1_bak_camo, soldier_camouflage_suit, soldier_a1eod, soldier_blackops, soldier_5stars_green |
| **Brown**| rus_army_1 (nur 1 Variante) | rus_army_1_bak_*, soldier_c1_camouflage_suit, soldier_c1eod, rusops, soldier_5stars_brown |

### Empfohlene PA-Skins pro Fraktion (nur passende, farblich zugeordnet)

- **Grey (EU):** soldier_b1, soldier_b2, soldier_b3, soldier_b3_vest, soldier_b1_camo_vest, soldier_b1_camouflage_suit, soldier_b1eod, soldier_blackops, soldier_5stars_grey, soldier_fm_grey, ggf. soldier_b_vest_t3 (Vest‑T3‑Look).
- **Green (US):** soldier_a1, soldier_a2, soldier_a3, soldier_a1_vest, soldier_camouflage_suit, soldier_a1eod, soldier_usf_assault, soldier_blackops, soldier_5stars_green, soldier_fm_green.
- **Brown (RU):** soldier_c1, soldier_c2, soldier_c3, soldier_c1_vest, soldier_c1_camouflage_suit, soldier_c1eod, soldier_fsb, rusops (falls in PA als Datei vorhanden), soldier_5stars_brown, soldier_fm_brown.

Skins aus PA, die wir **nicht** übernehmen (Thema/Stil/Farbe passt nicht oder PA-spezifisch): wick*, costume_*, soldier_rambo, soldier_terminator, soldier_nazi_rifleman, soldier_ninja, soldier_musket_*, soldier_sword_*, soldier_boris, soldier_ncr, soldier_ss, soldier_monolith, navy, prison (prison behalten wir nur, wenn ihr den gleichen Prison-Look wollt).

---

## Wichtig: Keine weiteren Assets nötig

Die Soldier-Modelle in Project_Apocalypse sind **Voxel-XMLs**: Geometrie, Farben und Skeleton sind in der jeweiligen `.xml` enthalten. Es werden **keine** zusätzlichen `.mesh`-, `.material`- oder Texture-Dateien referenziert.  
→ **Es reicht, die unten stehenden XML-Dateien zu kopieren.**

Die **soldier_animations.xml** bleibt die des RWR_total_conversion_mod (nicht ersetzen). Die Engine nutzt sie gemeinsam für alle Soldaten-Modelle.

---

## Quell- und Zielordner

| | Pfad |
|---|------|
| **Quelle** | `C:\Program Files (x86)\Steam\steamapps\workshop\content\270150\3238197561\media\packages\Project_Apocalypse\models\` |
| **Ziel** | `C:\Program Files (x86)\Steam\steamapps\workshop\content\270150\684867367\media\packages\RWR_total_conversion_mod\models\` |

Alle Dateien 1:1 in den **Ziel-**`models\`-Ordner kopieren (bestehende gleiche Namen werden überschrieben).

---

## Liste der zu kopierenden Dateien

### Pflicht (Basis + Varianten + High-Rank) – 18 Stück

**Grey (EU):** soldier_b1.xml, soldier_b2.xml, soldier_b3.xml, soldier_b3_vest.xml, soldier_b1_camo_vest.xml, soldier_fm_grey.xml  

**Green (US):** soldier_a1.xml, soldier_a2.xml, soldier_a3.xml, soldier_a1_vest.xml, soldier_usf_assault.xml, soldier_fm_green.xml  

**Brown (RU):** soldier_c1.xml, soldier_c2.xml, soldier_c3.xml, soldier_c1_vest.xml, soldier_fsb.xml, soldier_fm_brown.xml  

### Optional (mehr Abwechslung / Vest-T3-Look)

| Fraktion | Datei | Verwendung |
|----------|--------|------------|
| Grey | soldier_b_vest_t3.xml | Vest-T3-Varianten (statt ger_army_1_3) |
| Green | soldier_a_vest_t3.xml oder soldier_t_vest_t3.xml | Falls in PA vorhanden, für Vest-T3 |
| Brown | soldier_c_vest_t3.xml | Vest-T3-Varianten |

### EOD (optional überschreiben)

soldier_b1eod.xml, soldier_a1eod.xml, soldier_c1eod.xml – im Mod bereits referenziert; mit PA-Version überschreiben für einheitlichen Look.

### Bewusst nicht übernehmen (Stil/Thema/Farbe)

- wick*, costume_*, soldier_rambo*, soldier_terminator*, soldier_nazi_rifleman, soldier_ninja*, soldier_musket_*, soldier_sword_*, soldier_boris*, soldier_ncr*, soldier_ss, soldier_monolith, soldier_navy*, soldier_cowboy*  
- prisoner: soldier_prison.xml nur übernehmen, wenn ihr den PA-Prison-Look wollt (eine Version für alle Fraktionen).

---

## PowerShell-Kopierskript (optional)

Einmal in PowerShell ausführen (Quelle/Ziel wie oben). Zuerst die **Pflicht-Dateien**, danach optional die **Vest-T3**- und **EOD**-Dateien:

```powershell
$src = "C:\Program Files (x86)\Steam\steamapps\workshop\content\270150\3238197561\media\packages\Project_Apocalypse\models"
$dst = "C:\Program Files (x86)\Steam\steamapps\workshop\content\270150\684867367\media\packages\RWR_total_conversion_mod\models"

# Pflicht (Basis + Varianten + FM)
$files = @(
    "soldier_b1.xml", "soldier_b2.xml", "soldier_b3.xml",
    "soldier_b3_vest.xml", "soldier_b1_camo_vest.xml", "soldier_fm_grey.xml",
    "soldier_a1.xml", "soldier_a2.xml", "soldier_a3.xml",
    "soldier_a1_vest.xml", "soldier_usf_assault.xml", "soldier_fm_green.xml",
    "soldier_c1.xml", "soldier_c2.xml", "soldier_c3.xml",
    "soldier_c1_vest.xml", "soldier_fsb.xml", "soldier_fm_brown.xml"
)
foreach ($f in $files) {
    $sp = Join-Path $src $f
    if (Test-Path $sp) { Copy-Item $sp $dst -Force; Write-Host "OK: $f" } else { Write-Host "FEHLT: $f" }
}

# Optional: Vest-T3 + EOD (überschreibt ggf. vorhandene)
$optional = @("soldier_b_vest_t3.xml", "soldier_c_vest_t3.xml", "soldier_t_vest_t3.xml", "soldier_b1eod.xml", "soldier_a1eod.xml", "soldier_c1eod.xml")
foreach ($f in $optional) {
    $sp = Join-Path $src $f
    if (Test-Path $sp) { Copy-Item $sp $dst -Force; Write-Host "OK (optional): $f" } else { Write-Host "Optional nicht vorhanden: $f" }
}
```

---

## Nach dem Kopieren: Faction-.models anpassen

Aktuell verweisen eure **basic**-Dateien im Mod auf **andere** Dateinamen als PA:

- **Grey:** ger_army_1.xml, ger_army_1_1.xml, ger_army_1_2.xml  
- **Green:** us_army_1.xml, us_army_2.xml, us_army_3.xml  
- **Brown:** rus_army_1.xml (nur eine Variante)

Damit die **PA-Skins** genutzt werden, müsst ihr eine der beiden Wege gehen:

**Option A – .models auf PA-Namen umstellen (empfohlen für maximale Abwechslung):**

- In `grey_default_basic.models`: Einträge ersetzen durch `soldier_b1.xml`, `soldier_b2.xml`, `soldier_b3.xml`.
- In `green_default_basic.models`: ersetzen durch `soldier_a1.xml`, `soldier_a2.xml`, `soldier_a3.xml`.
- In `brown_default_basic.models`: ersetzen durch `soldier_c1.xml`, `soldier_c2.xml`, `soldier_c3.xml` (damit Brown ebenfalls 3 Basis-Varianten hat).
- In `*_default.models`: Vest-/Tarn-/EOD-/BlackOps-/HighRank-Referenzen von ger_army_1_3 / us_army_1_bak_camo / rus_army_1_bak_* auf die PA-Pendants umstellen (z. B. soldier_b3_vest, soldier_b_vest_t3 für Grey; soldier_a1_vest / us_army-Varianten für Green; soldier_c1_vest, rus_army-Varianten für Brown). Nur Einträge anpassen, deren carry_item/Keys ihr im Mod habt (vest2, vest3, vest4, camouflage_suit, eod, blackops, rank).

**Option B – PA-Dateien unter euren bestehenden Namen kopieren:**

- PA `soldier_b1.xml` zusätzlich als `ger_army_1.xml` kopieren, `soldier_b2.xml` als `ger_army_1_1.xml`, `soldier_b3.xml` als `ger_army_1_2.xml` (analog Green/Brown). Dann bleiben eure .models unverändert; ihr nutzt aber nur je einen PA-Skin pro Slot (keine echte b2/b3-Vielfalt unter verschiedenen Namen).

Wenn ihr für **Support** oder **Supporter** eigene Looks wollt, könnt ihr neue .models-Dateien anlegen (z. B. grey_support.models mit nur soldier_b1_camo_vest.xml) und in der Faction-XML beim `<soldier name="support">` diese Datei zusätzlich einbinden.

---

## Kurz-Checkliste

- [ ] Pflicht-XMLs (18 Stück) von Project_Apocalypse\models\ nach RWR_total_conversion_mod\models\ kopiert
- [ ] Optional: Vest-T3- und EOD-XMLs kopiert, falls gewünscht
- [ ] soldier_animations.xml **nicht** überschrieben
- [ ] Faction-.models angepasst: entweder auf PA-Namen umgestellt (Option A) oder PA-Dateien unter bestehenden Namen kopiert (Option B)
- [ ] Spiel testen (Grey/Green/Brown; Default, Support, Mortar, Cover, Grenadier) – farblich keine Mischung zwischen Fraktionen
