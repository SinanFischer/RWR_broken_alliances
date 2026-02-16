# Commander-Tonalitaet fuer FP-Events

## Zweck

Diese Richtlinie legt den verpflichtenden Ton fuer alle Commander-Meldungen im Fraktionspunkte-System fest.
Grundlage ist das Szenario aus `docs/ueberblick/ERA_STORY.md` (Großer Konflikt 2028+, alle gegen alle, kriegsmuede und zynische Atmosphaere).

## Tonale Leitlinien

- **Direkt und operativ:** kurze Befehls- oder Lage-Saetze, keine langen Erklaertexte.
- **Duestere Ernsthaftigkeit:** professionell, angespannt, kein Humor, keine lockere Sprache.
- **AI als Fuehrungsinstanz:** Meldungen klingen wie automatische Lage- und Befehlsupdates.
- **Kriegsmuedes Umfeld:** Sprache darf hart und pragmatisch sein, aber ohne Pathos.
- **Szenario-treu:** drei Fraktionen, keine Verbundenheit, jederzeit Feindlage moeglich.

## Formale Regeln

- Meldung immer in **Englisch**.
- Friendly/Enemy Meldungen pro Event als Konstanten direkt in der Event-Datei definieren.
- Jede Commander-Meldung endet mit dem FP-Kosten-Suffix im Format: `(-N FP)`.
- Bei Events mit Delay:
  - Meldung 1 = Ankuendigung (vor Ausfuehrung)
  - Meldung 2 = Ausfuehrung (nach Ablauf)
- Enemy-Infos sind optional und koennen bewusst leer sein (z. B. Event1).

## Stilbeispiele

- **Gut:** `AI Command: Your squad is below combat strength. Dispatching a support team now.`
- **Gut:** `Enemy Commander: Enemy company assault incoming. Impact in 60 seconds.`
- **Schlecht:** lange RP-Texte, Witze, uebertrieben heroische Sprueche, unklare Passiv-Formulierungen.

## Review-Check vor Merge

1. Passen die Meldungen zur Kriegsstimmung aus `docs/ueberblick/ERA_STORY.md`?
2. Sind die Saetze kurz, klar und operativ?
3. Sind Friendly und Enemy Meldungen logisch getrennt?
4. Endet jede gesendete Meldung korrekt mit `(-N FP)`?
