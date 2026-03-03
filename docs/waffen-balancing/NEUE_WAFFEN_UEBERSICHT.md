# Stash-Waffen: Übersicht & Balancing (Broken Alliances)

Alle Waffen, die in der Lobby-Waffenkammer (**Stash**) aktiv sind – mit fraktionsspezifischer Aufteilung und technischen Balancing-Hinweisen.

**Konzept:** Asymmetrisches Balancing nach dem **Schere-Stein-Papier-Prinzip** – jede Fraktion hat einzigartige Stärken und Schwächen. Mächtige Waffen werden durch geringe **Spawn-Raten** (commonness), **Bewegungsmalus** (speed modifier) und/oder hohe **RP-Preise** ausgeglichen.

---

## Fraktionsthemen (Schere-Stein-Papier)

| Fraktion | Thema | Stärke | Schwäche |
|----------|--------|--------|----------|
| **USA** | High-Tech, Mobilität & Präzision | Gezielte Ausschaltung, taktische Manöver, Luftdetonation | Anfällig im Nahkampf-Chaos |
| **EU** | Schwer gepanzerte Phalanx & Unterdrückungsfeuer | Schilde, Dauerfeuer, schwer zu knacken | Anfällig für schwere Explosionen (Schilde blocken keinen Explosivschaden) |
| **RU** | Flächenschaden, Chaos & rohe Gewalt | Massige Explosivwaffen, kontert EU-Schilde | Auf offener Fläche Ziele für US-Sniper |
| **Neutral** | Utility, Stealth, CQB für alle | Unterstützung, Nahkampf, Flexibilität | Kein Fraktions-Bonus |

---

## Tabelle: Fraktion · Waffenart · Preis

| Waffe | Fraktion | Waffenart | Preis (RP) |
|-------|----------|-----------|-------------|
| **Medizinisches Dartgewehr** (taser_medic) | all | Special (Heilen) | 120 |
| **XM25** | USA | Explosiv (Granatwerfer, Luftdetonation) | — |
| **XM25 Schall** (xm25_r) | USA | Explosiv (Granatwerfer) | — |
| **TTI** (Kampfschild) | EU | Schild | — |
| **Truvelo AMis Suppressed** | EU | Sniper (Explosiv, 6 Schuss) | — |
| **ULTIMAX 100** | EU | MG | — |
| **ULTIMAX 100 Magazin** (ultimax_m) | EU | MG | — |
| **Sword** (Sabre) | all | Nahkampf (Melee) | — |
| **M16A4 Tactical** (m16a4_support, mit Schild) | USA | Gewehr (AR) | — |
| **SBL** (Kreissägen) | RU | Special (Explosiv) | — |
| **Camouflage Shield** | USA | Schild | 80 |
| **Goldenes Messer** | all | Nahkampf (Melee) | — |
| **Gilboa DBR** | EU | Gewehr (AR, 30 Schuss, Shotgun-Munition) | — |
| **Tommy Gun** | RU | MG / SMG (50 Schuss) | — |
| **M1 Garand Modern** | USA | DMR (8 Schuss) | — |
| **Origin-12** | all | Shotgun (30 Schuss) | — |
| **Origin-12 S** (origin_12_s) | all | Shotgun | — |
| **Verbundbogen** (compound_bow) | all | Special (Bogen) | — |
| **Verbundbogen Explosiv** (compound_bow_alt) | all | Explosiv (Bogen) | — |
| **RPK-16** | RU | MG | — |
| **RPK-16 Langrohr** (rpk16_long) | RU | MG | — |
| **CheyTac M200** | USA | Sniper (Großkaliber) | — |
| **M16A4 GL Edition** (m16a4_w_m203) | USA | Gewehr + Granatwerfer | ~2,3× Standard-AR |
| **M16A4 GL Edition** (m16a4_w_m203_g) | USA | Gewehr + Granatwerfer | ~2,3× Standard-AR |
| **G36 GL** (g36_w_ag36) | EU | Gewehr + Granatwerfer | ~2,3× Standard-AR |
| **G36 GL** (g36_w_ag36_g) | EU | Gewehr + Granatwerfer | ~2,3× Standard-AR |
| **AK-47 GL** (ak47_w_gp25) | RU | Gewehr + Granatwerfer | ~2,3× Standard-AR |
| **AK-47 GL** (ak47_w_gp25_g) | RU | Gewehr + Granatwerfer | ~2,3× Standard-AR |
| **AN-94 Salve** (an94_burst) | RU | Gewehr (Salven) | — |
| **QBZ-95** | all | Gewehr (inkl. Shotgun-Modus) | — |
| **QBZ-95 US** (qbz95_us) | all | Gewehr (inkl. Shotgun-Modus) | — |
| **QLZ-87** (qlz87_b) | RU | Explosiv (schwerer Granatwerfer) | — |
| **FHJ-01 FAE** | RU | Explosiv (Anti-Personen-Werfer) | — |

*„—" = Preis in Vanilla/Mod ggf. abweichend oder nicht fest gesetzt.*

---

## Technisches Balancing (XML-Modding)

Damit keine Fraktion die andere überrennt, bei **extremen Waffen** (z. B. SBL, QLZ-87, TTI-Schild, CheyTac) folgende Stellschrauben nutzen:

| Schritt | Wo | Zweck |
|--------|-----|--------|
| **1. Spawnhäufigkeit** | `<commonness value="…">` in .weapon | Standard: 0,2–0,5. **Elite-Waffen** (SBL, QLZ-87, CheyTac): z. B. **0,005** → seltene „Boss-Gegner“. |
| **2. Bewegungsmalus** | `<modifier class="speed" value="-0.35" />` (o. ä.) in .weapon | QLZ-87, TTI, FHJ-01: **−35 % bis −45 %** → tödliche Stärke, aber Trägheit und Flanken-Anfälligkeit. |
| **3. RP-Preise (Waffenkammer)** | `price="X"` | Standard-AR: 2–10 RP. **Elite** (QLZ-87, SBL): **200–350 RP** → Spieler muss erst Basen/Items sammeln. |
| **4. Fraktionslisten** | `.resources` | Waffen **nicht** in `common.resources` (sonst alle). Nur in **green_default.resources** (USA), **grey_default.resources** (EU), **brown_default.resources** (RU) eintragen. |

---

## Besonderheiten pro Waffe

### Neutral (all) – Support, Stealth, CQB

**Medizinisches Dartgewehr (taser_medic)**  
- **Spielerwaffe**, 120 RP, Waffenkammer für alle Fraktionen.  
- Heilt Verbündete per Dart; unterdrückt. Ein-Schuss-Magazin, hohe Genauigkeit.

**Sword (Sabre), Goldenes Messer**  
- Nahkampf für Stürmer / AI-Nahkampf-Trupps; für alle als Stealth-/Ninja-Option.

**Verbundbogen / Verbundbogen Explosiv (compound_bow, compound_bow_alt)**  
- Standard-Pfeil und Explosiv-Pfeil; von Stealth-Einheiten (z. B. Black-Ops-Westen) selten getragen.

**Origin-12 / Origin-12 S**  
- Schnelle 30-Schuss-Shotguns; neutrale CQB-Belohnung für Gebäude-Kämpfer.

**QBZ-95 / QBZ-95 US (qbz95, qbz95_us)**  
- Gewehr mit Shotgun-Modus; flexibel. **Hinweis:** AI schaltet Feuermodi nicht um – für Shotgun-AI ggf. separate .weapon mit Shotgun als Standardangriff.

---

### USA – High-Tech, Mobilität & Präzision

**XM25 / XM25 Schall (xm25, xm25_r)**  
- Luftdetonations-Granatwerfer (von „all“ zu USA); kontert Feinde hinter Deckung. Schall-Variante gedämpft.

**M16A4 Tactical (m16a4_support)**  
- M16A4 mit kleinem Schild; erhöhter Schutz im Vorwärtskampf.

**M16A4 GL Edition (m16a4_w_m203, m16a4_w_m203_g)**  
- M16A4 mit Unterlauf-Granatwerfer; ca. 2,3× Preis der Standard-M16A4.

**M1 Garand Modern**  
- Wuchtige 8-Schuss-DMR; hohe Killrate.

**CheyTac M200**  
- Schwerer Sniper, großkalibrig; hoher Schaden und Reichweite. **Balancing:** z. B. commonness 0,005.

**Camouflage Shield**  
- 80 RP, nur USA. Tarn-Schild für flankierende Stealth-Trupps; gleiche Deflekt-Logik wie andere Schilde.

---

### EU – Phalanx & Unterdrückungsfeuer

**TTI (Kampfschild)**  
- Macht EU-Infanterie zur „Wand“; Schutz vor Projektilen, Nahkampf/Sidearm möglich. **Balancing:** Speed-Malus −35 % bis −45 %, ggf. hoher RP-Preis.

**Truvelo AMis Suppressed**  
- Explosiv-Sniper, 6 Schuss, unterdrückt; seltener EU-„Bunkerbrecher“.

**ULTIMAX 100 / ULTIMAX 100 Magazin (ultimax, ultimax_m)**  
- Leichtes MG; Dauerfeuer-Thema EU. Magazin-Variante als Alternative.

**Gilboa DBR**  
- Starkes Gewehr, 30 Schuss, shotgun-ähnliche Munition; hohe Durchschlagkraft.

**G36 GL (g36_w_ag36, g36_w_ag36_g)**  
- G36 mit Granatwerfer; ca. 2,3× Preis des normalen Sturmgewehrs.

---

### RU – Flächenschaden & rohe Gewalt

**SBL (Kreissägen)**  
- Schießt Kreissägen; kontert EU-Schilde (Explosivschaden). **Balancing:** commonness sehr niedrig (z. B. 0,005), RP 200–350.

**QLZ-87 (qlz87_b)**  
- Schwerer Granatwerfer; kontert EU-Phalanx. **Balancing:** Speed-Malus −35 % bis −45 %, commonness niedrig, RP 200–350.

**FHJ-01 FAE**  
- Anti-Personen-Werfer, FAE/Staubexplosion; stark gegen Gruppen. **Balancing:** Speed-Malus, geringe Spawn-Rate.

**Tommy Gun**  
- MG, 50 Schuss, schnelle Feuerrate; ikonische RU-Sonderwaffe.

**RPK-16 / RPK-16 Langrohr (rpk16, rpk16_long)**  
- MG für RU; Langrohr-Variante präziser. Geeignet als AI-MG.

**AK-47 GL (ak47_w_gp25, ak47_w_gp25_g)**  
- AK-47 mit Granatwerfer; ca. 2,3× Preis der Standard-AK.

**AN-94 Salve (an94_burst)**  
- Salven-Waffe; kann als AI-Waffe mit geringer Wahrscheinlichkeit vergeben werden.
