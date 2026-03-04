# Miniboss USA (Green)

**Fraktion:** United States (Green)  
**Resources:** `factions/common_miniboss.resources` (Basis) + **`factions/green_miniboss.resources`** (fraktionsspezifisch)

---

## Lade-Reihenfolge

Der Miniboss lädt zuerst `common_miniboss.resources` (setzt mit `clear_weapons="1"` den Pool) und danach **`green_miniboss.resources`**, das weitere Waffen **hinzufügt**.

---

## Waffen in green_miniboss.resources (aktuell)

| Waffe (key) | Beschreibung | **commonness** (.weapon) | Nur durch Miniboss erhältlich? |
|-------------|--------------|--------------------------|---------------------------------|
| `m4a1_scope.weapon` | M4A1 mit Scope | siehe .weapon | Prüfen: nur hier oder auch in green_primaries/armory? |
| `smaw.weapon` | SMAW, Raketenwerfer | 0.06 | Nein – in allen Miniboss-Pools |
| `m202_flash.weapon` | M202 Flash, Mehrfach-Raketenwerfer | 0.09 | Nein – in allen Miniboss-Pools |
| `m16a4_support.weapon` | M16A4 Support (Schild + Scope) | 0.004 | Nein – auch in armory_green (USA-Waffenkammer) |

---

## Elite-Waffen (nur durch Miniboss erhältlich)

**Definition:** Waffen, die **nur** in `green_miniboss.resources` stehen und **nicht** in armory_green, green_primaries, green_secondaries oder common.resources. Erhältlich nur durch Töten des US-Miniboss (Drop).

| Waffe (key) | Name / Rolle | **commonness** | **Preis (RP)** | Anmerkung |
|-------------|--------------|----------------|----------------|-----------|
| *(noch keine)* | — | — | — | Hier eintragen, sobald eine Waffe **ausschließlich** in `green_miniboss.resources` eingetragen wird (nicht in Stash, nicht im normalen KI-Pool). |

---

## Referenz: gemeinsamer Pool (common_miniboss.resources)

- F2000, Milkor MGL, VSS Vintorez, NS2000, Stoner LMG, XM8, MG42, Steyr AUG, APR, Lahti L39, Pecheneg Bullpup  
- Westen: vest4, vest_blackops3 (enabled), vest1/vest2/eodvest disabled

Die fraktionsspezifischen Waffen oben kommen **zusätzlich** zu diesem Pool.
