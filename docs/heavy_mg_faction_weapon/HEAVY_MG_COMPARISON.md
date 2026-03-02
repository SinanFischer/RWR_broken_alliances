# Heavy MG — Fraktionswaffen-Vergleich

> **Legende:**
> - **Feuerrate** – `retrigger_time`: Zeit in Sek. zwischen zwei Schüssen (niedriger = schneller)
> - **Accuracy Factor** – Basisgenauigkeits-Multiplikator (höher = präziser)
> - **Spread Range** – Streuungsbreite (niedriger = enger)
> - **Kill Probability** – Wahrscheinlichkeit eines Kills pro Treffer (aus `projectile`)
> - **Kill Decay Start/End** – Zeitfenster in Sek., in dem die Kill-Wahrscheinlichkeit auf 0 abfällt
> - **Magazin** – Anzahl Schüsse pro Nachladevorgang
> - **Speed Penalty** – Bewegungsstrafe durch Waffe (`modifier class="speed"`)
> - **Encumbrance** – Tragegewicht (beeinflusst Ausdauer & Slot-Nutzung)
> - **Preis** – Kaufpreis in der Waffenkammer (Armory)
> - **Sichtweite** – `sight_range_modifier` (Multiplikator auf Standard-Sichtweite)
> - **Schießen im Stand** – `can_shoot_standing` (0 = nicht möglich, 1 = möglich)
> - **Acc. Stehend** – Genauigkeit aus `<stance state_key="standing">`
> - **Acc. Liegend** – Genauigkeit aus `<stance state_key="prone">`
> - **Acc. Laufend** – Genauigkeit aus `<stance state_key="running">`
> - **Überhitzungs-Cooldown** – `cooldown_start` in Sek. bis Überhitzungsphase beginnt

---

## Vergleichstabelle

| Stat | 🟤 RU — QJZ-89 "Volk" | 🟢 EU — M1917 Savage-Lewis | 🔵 USA — MG-08 Heavy CustoM22 |
|---|---|---|---|
| **Dateiname** | `qjz89_volk.weapon` | `m1917_savage_lewis.weapon` | `mg08_heavy_custom22.weapon` |
| **Fraktion** | Brown (RU) | Green (EU) | Grey (USA) |
| **Preis** | **200** | **200** | **200** |
| **Magazingröße** | **200** | 97 | 60 |
| **Feuerrate** (`retrigger_time`) | 0.10 s | 0.12 s | **0.085 s** |
| **Accuracy Factor** | 0.85 | 0.80 | **0.90** |
| **Spread Range** | 0.30 | **0.25** | — (Burst) |
| **Kill Probability** | **0.88** | 0.65 | 0.57 |
| **Kill Decay Start** | 0.48 s | **0.51 s** | 0.38 s |
| **Kill Decay End** | 0.70 s | **0.80 s** | 0.70 s |
| **Projektilgeschwindigkeit** | **110.0** | **100.0** | **100.0** |
| **Sichtweite-Modifier** | **×1.1** | ×1.0 (Standard) | ×1.0 (Standard) |
| **Schießen im Stand** | ❌ Nein | **✅ Ja** | ❌ Nein |
| **Schießen in Hocke** | ❌ Nein | **✅ Ja** | **✅ Ja** |
| **Acc. Stehend** | 0.85 | 0.65 | **0.70** |
| **Acc. Hockend** | 0.85 | 0.65 | **0.80** |
| **Acc. Liegend** | 0.85 | 0.75 | **1.00** |
| **Acc. Liegend (bewegt)** | **0.50** | — | **0.10** |
| **Acc. Laufend** | 0.20 | 0.30 | **0.05** |
| **Acc. Gehend** | 0.20 | **0.65** | 0.40 |
| **Speed Penalty** | −45 % | −20 % | **−7 %** |
| **Encumbrance** | **10.0** | 11.0 | **10.0** |
| **Überhitzungs-Cooldown** | Ja (0.5 s) | Ja (0.5 s) | **❌ Keine** |
| **Sustained Fire Grow** | **0.1000** | 0.0300 | 0.0622 |
| **Sustained Fire Diminish** | **0.40** | 0.15 | **0.40** |
| **Burst Shots** | — | — | **6** |
| **Waffenklasse** | 0 (Standard) | 0 (Standard) | **4 (Burst)** |
| **In Stock (Armory)** | **✅ Ja** | **✅ Ja** | **✅ Ja** |
| **Basisklasse** | `base_primary_rare` | `base_primary_rare` | `base_primary_rare` |
| **Projektilbasis** | `50cal_bullet` | `bullet` | `bullet` |

---

## Registrierungs-Status

| Schritt | QJZ-89 "Volk" | M1917 Savage-Lewis | MG-08 Heavy CustoM22 |
|---|---|---|---|
| `all_weapons.xml` | ✅ | ✅ | ✅ |
| `common.resources` | ✅ | ✅ | ✅ |
| `brown_primaries.resources` | ✅ | — | — |
| `brown_mgs.resources` | ✅ | — | — |
| `green_primaries.resources` | — | ✅ | — |
| `green_mgs.resources` | — | ✅ | — |
| `grey_primaries.resources` | — | — | ✅ |
| `grey_mgs.resources` | — | — | ✅ |

---

*Zuletzt aktualisiert: 2026-03-02*
