# Plan: Cooldown-Effekt für MG- und Minigun-Varianten (Scoped + Non-Scoped)

## Ziel
Nach zu viel Dauerfeuer soll bei allen vier Deploy-Waffen (MG, MG Scoped, Minigun, Minigun Scoped) ein **Cooldown/Überhitzungseffekt** greifen: Schuss wird blockiert, bis ein interner Wert wieder unter eine Schwelle fällt; optional Sound-Feedback.

## Technik (aus Vanilla)

- **cooldown_start** (*Schwellwert 0–1: ab wann Dauerfeuer als „überhitzt“ gilt und Schuss blockiert wird*): Je höher, desto länger darf durchgefeuert werden.
- **cooldown_end** (*Schwellwert 0–1: unter diesem Wert darf wieder geschossen werden*): Meist 0.0 = vollständig abkühlen.
- Während Dauerfeuer steigt ein interner Wert; wenn er ≥ cooldown_start erreicht → Cooldown. Wenn nicht gefeuert wird, sinkt der Wert; bei ≤ cooldown_end → wieder schussbereit.
- **Sound:** `<sound key="cooldown" fileref="overheating_mg.wav" volume="…"/>` spielt beim Eintritt in den Cooldown.

**Vanilla-Referenz:**
- `deployable_mg.weapon`: cooldown_start="0.4" cooldown_end="0.0", Sound overheating_mg.wav
- `deployable_minig.weapon`: cooldown_start="0.6" cooldown_end="0.0", Sound overheating_mg.wav

## Betroffene Dateien (nur Mod-Paket RWR_broken_alliances)

| Datei | Aktuell | Aktion |
|-------|---------|--------|
| `weapons/common/deployable_mg.weapon` | kein Cooldown | cooldown_start/end + Sound ergänzen |
| `weapons/common/deployable_mg_scoped.weapon` | kein Cooldown | cooldown_start/end + Sound ergänzen |
| `weapons/common/deployable_minig.weapon` | kein Cooldown | cooldown_start/end + Sound ergänzen |
| `weapons/common/deployable_minig_scoped.weapon` | kein Cooldown | cooldown_start/end + Sound ergänzen |

## Konkrete Änderungen

1. **`<specification>`** in jeder der vier Dateien: Am Ende der Zeile mit `sight_height_offset` zwei Attribute anfügen (vor `/>`):
   - MG (non-scoped): `cooldown_start="0.4"` `cooldown_end="0.0"` (wie Vanilla-MG)
   - MG Scoped: `cooldown_start="0.4"` `cooldown_end="0.0"`
   - Minigun (non-scoped): `cooldown_start="0.6"` `cooldown_end="0.0"` (wie Vanilla-Minigun)
   - Minigun Scoped: `cooldown_start="0.6"` `cooldown_end="0.0"`

2. **Sound:** In jeder Datei nach dem bestehenden `<sound class="operation" key="fire" …/>` ein neues Element einfügen:
   - `<sound key="cooldown" fileref="overheating_mg.wav" volume="0.4"/>`  
   (Minigun-Varianten optional volume="0.5" wie Vanilla-Minigun.)

## Keine weiteren Änderungen
- `sustained_fire_grow_step` / `sustained_fire_diminish_rate` bleiben unverändert (steuern u. a. Streuung/„Hitze“-Aufbau; Cooldown nutzt denselben oder einen verwandten Mechanismus).
- Keine Script- oder XML-Referenz-Anpassungen nötig.

## Abnahme
- In-game: MG und Minigun (normal + Scoped) jeweils lange durchfeuern → Überhitzungssound, Schuss stoppt → nach kurzer Pause wieder feuern können.
