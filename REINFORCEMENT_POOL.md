# Nachschub-Pool-System (Reinforcement Pool)

Kurzbeschreibung des in `scripts/trackers/reinforcement_pool_tracker.as` implementierten Systems: begrenzter Nachschub pro Fraktion, Eroberungs- und Verteidiger-Bonus, Commander-Meldungen, Chat-Befehle.

---

## 1. Grundprinzip

- **Pro Fraktion** gibt es einen **Nachschub-Pool** (Standard: **1000** Soldaten).
- **Jeder Tod** eines Soldaten der Fraktion verringert den Pool um 1.
- **Bei 0** wird das Spawnen für diese Fraktion dauerhaft deaktiviert (`capacity_multiplier = 0`). Es spielen nur noch die bereits lebenden Soldaten weiter.

---

## 2. Konstanten (Anpassung im Code)

| Konstante | Wert | Bedeutung |
|-----------|------|-----------|
| `REINFORCEMENT_POOL_INITIAL` | 1000 | Start-Nachschub pro Fraktion |
| `BASE_BONUS_DEFAULT` | 25 | Eroberungs-Bonus **leichte/Side-Basis** (Gesamtmenge über 5 Min) |
| `BASE_BONUS_MEDIUM` | 50 | Eroberungs-Bonus **mittlere Basis** |
| `BASE_BONUS_STRONG` | 100 | Eroberungs-Bonus **große/Haupt-Basis** |
| `BASE_FILL_TIME` | 300 s | Zeit, über die der Eroberungs-Bonus pro Basis „eingefüllt“ wird (5 Min) |
| `DEFENDER_BONUS_INTERVAL` | 60 s | Intervall für den Verteidiger-Bonus (jede Minute) |
| `DEFENDER_BONUS_SIDE` | 2 | Verteidiger-Bonus pro **leichte/Side-Basis** pro Minute |
| `DEFENDER_BONUS_MEDIUM` | 4 | Verteidiger-Bonus pro **mittlere Basis** pro Minute |
| `DEFENDER_BONUS_STRONG` | 6 | Verteidiger-Bonus pro **große Basis** pro Minute |

---

## 3. Eroberungs-Bonus

- **Pro eroberte und gehaltene Basis** läuft ein Counter.
- Über **5 Minuten** (`BASE_FILL_TIME`) wird der Basis-Bonus **graduell** dem Pool der Besitzerfraktion gutgeschrieben:
  - **Leicht/Side:** 25 (gesamt)
  - **Mittel:** 50
  - **Groß:** 100
- **Bei Besitzerwechsel** wird der Counter für diese Basis auf **0** gesetzt; der neue Besitzer bekommt den Bonus erneut über 5 Min.

**Einstufung der Basis** (anhand des Basis-**Key**, lowercase):

- **Groß (100):** Key enthält z. B. `hq`, `main`, `capital`, `headquarters`, `zentrum`, `haupt`
- **Mittel (50):** Key enthält z. B. `stützpunkt`, `outpost`, `forward`, `festung`, `fort`, `base`, `stütz`
- **Leicht (25):** alle übrigen (Side/kleine Basen)

---

## 4. Verteidiger-Bonus

- **Jede Minute** (`DEFENDER_BONUS_INTERVAL`) erhalten Fraktionen zusätzlichen Nachschub **pro gehaltener Basis**:
  - **Leicht/Side:** +2
  - **Mittel:** +4
  - **Groß:** +6
- Gehaltene Basen lohnen sich damit dauerhaft durch konstanten Nachschub-Zuwachs.

---

## 5. Commander-Meldungen

- Beim **ersten Start:** „Nachschub: 1000 verbleibend.“ (pro Fraktion).
- Bei **Unterschreiten** der Schwellen **800, 600, 500, 300, 100, 10** je einmal: „Nachschub: X verbleibend.“
- Bei **0:** „Nachschub aufgebraucht. Keine Verstärkung mehr.“ + Spawn wird deaktiviert.

---

## 6. UI

- **Score-Anzeige** (oben, wie bei Minimodes): Pro Fraktion wird die **aktuelle Pool-Zahl** angezeigt.
- **Farben** pro Slot (fest): F0 = Grün, F1 = Rot, F2 = Orange, weitere = Grau.

---

## 7. Chat-Befehle

- **`/nachschub`** oder **`/pool`** (ohne Admin-Rechte):
  - Ausgabe pro Fraktion: **Verbleibend** (Pool), **tot** (gefallene Soldaten), **lebend** (aktuelle Charakteranzahl).
  - Beispiel: `Nachschub | F0: 500 verbl., 120 tot, 45 lebend | F1: 800 verbl., 50 tot, 38 lebend`

---

## 8. Technik (für Modder)

- **Events:** `character_kill`, `chat_event`, `base_owner_change_event`
- **Throttle:** `getBases()` nur alle **1 s** (`BASE_UPDATE_INTERVAL`), Catch-up auf max. 2 s begrenzt.
- **Cache:** Basis-Bonus (25/50/100) pro `base_id` gecacht (`m_baseBonusCache`), keine wiederholten String-Checks.
- **Score-Display** wird nur bei Pool-Änderung (Kill oder Basis-Bonus) aktualisiert.

Einbindung des Trackers erfolgt in den jeweiligen Gamemodes (z. B. Invasion, Quick Match, Campaign) über `addTracker(ReinforcementPoolTracker(m_metagame))` (oder entsprechende API des Mods).
