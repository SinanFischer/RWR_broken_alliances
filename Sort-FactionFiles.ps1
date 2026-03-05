# ==============================================================================
# Sort-FactionFiles.ps1
# RWR Broken Alliances – Factions-Ordner nach Einheitenklassen sortieren
#
# VERWENDUNG:
#   1. Dry-Run (Simulation, KEINE echten Verschiebungen):
#      .\Sort-FactionFiles.ps1
#
#   2. Echter Lauf:
#      .\Sort-FactionFiles.ps1 -DryRun $false
#
# WARNUNG: Lies die README-Sektion am Ende dieser Datei, bevor du den echten
#          Lauf startest. Pfade in grey.xml/green.xml/brown.xml MÜSSEN danach
#          manuell angepasst werden!
# ==============================================================================

param(
    # DryRun = $true -> simuliert nur, verschiebt NICHTS.
    # DryRun = $false -> führt echte Move-Operationen aus.
    [bool]$DryRun = $true
)

# --- KONFIGURATION: Ziel-Verzeichnis ---
$FactionsPath = "C:\Program Files (x86)\Steam\steamapps\common\RunningWithRifles\media\packages\RWR_broken_alliances\factions"

# ==============================================================================
# SCHLÜSSELWORT-TABELLE – hier einfach neue Keywords ergänzen
# Reihenfolge der Keys bestimmt die Match-Priorität (oben = höhere Priorität)
# ==============================================================================
$CategoryKeywords = [ordered]@{
    "sniper"           = @("sniper", "lonewolf", "marksman", "recon")
    "eod"              = @("eod")
    "elite"            = @("elite", "specialforces", "specops", "blackops", "miniboss", "bodyguard", "captain")
    "support"          = @("support", "medic", "mg", "cover_troop", "mortar", "grenadier")
    # "common_resources" ist der automatische Fallback – kein Keyword nötig
}

# ==============================================================================
# SICHERHEITSLISTE – diese Dateien werden NIE verschoben (Fraktions-Kerndateien)
# Begründung: grey.xml etc. referenzieren Kindateien per RELATIVEM Pfad.
# Wenn grey.xml selbst umzieht, brechen ALLE internen Pfade sofort.
# ==============================================================================
$NeverMove = @(
    "grey.xml", "green.xml", "brown.xml",
    "grey_boss.xml", "green_boss.xml", "brown_boss.xml",
    "deathmatch.xml"
)

# ==============================================================================
# SKRIPT-LOGIK (nichts weiter unten ändern nötig)
# ==============================================================================

if ($DryRun) {
    Write-Host "`n[DRY-RUN MODUS] Keine Dateien werden wirklich verschoben.`n" -ForegroundColor Yellow
} else {
    Write-Host "`n[ECHTER LAUF] Dateien werden JETZT verschoben.`n" -ForegroundColor Red
}

# Unterordner erstellen (oder bestätigen dass sie existieren)
$SubFolders = @("elite", "eod", "support", "sniper", "common_resources")
foreach ($folder in $SubFolders) {
    $folderPath = Join-Path $FactionsPath $folder
    if (-not (Test-Path $folderPath)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $folderPath | Out-Null
        }
        Write-Host "[DIR] Erstelle: $folder\" -ForegroundColor Green
    }
}

# Protokoll-Sammlungen
$Moved   = @{}  # category -> list of filenames
$Skipped = @()  # Dateien in $NeverMove
$Errors  = @()  # Fehler beim Verschieben
$SubFolders | ForEach-Object { $Moved[$_] = @() }

# Nur Dateien im ROOT des Factions-Ordners (nicht rekursiv, nicht Unterordner)
$Files = Get-ChildItem -Path $FactionsPath -File

foreach ($file in $Files) {

    # Sicherheitscheck: Kerndateien nie anfassen
    if ($NeverMove -contains $file.Name) {
        $Skipped += $file.Name
        Write-Host "[SKIP]   $($file.Name) (Kerndatei – wird nie verschoben)" -ForegroundColor DarkGray
        continue
    }

    $fileNameLower  = $file.Name.ToLower()
    $targetCategory = $null

    # Keyword-Matching in Prioritäts-Reihenfolge
    foreach ($category in $CategoryKeywords.Keys) {
        foreach ($keyword in $CategoryKeywords[$category]) {
            if ($fileNameLower -like "*$keyword*") {
                $targetCategory = $category
                break
            }
        }
        if ($targetCategory) { break }
    }

    # Fallback: common_resources
    if (-not $targetCategory) {
        $targetCategory = "common_resources"
    }

    $destination     = Join-Path $FactionsPath $targetCategory
    $destinationFile = Join-Path $destination $file.Name

    # Konflikt-Check: Datei existiert bereits im Ziel
    if (Test-Path $destinationFile) {
        $Errors += "KONFLIKT: '$($file.Name)' existiert bereits in '$targetCategory\'. Übersprungen."
        Write-Host "[KONFLIKT] $($file.Name) -> $targetCategory\ (existiert bereits!)" -ForegroundColor Magenta
        continue
    }

    if ($DryRun) {
        Write-Host "[WOULD MOVE] $($file.Name)  ->  $targetCategory\" -ForegroundColor Cyan
        $Moved[$targetCategory] += $file.Name
    } else {
        try {
            Move-Item -Path $file.FullName -Destination $destination -ErrorAction Stop
            Write-Host "[MOVED]  $($file.Name)  ->  $targetCategory\" -ForegroundColor Cyan
            $Moved[$targetCategory] += $file.Name
        }
        catch {
            $errMsg = "FEHLER bei '$($file.Name)': $($_.Exception.Message)"
            $Errors += $errMsg
            Write-Host "[ERROR]  $errMsg" -ForegroundColor Red
        }
    }
}

# --- ZUSAMMENFASSUNG ---
Write-Host "`n===============================================================" -ForegroundColor White
Write-Host "  ZUSAMMENFASSUNG $(if ($DryRun) {'(DRY-RUN)'} else {'(ECHT)'})" -ForegroundColor White
Write-Host "===============================================================" -ForegroundColor White

foreach ($cat in $SubFolders) {
    $count = $Moved[$cat].Count
    if ($count -gt 0) {
        Write-Host "  $cat`: $count Datei(en)" -ForegroundColor Cyan
        $Moved[$cat] | ForEach-Object { Write-Host "      - $_" -ForegroundColor DarkCyan }
    }
}

Write-Host "  ÜBERSPRUNGEN (Kerndateien): $($Skipped.Count)" -ForegroundColor DarkGray

if ($Errors.Count -gt 0) {
    Write-Host "`n  FEHLER/KONFLIKTE: $($Errors.Count)" -ForegroundColor Red
    $Errors | ForEach-Object { Write-Host "    -> $_" -ForegroundColor Red }
}

Write-Host "`n[DONE] Skript abgeschlossen.`n" -ForegroundColor Green

if ($DryRun) {
    Write-Host "Zum echten Ausführen: .\Sort-FactionFiles.ps1 -DryRun `$false" -ForegroundColor Yellow
}

# ==============================================================================
# README – PFLICHTLEKTÜRE VOR DEM ECHTEN LAUF
# ==============================================================================
#
# KRITISCH: PFADE IN DEN FRAKTIONS-XMLS MÜSSEN NACH DEM VERSCHIEBEN ANGEPASST WERDEN
# ===================================================================================
#
# Die Engine löst Pfade in grey.xml/green.xml/brown.xml RELATIV ZUR EIGENEN
# DATEI-POSITION auf (nicht relativ zum Package-Root!).
#
# grey.xml liegt in:   factions/
# Es referenziert:     <resources file="grey_sniper.resources" />
#                                        ^--- relativ zu factions/
#
# Nach dem Verschieben von grey_sniper.resources nach factions/sniper/ muss
# in grey.xml aus:
#     <resources file="grey_sniper.resources" />
# werden:
#     <resources file="sniper/grey_sniper.resources" />
#
# VOLLSTÄNDIGES BEISPIEL (grey.xml, Soldat-Typ "sniper"):
# -------------------------------------------------------
# VORHER (alle Dateien in factions/):
#     <ai filename="sniper.ai" />
#     <resources file="common_snipers.resources" />
#     <resources file="grey_sniper.resources" />
#     <resources file="common_sniper_secondary.resources" />
#
# NACHHER (Dateien in factions/sniper/):
#     <ai filename="sniper/sniper.ai" />
#     <resources file="sniper/common_snipers.resources" />
#     <resources file="sniper/grey_sniper.resources" />
#     <resources file="sniper/common_sniper_secondary.resources" />
#
# DATEIEN DIE ANGEPASST WERDEN MÜSSEN:
#   - factions/grey.xml       (referenziert alle .resources, .ai, .models)
#   - factions/green.xml      (analog)
#   - factions/brown.xml      (analog)
#   - factions/grey_boss.xml  (analog, falls Boss-Units Unterordner-Dateien nutzen)
#   - factions/green_boss.xml (analog)
#   - factions/brown_boss.xml (analog)
#
# WARUM grey.xml SELBST NICHT VERSCHOBEN WIRD:
#   grey.xml wird von der RWR-Engine direkt aus factions/ geladen.
#   Würde grey.xml nach factions/common_resources/ verschoben, müsste entweder
#   package_config.xml oder der interne Engine-Lookup angepasst werden –
#   ein nicht-triviales Risiko für sofortige Crashes.
#   Daher: grey/green/brown.xml bleiben IMMER in factions/.
#
# EMPFOHLENE VORGEHENSWEISE:
#   1. Dry-Run ausführen und Liste prüfen
#   2. Git-Commit VOR dem echten Lauf (Sicherheitsnetz)
#   3. Echten Lauf ausführen: .\Sort-FactionFiles.ps1 -DryRun $false
#   4. grey.xml, green.xml, brown.xml öffnen und alle Pfade ergänzen
#   5. Spiel testen
# ==============================================================================
