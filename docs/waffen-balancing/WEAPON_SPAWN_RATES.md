# WEAPON_SPAWN_RATES — Ist-Zustand Tracker

> **Zweck:** Live-Abgleich zwischen geplanten Werten (`COMMONNESS_UND_KI_SPAWN.md`) und tatsächlichen Werten in den `.weapon`-Dateien.  
> **Aktualisieren nach:** jedem `commonness`-Edit in einer `.weapon`-Datei.  
> **Tier-Definitionen & Regelwerk:** → `COMMONNESS_UND_KI_SPAWN.md` · `BALANCING_REGELWERK.md`

---

## Legende

| Status | Bedeutung |
|--------|-----------|
| ✅ | Ist-Wert entspricht Soll-Tier |
| ⚠️ | Abweichung ≤ 50 % — tolerierbar, prüfen |
| ❌ | Nicht implementiert oder falscher Tier |
| 🔒 | Bewusst 0.0 — nur Stash/Boss/Drop |

**Spalten:** `Datei` · `Ist` (aktuell in .weapon) · `Soll` (aus COMMONNESS_UND_KI_SPAWN.md) · `Tier` · `in_stock` · `respawn` · `Status`

---

## 1. Fraktion Grün — `weapons/green/`

### 1.1 Standard-Infanterie (Basis-AR)

| Waffe | Datei | Ist | Soll | Tier | in_stock | respawn | Status |
|-------|-------|-----|------|------|----------|---------|--------|
| M16A4 | `m16a4.weapon` | 0.22 | 0.2 | basic | — | — | ⚠️ |
| M4A1 Scope | `m4a1_scope.weapon` | 0.30 | 0.2 | basic | 1 | 1 | ⚠️ |
| G36 | `g36.weapon` | 0.22 | 0.2 | basic | — | — | ⚠️ |
| L85A2 | `l85a2.weapon` | 0.046 | 0.05 | häufig | 1 | 1 | ✅ |
| XM8 | `xm8.weapon` | 0.043 | 0.05 | häufig | 1 | 1 | ⚠️ |
| HK416 | `hk416.weapon` | 0.025 | 0.02 | selten | 1 | 1 | ✅ |
| FAMAS G1 | `famasg1.weapon` | 0.049 | 0.05 | häufig | 1 | 1 | ✅ |
| FAMAS Elite | `famasg1_elite.weapon` | 0.050 | 0.05 | häufig | 1 | 1 | ✅ |
| SG552 | `sg552.weapon` | 0.024 | 0.02 | selten | 1 | 1 | ✅ |
| F2000 | `f2000.weapon` | 0.0012 | 0.002 | sehr selten | 1 | 1 | ⚠️ |

### 1.2 LMG / Support

| Waffe | Datei | Ist | Soll | Tier | in_stock | respawn | Status |
|-------|-------|-----|------|------|----------|---------|--------|
| M249 | `m249.weapon` | 0.050 | 0.05 | häufig | 1 | 1 | ✅ |
| M240 | `m240.weapon` | 0.029 | 0.05 | häufig | — | — | ⚠️ |
| MG4 | `mg4.weapon` | 0.050 | 0.05 | häufig | — | — | ✅ |
| IMI Negev | `imi_negev.weapon` | 0.028 | 0.05 | häufig | — | — | ⚠️ |
| M1917 Savage Lewis | `m1917_savage_lewis.weapon` | 0.0053 | 0.005 | sehr selten | 1 | 1 | ✅ |
| Stoner LMG | `stoner_lmg.weapon` | 0.0028 | 0.003 | sehr selten | 1 | 1 | ✅ |
| Stoner LMG Elite | `stoner_lmg_elite.weapon` | 0.050 | 0.05 | häufig | 1 | 1 | ✅ |
| FN Evolys | `fn_evolys.weapon` | 0.000 | — | — | 0 | 0 | 🔒 |
| ULTIMAX | `ultimax.weapon` | 0.000 | 0.05 | häufig | 1 | 0 | ❌ |
| ULTIMAX M | `ultimax_m.weapon` | 0.000 | 0.05 | häufig | 1 | 0 | ❌ |

### 1.3 Sniper / DMR

| Waffe | Datei | Ist | Soll | Tier | in_stock | respawn | Status |
|-------|-------|-----|------|------|----------|---------|--------|
| M24 A2 | `m24_a2.weapon` | 0.038 | 0.038 | selten | — | — | ✅ |
| PSG90 | `psg90.weapon` | 0.038 | 0.038 | selten | — | — | ✅ |
| Barrett M107 | `barrett_m107.weapon` | 0.0025 | 0.002 | sehr selten | 1 | 0 | ✅ |
| M200 CheyTac | `m200.weapon` | 0.0003 | 0.0002 | episch | 1 | 0 | ✅ |
| Truvelo AMRIS | `truvelo_amris.weapon` | 0.000 | 0.0005 | episch | 1 | 0 | ❌ |
| M14 EBR | `m14_ebr.weapon` | 0.010 | 0.01 | selten | 1 | 1 | ✅ |
| ScarSSR | `scarssr.weapon` | 0.0025 | 0.002 | sehr selten | 1 | 1 | ✅ |
| ScarSSR Elite | `scarssr_elite.weapon` | 0.050 | 0.05 | häufig | 0 | 0 | ✅ |
| APR | `apr.weapon` | 0.0012 | 0.001 | episch | 1 | 1 | ✅ |
| G28 | `g28.weapon` | 0.010 | 0.01 | selten | — | — | ✅ |

### 1.4 Spezial / Stash

| Waffe | Datei | Ist | Soll | Tier | in_stock | respawn | Status |
|-------|-------|-----|------|------|----------|---------|--------|
| M16A4 Support | `m16a4_support.weapon` | 0.004 | 0.1 | häufig | 1 | 0 | ❌ |
| M16A4 w/ M203 | `m16a4_w_m203.weapon` | 0.020 | 0.002 | sehr selten | 1 | 0 | ❌ |
| M16A4 w/ M203 G | `m16a4_w_m203_g.weapon` | 0.000 | 0.002 | sehr selten | 1 | 0 | ❌ |
| Honey Badger | `honey_badger.weapon` | 0.001 | 0.001 | episch | 1 | 1 | ✅ |
| Honey Badger Elite | `honey_badger_elite.weapon` | 0.050 | 0.05 | häufig | 1 | 1 | ✅ |
| Steyr AUG | `steyr_aug.weapon` | 0.0028 | 0.003 | sehr selten | 1 | 1 | ✅ |
| Steyr AUG Elite | `steyr_aug_elite.weapon` | 0.050 | 0.05 | häufig | 1 | 1 | ✅ |
| Gilboa DBR | `gilboa_dbr.weapon` | 0.000 | 0.1 | häufig | 1 | 0 | ❌ |
| M1 Garand M | `m1_garand_m.weapon` | 0.005 | 0.1 | häufig | 1 | 0 | ❌ |
| G36 w/ AG36 | `g36_w_ag36.weapon` | 0.020 | 0.002 | sehr selten | 1 | 0 | ❌ |
| G36 w/ AG36 G | `g36_w_ag36_g.weapon` | 0.000 | 0.002 | sehr selten | 1 | 0 | ❌ |
| XM25 | `xm25.weapon` | 0.0005 | 0.002 | sehr selten | 1 | 1 | ⚠️ |
| XM25 R | `xm25_r.weapon` | 0.000 | — | — | 1 | 0 | 🔒 |
| M72 LAW | `m72_law.weapon` | 0.066 | 0.06 | häufig | — | — | ✅ |
| Javelin | `javelin.weapon` | 0.020 | 0.02 | selten | 1 | 0 | ✅ |
| Javelin Captain | `javelin_captain.weapon` | 0.020 | 0.02 | selten | 1 | 0 | ✅ |
| Javelin Elite | `javelin_elite.weapon` | 0.005 | 0.005 | sehr selten | 1 | 0 | ✅ |
| SMAW | `smaw.weapon` | 0.002 | 0.002 | sehr selten | 1 | 1 | ✅ |
| M2 Carl Gustav | `m2_carlgustav.weapon` | 0.059 | 0.06 | häufig | — | — | ✅ |
| M202 FLASH | `m202_flash.weapon` | 0.020 | 0.02 | selten | 1 | 0 | ✅ |
| M120 Heavy Mortar | `m120_heavy_mortar.weapon` | 0.000 | — | — | — | — | 🔒 |
| M120 Deploy | `m120_heavy_mortar_deploy.weapon` | 0.005 | 0.005 | sehr selten | 1 | 0 | ✅ |
| MGL Flasher | `mgl_flasher.weapon` | 0.0002 | 0.0002 | episch | 1 | 1 | ✅ |
| Milkor MGL | `milkor_mgl.weapon` | 0.0008 | 0.001 | episch | 1 | 1 | ✅ |

### 1.5 Sidearms / CQB

| Waffe | Datei | Ist | Soll | Tier | in_stock | respawn | Status |
|-------|-------|-----|------|------|----------|---------|--------|
| Glock17 | `glock17.weapon` | 0.0001 | 0.0001 | episch | 0 | 1 | ✅ |
| Beretta M9 | `beretta_m9.weapon` | 0.0001 | 0.0001 | episch | 0 | 1 | ✅ |
| Beretta 93R | `beretta_93r.weapon` | 0.0014 | 0.001 | episch | 0 | 0 | ✅ |
| Desert Eagle | `desert_eagle.weapon` | 0.000 | — | — | — | — | 🔒 |
| Desert Eagle Gold | `desert_eagle_gold.weapon` | 0.000 | — | — | 0 | 0 | 🔒 |
| M712 | `m712.weapon` | 0.0015 | 0.001 | episch | 1 | 1 | ✅ |
| Model 29 | `model_29.weapon` | 0.002 | 0.002 | sehr selten | 1 | 1 | ✅ |
| P90 | `p90.weapon` | 0.000 | — | — | 1 | 1 | 🔒 |
| Kriss Vector | `kriss_vector.weapon` | 0.000 | — | — | 1 | 1 | 🔒 |
| MP5SD | `mp5sd.weapon` | 0.000 | — | — | — | — | 🔒 |
| MP7 | `mp7.weapon` | 0.0010 | 0.001 | episch | 1 | 1 | ✅ |
| Steyr TMP | `steyr_tmp.weapon` | 0.000 | — | — | 1 | 1 | 🔒 |
| Mini Uzi | `mini_uzi.weapon` | 0.000 | — | — | 1 | 1 | 🔒 |

### 1.6 Schuss- / Shotgun

| Waffe | Datei | Ist | Soll | Tier | in_stock | respawn | Status |
|-------|-------|-----|------|------|----------|---------|--------|
| AA-12 | `aa-12.weapon` | 0.0019 | 0.002 | sehr selten | 1 | 0 | ✅ |
| Jackhammer | `jackhammer.weapon` | 0.0001 | 0.0001 | episch | 1 | 0 | ✅ |
| SPAS-12 | `spas-12.weapon` | 0.029 | 0.01 | selten | — | — | ❌ |
| Mossberg | `mossberg.weapon` | 0.029 | 0.029 | selten | — | — | ✅ |
| Benelli M4 | `benelli_m4.weapon` | 0.0006 | 0.001 | episch | 1 | 1 | ⚠️ |
| Benelli M4 Supp | `benelli_m4_supp.weapon` | 0.001 | 0.001 | episch | 1 | 0 | ✅ |
| UTS-15 | `uts15.weapon` | 0.004 | 0.004 | sehr selten | 1 | 0 | ✅ |
| CAWS | `caws.weapon` | 0.010 | 0.01 | selten | 1 | 1 | ✅ |
| TTI | `tti.weapon` | 0.005 | 0.005 | sehr selten | 1 | 0 | ✅ |

---

## 2. Fraktion Braun — `weapons/brown/`

### 2.1 Standard-Infanterie

| Waffe | Datei | Ist | Soll | Tier | in_stock | respawn | Status |
|-------|-------|-----|------|------|----------|---------|--------|
| AK-47 | `ak47.weapon` | 0.22 | 0.2 | basic | — | — | ⚠️ |
| AKS-74U | `aks74u.weapon` | 0.046 | 0.05 | häufig | 1 | 1 | ✅ |
| AEK-919k | `aek_919k.weapon` | 0.000 | 0.0001 | episch | 1 | 1 | ❌ |
| AK-47 w/ GP-25 | `ak47_w_gp25.weapon` | 0.020 | 0.002 | sehr selten | 1 | 0 | ❌ |
| AK-47 w/ GP-25 G | `ak47_w_gp25_g.weapon` | 0.000 | 0.002 | sehr selten | 1 | 0 | ❌ |
| AN-94 Burst | `an94_burst.weapon` | 0.000 | 0.1 | häufig | 1 | 0 | ❌ |

### 2.2 LMG / MG

| Waffe | Datei | Ist | Soll | Tier | in_stock | respawn | Status |
|-------|-------|-----|------|------|----------|---------|--------|
| PKM | `pkm.weapon` | 0.031 | 0.05 | häufig | — | — | ⚠️ |
| RPK-74M | `rpk74m.weapon` | 0.050 | 0.05 | häufig | 1 | 1 | ✅ |
| RPK-16 | `rpk16.weapon` | 0.0028 | 0.05 | häufig | 0 | 0 | ❌ |
| RPK-16 Long | `rpk16_long.weapon` | 0.0028 | 0.04 | häufig | 0 | 0 | ❌ |
| MG42 | `mg42.weapon` | 0.00001 | 0.05 | häufig | 1 | 1 | ❌ |
| MG42 Elite | `mg42_elite.weapon` | 0.050 | 0.05 | häufig | 1 | 1 | ✅ |
| QJZ-89 Volk | `qjz89_volk.weapon` | 0.005 | 0.005 | sehr selten | 1 | 1 | ✅ |

### 2.3 Sniper / DMR

| Waffe | Datei | Ist | Soll | Tier | in_stock | respawn | Status |
|-------|-------|-----|------|------|----------|---------|--------|
| Dragunov SVD | `dragunov_svd.weapon` | 0.040 | 0.04 | selten | — | — | ✅ |
| SV-98 | `sv98.weapon` | 0.010 | 0.01 | selten | — | — | ✅ |
| VSS Vintorez | `vss_vintorez.weapon` | 0.0008 | 0.001 | episch | 1 | 1 | ⚠️ |

### 2.4 Spezial / AT

| Waffe | Datei | Ist | Soll | Tier | in_stock | respawn | Status |
|-------|-------|-----|------|------|----------|---------|--------|
| RPG-7 | `rpg-7.weapon` | 0.067 | 0.06 | häufig | — | — | ✅ |
| Saiga12K | `saiga12k.weapon` | 0.010 | 0.01 | selten | 1 | 1 | ✅ |
| PB | `pb.weapon` | 0.000 | — | — | — | — | 🔒 |
| Pecheneg Bullpup | `pecheneg_bullpup.weapon` | 0.00005 | 0.0001 | legendär | 1 | 0 | ⚠️ |
| Gun Tommy | `gun_tommy.weapon` | 0.020 | 0.02 | selten | 0 | 0 | ✅ |

---

## 3. Fraktion Grau — `weapons/grey/`

| Waffe | Datei | Ist | Soll | Tier | in_stock | respawn | Status |
|-------|-------|-----|------|------|----------|---------|--------|
| QBZ-95 | `qbz95.weapon` | 0.000 | 0.1 | häufig | 1 | 0 | ❌ |
| QBZ-95 US | `qbz95_us.weapon` | 0.000 | 0.1 | häufig | 1 | 0 | ❌ |
| QBZ-95 Shotgun | `qbz95_shotgun.weapon` | 0.010 | 0.01 | selten | 0 | 0 | ✅ |
| QBS-09 | `qbs-09.weapon` | 0.010 | 0.01 | selten | — | — | ✅ |
| QCW-05 | `qcw-05.weapon` | 0.000 | — | — | — | — | 🔒 |
| QLZ-87 B | `qlz87_b.weapon` | 0.000 | 0.0001 | legendär | 1 | 0 | ❌ |
| FHJ-01 | `fhj01.weapon` | 0.0003 | 0.01 | selten | 1 | 0 | ❌ |
| NS2000 | `ns2000.weapon` | 0.0019 | 0.002 | sehr selten | 1 | 1 | ✅ |
| MG08 Heavy | `mg08_heavy_custom22.weapon` | 0.004 | 0.004 | sehr selten | 1 | 1 | ✅ |

---

## 4. ❌ Offene Todos (Nicht implementiert / Falscher Wert)

Alle Waffen mit Status `❌` — kurze Priorität:

| Waffe | Datei | Ist | Soll | Prio |
|-------|-------|-----|------|------|
| ULTIMAX | `green/ultimax.weapon` | 0.0 | 0.05 | Hoch |
| ULTIMAX M | `green/ultimax_m.weapon` | 0.0 | 0.05 | Hoch |
| QBZ-95 | `grey/qbz95.weapon` | 0.0 | 0.1 | Hoch |
| QBZ-95 US | `grey/qbz95_us.weapon` | 0.0 | 0.1 | Hoch |
| AN-94 Burst | `brown/an94_burst.weapon` | 0.0 | 0.1 | Hoch |
| MG42 | `brown/mg42.weapon` | 0.00001 | 0.05 | Hoch |
| RPK-16 | `brown/rpk16.weapon` | 0.0028 | 0.05 | Hoch |
| Gilboa DBR | `green/gilboa_dbr.weapon` | 0.0 | 0.1 | Mittel |
| M1 Garand M | `green/m1_garand_m.weapon` | 0.005 | 0.1 | Mittel |
| M16A4 Support | `green/m16a4_support.weapon` | 0.004 | 0.1 | Mittel |
| Truvelo AMRIS | `green/truvelo_amris.weapon` | 0.0 | 0.0005 | Mittel |
| QLZ-87 B | `grey/qlz87_b.weapon` | 0.0 | 0.0001 | Niedrig |
| AEK-919k | `brown/aek_919k.weapon` | 0.0 | 0.0001 | Niedrig |
| FHJ-01 | `grey/fhj01.weapon` | 0.0003 | 0.01 | Niedrig |
| SPAS-12 | `green/spas-12.weapon` | 0.029 | 0.01 | Niedrig |
| M16A4 w/ M203 | `green/m16a4_w_m203.weapon` | 0.02 | 0.002 | Niedrig |
| AK-47 w/ GP-25 | `brown/ak47_w_gp25.weapon` | 0.02 | 0.002 | Niedrig |

---

## 5. Cursor-Workflow: Dieses Dokument effektiv nutzen

### 5.1 Beim Editieren einer .weapon Datei

Immer beide Docs als Kontext mitgeben:

```
@WEAPON_SPAWN_RATES.md @COMMONNESS_UND_KI_SPAWN.md

Setze commonness für `green/ultimax.weapon` auf 0.05 (Tier häufig, LMG-Klasse).
Danach aktualisiere die Todo-Tabelle in WEAPON_SPAWN_RATES.md:
ULTIMAX → Ist: 0.05, Status: ✅
```

### 5.2 Balancing-Audit (komplette Fraktion)

```
@WEAPON_SPAWN_RATES.md @BALANCING_REGELWERK.md

Prüfe alle ❌-Einträge der Fraktion Braun.
Erstelle pro Waffe den passenden XML-Patch (nur <commonness>-Zeile) und liste 
welche Regeln (1–10) relevant sind.
```

### 5.3 Neue Waffe integrieren

```
@WEAPON_SPAWN_RATES.md @COMMONNESS_UND_KI_SPAWN.md @BALANCING_REGELWERK.md

Neue Waffe: [NAME], Fraktion: [green/brown/grey], Klasse: [LMG/Sniper/...].
1. Bestimme Tier nach Vanilla-Referenz (Abschnitt 0 COMMONNESS_UND_KI_SPAWN).
2. Schlage commonness, in_stock, can_respawn_with vor.
3. Füge einen neuen Zeileneintrag in WEAPON_SPAWN_RATES.md hinzu.
```

### 5.4 Schnell-Sync nach Batch-Edit

```
@WEAPON_SPAWN_RATES.md

Ich habe folgende commonness-Werte geändert:
- ultimax.weapon: 0.0 → 0.05
- qbz95.weapon: 0.0 → 0.1
Aktualisiere die Tabellen und Todo-Liste entsprechend.
```

---

*Zuletzt aktualisiert: automatisch extrahiert via Sort-WeaponFiles / Update-WeaponPaths Pipeline.*  
*Tier-Definitionen: `COMMONNESS_UND_KI_SPAWN.md` Abschnitt 0–1.*
