# Miniboss EU (Grey)

**Fraktion:** European Union (Grey)  
**Resources:** `factions/common_miniboss.resources` (Basis) + **`factions/grey_miniboss.resources`** (fraktionsspezifisch)

---

## Lade-Reihenfolge

Der Miniboss lädt zuerst `common_miniboss.resources` (setzt mit `clear_weapons="1"` den Pool) und danach **`grey_miniboss.resources`**, das weitere Waffen **hinzufügt**.

---

## Waffen in grey_miniboss.resources (aktuell)

| Waffe (key) | Beschreibung | **commonness** (.weapon) | Nur durch Miniboss erhältlich? |
|-------------|--------------|--------------------------|---------------------------------|
| `hk416.weapon` | HK416, Sturmgewehr | siehe .weapon (EU-Pool) | Nein – auch im EU-Pool (grey_primaries/default) |
| `smaw.weapon` | SMAW, Raketenwerfer | 0.06 | Nein – in allen Miniboss-Pools |
| `m202_flash.weapon` | M202 Flash, Mehrfach-Raketenwerfer | 0.09 | Nein – in allen Miniboss-Pools |

---

## Elite-Waffen (nur durch Miniboss erhältlich)

**Definition:** Waffen, die **nur** in `grey_miniboss.resources` stehen und **nicht** in armory_grey, grey_primaries, grey_secondaries oder common.resources. Erhältlich nur durch Töten des EU-Miniboss (Drop).

| Waffe (key) | Name / Rolle | **commonness** | **Preis (RP)** | Anmerkung |
|-------------|--------------|----------------|----------------|-----------|
| *(noch keine)* | — | — | — | Hier eintragen, sobald eine Waffe **ausschließlich** in `grey_miniboss.resources` eingetragen wird (nicht in Stash, nicht im normalen KI-Pool). |

---

## Referenz: gemeinsamer Pool (common_miniboss.resources)

- F2000, Milkor MGL, VSS Vintorez, NS2000, Stoner LMG, XM8, MG42, Steyr AUG, APR, Lahti L39, Pecheneg Bullpup  
- Westen: vest4, vest_blackops3 (enabled), vest1/vest2/eodvest disabled

Die fraktionsspezifischen Waffen oben kommen **zusätzlich** zu diesem Pool.
