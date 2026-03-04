# Miniboss Russia (Brown)

**Fraktion:** Russia (Brown)  
**Resources:** `factions/common_miniboss.resources` (Basis) + **`factions/brown_miniboss.resources`** (fraktionsspezifisch)

---

## Lade-Reihenfolge

Der Miniboss lädt zuerst `common_miniboss.resources` (setzt mit `clear_weapons="1"` den Pool) und danach **`brown_miniboss.resources`**, das weitere Waffen **hinzufügt**.

---

## Waffen in brown_miniboss.resources (aktuell)

| Waffe (key) | Beschreibung | **commonness** (.weapon) | Nur durch Miniboss erhältlich? |
|-------------|--------------|--------------------------|---------------------------------|
| `aks74u.weapon` | AKS-74U, Kurzgewehr | 0.0005 (Vanilla) | Nein – auch in brown_primaries (KI-Pool) |
| `smaw.weapon` | SMAW, Raketenwerfer | 0.06 | Nein – in allen Miniboss-Pools |
| `m202_flash.weapon` | M202 Flash, Mehrfach-Raketenwerfer | 0.09 | Nein – in allen Miniboss-Pools |
| `rpk16_long.weapon` | RPK-16 Langrohr, Leicht-MG 96 Schuss | **0.04** | **Ja** – nur hier, nicht in Stash/KI-Pool |

---

## Elite-Waffen (nur durch Miniboss erhältlich)

**Definition:** Waffen, die **nur** in `brown_miniboss.resources` stehen und **nicht** in armory_brown, brown_primaries, brown_secondaries oder brown_mgs. Erhältlich nur durch Töten des russischen Miniboss (Drop).

| Waffe (key) | Name / Rolle | **commonness** | **Preis (RP)** | Anmerkung |
|-------------|--------------|----------------|----------------|-----------|
| `rpk16_long.weapon` | RPK-16 Langrohr | **0.04** | **256** (+40 vs. Kurzrohr) | **~20 %** Chance, dass Brown-Miniboss sie trägt (commonness gewichtet im Pool). Nicht kaufbar (in_stock=0). 96 Mag, kill 0.65. |

---

## Referenz: gemeinsamer Pool (common_miniboss.resources)

- F2000, Milkor MGL, VSS Vintorez, NS2000, Stoner LMG, XM8, MG42, Steyr AUG, APR, Lahti L39, Pecheneg Bullpup  
- Westen: vest4, vest_blackops3 (enabled), vest1/vest2/eodvest disabled

Die fraktionsspezifischen Waffen oben kommen **zusätzlich** zu diesem Pool.
