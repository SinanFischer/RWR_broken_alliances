# FP-AI System (Utility AI)

## Ziel

Die FP-AI entscheidet periodisch pro Fraktion, ob FP sofort ausgegeben oder gespart werden.

## Datenfluss

1. `FactionPointsAiTracker` startet alle `FP_AI_DECISION_INTERVAL` Sekunden einen Tick.
2. `FactionPointsAiPlanner` baut pro Fraktion einen `DecisionContext`.
3. `FactionPointsAiScorer` berechnet Utility-Scores fuer bekannte Events (`event1`, `event2`).
4. Planner waehlt das beste Event oberhalb Schwellwert und fuehrt es ueber `FactionPointsEventRegistry` aus.

## Event-Typen

- **PlayerEvent**: benoetigt `player_id` und laeuft nur mit aktivem Spieler in der Fraktion.
- **AI Event**: benoetigt keinen `player_id` und laeuft direkt ueber `faction_id`.

## Wichtige Konfigurationswerte

- `FP_AI_MIN_POINTS_RESERVE`: Sicherheitsreserve, die nach Ausgaben verbleiben muss.
- `FP_AI_MIN_UTILITY_TO_SPEND`: Mindest-Score zum Ausloesen.
- `FP_AI_EVENT1_IMPORTANCE`, `FP_AI_EVENT2_IMPORTANCE`: Prioritaetsgewichte.
- `FP_AI_EVENT2_SAVE_TARGET`: Sparziel fuer Angriffs-Event.

## Debug-Kommandos

- `/fp_ai` zeigt naechsten Tick und letzte AI-Entscheidung.
- `/fp_ai_tick` erzwingt sofort einen AI-Tick.
