# Skins von Project_Apocalypse übernehmen

Diese Anleitung listet alle Dateien, die aus **Project_Apocalypse** in den **RWR_total_conversion_mod** kopiert werden müssen, damit die empfohlenen Soldaten-Skins (inkl. Support + Supporter) funktionieren.

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

## Liste der zu kopierenden Dateien (18 Stück)

### Grey (EU) – Basis + Support + Supporter
| # | Dateiname |
|---|-----------|
| 1 | `soldier_b1.xml` |
| 2 | `soldier_b2.xml` |
| 3 | `soldier_b3.xml` |
| 4 | `soldier_b3_vest.xml` |
| 5 | `soldier_b1_camo_vest.xml` |
| 6 | `soldier_fm_grey.xml` |

### Green (US) – Basis + Support + Supporter
| # | Dateiname |
|---|-----------|
| 7 | `soldier_a1.xml` |
| 8 | `soldier_a2.xml` |
| 9 | `soldier_a3.xml` |
| 10 | `soldier_a1_vest.xml` |
| 11 | `soldier_usf_assault.xml` |
| 12 | `soldier_fm_green.xml` |

### Brown (RU) – Basis + Support + Supporter
| # | Dateiname |
|---|-----------|
| 13 | `soldier_c1.xml` |
| 14 | `soldier_c2.xml` |
| 15 | `soldier_c3.xml` |
| 16 | `soldier_c1_vest.xml` |
| 17 | `soldier_fsb.xml` |
| 18 | `soldier_fm_brown.xml` |

*(Falls ihr EOD behaltet und die PA-EOD-Skins nutzen wollt, zusätzlich: soldier_b1eod.xml, soldier_a1eod.xml, soldier_c1eod.xml – im Mod bereits vorhanden, ggf. mit PA-Version überschreiben.)*

---

## PowerShell-Kopierskript (optional)

Einmal in PowerShell ausführen (Quelle/Ziel wie oben):

```powershell
$src = "C:\Program Files (x86)\Steam\steamapps\workshop\content\270150\3238197561\media\packages\Project_Apocalypse\models"
$dst = "C:\Program Files (x86)\Steam\steamapps\workshop\content\270150\684867367\media\packages\RWR_total_conversion_mod\models"

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
```

---

## Nach dem Kopieren: Faction-.models anpassen

Damit die neuen Skins genutzt werden, müssen die **Faction-.models** im Mod auf diese Dateien verweisen. Aktuell nutzt ihr z. B.:

- `grey_default_basic.models` + `grey_default.models`
- `green_default_basic.models` + `green_default.models`
- `brown_default_basic.models` + `brown_default.models`

Die **basic**-Dateien listen die Basis-Varianten (z. B. soldier_b1/b2/b3). Die **default**-Dateien listen zusätzliche Looks (Vesten, Tarnanzug, EOD, FM, etc.) mit `requirement` (Rank, carry_item).

**Option A – Nur ersetzen:**  
Ihr kopiert die **factions**-`.models`-Dateien aus Project_Apocalypse (grey_default_basic.models, grey_default.models, …) in euren Mod und passt nur die Pfade/Referenzen an, die auf PA-spezifische Ressourcen zeigen (z. B. carry_items, die ihr nicht habt). Oder ihr behaltet eure .models und ergänzt/ersetzt nur die model-Einträge für die neuen Skins.

**Option B – Minimale Anpassung:**  
In euren bestehenden `*_default_basic.models` und `*_default.models` bleiben die gleichen **Dateinamen** (soldier_b1.xml, soldier_a1.xml, …). Nach dem Kopieren der 19 XMLs aus PA zeigen eure .models automatisch auf die neuen Skins – **keine Änderung an den .models nötig**, sofern ihr die gleichen Dateinamen weiterverwendet.

Wenn ihr für **Support** oder **Supporter** eigene Looks wollt, könnt ihr neue .models-Dateien anlegen (z. B. grey_support.models mit nur soldier_b1_camo_vest.xml) und in der Faction-XML beim `<soldier name="support">` diese Datei zusätzlich einbinden.

---

## Kurz-Checkliste

- [ ] 18 XML-Dateien von Project_Apocalypse\models\ nach RWR_total_conversion_mod\models\ kopiert
- [ ] soldier_animations.xml **nicht** überschrieben
- [ ] Optional: Faction-.models angepasst, falls ihr eigene .models aus PA übernommen habt
- [ ] Spiel testen (Grey/Green/Brown, Default, Support, ggf. Supporter)
