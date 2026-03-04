# common_miniboss.resources – Commonness der Waffen

**commonness** (*Gewicht bei der Zufallsauswahl aus dem Pool: höher = öfter gewählt*) wird in der jeweiligen `.weapon`-Datei definiert. Miniboss-Soldaten laden `common_miniboss.resources` + fraktionsspezifische `*_miniboss.resources`; die Engine wählt aus dem kombinierten Pool pro Slot nach commonness.

**Im Spiel gilt:** Alle genannten Waffen haben eine `.weapon`-Datei in **RWR_broken_alliances/weapons** (Mod-Override). Es zählen ausschließlich die **Mod-Werte**; Vanilla wird überschrieben.

*x = Waffe im Miniboss-Pool dieser Fraktion (common_miniboss = alle; brown/green/grey_miniboss = nur diese Fraktion).*

| Waffe (key) | RU | EU | USA | commonness (Mod) | Chance (≈) | Quelle(n) |
|-------------|----|----|-----|------------------|------------|------------|
| f2000.weapon | x | x | x | 0.0012 | 10,2 % | Mod |
| milkor_mgl.weapon | x | x | x | 0.0008 | 6,8 % | Mod |
| vss_vintorez.weapon | x | x | x | 0.0008 | 6,8 % | Mod |
| ns2000.weapon | x | x | x | 0.0019 | 16,2 % | Mod |
| stoner_lmg.weapon | x | x | x | 0.0028 | **23,9 %** | Mod |
| mg42.weapon | x | x | x | 0.00001 | 0,1 % | Mod |
| steyr_aug.weapon | x | x | x | 0.0028 | **23,9 %** | Mod |
| apr.weapon | x | x | x | 0.0012 | 10,2 % | Mod |
| lahti_l39.weapon | x | x | x | 0.000075 | 0,6 % | Mod |
| pecheneg_bullpup.weapon | x | x | x | 0.00005 | 0,4 % | Mod |

*Chance = commonness / Summe(commonness) im Pool. Summe (nur Waffen mit commonness > 0): 0,011735. commonness 0 = Waffe ist im Pool, wird aber nie per Zufall gewählt. Fraktionsspezifische Miniboss-Waffen kommen zusätzlich ins Pool (nur in der jeweiligen Fraktion).*

---

### Fraktionsspezifische Miniboss-Waffen (nur in *_miniboss.resources)

| Waffe (key) | RU | EU | USA | commonness (Mod) | Quelle(n) |
|-------------|----|----|-----|------------------|------------|
| rpk16_long.weapon | x | — | — | 0.0028 | Mod |
| m16a4_support.weapon | — | — | x | 0.004 | Mod |
| hk416.weapon | — | x | — | — | Vanilla |
| m4a1_scope.weapon | — | — | x | — | Vanilla |
| smaw.weapon | x | x | x | — | Vanilla |
| m202_flash.weapon | x | x | x | — | Vanilla |

**Relative Gewichtung (Broken Alliances):**  
**stoner_lmg** und **steyr_aug** je 23,9 %, **ns2000** 16,2 %, **f2000** und **apr** je 10,2 %, **milkor_mgl** und **vss_vintorez** je 6,8 %.

Änderungen an der Auswahlwahrscheinlichkeit: `commonness` in der zugehörigen `.weapon`-Datei unter `weapons/` anpassen.
