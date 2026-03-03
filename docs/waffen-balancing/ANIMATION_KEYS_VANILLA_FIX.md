# Animation-Keys: Vanilla-Kompatibilität (Broken Alliances)

Waffen aus Vanilla/Mod, die **animation_key** nutzen, müssen Keys verwenden, die im Spiel existieren. Fehlende Keys führen zu `WARNING, animation key … not found` und bei Nutzung zu **ERROR, requesting invalid animation id for character spec** → **!!!EXECUTION HALTED!!!**.

## Durchgeführte Korrekturen

| Waffe | Vorher (fehlerhaft) | Nachher (Vanilla) |
|-------|---------------------|-------------------|
| **SBL** (sbl.weapon) | `reloading, pan mag` | `reloading, m79` |
| **Golden Knife** (golden_knife.weapon) | `stabbing, burst` | `melee, bayonet` |
| **Origin-12** (origin_12.weapon) | `reloading, drum mag` | `reloading, pkm` |
| **Origin-12 S** (origin_12_s.weapon) | `reloading, drum mag` | `reloading, pkm` |
| **RPK-16** (rpk16.weapon) | `reloading, drum mag` | `reloading, pkm` |
| **RPK-16 Langrohr** (rpk16_long.weapon) | `reloading, drum mag` | `reloading, pkm` |

## Geprüft, keine Änderung nötig

Diese Stash-Waffen nutzen nur **animation_key**-Werte, die in Vanilla vorkommen und im Mod unverändert gelassen wurden:

- **Sabre** (sabre.weapon): melee, saber / melee, saber whip|stab|slash; hold, saber; running, saber; etc.
- **Compound Bow / Compound Bow Alt**: reload, bow; recoil, bow; still, bow; etc.
- **XM25 / XM25 Schall**: reloading, m79
- **QLZ-87**: reloading, pkm; walking, carrying load; still, carrying load
- **QBZ-95 / QBZ-95 US**: reloading, famasg1 / sg552; switch fire mode
- **AN-94, AK-47 GL, G36 GL, M16A4 GL, M200, M1 Garand, Tommy Gun, Gilboa DBR**: jeweils gängige Vanilla-Reload-Keys (reloading, ak47; reloading, ar1, prone; etc.)
- **FHJ-01**: nur ref-Nummern (keine animation_key für reload)
- **TTI, Truvelo, ULTIMAX, Taser, Camouflage Shield, m16a4_support**: nicht auf fehlerhafte Keys geprüft; bei Absturz Log nach `WARNING, animation key` durchsuchen

## Log-Warnung „faction_id not found“

`SCRIPT:WARNING, attribute faction_id of type int not found in character element` kommt vom **Metagame-Lua-Skript**, nicht von der Waffen-XML. Sie tritt auf, wenn das Spiel Charakter-Daten ohne `faction_id` sendet (z. B. beim Beenden/Szenenwechsel). **Kein Fix in .weapon-Dateien nötig.**

## Bei weiteren Abstürzen

1. In `rwr_game.log` nach **ERROR** und **EXECUTION HALTED** suchen.
2. Hinweis befolgen: **search the log for "WARNING, animation key"**.
3. Den dort genannten **animation_key** in der genutzten Waffen-.weapon suchen und durch einen in Vanilla-Waffen verwendeten Key ersetzen (z. B. in `media/packages/vanilla/weapons/*.weapon` nach dem gleichen state_key suchen und dessen animation_key übernehmen).
