# Preis-Anpassung für Waffen nach Schema:
# <= 10: unverändert
# 10 - 100: -40% (Faktor 0.6)
# 101 - 300: -50% (Faktor 0.5)
# > 300: unverändert

$weaponsPath = Join-Path $PSScriptRoot "..\weapons"
$files = Get-ChildItem -Path $weaponsPath -Filter "*.weapon" -Recurse

$changed = 0
$unchanged = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    if ($content -match 'price="([\d.]+)"') {
        $oldPriceStr = $Matches[1]
        $oldPrice = [double]$oldPriceStr
        $newPrice = $oldPrice

        if ($oldPrice -le 10) {
            $newPrice = $oldPrice
        } elseif ($oldPrice -le 100) {
            $newPrice = [math]::Round($oldPrice * 0.6, 1)
        } elseif ($oldPrice -le 300) {
            $newPrice = [math]::Round($oldPrice * 0.5, 1)
        }
        # > 300: bleibt

        if ($newPrice -ne $oldPrice) {
            # Exakte Original-Zeichenkette ersetzen (z.B. "13.0" oder "210")
            $content = $content -replace [regex]::Escape("price=`"$oldPriceStr`""), "price=`"$newPrice`""
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            Write-Host "$($file.Name): $oldPriceStr -> $newPrice"
            $changed++
        } else {
            $unchanged++
        }
    }
}

Write-Host "`nFertig: $changed geändert, $unchanged unverändert"
