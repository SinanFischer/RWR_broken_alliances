# Stash-Waffen: RP-Preisliste (verbindlich)

Lückenlose, fair ausbalancierte **RP-Preisliste** (Resource Points) für alle Waffen in der Waffenkammer (**Stash**). Quelle: `factions/armory_common.resources` + `price` in `weapons/*.weapon`.

---

## 1. Denkprozess

- **Workspace verifiziert:** Alle Stash-Waffen stehen in `armory_common.resources` (nur Referenzen; `price` und ggf. `in_stock` liegen in den jeweiligen `.weapon`-Dateien). Es gibt **32 Stash-Waffen**; **xm25_r** ist nicht in der Armory (nur **xm25**).
- **Referenz: Basis-AR (G36, M16A4, AK-47):** Die **normalen** Sturmgewehre ohne GL/Support sind im Mod mit festem RP-Wert hinterlegt und dienen als **Preis-Referenz** (sie stehen **nicht** in der Stash-Liste, sind aber die logische Basis für die Matrix):
  - **G36** (`weapons/g36.weapon`): **16 RP**
  - **M16A4** (`weapons/m16a4.weapon`): **16 RP**
  - **AK-47** (`weapons/ak47.weapon`): **15 RP**
  - → **Basis-AR = 15–16 RP** (Rundung: **16 RP** als Rechenreferenz).
- **Stash-Einstieg vs. Basis:** Der günstigste AR in der Waffenkammer ist **M16A4 Tactical** (m16a4_support) mit **90 RP** = ca. **5,6× Basis-AR** (90/16). Die Stash bietet bewusst nur „gehobene“ Varianten; die reinen Basis-ARs (G36, M16, AK) sind Spawn-/Feldwaffen.
- **Preis-Matrix-Faktoren** (alle von Basis-AR 16 RP abgeleitet):
  - **GL-Varianten** (M16/G36/AK + Unterlauf-Granatwerfer): 250 RP ≈ **15,6× Basis** bzw. **2,78× Stash-AR** (250/90).
  - **Spezialgewehre/DMR/Shotgun** (Gilboa, M1 Garand, Tommy, Origin-12, Bogen, RPK-16): 150–216 RP (ca. 9× bis 13,5× Basis).
  - **Explosiv/Special** (XM25, SBL, QLZ-87): 220–379 RP; **Elite-Sniper** (Truvelo, M200): 648–880 RP; **Schwer-MG** (ULTIMAX): 800 RP.
  - **Schilde/Melee:** TTI 210, Camo 100, Sabre 333, Golden Knife 1000 (Prestige).
  - **Utility:** Taser Medic + FHJ-01 je 20 RP (Support-Rolle, kein Hauptkampfwert).
- **Lücken:** Keine – jede Stash-Waffe hat in den `.weapon`-Dateien einen numerischen `price`-Wert. Die folgende Tabelle übernimmt diese Werte und ordnet sie der Matrix zu.

---

## 2. Preis-Matrix (Kurzreferenz)

- **Basis-AR (Referenz, nicht im Stash):** **15–16 RP** (AK-47: 15, G36/M16A4: 16) – Quelle: `weapons/ak47.weapon`, `g36.weapon`, `m16a4.weapon`.
- **Stash-Einstieg AR:** **90 RP** (m16a4_support) ≈ **5,6× Basis-AR**.
- **Gewehr + Granatwerfer (GL):** **250 RP** (≈ 15,6× Basis-AR bzw. 2,78× Stash-AR).
- **Spezialist (DMR / Shotgun / MG leicht / Bogen):** **150–216 RP** (Gilboa 150, M1 Garand/Tommy 200, Origin-12 210, Bogen 215, RPK-16 216).
- **Explosiv / Special mittel:** **220–300 RP** (XM25 220, SBL 300).
- **Schilde:** **100–210 RP** (Camo 100, TTI 210).
- **Melee:** **333 RP** (Sabre), **1000 RP** (Golden Knife, Prestige).
- **Elite-Sniper / Schwer-MG / Schwer-Explosiv:** **379–880 RP** (QLZ-87 379, Truvelo 648, ULTIMAX 800, M200 880).
- **Utility (Heilen / Nischen-Explosiv):** **20 RP** (taser_medic, FHJ-01).

---

## 3. Finale Tabelle: Stash-Waffen · Fraktion · Waffenart · Preis (RP) · Begründung

| Waffe | Fraktion | Waffenart | Preis (RP) | Begründung (Kurz) |
|-------|----------|-----------|------------|-------------------|
| Medizinisches Dartgewehr (taser_medic) | all | Special (Heilen) | 20 | Utility; Heilen, kein Kampf-Fokus |
| XM25 (xm25) | USA | Explosiv (Luftdetonation) | 220 | Explosiv mittel; Luftdetonation, begrenzt Magazin |
| TTI (tti) | EU | Schild | 210 | Schild + Sidearm; hoher Speed-Malus, Defensiv |
| Truvelo AMis Suppressed (truvelo_amris) | EU | Sniper (Explosiv, 6 Schuss) | 648 | Elite-Sniper Explosiv; sehr selten spawnen |
| ULTIMAX 100 (ultimax) | EU | MG | 800 | Schwer-MG; Dauerfeuer-Elite, hoher Wert |
| ULTIMAX 100 Magazin (ultimax_m) | EU | MG | 800 | Wie ultimax, Magazin-Variante |
| Sword / Sabre (sabre) | all | Nahkampf (Melee) | 333 | Melee-Elite; einzigartige Rolle |
| M16A4 Tactical (m16a4_support) | USA | Gewehr (AR + Schild) | 90 | Stash-Einstieg AR; ≈ 5,6× Basis-AR (G36/M16/AK 15–16 RP) |
| SBL / Kreissägen (sbl) | RU | Special (Explosiv) | 300 | Explosiv Special; kontert Schilde, begrenzte Spawn-Rate |
| Camouflage Shield (camo_shield) | USA | Schild | 100 | Defensiv; Tarn-Schild, kein Offensiv-Bonus |
| Goldenes Messer (golden_knife) | all | Nahkampf (Melee) | 1000 | Prestige/Elite-Melee; bewusst teuer |
| Gilboa DBR (gilboa_dbr) | EU | Gewehr (AR, Shotgun-Munition) | 150 | Spezial-AR; 30 Schuss, shotgun-ähnlich |
| Tommy Gun (gun_tommy) | RU | MG / SMG (50 Schuss) | 200 | Spezialist; hohe Feuerrate, 50 Schuss |
| M1 Garand Modern (m1_garand_m) | USA | DMR (8 Schuss) | 200 | DMR; 8 Schuss, hohe Killrate |
| Origin-12 (origin_12) | all | Shotgun (30 Schuss) | 210 | CQB-Shotgun; 30 Schuss, schnell |
| Origin-12 S (origin_12_s) | all | Shotgun | 210 | Wie Origin-12, Variante |
| Verbundbogen (compound_bow) | all | Special (Bogen) | 215 | Stealth/Special; Standard-Pfeil |
| Verbundbogen Explosiv (compound_bow_alt) | all | Explosiv (Bogen) | 215 | Wie Bogen + Explosiv-Pfeil |
| RPK-16 (rpk16) | RU | MG | 216 | Leicht-MG; RU-Standard-MG |
| RPK-16 Langrohr (rpk16_long) | RU | MG | 216 | RPK-16 mit Langrohr; etwas präziser |
| CheyTac M200 (m200) | USA | Sniper (Großkaliber) | 880 | Elite-Sniper; maximaler Schaden/Reichweite |
| M16A4 GL (m16a4_w_m203) | USA | Gewehr + Granatwerfer | 250 | GL; ≈ 15,6× Basis-AR (M16/G36/AK 16 RP) |
| M16A4 GL (m16a4_w_m203_g) | USA | Gewehr + Granatwerfer | 250 | GL; Granat-Variante |
| G36 GL (g36_w_ag36) | EU | Gewehr + Granatwerfer | 250 | GL; ≈ 15,6× Basis-AR (G36 16 RP) |
| G36 GL (g36_w_ag36_g) | EU | Gewehr + Granatwerfer | 250 | GL; Granat-Variante |
| AK-47 GL (ak47_w_gp25) | RU | Gewehr + Granatwerfer | 250 | GL; ≈ 16,7× Basis-AR (AK-47 15 RP) |
| AK-47 GL (ak47_w_gp25_g) | RU | Gewehr + Granatwerfer | 250 | GL; Granat-Variante |
| AN-94 Salve (an94_burst) | RU | Gewehr (Salven) | 250 | Spezial-AR; Salvenfeuer, GL-Niveau |
| QBZ-95 (qbz95) | all | Gewehr (inkl. Shotgun-Modus) | 280 | Flex-AR; AR + Shotgun-Modus |
| QBZ-95 US (qbz95_us) | all | Gewehr (inkl. Shotgun-Modus) | 280 | Wie QBZ-95, US-Variante |
| QLZ-87 (qlz87_b) | RU | Explosiv (schwerer Granatwerfer) | 379 | Schwer-Explosiv; kontert Phalanx, Speed-Malus |
| FHJ-01 FAE (fhj01) | RU | Explosiv (Anti-Personen-Werfer) | 20 | Utility/Nische; FAE gegen Gruppen, begrenzte Rolle |

---

## 4. Hinweise

- **Basis-AR (G36, M16A4, AK-47)** haben **15–16 RP** im Mod, stehen aber **nicht** in `armory_common.resources` – sie sind die Referenz für die Matrix, nicht kaufbar in der Waffenkammer.
- **Keine „—“ mehr:** Jede Stash-Waffe hat einen festen RP-Wert; die Werte entsprechen den aktuellen `price`-Angaben in `weapons/*.weapon`.
- **Anpassung:** Änderungen an RP-Preisen bitte in der jeweiligen `.weapon`-Datei unter `<inventory … price="…" />` vornehmen und diese Tabelle sowie ggf. `NEUE_WAFFEN_UEBERSICHT.md` nachziehen.
- **xm25_r** ist nicht in `armory_common.resources` und erscheint daher nicht in dieser Stash-Liste; der Preis in `xm25_r.weapon` (200 RP) ist nur relevant, falls die Waffe später in die Waffenkammer aufgenommen wird.
