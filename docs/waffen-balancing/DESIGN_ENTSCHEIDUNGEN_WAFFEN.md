# Design-Entscheidungen Waffen (verbindlich)

Zentrale Referenz für alle Stash-Waffen und KI-Waffen. Bei Validierung und Erstellung **zwingend** anwenden.

---

## 3. Speed-Modifier (Vollständige Zuordnung)

`<modifier class="speed" value="..." />` – exakte Werte nach Vanilla-Standard:

| Waffe | value | Klasse |
|-------|--------|--------|
| M1 Garand (DMR) | -0.08 | Mittel |
| CheyTac M200 (Sniper) | -0.12 | Schwer |
| XM25 (Explosiv) | -0.12 | Schwer |
| Gilboa DBR (AR/Shotgun) | -0.05 | Standard |
| Origin-12 (Shotgun) | -0.08 | Mittel |
| Tommy Gun (SMG) | -0.075 | Standard/Mittel |
| RPK-16 (LMG) | -0.06 | Mittel |
| AN-94 (AR) | -0.032 | Standard |
| ULTIMAX (LMG) | -0.10 | Mittel/Schwer |
| Bogen (compound_bow/alt) | -0.10 | Mittel |
| Camouflage Shield | -0.10 | Deutlich mobiler als TTI |
| **TTI (Kampfschild)** | **-0.35** | **exakt** (Schwer Defensiv) |
| QLZ-87, FHJ-01 (Schwer Explosiv) | -0.40 bis -0.45 | Schwer Explosiv |
| SBL (Explosiv-Elite) | -0.40 (empfohlen) | Schwer Explosiv |

---

## 4. Fraktionslisten (.resources) & „All“

- **„all“-Waffen:** Ausschließlich in **common.resources** eintragen (wird an alle Fraktionen vererbt).
- **Fraktionsspezifisch (EU/USA/RU):** Nur in jeweiligen **_default.resources** oder **_primaries.resources** (green, grey, brown).
- **Waffenkammer (Stash pro Fraktion):**  
  - **armory_common.resources** → alle Fraktionen  
  - **armory_green.resources** → nur USA (z. B. XM25 Schall)  
  - **armory_grey.resources** → nur EU (z. B. TTI)  
  - **armory_brown.resources** → nur RU  
  Fraktions-only-Waffen (TTI, XM25_r) **dürfen nicht in common.resources** stehen, sonst erscheinen sie in der Waffenkammer aller Fraktionen.
- **GL-Varianten:** Im Stash und in _primaries nur die **Basis-Waffe** (z. B. m16a4_w_m203). Die **_g**-Varianten (Granat-Modus) sind nur technische Next-in-Chain-Referenzen und **nicht** separat im Shop listen.

---

## 5. Stash vs. KI-Spawn (Exklusive Items)

- **Nur-Stash-Waffen** (z. B. taser_medic, Camouflage Shield): In der .weapon **commonness value="0.0"** und **in_stock="1"**. KI spawnt damit nicht.
- **Bogen:** **commonness value="0.0005"**. KI hat keine Schleich-Logik; wird als seltene Waffe im RNG-Pool behandelt.

---

## 6. Varianten & Modus-Wechsel (KI)

- KI schaltet keine Feuermodi um. Bei alternativen Modi **zwingend separate .weapon-Datei** für KI, wenn sie diesen Modus nutzen soll.
- **QBZ-95 Shotgun-Modus:** **qbz95_shotgun.weapon** für KI, Fraktion „all“, commonness 0.01 (Tier 2, CQB). Spieler nutzt im Shop nur die Basis-**qbz95.weapon**.
- **compound_bow:** Nur **ein** Eintrag (compound_bow.weapon) im Stash für Spieler (Pfeil/Explosiv-Pfeil über Next-in-Chain).

---

## 7. projectile_speed (Skala & Granaten)

- **XM25:** Vanilla-Granaten-Skala → **projectile_speed="40.0"**.
- **Gilboa DBR:** Shotgun-Munition → **projectile_speed="90.0"** und **kurzer Decay** (kill_decay_start/end kurz).
- **Konventionelle Waffen:** Vanilla-Skala beibehalten (ARs ~100, Sniper ~150+). Siehe PROJEKTILGESCHWINDIGKEIT_REGELN.md für angehobene Skala (155–165) bei Neuanpassungen.

---

## 8. Elite-Definition & Preis-Bindung

- **Verbindliche Elite-Liste (Tier 4):** SBL, QLZ-87, CheyTac M200, Truvelo Amris, FHJ-01.  
  **Commonness:** **0.0001 bis 0.0005** (0.0001 bis 0.005 laut Regelwerk; hier verschärft).
- **ULTIMAX:** Preis **800 RP** (Vanilla) ist verbindlich für den Stash.

---

## 9. Encumbrance & Magazin-Logik

- **Encumbrance:**  
  - Standard (Tier 1 & 2 ARs/SMGs): **11.0**  
  - Sniper / LMGs: **15.0 bis 20.0**  
  - Schwere Elite (SBL, QLZ-87, Schilde): **25.0 bis 35.0**
- **Magazin:** Wenn **kill_probability > 1.0** (z. B. M200, Garand, Bogen), darf **magazine_size** den Wert **10** nicht überschreiten.

---

## 10. Melee & Schilde

- **Reine Nahkampfwaffen** (Sabre, Golden Knife): Keine projectile_speed-Regel; Engine-Standard **`<result class="melee" />`** verwenden.
- **Camouflage Shield:** Speed-Modifier **-0.10** (deutlich mobiler als TTI).  
- **TTI:** Speed-Modifier **exakt -0.35**.

---

## 11. Doku vs. XML (Verbindliche Quelle)

- **Doku überschreibt** bestehende XML-Platzhalter.
- **taser_medic:** **price="120"** (verbindlich).
- **SBL:** **price="300"** (verbindlich).

---

## 12. can_shoot_standing (Haltungszwang)

- **Definition „schwer“:** Nur **massive** Waffen (QLZ-87, MRL, schwere stationäre Deployables) → **can_shoot_standing="0"** (nur Hocke/Liegen).
- **Leichte LMGs / SMGs** (ULTIMAX, RPK-16, Tommy Gun): **can_shoot_standing="1"**. Balance über **hohen Rückstoß** (Accuracy Penalty) im Stehen.
- **RPK-16 Long:** Wie RPK-16 → **can_shoot_standing="1"**.
