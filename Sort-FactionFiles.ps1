# Sort-FactionFiles.ps1
# RWR Broken Alliances - Factions-Ordner nach Einheitenklassen sortieren
#
# Dry-Run (Standard, verschiebt NICHTS):
#   .\Sort-FactionFiles.ps1
#
# Echter Lauf:
#   .\Sort-FactionFiles.ps1 -DryRun $false

param(
    # Standard = Dry-Run. Echter Lauf: .\Sort-FactionFiles.ps1 -Execute
    [switch]$Execute
)
$DryRun = -not $Execute.IsPresent

$FactionsPath = "C:\Program Files (x86)\Steam\steamapps\common\RunningWithRifles\media\packages\RWR_broken_alliances\factions"

# --- SCHLUESSELWORT-TABELLE (oben = hoehere Prioritaet) ---
# Einfach neue Keywords in die Arrays eintragen.
$CategoryKeywords = [ordered]@{
    "sniper"  = @("sniper", "lonewolf", "marksman", "recon")
    "eod"     = @("eod")
    "elite"   = @("elite", "specialforces", "specops", "blackops", "miniboss", "bodyguard", "captain")
    "support" = @("support", "medic", "mg", "cover_troop", "mortar", "grenadier")
}

# --- KERNDATEIEN: Werden NIE verschoben ---
# grey.xml referenziert Kinder per relativer Pfad -> Verschieben wuerde alle internen Pfade brechen.
$NeverMove = @(
    "grey.xml", "green.xml", "brown.xml",
    "grey_boss.xml", "green_boss.xml", "brown_boss.xml",
    "deathmatch.xml"
)

# --- Unterordner anlegen ---
$SubFolders = @("sniper", "eod", "elite", "support", "common_resources")

if ($DryRun) {
    Write-Host ""
    Write-Host "[DRY-RUN] Simulation - keine Dateien werden verschoben." -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "[ECHTER LAUF] Dateien werden jetzt verschoben." -ForegroundColor Red
    Write-Host ""
}

foreach ($folder in $SubFolders) {
    $folderPath = Join-Path $FactionsPath $folder
    if (-not (Test-Path $folderPath)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $folderPath | Out-Null
        }
        Write-Host "[DIR] Erstelle: $folder\" -ForegroundColor Green
    }
}

# Protokoll
$Moved   = @{}
$Skipped = @()
$Errors  = @()
foreach ($cat in $SubFolders) { $Moved[$cat] = @() }

# Nur Dateien im Root-Verzeichnis (nicht rekursiv)
$Files = Get-ChildItem -Path $FactionsPath -File

foreach ($file in $Files) {

    # Kerndateien schuetzen
    if ($NeverMove -contains $file.Name) {
        $Skipped += $file.Name
        Write-Host "[SKIP]   $($file.Name)  (Kerndatei - nie verschieben)" -ForegroundColor DarkGray
        continue
    }

    $lower  = $file.Name.ToLower()
    $target = $null

    # Keyword-Matching in Prioritaetsreihenfolge
    foreach ($cat in $CategoryKeywords.Keys) {
        foreach ($kw in $CategoryKeywords[$cat]) {
            if ($lower -like "*$kw*") {
                $target = $cat
                break
            }
        }
        if ($target) { break }
    }

    # Fallback
    if (-not $target) { $target = "common_resources" }

    $destDir  = Join-Path $FactionsPath $target
    $destFile = Join-Path $destDir $file.Name

    # Konflikt: Zieldatei existiert bereits
    if (Test-Path $destFile) {
        $msg = "KONFLIKT: '$($file.Name)' existiert bereits in '$target\' -> uebersprungen"
        $Errors += $msg
        Write-Host "[KONFLIKT] $msg" -ForegroundColor Magenta
        continue
    }

    if ($DryRun) {
        Write-Host "[MOVE?]  $($file.Name)  ->  $target\" -ForegroundColor Cyan
        $Moved[$target] += $file.Name
    } else {
        try {
            Move-Item -Path $file.FullName -Destination $destDir -ErrorAction Stop
            Write-Host "[MOVED]  $($file.Name)  ->  $target\" -ForegroundColor Cyan
            $Moved[$target] += $file.Name
        } catch {
            $err = "FEHLER bei '$($file.Name)': $($_.Exception.Message)"
            $Errors += $err
            Write-Host "[ERROR]  $err" -ForegroundColor Red
        }
    }
}

# --- Zusammenfassung ---
Write-Host ""
Write-Host "======================================================" -ForegroundColor White
if ($DryRun) {
    Write-Host "  ZUSAMMENFASSUNG (DRY-RUN)" -ForegroundColor Yellow
} else {
    Write-Host "  ZUSAMMENFASSUNG (ECHT)" -ForegroundColor Green
}
Write-Host "======================================================" -ForegroundColor White

$total = 0
foreach ($cat in $SubFolders) {
    $n = $Moved[$cat].Count
    $total += $n
    if ($n -gt 0) {
        Write-Host "  $cat`:  $n Datei(en)" -ForegroundColor Cyan
        foreach ($f in $Moved[$cat]) {
            Write-Host "      $f" -ForegroundColor DarkCyan
        }
    }
}
Write-Host "  common_resources (Fallback) siehe oben" -ForegroundColor DarkGray
Write-Host "  Kerndateien uebersprungen: $($Skipped.Count)" -ForegroundColor DarkGray
Write-Host "  Gesamt verschoben: $total" -ForegroundColor White

if ($Errors.Count -gt 0) {
    Write-Host ""
    Write-Host "  FEHLER/KONFLIKTE: $($Errors.Count)" -ForegroundColor Red
    foreach ($e in $Errors) {
        Write-Host "    -> $e" -ForegroundColor Red
    }
}

Write-Host ""
if ($DryRun) {
    Write-Host "Echter Lauf: .\Sort-FactionFiles.ps1 -Execute" -ForegroundColor Yellow
}
Write-Host "[DONE]" -ForegroundColor Green
Write-Host ""
