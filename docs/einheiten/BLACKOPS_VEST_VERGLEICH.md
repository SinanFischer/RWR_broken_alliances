# Black-Ops-Westen: Vergleich

Vergleich **Vanilla Black Ops** (`vest_blackops`) und **Black Ops III** (`vest_blackops3`, Mod).

| Eigenschaft | Black Ops (Vanilla) | Black Ops III (Mod) |
|-------------|---------------------|----------------------|
| **Key / Name** | `vest_blackops.carry_item` / „black ops vest“ | `vest_blackops3.carry_item` / „black ops vest III“ |
| **Anzahl Zustände** | 2 (Voll → beschädigt) | 4 (Voll → bo3_2 → bo3_3 → bo3_4) |
| **Treffer bis „verbraucht“** | 1 (dann nächster Treffer = wound) | 3 (dann nächster Treffer = wound) |
| **Preis (Armory, 1. Zustand)** | 40 | 120 |
| **In Waffenkammer** | Ja (`in_stock="1"`) | Nein (`in_stock="0"`) |
| **Rank** | 0.3 | 0.3 |
| **Encumbrance** | 4 | 4 |
| **Modell / HUD** | `vest_black.xml` / `hud_blackops.png` | gleich |

---

## Modifier (Voll / erste Stufe)

| Modifier | Black Ops (Voll) | Black Ops III (Voll / Stufe 1+2) |
|----------|------------------|----------------------------------|
| **speed** | +0.02 | **+0.075** (Hälfte der Captain-/Cargo-Weste) |
| **hit_success_probability** | -0.08 | -0.08 |
| **night_detectability** | -0.25 | -0.25 |

*Black Ops III Stufe 3+4 (stark beschädigt/kaputt): speed -0.04.*

---

## Treffer-Logik (Projektil, tödlich)

| Treffer | Black Ops | Black Ops III |
|---------|-----------|----------------|
| 1. | absorbiert (→ none), Weste → beschädigt | absorbiert (→ none), Weste → bo3_2 |
| 2. | wound (Weste bleibt beschädigt) | absorbiert (→ none), Weste → bo3_3 |
| 3. | – | stun, Weste → bo3_4 |
| 4. | – | wound (Weste bleibt bo3_4) |
| 5. (nach 4.) | – | Tod (ohne weitere Westen-Stufe) |

---

## Kurzfassung

- **Black Ops III** ist in der Treffer-Logik **3× so stark** (3 absorbierte Treffer statt 1).
- **Speed:** Black Ops III hat in den vollen Stufen **+0,075** (die Hälfte der Captain-/Cargo-Weste), Vanilla Black Ops nur +0,02. Tarnung und hit_success wie Vanilla.
- **Black Ops III** ist nur per **`/blackops3`** (Admin) bzw. per Unlock-Abgabe spawnbar, nicht direkt in der Waffenkammer kaufbar.
