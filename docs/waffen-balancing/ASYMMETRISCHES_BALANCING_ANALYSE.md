# Asymmetrisches Waffen-Balancing: Analyse & Stats (Broken Alliances)

Technische Analyse der Stash-Waffen mit **Fraktionsidentität**, **Engine-Parametern** und **Vergleichstabelle** für faire, asymmetrische Balance.

---

<denkprozess>

## 1. Kern-Identität pro Fraktion

- **USA (Green):** Präzision & Mobilität. **Identität:** Gezielte Einzelschüsse, Reichweite, Luftdetonation, wenig Dauerfeuer. Spieler sollen sich bewegen, Deckung nutzen, Ziele ausschalten – nicht im Nahkampf-Chaos gewinnen.
- **EU (Grey):** Phalanx & Unterdrückung. **Identität:** Schilde, hohe Feuerrate/MG-Dauerfeuer, schwer zu knacken durch Projektilwaffen. Schwäche: Explosiv durchdringt Schilde → RU und Explosiv-Nischen kontern.
- **RU (Brown):** Fläche & rohe Gewalt. **Identität:** Explosiv, hohe Feuerrate (SMG/MG), Salven, Chaos. Stärke gegen EU-Phalanx; Schwäche: auf offener Fläche anfällig für US-Sniper/Präzision.
- **Neutral (all):** Utility, Stealth, CQB. **Identität:** Kein Fraktions-Bonus; Heilen, Nahkampf, Shotguns, Bogen, flexible Allrounder. Ergänzt alle Fraktionen ohne eine zu bevorzugen.

## 2. Verteilungsregeln

- **Präzisionswaffen (DMR, Sniper, gezielte AR)** → USA (evtl. eine EU-Sniper-Ausnahme als „Bunkerbrecher“).
- **Schilde, MG, Dauerfeuer-AR** → EU.
- **Explosiv (Granatwerfer, SBL, FAE), Salven-AR, MG mit hoher Feuerrate** → RU.
- **Heilen, Melee, Shotgun, Bogen, Hybrid-AR** → Neutral, sofern nicht fraktionsspezifisch gebraucht.

## 3. Skalierung der RWR-Engine-Parameter für faire Asymmetrie

- **retrigger_time** (*Zeit in Sekunden zwischen zwei Schüssen*): Niedrig = hohe Feuerrate (EU MG, RU Tommy/AN-94). Hoch = Präzision/USA (M200, XM25, M1 Garand). **Fairness:** DPS über Zeit angleichen – USA höherer Einzelschaden pro Treffer, RU/EU mehr Treffer bei geringerem kill_prob.
- **sustained_fire_diminish_rate** (*wie schnell die Genauigkeit bei Dauerfeuer abnimmt*): Höher = Streuung wächst schnell (Tommy, M16 Support) → Nahkampf/Unterdrückung. Niedrig/negativ = MG behält Genauigkeit (Ultimax). USA-AR: mittel bis hoch, damit Burst-Feuer belohnt wird.
- **spread_range** (*Streuung in RWR-Einheiten*): USA-Sniper/DMR niedrig; EU/RU MG und Shotguns höher. **Fairness:** Präzision kostet Feuerrate, Feuerrate kostet Präzision.
- **kill_probability** (*Kill-Chance pro Treffer, typ. 0,5–1,5*): USA-DMR/Sniper höher (1,05–1,5); AR/MG 0,5–0,65. Elite-Waffen (M200, SBL, QLZ) durch **commonness**, **speed modifier** und **RP-Preis** zügeln, nicht durch übermäßiges kill_prob.

**Formel-Gedanke:** `Effektive DPS ≈ (1/retrigger_time) × kill_prob × (1 - spread_penalty)`. Fraktionen sollen bei vergleichbarem Skill und Kontext auf ähnliche „effektive DPS“ kommen, aber über unterschiedliche Wege (Burst vs. Dauerfeuer vs. Einzelschuss vs. Explosiv).

</denkprozess>

---

## Fraktionsanalyse

### USA (Green)
- **Identität & Spielstil:** High-Tech, Mobilität, Präzision. Gezielte Ausschaltung, Luftdetonation, taktische Manöver.
- **Pros:** Hohe Einzelschuss-Killrate (M200, M1 Garand), Luftdetonation (XM25) gegen Deckung, Camouflage Shield für Flanken, M16 GL für Flexibilität.
- **Contras:** Anfällig im Nahkampf (wenig CQB-Spezialwaffen), AR-Standard kill_prob moderat; Sniper/M200 durch lange retrigger_time und ggf. commonness begrenzt.

### EU (Grey)
- **Identität & Spielstil:** Schwer gepanzerte Phalanx, Unterdrückungsfeuer, schwer zu knacken.
- **Pros:** TTI-Schild + Sidearm, ULTIMAX Dauerfeuer mit guter Genauigkeit (niedrige/negative diminish_rate), Truvelo Explosiv-Sniper gegen Bunker, Gilboa DBR hohe Durchschlagkraft.
- **Contras:** Schilde blocken keinen Explosivschaden (RU kontert); Speed-Malus am TTI; Explosiv-Optionen begrenzt.

### RU (Brown)
- **Identität & Spielstil:** Flächenschaden, Chaos, rohe Gewalt; kontert EU-Phalanx.
- **Pros:** SBL, QLZ-87, FHJ-01 gegen Schilde/Gruppen; Tommy Gun hohe Feuerrate; RPK-16/Long starke MG; AN-94 Salve; AK GL.
- **Contras:** Auf offener Fläche Ziele für US-Sniper; schwere Waffen mit Speed-Malus (QLZ, FHJ, ggf. SBL); Elite-Waffen durch commonness/RP begrenzt.

### Neutral (all)
- **Identität & Spielstil:** Utility, Stealth, CQB für alle Fraktionen.
- **Pros:** Heilen (taser_medic), Melee (Sabre, Golden Knife), Shotguns (Origin-12), Bogen (Stealth), QBZ-95 flexibel.
- **Contras:** Kein Fraktions-Bonus; keine exklusiven „Killer“-Nischen – ergänzend.

---

## Balancing-Tabelle (Stash-Waffen)

| Waffe | Fraktion | Preis (RP) | Uniqueness | Retrigger Time | Fire Diminish Rate | Accuracy / Spread | Kill Rate | Pros & Contras (Kurz) |
|-------|----------|------------|------------|----------------|--------------------|-------------------|-----------|------------------------|
| **taser_medic** | all | 120 | Heilen, unterdrückt | −1 (Einzelschuss) | 0,65 | hoch (0,95 factor) | N/A (Heil) | Pro: Support. Contra: 1 Schuss, kein Kill. |
| **XM25** | USA | — | Luftdetonation | 1,8 | 0,5 | — | Explosiv | Pro: Deckungskonter. Contra: Magazin 4, langsam. |
| **XM25 Schall** (xm25_r) | USA | — | wie XM25, gedämpft | 1,7 | 0,5 | — | Explosiv | Pro: Stealth. Contra: wie XM25. |
| **TTI** (Kampfschild) | EU | — | Schild + 6 Projektile | −1 | 0,9 | 0,7 factor | 0,6 | Pro: Phalanx. Contra: Speed −35 %, Explo durchdringt. |
| **Truvelo AMis** | EU | 648 | Explosiv-Sniper, 6 Schuss, suppressed | −1 | 0,7 | sehr hoch (0,95 crouch) | Explosiv | Pro: Bunkerbrecher. Contra: Einzelschuss, teuer. |
| **ULTIMAX 100** | EU | 800 | MG, 100 Schuss | 0,09 | −1,2 | 0,8 factor | 0,6 | Pro: Dauerfeuer, Genauigkeit stabil. Contra: Preis. |
| **ULTIMAX 100 Magazin** (ultimax_m) | EU | 800 | MG, 30 Schuss, Wechsel zu Trommel | 0,1 | −1,35 | 0,85 factor | 0,6 | Pro: Schneller Wechsel. Contra: wie Ultimax. |
| **Sabre** (Sword) | all | — | Melee, Reichweite 3,5 | N/A (Melee) | N/A | N/A | success 4,0 | Pro: Stealth/Nahkampf. Contra: Nur Nahbereich. |
| **M16A4 Tactical** (m16a4_support) | USA | 90 | AR + Schild, 100 Schuss | 0,113 | 1,40 | stance 0,8–0,94 | 0,5 | Pro: Vorwärtskampf. Contra: Kein Stehen-Feuer, Speed −8 %. |
| **SBL** (Kreissägen) | RU | 300 | Explosiv, kontert Schilde | −1 | 1 | — | Explosiv | Pro: Anti-Phalanx. Contra: commonness/RP, 1 Schuss. |
| **Camouflage Shield** | USA | 80 | Tarn-Schild | N/A (Schild) | N/A | N/A | — | Pro: Flanken-Stealth. Contra: Nur Deflekt, kein Explo-Schutz. |
| **Goldenes Messer** | all | — | Melee, suppressed | 1,0 | 1,0 | 0 spread | N/A (Melee) | Pro: Stealth. Contra: Nahkampf only. |
| **Gilboa DBR** | EU | 150 | AR, 2 Projektile/Schuss, 30 Schuss | 0,15 | 1,2 | 1,0 factor | 0,5 | Pro: Durchschlag. Contra: Speed −5 %. |
| **Tommy Gun** | RU | 200 | MG/SMG, 50 Schuss | 0,0825 | 3,0 | 0,9 factor | 0,52 | Pro: Hohe Feuerrate. Contra: Streuung wächst schnell. |
| **M1 Garand Modern** | USA | 200 | DMR, 8 Schuss | 0,28 | 2,8 | 0,285 spread | 1,05 | Pro: Hoher Einzelschaden. Contra: Magazin klein, Streuung. |
| **Origin-12** | all | 210 | Shotgun, 30 Schuss, 3 Projektile | 0,18 | 1,2 | 0,8 factor | 0,55 | Pro: CQB. Contra: Speed −8 %, Nahbereich. |
| **Origin-12 S** (origin_12_s) | all | — | wie Origin-12, Variante | 0,18 | 1,0 | — | 0,55 | Pro/Contra: wie Origin-12. |
| **Verbundbogen** (compound_bow) | all | 215 | Bogen, stealth, 1 Pfeil | −1 | 0,5 | 1,0 standing | 1,5 | Pro: Leise, OHK-Potenzial. Contra: Langsam, beweglichkeitsabhängig. |
| **Verbundbogen Explosiv** (compound_bow_alt) | all | 215 | Explosiv-Pfeil | −1 | 0,5 | 0,95 factor | Explosiv | Pro: Flächenschaden. Contra: Speed −11 %, langsam. |
| **RPK-16** | RU | — | MG | 0,085 | 0,9 | 0,19 spread | 0,55 | Pro: Gute Feuerrate. Contra: Streuung. |
| **RPK-16 Langrohr** (rpk16_long) | RU | — | MG, präziser | 0,085 | 0,7 | 0,25 spread | 0,65 | Pro: Höherer Kill, etwas stabiler. Contra: Mehr Spread. |
| **CheyTac M200** | USA | — | Sniper Großkaliber | 2,2 | 0,5 | 0,8 spread | 1,5 | Pro: OHK-Potenzial. Contra: commonness, sehr langsam. |
| **M16A4 GL** (m16a4_w_m203) | USA | ~2,3× AR | AR + GL | 0,113 | 1,40 | — | 0,5 | Pro: Flexibilität. Contra: Preis, GL getrennt. |
| **M16A4 GL** (m16a4_w_m203_g) | USA | ~2,3× AR | GL-Fokus | −1 (GL) | 0,2 | 0,04 | — | Pro: GL präzise. Contra: GL-Modus. |
| **G36 GL** (g36_w_ag36) | EU | ~2,3× AR | AR + GL | 0,110 | 1,38 | — | 0,5 | Pro: wie M16 GL. Contra: wie M16 GL. |
| **G36 GL** (g36_w_ag36_g) | EU | ~2,3× AR | GL-Fokus | −1 (GL) | 0,2 | 0,04 | — | Pro/Contra: wie M16 GL-G. |
| **AK-47 GL** (ak47_w_gp25) | RU | ~2,3× AR | AR + GL | 0,123 | 1,2 | — | 0,55 | Pro: RU-Flexibilität. Contra: wie andere GL. |
| **AK-47 GL** (ak47_w_gp25_g) | RU | ~2,3× AR | GL-Fokus | −1 (GL) | 0,2 | 0,04 | — | Pro/Contra: wie andere GL-G. |
| **AN-94 Salve** (an94_burst) | RU | — | Salven-AR | 0,035 / 0,1 burst | 0,60 | — | 0,5 | Pro: Sehr hohe Burst-Feuerrate. Contra: Salven-Disziplin. |
| **QBZ-95** | all | — | AR + Shotgun-Modus | 0,12 | 1,3 | 0,15 spread | 0,53 | Pro: Flexibel. Contra: AI wechselt Modus nicht. |
| **QBZ-95 US** (qbz95_us) | all | — | wie QBZ-95 | 0,18 | 0,8 | — | 0,62 | Pro: Etwas höherer Kill. Contra: Langsamer. |
| **QLZ-87** (qlz87_b) | RU | — | Schwerer Granatwerfer | 0,45 | 0,4 | 0,20 spread | Explosiv | Pro: Anti-Phalanx. Contra: Speed-Malus, commonness, RP. |
| **FHJ-01 FAE** | RU | — | Anti-Personen-Werfer, FAE | −1 | 0,8 | — | Explosiv | Pro: Gruppen. Contra: Speed, Magazin 1, Einzelschuss. |

*Hinweise:*  
- **Retrigger −1** = Einzelschuss / manuell (z. B. Repetierer, Granatwerfer).  
- **Fire Diminish Rate negativ** = Genauigkeit verbessert sich bei Dauerfeuer (MG).  
- **Kill Rate** = `kill_probability` wo vorhanden; Explosivwaffen = „Explosiv“ (projektilseitig).  
- **—** = Wert in .weapon nicht explizit oder aus Basis-Datei; Preis „—“ = Mod/Vanilla abweichend oder nicht fest gesetzt.

---

## Nächste Schritte (Stellschrauben)

- **USA:** M200/XM25 commonness niedrig (z. B. 0,005); Camouflage Shield Preis 80 RP prüfen.  
- **EU:** TTI speed modifier (−35 %) und RP/ commonness bestätigen; ULTIMAX-Preis vs. Stärke abwägen.  
- **RU:** SBL, QLZ-87, FHJ-01 commonness + RP (200–350) + speed modifier konsistent setzen.  
- **Neutral:** taser_medic 120 RP (Dokumentation); Origin-12 / Bogen-Preise einheitlich dokumentieren.
