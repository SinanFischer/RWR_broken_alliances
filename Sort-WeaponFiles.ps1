param(
    [switch]$Execute
)

$DryRun = -not $Execute.IsPresent

$WeaponsPath = "C:\Program Files (x86)\Steam\steamapps\common\RunningWithRifles\media\packages\RWR_broken_alliances\weapons"

$GreenWeapons = @(
    'aa-12', 'apr', 'barrett_m107',
    'benelli_m4', 'benelli_m4_supp',
    'beretta_93r', 'beretta_m9',
    'caws', 'desert_eagle', 'desert_eagle_gold',
    'f2000', 'famasg1', 'famasg1_elite', 'fn_evolys',
    'g28', 'g36', 'g36_w_ag36', 'g36_w_ag36_g',
    'gilboa_dbr', 'glock17', 'gun_tommy',
    'hk416', 'honey_badger', 'honey_badger_elite',
    'imi_negev', 'jackhammer',
    'javelin', 'javelin_captain', 'javelin_elite',
    'kriss_vector', 'l85a2',
    'm1_garand_m', 'm1917_savage_lewis',
    'm120_heavy_mortar', 'm120_heavy_mortar_deploy',
    'm14_ebr', 'm16a4', 'm16a4_support', 'm16a4_w_m203', 'm16a4_w_m203_g',
    'm200', 'm202_flash', 'm240', 'm249', 'm24_a2',
    'm2_carlgustav', 'm4a1_scope', 'm712', 'm72_law',
    'm79', 'm79_terminator',
    'mg4', 'mgl_flasher', 'milkor_mgl',
    'mini_uzi', 'model_29', 'mossberg', 'mp5sd', 'mp7',
    'p90', 'psg90',
    'scarssr', 'scarssr_elite',
    'scorpion-evo', 'sg552', 'smaw', 'spas-12',
    'steyr_aug', 'steyr_aug_elite', 'steyr_tmp',
    'stoner_lmg', 'stoner_lmg_elite',
    'truvelo_amris', 'tti',
    'ultimax', 'ultimax_m', 'uts15',
    'xm25', 'xm25_r', 'xm8'
)

$BrownWeapons = @(
    'ak47', 'ak47_w_gp25', 'ak47_w_gp25_g',
    'aks74u', 'aek_919k', 'an94_burst',
    'dragunov_svd',
    'mg42', 'mg42_elite',
    'pb', 'pecheneg_bullpup', 'pkm',
    'qjz89_volk',
    'rpg-7', 'rpk16', 'rpk16_long', 'rpk74m',
    'saiga12k', 'sv98', 'vss_vintorez'
)

$GreyWeapons = @(
    'fhj01', 'mg08_heavy_custom22', 'ns2000',
    'qbs-09', 'qbz95', 'qbz95_shotgun', 'qbz95_us',
    'qcw-05', 'qlz87_b'
)

$NeverMove = @(
    'all_weapons.xml', 'invasion_all_weapons.xml',
    'all_throwables.xml', 'invasion_all_throwables.xml',
    'impact_grenade.xml', 'stun_grenade.xml',
    'base_primary.weapon', 'base_primary_rare.weapon',
    'base_primary_shotgun.weapon', 'base_primary_sniper.weapon',
    'base_secondary.weapon', 'base_secondary_sidearm.weapon',
    'mortar.vehicle'
)

Write-Host "`n=== Sort-WeaponFiles.ps1 ===" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "MODUS: DRY-RUN" -ForegroundColor Yellow
} else {
    Write-Host "MODUS: EXECUTE" -ForegroundColor Red
}

foreach ($Folder in @('green', 'brown', 'grey', 'common')) {
    $FolderPath = Join-Path $WeaponsPath $Folder
    if (-not (Test-Path $FolderPath)) {
        if (-not $DryRun) { New-Item -ItemType Directory -Path $FolderPath | Out-Null }
        Write-Host "CREATE DIR: $Folder/" -ForegroundColor Green
    }
}

$Stats = @{ moved = 0; skipped = 0; errors = 0 }

foreach ($File in (Get-ChildItem -Path $WeaponsPath -File)) {
    $FileName = $File.Name
    $BaseName = $File.BaseName

    if ($NeverMove -contains $FileName) {
        Write-Host "SKIP (protected) : $FileName" -ForegroundColor DarkGray
        $Stats.skipped++; continue
    }
    if ($File.Extension -eq '.projectile') {
        Write-Host "SKIP (projectile): $FileName" -ForegroundColor DarkGray
        $Stats.skipped++; continue
    }

    $Target = if     ($GreenWeapons -contains $BaseName) { 'green'  }
              elseif ($BrownWeapons -contains $BaseName) { 'brown'  }
              elseif ($GreyWeapons  -contains $BaseName) { 'grey'   }
              else                                       { 'common' }

    if ($DryRun) {
        Write-Host "MOVE -> $Target/ : $FileName" -ForegroundColor Cyan
    } else {
        try {
            Move-Item -Path $File.FullName -Destination (Join-Path $WeaponsPath "$Target\$FileName") -ErrorAction Stop
            Write-Host "MOVED -> $Target/ : $FileName" -ForegroundColor Green
            $Stats.moved++
        } catch {
            Write-Host "ERROR: $FileName -> $_" -ForegroundColor Red
            $Stats.errors++
        }
    }
}

Write-Host "`n=== ERGEBNIS ===" -ForegroundColor Cyan
Write-Host "Verschoben: $($Stats.moved) | Uebersprungen: $($Stats.skipped) | Fehler: $($Stats.errors)"
