# Kopiert alle Wiesel- und Captain/Bodyguard-Assets von Project_Apocalypse in Broken Alliances.
# Einmal ausfuehren (Rechtklick -> Mit PowerShell ausfuehren oder: powershell -ExecutionPolicy Bypass -File copy_wiesel_assets.ps1)

$PA  = "C:\Program Files (x86)\Steam\steamapps\workshop\content\270150\3238197561\media\packages\Project_Apocalypse"
$RWR = "C:\Program Files (x86)\Steam\steamapps\common\RunningWithRifles\media\packages\broken_alliances"

$models = @(
    "wiesel_body.mesh", "wiesel_body_broken.mesh", "wiesel_tow.mesh", "wiesel_mg3.mesh", "wiesel_track.mesh",
    "wiesel_mk20_body.mesh", "wiesel_mk20_body_broken.mesh", "wiesel_mk20_turret.mesh", "wiesel_mk20_turret_broken.mesh", "wiesel_mk20_cannon.mesh",
    "javelin_backpack.xml", "javmissile.xml"
)
$textures = @(
    "wiesel_body.png", "wiesel_body_broken.png", "wiesel_turret.png",
    "wiesel_mk20_body.png", "wiesel_mk20_body_broken.png", "wiesel_mk20_turret.png", "wiesel_mk20_turret_broken.png",
    "flare_stick.png", "flare_stick_blue.png", "hud_flare_blue.png"
)
$sounds = @("wiesel_mk20_shot.wav", "minigun.wav")
$weapons = @("javelin_type2.projectile")

$copied = 0
$missing = @()

foreach ($f in $models) {
    $src = Join-Path $PA "models\$f"
    if (Test-Path $src) { Copy-Item $src (Join-Path $RWR "models\$f") -Force; $copied++ } else { $missing += $src }
}
foreach ($f in $textures) {
    $src = Join-Path $PA "textures\$f"
    if (Test-Path $src) { Copy-Item $src (Join-Path $RWR "textures\$f") -Force; $copied++ } else { $missing += $src }
}
foreach ($f in $sounds) {
    $src = Join-Path $PA "sounds\$f"
    if (Test-Path $src) { Copy-Item $src (Join-Path $RWR "sounds\$f") -Force; $copied++ } else { $missing += $src }
}
foreach ($f in $weapons) {
    $src = Join-Path $PA "weapons\$f"
    if (Test-Path $src) { Copy-Item $src (Join-Path $RWR "weapons\$f") -Force; $copied++ } else { $missing += $src }
}

Write-Host "Kopiert: $copied Dateien."
if ($missing.Count -gt 0) { Write-Host "Nicht gefunden (evtl. in PA fehlend):"; $missing | ForEach-Object { Write-Host "  $_" } }
