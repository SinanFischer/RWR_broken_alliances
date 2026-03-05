param(
    [switch]$Execute
)

$DryRun = -not $Execute.IsPresent

$WeaponsPath = "C:\Program Files (x86)\Steam\steamapps\common\RunningWithRifles\media\packages\RWR_broken_alliances\weapons"

Write-Host "`n=== Update-WeaponPaths.ps1 ===" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "MODUS: DRY-RUN" -ForegroundColor Yellow
} else {
    Write-Host "MODUS: EXECUTE" -ForegroundColor Red
}

# Phase 1: FileMap aufbauen { 'filename.weapon' -> 'subfolder' }
$Subfolders = @('green', 'brown', 'grey', 'common')
$FileMap = @{}
foreach ($Folder in $Subfolders) {
    $FolderPath = Join-Path $WeaponsPath $Folder
    if (Test-Path $FolderPath) {
        Get-ChildItem -Path $FolderPath -File | ForEach-Object { $FileMap[$_.Name] = $Folder }
    }
}

if ($FileMap.Count -eq 0) {
    Write-Host "FEHLER: Keine verschobenen Dateien gefunden. Zuerst Sort-WeaponFiles.ps1 -Execute ausfuehren." -ForegroundColor Red
    exit 1
}
Write-Host "Erkannte verschobene Dateien: $($FileMap.Count)`n" -ForegroundColor Cyan

# Hilfsfunktion: ersetzt bare file="name" Referenzen per literalem String-Replace
# (kein Regex -> kein Escaping-Problem, kein doppeltes Patching)
function Update-FileRefs {
    param([string]$Content, [hashtable]$Map, [ref]$Count)
    foreach ($FileName in $Map.Keys) {
        $Old = 'file="' + $FileName + '"'
        $New = 'file="' + $Map[$FileName] + '/' + $FileName + '"'
        if ($Content.Contains($Old)) {
            $Content = $Content.Replace($Old, $New)
            $Count.Value++
        }
    }
    return $Content
}

# Phase 2: Master-XML Dateien (weapons/ Root + alle maps/ Unterordner)
Write-Host "--- Phase 2: Master-XML ---" -ForegroundColor Yellow
$ModRoot = Split-Path $WeaponsPath -Parent

# Direkte Master-Dateien im weapons/ Root
$MasterPaths = @(
    (Join-Path $WeaponsPath 'all_weapons.xml'),
    (Join-Path $WeaponsPath 'invasion_all_weapons.xml'),
    (Join-Path $WeaponsPath 'all_throwables.xml'),
    (Join-Path $WeaponsPath 'invasion_all_throwables.xml')
)

# Alle all_weapons.xml Dateien in maps/ Unterordnern
$MapWeaponFiles = Get-ChildItem -Path (Join-Path $ModRoot 'maps') -Recurse -Filter 'all_weapons.xml' -ErrorAction SilentlyContinue
foreach ($mf in $MapWeaponFiles) { $MasterPaths += $mf.FullName }

foreach ($Path in $MasterPaths) {
    if (-not (Test-Path $Path)) { Write-Host "SKIP (nicht vorhanden): $Path" -ForegroundColor DarkGray; continue }

    $RelPath = $Path.Replace($ModRoot + '\', '')
    $Content = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    $Changes = 0
    $Content = Update-FileRefs -Content $Content -Map $FileMap -Count ([ref]$Changes)

    if ($Changes -gt 0) {
        Write-Host "UPDATE $RelPath : $Changes Referenzen" -ForegroundColor Green
        if (-not $DryRun) { [System.IO.File]::WriteAllText($Path, $Content, [System.Text.Encoding]::UTF8) }
    } else {
        Write-Host "OK (keine Aenderung): $RelPath" -ForegroundColor DarkGray
    }
}

# Phase 3: Interne Referenzen in verschobenen .weapon Dateien
# z.B. green/famasg1_elite.weapon hat file="famasg1.weapon" -> file="green/famasg1.weapon"
Write-Host "`n--- Phase 3: Interne .weapon Referenzen ---" -ForegroundColor Yellow
$TotalInternal = 0
foreach ($Folder in $Subfolders) {
    $FolderPath = Join-Path $WeaponsPath $Folder
    if (-not (Test-Path $FolderPath)) { continue }
    foreach ($WFile in (Get-ChildItem -Path $FolderPath -Filter "*.weapon" -File)) {
        $Content = [System.IO.File]::ReadAllText($WFile.FullName, [System.Text.Encoding]::UTF8)
        $Changes = 0
        $Content = Update-FileRefs -Content $Content -Map $FileMap -Count ([ref]$Changes)
        if ($Changes -gt 0) {
            Write-Host "  UPDATE $Folder/$($WFile.Name) : $Changes interne Ref(en)" -ForegroundColor Green
            $TotalInternal += $Changes
            if (-not $DryRun) { [System.IO.File]::WriteAllText($WFile.FullName, $Content, [System.Text.Encoding]::UTF8) }
        }
    }
}
if ($TotalInternal -eq 0) { Write-Host "  Keine internen Referenzen benoetigen Update." -ForegroundColor DarkGray }

# Phase 4: Verifikation aller Master-Dateien inkl. maps/
Write-Host "`n--- Phase 4: Verifikation ---" -ForegroundColor Yellow
$Warnings = 0
$VerifyPaths = @(
    (Join-Path $WeaponsPath 'all_weapons.xml'),
    (Join-Path $WeaponsPath 'invasion_all_weapons.xml')
)
$MapWeaponFilesVerify = Get-ChildItem -Path (Join-Path $ModRoot 'maps') -Recurse -Filter 'all_weapons.xml' -ErrorAction SilentlyContinue
foreach ($mf in $MapWeaponFilesVerify) { $VerifyPaths += $mf.FullName }

foreach ($Path in $VerifyPaths) {
    if (-not (Test-Path $Path)) { continue }
    $RelPath = $Path.Replace($ModRoot + '\', '')
    $Content = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    foreach ($FileName in $FileMap.Keys) {
        $Bare = 'file="' + $FileName + '"'
        if ($Content.Contains($Bare)) {
            Write-Host "WARN: '$Bare' noch ohne Prefix in $RelPath" -ForegroundColor Red
            $Warnings++
        }
    }
}
if ($Warnings -eq 0) {
    Write-Host "Alle Referenzen korrekt." -ForegroundColor Green
} else {
    Write-Host "$Warnings Referenz(en) benoetigen manuelle Pruefung!" -ForegroundColor Red
}

Write-Host "`n=== FERTIG ===" -ForegroundColor Cyan
if ($DryRun) { Write-Host "Echter Lauf: .\Update-WeaponPaths.ps1 -Execute" -ForegroundColor Yellow }
