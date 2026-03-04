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

## Tabelle: Fraktion · Waffenart · Preis · Finished

| Waffe | Fraktion | Waffenart | Preis (RP) | Finished |
|-------|----------|-----------|------------|----------|
| **Medizinisches Dartgewehr** (taser_medic) | all | Special (Heilen) | 120 | ✓ armory_common |
| **XM25** | USA | Explosiv (Granatwerfer, Luftdetonation) | 220 | ✓ armory_green |
| **XM25 Schall** (xm25_r) | USA | Explosiv (gedämpft) | 190 | ✓ nur USA |
| **TTI** (Kampfschild) | EU | Schild (Secondary) | 150 | ✓ nur EU |
| **Truvelo AMis Suppressed** | EU | Sniper (Explosiv, 6 Schuss) | — | ✓ armory_common |
| **ULTIMAX 100** | EU | MG | — | ✓ armory_common |
| **ULTIMAX 100 Magazin** (ultimax_m) | EU | MG | — | ✓ armory_common |
| **Sword** (Sabre) | all | Nahkampf (Melee) | 333 | ✓ Standard-Sekundär (default_secondaries) |
| **M16A4 Tactical** (m16a4_support) | USA | Gewehr (AR + Schild) | 62 | ✓ armory_green |
| **SBL** (Kreissägen) | all | Special (Explosiv, Slot-1-AT) | 300 | ✓ common/eod-Pools, nicht kaufbar |
| **Camouflage Shield** | USA | Schild | 80 | ✓ armory_green |
| **Goldenes Messer** | all | Nahkampf (Melee) | 1000 | ✓ armory_common (in_stock=0) |
| **Gilboa DBR** | EU | Gewehr (AR, Shotgun-Munition) | — | ✓ armory_common |
| **Tommy Gun** | RU | MG / SMG (50 Schuss) | nicht kaufbar | ✓ nur RU Support-AI (brown_mgs) |
| **M1 Garand Modern** | USA | DMR (8 Schuss) | — | ✓ armory_common |
| **Origin-12** | all | Shotgun (30 Schuss) | — | ✓ armory_common |
| **Origin-12 S** (origin_12_s) | all | Shotgun | — | ✓ armory_common |
| **Verbundbogen** (compound_bow) | all | Special (Bogen) | — | ✓ armory_common |
| **Verbundbogen Explosiv** (compound_bow_alt) | all | Explosiv (Bogen) | — | ✓ armory_common |
| **RPK-16** | RU | MG (74 Mag) | 216 | ✓ armory_brown + brown_mgs |
| **RPK-16 Langrohr** (rpk16_long) | RU | MG (96 Mag) | 256 | ✓ nur Miniboss-Drop (nicht kaufbar) |
| **CheyTac M200** | USA | Sniper (Großkaliber) | — | ✓ armory_common |
| **M16A4 GL** (m16a4_w_m203) | USA | Gewehr + Granatwerfer | 80 | ✓ armory_green |
| **M16A4 GL** (m16a4_w_m203_g) | USA | Gewehr + Granatwerfer | 80 | ✓ armory_green |
| **G36 GL** (g36_w_ag36) | EU | Gewehr + Granatwerfer | 80 | ✓ armory_grey |
| **G36 GL** (g36_w_ag36_g) | EU | Gewehr + Granatwerfer | 80 | ✓ armory_grey |
| **AK-47 GL** (ak47_w_gp25) | RU | Gewehr + Granatwerfer | 75 | ✓ armory_brown |
| **AK-47 GL** (ak47_w_gp25_g) | RU | Gewehr + Granatwerfer | 75 | ✓ armory_brown |
| **AN-94 Salve** (an94_burst) | RU | Gewehr (Salven) | 250 | ✓ armory_brown |
| **QBZ-95** | all | Gewehr (inkl. Shotgun-Modus) | — | ✓ armory_common |
| **QBZ-95 US** (qbz95_us) | all | Gewehr (inkl. Shotgun-Modus) | — | ✓ armory_common |
| **QLZ-87** (qlz87_b) | RU | Explosiv (schwerer Granatwerfer) | — | ✓ armory_common |
| **FHJ-01 FAE** | RU | Explosiv (Anti-Personen-Werfer) | 45 | ✓ armory_common |

*„—" = Preis in Vanilla/Mod ggf. abweichend oder nicht fest gesetzt. **Finished** = Implementierung (XML, Armory, Doku) abgeschlossen.*

---

## Technisches Balancing (XML-Modding)

Damit keine Fraktion die andere überrennt, bei **extremen Waffen** (z. B. SBL, QLZ-87, TTI-Schild, CheyTac) folgende Stellschrauben nutzen:

| Schritt | Wo | Zweck |
|--------|-----|--------|
| **1. Spawnhäufigkeit** | `<commonness value="…">` in .weapon | Standard: 0,2–0,5. **Elite-Waffen** (SBL, QLZ-87, CheyTac): z. B. **0,005** → seltene „Boss-Gegner“. |
| **2. Bewegungsmalus** | `<modifier class="speed" value="-0.35" />` (o. ä.) in .weapon | QLZ-87, TTI, FHJ-01: **−35 % bis −45 %** → tödliche Stärke, aber Trägheit und Flanken-Anfälligkeit. |
| **3. RP-Preise (Waffenkammer)** | `price="X"` | Standard-AR: 2–10 RP. **Elite** (QLZ-87, SBL): **200–350 RP** → Spieler muss erst Basen/Items sammeln. |
| **4. Fraktionslisten** | `.resources` | Waffen **nicht** in `common.resources` (sonst alle). Nur in **green_default.resources** (USA), **grey_default.resources** (EU), **brown_default.resources** (RU) eintragen. **Waffenkammer:** USA-only = `armory_green.resources` (z. B. xm25_r), EU-only = `armory_grey.resources` (z. B. tti); alle anderen = `armory_common.resources`. |

---

## Besonderheiten pro Waffe

### Neutral (all) – Support, Stealth, CQB

**Medizinisches Dartgewehr (taser_medic)**  
- **Spielerwaffe**, 120 RP, Waffenkammer für alle Fraktionen.  
- Heilt Verbündete per Dart; unterdrückt. Ein-Schuss-Magazin, hohe Genauigkeit.

**Sword (Sabre), Goldenes Messer**  
- **Sabre:** **Standard-Sekundärwaffe** für Default-Soldaten (default/default_ai): `default_secondaries.resources` (nur sabre) wird in brown/grey/green vor den fraktionsspezifischen Secondaries geladen; commonness 0,15. Nahkampf für alle als Stealth-/Ninja-Option.
- Goldenes Messer: Prestige-Melee, 1000 RP.

**Verbundbogen / Verbundbogen Explosiv (compound_bow, compound_bow_alt)**  
- Standard-Pfeil und Explosiv-Pfeil; von Stealth-Einheiten (z. B. Black-Ops-Westen) selten getragen.

**Origin-12 / Origin-12 S**  
- Schnelle 30-Schuss-Shotguns; neutrale CQB-Belohnung für Gebäude-Kämpfer.

**QBZ-95 / QBZ-95 US (qbz95, qbz95_us)**  
- Gewehr mit Shotgun-Modus; flexibel. **Hinweis:** AI schaltet Feuermodi nicht um – für Shotgun-AI ggf. separate .weapon mit Shotgun als Standardangriff.

---

### USA – High-Tech, Mobilität & Präzision

**XM25 / XM25 Schall (xm25, xm25_r)**  
- Luftdetonations-Granatwerfer, USA. XM25 (220 RP) in armory_common; **XM25 Schall** (190 RP) nur in **USA-Waffenkammer** (armory_green.resources). Schall-Variante gedämpft.

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
- EU, **150 RP**, nur **EU-Waffenkammer** (armory_grey.resources). **Secondary** (Slot 1). Selten bis sehr selten (commonness 0,005). KI: Support Troop, Default, eod_light, eod, cover_troop. Macht EU-Infanterie zur „Wand“; Schutz vor Projektilen, Nahkampf/Sidearm möglich. **Balancing:** Speed-Malus −35 % bis −45 %, ggf. hoher RP-Preis.

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
- Schießt Kreissägen; kontert EU-Schilde (Explosivschaden). **Pools:** common.resources, common_eod_light.resources, common_eod.resources (Slot-1-AT). **Balancing:** commonness 0 (nur Stash/Boss/EOD-Pool), RP 300.

**QLZ-87 (qlz87_b)**  
- Schwerer Granatwerfer; kontert EU-Phalanx. **Balancing:** Speed-Malus −35 % bis −45 %, commonness niedrig, RP 200–350.

**FHJ-01 FAE**  
- Anti-Personen-Werfer, FAE/Staubexplosion; stark gegen Gruppen. **Balancing:** Speed-Malus, geringe Spawn-Rate.

**Tommy Gun**  
- RU, **nicht in der Waffenkammer** (in_stock=0). Russische MG-Waffe im **seltenen Bereich** (commonness 0,02) **nur für RU Support Troop AI** (brown_mgs.resources, brown.xml support). 50 Schuss, schnelle Feuerrate.

**RPK-16 / RPK-16 Langrohr (rpk16, rpk16_long)**  
- **RPK-16:** 74 Mag, Waffenkammer (216 RP) + KI (brown_mgs). **RPK-16 Langrohr:** 96 Mag, nur **Brown-Miniboss-Drop** (brown_miniboss.resources), nicht kaufbar; 256 RP Referenz (+40 vs. Kurzrohr).

**AK-47 GL (ak47_w_gp25, ak47_w_gp25_g)**  
- AK-47 mit Granatwerfer; ca. 2,3× Preis der Standard-AK.

**AN-94 Salve (an94_burst)**  
- Salven-Waffe; kann als AI-Waffe mit geringer Wahrscheinlichkeit vergeben werden.
