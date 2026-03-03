# Heavy MG — Fraktionswaffen-Vergleich (Balanced)

> **Legende:**
> - **Feuerrate** – `retrigger_time`: Zeit in Sek. zwischen zwei Schüssen (niedriger = schneller)
> - **Accuracy Factor** – Basisgenauigkeits-Multiplikator (höher = präziser)
> - **Spread Range** – Streuungsbreite (niedriger = enger)
> - **Sustained Fire Grow** – Wie schnell die Genauigkeit beim Dauerfeuer abnimmt (Rückstoß-Akkumulation; niedriger = stabiler)
> - **Sustained Fire Diminish** – Wie schnell sich die Genauigkeit nach dem Feuern erholt
> - **Kill Probability** – Wahrscheinlichkeit eines Kills pro Treffer
> - **Kill Decay Start/End** – Zeitfenster in Sek., in dem Kill-Wahrscheinlichkeit auf 0 abfällt (größer = effektiver auf Distanz)
> - **Magazin** – Anzahl Schüsse pro Nachladevorgang
> - **Speed Penalty** – Bewegungsstrafe durch Waffe (`modifier class="speed"`)
> - **Encumbrance** – Tragegewicht
> - **Preis** – Kaufpreis in der Waffenkammer
> - **Sichtweite** – `sight_range_modifier` (Multiplikator auf Standard-Sichtweite)

---

## Verfügbarkeit

**🎯 Fraktionsspezifisch**: Diese Waffen sind **fraktionsexklusiv** verfügbar. Jede Fraktion kann ihre HMG in der **Armory kaufen** (200 RP) und **MG-Soldaten können direkt damit respawnen**. Cross-Faction-Verfügbarkeit ist **nicht** möglich — Russen erhalten nur die QJZ-89, USA nur die M1917, EU nur die MG-08.

---

## Rollen-Übersicht

| | 🟤 RU — QJZ-89 "Volk" | 🟢 USA — M1917 Savage-Lewis | 🔵 EU — MG-08 Heavy CustoM22 |
|---|---|---|---|
| **Rolle** | Anti-Material | Gebietskontrolle / Suppression | Präzision + Feuerrate |
| **Stärke** | Vernichtende Einzelschuss-Kraft, lange Reichweite | Riesiges Magazin, kaum Streuungsanstieg | Engste Streuung, höchste Kadenz, Laser im Liegen |
| **Schwäche** | Extrem langsam, massiver Rückstoß, nur liegend effektiv | Niedrigster Schaden, mittlere Mobilität | Kleines Magazin, steht nur kniend/liegend |

---

## Vergleichstabelle

| Stat | 🟤 RU — QJZ-89 "Volk" | 🟢 USA — M1917 Savage-Lewis | 🔵 EU — MG-08 Heavy CustoM22 |
|---|---|---|---|
| **Dateiname** | `qjz89_volk.weapon` | `m1917_savage_lewis.weapon` | `mg08_heavy_custom22.weapon` |
| **Preis** | **200** | **200** | **200** |
| **Magazingröße** | **200** | 165 | 60 |
| **Feuerrate** (`retrigger_time`) | 0.13 s (langsam) | 0.10 s | **0.07 s** (schnellste) |
| **Accuracy Factor** | 0.85 | 0.82 | **0.92** |
| **Spread Range** | 0.45 (breit) | 0.28 | **0.12** (engste) |
| **Sustained Fire Grow** | 0.12 | **0.02** (kaum Anstieg) | 0.05 |
| **Sustained Fire Diminish** | 0.25 | 0.12 | **0.50** (schnellste Erholung) |
| **Kill Probability** | **0.80** | 0.58 | 0.50 |
| **Kill Decay Start** | **0.60 s** | 0.40 s | 0.35 s |
| **Kill Decay End** | **1.00 s** | 0.65 s | 0.65 s |
| **Projektilgeschwindigkeit** | **115.0** | 100.0 | 100.0 |
| **Sichtweite-Modifier** | **×1.2** | ×1.0 (Standard) | ×1.0 (Standard) |
| **Schießen im Stand** | ❌ Nein | **✅ Ja** | ❌ Nein |
| **Schießen in Hocke** | ❌ Nein | **✅ Ja** | **✅ Ja** |
| **Acc. Laufend** | 0.10 | **0.35** | 0.05 |
| **Acc. Gehend** | 0.15 | **0.70** | 0.40 |
| **Acc. Stehend** | 0.75 | 0.70 | 0.65 |
| **Acc. Hockend** | 0.80 | 0.72 | **0.85** |
| **Acc. Liegend** | **0.95** | 0.80 | 0.92 |
| **Acc. Liegend (bewegt)** | **0.30** | — | 0.10 |
| **Acc. Über Mauer** | 0.75 | 0.70 | **0.88** |
| **Speed Penalty** | **−55 %** (extrem langsam) | −20 % | **−7 %** (mobilste) |
| **Encumbrance** | **10.0** | 11.0 | **10.0** |
| **Überhitzungs-Cooldown** | Ja (**0.9 s**) | Ja (0.5 s) | **❌ Keine** |
| **Burst Shots** | — | — | **6** |
| **Waffenklasse** | 0 (Standard) | 0 (Standard) | **4 (Burst)** |
| **Projektilbasis** | `50cal_bullet` | `bullet` | `bullet` |
| **Respawn möglich** | **✅ Ja** | **✅ Ja** | **✅ Ja** |
| **In Stock (Armory)** | **✅ Ja** | **✅ Ja** | **✅ Ja** |

---

## Registrierungs-Status

| Schritt | QJZ-89 "Volk" | M1917 Savage-Lewis | MG-08 Heavy CustoM22 |
|---|---|---|---|
| `all_weapons.xml` | ✅ | ✅ | ✅ |
| `common.resources` | **❌ Entfernt** | **❌ Entfernt** | **❌ Entfernt** |
| `brown_primaries.resources` | **✅ Armory** | — | — |
| `brown_mgs.resources` | **✅ MG-Respawn** | — | — |
| `green_primaries.resources` | — | **✅ Armory** | — |
| `green_mgs.resources` | — | **✅ MG-Respawn** | — |
| `grey_primaries.resources` | — | — | **✅ Armory** |
| `grey_mgs.resources` | — | — | **✅ MG-Respawn** |

---

## Balancing-Changelog (2026-03-02)

| Stat | QJZ-89 "Volk" (vorher → neu) | M1917 Savage-Lewis (vorher → neu) | MG-08 Heavy CustoM22 (vorher → neu) |
|---|---|---|---|
| `retrigger_time` | 0.10 → **0.13** | 0.12 → **0.10** | 0.085 → **0.07** |
| `sustained_fire_grow_step` | 0.0622 → **0.12** | 0.03 → **0.02** | 0.10 → **0.05** |
| `spread_range` | 0.30 → **0.45** | 0.25 → **0.28** | — → **0.12** |
| `sight_range_modifier` | 1.1 → **1.2** | — | — |
| `magazine_size` | 200 (unverändert) | 97 → **165** | 60 (unverändert) |
| `kill_probability` | 0.88 → **0.80** | 0.65 → **0.58** | 0.57 → **0.50** |
| `kill_decay_end_time` | 0.70 → **1.00** | 0.80 → **0.65** | 0.70 → **0.65** |
| `projectile_speed` | 110.0 → **115.0** | — | — |
| `speed modifier` | −0.45 → **−0.55** | −0.20 (unverändert) | −0.07 (unverändert) |
| `accuracy_factor` | — | 0.80 → **0.82** | 0.90 → **0.92** |
| `sustained_fire_diminish_rate` | 0.4 → **0.25** | 0.15 → **0.12** | 0.4 → **0.50** |
| `cooldown_start` | 0.5 → **0.9** | — | — |
| `can_respawn_with` | 0 → **1** | 0 → **1** | 0 → **1** |
| **Verfügbarkeit** | Global → **Fraktionsspezifisch** | Global → **Fraktionsspezifisch** | Global → **Fraktionsspezifisch** |

---

*Zuletzt aktualisiert: 2026-03-02 — Balancing v1.3 (Fraktionsspezifisch + MG-Respawn)*
