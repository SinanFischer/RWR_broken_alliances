# Sets ai_sight_range_modifier = sight_range_modifier * 0.9 (10 % unter Spieler). InvariantCulture = sichere Dezimalpunkte.
$ErrorActionPreference = 'Stop'
$root = Join-Path $PSScriptRoot '..\..\weapons' | Resolve-Path
# (?<!ai_) verhindert Match innerhalb von ai_sight_range_modifier="…"
$rx = [regex]'(?<!ai_)sight_range_modifier="([0-9.]+)"(\s*ai_sight_range_modifier="[0-9.]+")?'
$ci = [System.Globalization.CultureInfo]::InvariantCulture
$aiFactor = 0.9
$count = 0
Get-ChildItem -Path $root -Recurse -Filter '*.weapon' | ForEach-Object {
    $path = $_.FullName
    $t = [System.IO.File]::ReadAllText($path)
    $new = $rx.Replace($t, {
        param($m)
        $rawP = $m.Groups[1].Value
        $p = [double]::Parse($rawP, $ci)
        if ($p -le 0) {
            $ai = 0.0
        } else {
            $ai = [math]::Round($p * $aiFactor, 4)
        }
        $aiStr = if ($ai -le 0) { '0' } else {
            $s = ([string]::Format($ci, '{0:0.###}', $ai)).TrimEnd('0').TrimEnd('.')
            if ([string]::IsNullOrEmpty($s)) { '0' } else { $s }
        }
        return ('sight_range_modifier="{0}" ai_sight_range_modifier="{1}"' -f $rawP, $aiStr)
    })
    if ($new -ne $t) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($path, $new, $utf8NoBom)
        $count++
    }
}
Write-Host "Updated $count weapon files under $root"
