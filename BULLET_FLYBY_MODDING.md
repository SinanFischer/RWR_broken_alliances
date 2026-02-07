# Kugel-Vorbeiflug / Kamera-Shake (Modding)

## Kurzfassung

- **Bullet-Flyby-Sound bei Treffer:** Umgesetzt – bei `player_wound` wird ein Zusatz-Sound an der Spielerposition abgespielt (`scripts/trackers/bullet_flyby_effect.as`).
- **Echter Near-Miss (Kugel fliegt vorbei, kein Treffer):** **Nicht möglich** mit der aktuellen RWR-Script-API. Die Engine sendet kein Event für „Projektil kam Spieler nah, ohne zu treffen“.
- **Kamera-Shake:** In Vanilla-Scripts und -Comms gibt es **keinen** Befehl wie `camera_shake` oder `screen_effect`. Ohne Engine-Änderung oder undokumentierten Client-Befehl ist Shake per Mod derzeit nicht umsetzbar.

---

## Was wurde eingebaut

1. **Tracker `BulletFlybyEffect`** (`scripts/trackers/bullet_flyby_effect.as`)
   - Reagiert auf **player_wound** (Spieler wird getroffen).
   - Spielt an der Trefferposition einen Sound ab (`barrier_bullet_01.wav`), um den Treffer-Moment etwas stärker zu betonen.
   - Sound-Datei ist über `m_flybySound` änderbar (z.B. auf einen eigenen Flyby-Sound).

2. **Einbindung im Gamemode**
   - In `my_gamemode.as`: `postBeginMatch()` ruft `addTracker(BulletFlybyEffect(this))` auf, damit der Tracker in jeder Kampagnen-Partie aktiv ist.

---

## Grenzen der API (Stand der Prüfung)

- **Verfügbare Events (Auszug):** `player_wound`, `player_die`, `player_kill`, `player_stun`, `hitbox_event`, `result_event`, Fahrzeug-/Basis-Events usw.
- **Kein Event:** für „Projektil in der Nähe des Spielers vorbeigeflogen“. Daher kann ein reiner Vorbeiflug-Sound (nur bei Near-Miss) per Script nicht zuverlässig ausgelöst werden.
- **Comms-Befehle (Beispiele):** `play_sound`, `update_camera`, `create_instance`, `update_character` usw. **Kein** `camera_shake`/`screen_effect` in den genutzten Vanilla-Scripts.

---

## Optionen für die Zukunft

- **Kamera-Shake:** Nur möglich, wenn die Engine (oder der Client) einen entsprechenden Befehl unterstützt. Ein auskommentierter Testaufruf liegt im Tracker (z.B. `camera_shake`); bei neuer Engine-Version ggf. aktivieren und prüfen.
- **Echter Near-Miss:** Würde ein Event (z.B. `projectile_near_player` oder Ähnliches) von der Engine gesendet, könnte derselbe Tracker erweitert werden: Bei diesem Event nur Sound (und ggf. Shake) auslösen, ohne `player_wound`.

---

## Eigene Sounds

- Sound-Datei im Mod (z.B. unter `sounds/`) ablegen und in `bullet_flyby_effect.as` `m_flybySound` auf den Dateinamen setzen (z.B. `mein_flyby.wav`).
- Vanilla bietet z.B. `a10_flyby.wav` / `ac130_flyby.wav` (Flugzeug); für Kugeln eignet sich oft etwas Kürzeres wie `barrier_bullet_01.wav` oder ein eigener kurzer „Zisch“-Sound.
