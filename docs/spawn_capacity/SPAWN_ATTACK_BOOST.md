# Spawn-Attack-Boost: Effekte und Ablauf

## Wann passiert es?

| Aspekt | Beschreibung |
|--------|--------------|
| **Auslöser** | Beim Öffnen des Spawn-Fensters (Wechsel AUS → AN) |
| **Chance** | **25 %** pro Fraktion, unabhängig pro Spawn-Zyklus |
| **Wer kann es bekommen?** | Jede Fraktion mit Nachschub (Pool > 0) und die in diesem Zyklus **nicht geblockt** ist (siehe Cooldown) |
| **Häufigkeit** | Pro Spawn-Zyklus wird für jede berechtigte Fraktion einmal 25 % gewürfelt |

---

## Was ist der „Attack“-Boost?

| Effekt | Normal | Mit Attack-Boost | Auswirkung |
|--------|--------|-------------------|------------|
| **Capacity-Multiplikator** | 1.0 (bzw. 2.0 bei Großangriff) | **1.3** | Bis zu 30 % mehr „Platz“ für Soldaten in diesem Spawn-Fenster |
| **Spawn-Rate** | 0.2 s Intervall (5 Spawns/s) | **0.2 / 1.5 ≈ 0,133 s** (1,5× schneller) | Mehr Einheiten pro Sekunde spawnen |
| **Ergebnis** | Gleichmäßiger Nachschub | **Mehr aktive Soldaten** in derselben Spawn-Phase | Deutlicher Vorteil für die geboostete Fraktion |

Der Boost gilt **nur in einem Spawn-Zyklus**: ausschließlich in den ca. 30 Sekunden, in denen das Spawn-Fenster **AN** ist. Danach endet er automatisch.

---

## Dauer und Cooldown

| Regel | Erklärung |
|-------|-----------|
| **Dauer** | **Genau ein Spawn-Zyklus** (nur die 30 s, in denen Spawn AN ist). Kein zeitbasiertes „90 s“, sondern bis zum Schließen des Fensters (AN → AUS). |
| **Cooldown** | Eine Fraktion, die in Zyklus N den Attack-Boost bekommen hat, ist für den **nächsten** Zyklus (N+1) **geblockt**. Sie kann erst wieder in Zyklus N+2 mit 25 % Chance gezogen werden. |
| **Mindest-Pause** | Es liegt **immer mindestens ein Spawn-Zyklus** (eine komplette AN-Phase + AUS-Phase) zwischen zwei Boosts derselben Fraktion. |

---

## Ablauf pro Spawn-Zyklus (tabellarisch)

| Schritt | Zeitpunkt | Was passiert |
|---------|-----------|--------------|
| 1 | Spawn geht **AUS → AN** | Für jede Fraktion mit Pool > 0 und **nicht geblockt**: 25 %-Wurf. Bei Treffer: Boost für diesen Zyklus aktivieren, Fraktion für den **nächsten** Zyklus blocken. |
| 2 | Während Spawn **AN** (30 s) | Geboostete Fraktion: 1,3× Capacity, 1,5× Spawn-Rate → mehr Einheiten spawnen. Commander-Meldung + HUD-Suffix (z. B. „[Surge]“) für diese Fraktion. |
| 3 | Spawn geht **AN → AUS** | Boost endet automatisch. Die Fraktion, die in diesem Zyklus geboostet war, wird von der Blockliste für den **nächsten** Zyklus entfernt (darf in N+2 wieder mit 25 % gezogen werden). |
| 4 | Nächster Zyklus (AUS → AN) | Wieder 25 % pro berechtigter Fraktion; die in N geboostete Fraktion ist in N+1 blockiert und nimmt nicht am Wurf teil. |

---

## Spieler-Information (Wer erfährt was?)

| Kanal | Wer | Inhalt |
|-------|-----|--------|
| **Commander-Meldung** | Nur die **geboostete Fraktion** | z. B. „Reinforcement surge active. Increased capacity and spawn rate this cycle.“ |
| **HUD / Score** | Alle Spieler | Bei der geboosteten Fraktion z. B. „12/45 [Surge]“, damit alle sehen, **welche** Fraktion den Vorteil hat. |

---

## Kurzüberblick Konstanten (Implementierung)

| Konstante | Wert | Bedeutung |
|-----------|------|-----------|
| `BOOST_CHANCE_ON_WINDOW_OPEN` | 0.25 | 25 % Chance pro Fraktion pro Spawn-Zyklus |
| `BOOST_CAPACITY_MULTIPLIER` | 1.3 | Capacity-Faktor für geboostete Fraktion |
| `BOOST_SPAWN_RATE_MULTIPLIER` | 1.5 | Spawn-Intervall wird durch diesen Wert geteilt (schnellere Rate) |
| **Dauer** | 1 Spawn-Zyklus | Kein fester Sekundenwert; Boost endet beim Wechsel AN → AUS. |
