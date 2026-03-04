# Miniboss – Elite-Waffen pro Fraktion

Jede Fraktion hat einen **Miniboss** (und ggf. miniboss_female). Deren Bewaffnung setzt sich zusammen aus:

1. **`factions/common_miniboss.resources`** (gemeinsamer Pool, `clear_weapons="1"`)
2. **`factions/<farb>_miniboss.resources`** (fraktionsspezifisch, wird danach geladen und **addiert**)

---

## Markdown pro Fraktion

| Fraktion | Datei | Resources |
|----------|-------|-----------|
| **Russia (Brown)** | [MINIBOSS_BROWN.md](MINIBOSS_BROWN.md) | `brown_miniboss.resources` |
| **EU (Grey)** | [MINIBOSS_GREY.md](MINIBOSS_GREY.md) | `grey_miniboss.resources` |
| **USA (Green)** | [MINIBOSS_GREEN.md](MINIBOSS_GREEN.md) | `green_miniboss.resources` |

In jeder Markdown-Datei:

- **Waffen in \<farb>_miniboss.resources** – aktuelle Einträge und ob sie woanders vorkommen
- **Elite-Waffen (nur durch Miniboss erhältlich)** – Waffen, die **nur** in dieser Resources-Datei stehen (nicht in Stash, nicht im normalen KI-Pool). Erhältlich nur durch Miniboss-Drop.

Neue **elite-only** Waffen: In der jeweiligen `*_miniboss.resources` eintragen und **nicht** in armory_* oder *_primaries/*_secondaries – dann in der zugehörigen Markdown-Tabelle dokumentieren.
