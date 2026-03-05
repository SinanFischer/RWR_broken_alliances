# Commonness-Tiers & KI-Spawn (Stash-Waffen)

**Zweck:** Deterministische Spawn-Raten für alle Stash-Waffen nach dem 4-Tier-System. **commonness** steuert ausschließlich KI-Spawn und Loot-Drops; Shop-Verfügbarkeit bleibt über `in_stock="1"` und `price` in den `.weapon`-Dateien.

---

## 0. Vanilla-Referenz (verbindlich)

**Quelle:** `vanilla/weapons/*.weapon` (RWR-Basis). Die KI-Waffenpools pro Rolle kommen aus `factions/` (z. B. `green_primaries.resources`, `common_snipers.resources`, `common_grenadier.resources`, `green_miniboss.resources`); die **commonness** in den `.weapon`-Dateien gewichtet innerhalb dieser Pools. Diese Vanilla-Werte sind der Referenzrahmen; alle **Mod-Spezialwaffen** (Stash-Waffen) müssen **niedrigere** Commonness haben als die Vanilla-Uniques der gleichen Kategorie (seltener spawnen).

## Waffen Commonness: Einteilung in Wörter + Bereiche

| Tier (Wort) | Commonness-Bereich | Beschreibung |
|-------------|--------------------|--------------|
| **basic** | **0,15 – 0,2** | Basis-Waffe der Einheiten (z. B. M16, G36, AK-47). |
| **häufig** | **0,05 – 0,15** | Normale Spezialwaffe; kommt seltener vor als basic, aber noch oft (z. B. schwere MG, DMR, Spezial-AR). |
| **selten** | **0,01 – 0,05** | Bessere Waffe; limitierte Spawn-Rate (z. B. CQB, Shotgun, Schild, Bogen). |
| **sehr selten** | **0,002 – 0,01** | Starke Waffe; taktische Zerstörer (z. B. GL, Explosiv). |
| **episch** | **0,0001 – 0,002** | Elite-Waffe; kommt sehr selten vor (z. B. Truvelo, M200, GL-Varianten). |
| **legendär** | **< 0,0001** | Sehr starke Waffe; Ultra-Elite, fast nur Boss-/Offiziers-Drops (z. B. QLZ-87, SBL, Golden Knife). | 


### 0.1 Basis-Waffen (Standard-Infanterie)

| Waffe | Commonness | Rolle |
|-------|------------|--------|
| M16A4 | **0.2** | Basis-AR USA |
| G36 | **0.2** | Basis-AR EU |
| AK-47 | **0.2** | Basis-AR RU |

→ **Tier-1-Obergrenze:** 0.2. Mod-Stash enthält keine Basis-ARs; alle Stash-Waffen sind Spezialfälle.

### 0.2 Vanilla-Uniques (Spezialwaffen im Basis-Spiel)

| Waffe | Commonness | Kategorie |
|-------|------------|-----------|
| M240 | **0.05** | Schweres MG |
| PKM | **0.05** | Schweres MG |
| shamshir_mg | **0.05** | MG |
| Javelin | **0.02** | AT |
| Mossberg | **0.01** | Shotgun / CQB |
| SPAS-12 | **0.01** | Shotgun |
| M24_A2 | **0.01** | Sniper (leicht) |
| M79 | **0.002** | Explosiv (Granatwerfer) |
| Model_29 (44 Magnum) | **0.002** | Explosiv / Sidearm |
| F2000 | **0.0006** | Spezial-AR |
| FAMAS G1 | **0.0003** | Spezial-AR |
| Steyr AUG | **0.0002** | Spezial-AR |
| Jackhammer | **0.0001** | CQB-Elite (Shotgun) |
| Stoner62 | **0.00002** | LMG Ultra-Elite |

### 0.3 Regel: Mod-Spezialwaffen seltener als Vanilla-Uniques

- **Alle** Stash-Spezialwaffen, die wir hinzufügen, müssen eine **niedrigere** Commonness haben als der jeweilige Vanilla-Unique der gleichen Kategorie.
- Konkret:
  - Schwere MG (z. B. ULTIMAX, RPK-16): **< 0.05** (Vanilla M240/PKM = 0.05) → z. B. **0.03** oder **0.02**.
  - Shotgun/CQB (Origin-12, TTI, Bogen): **≤ 0.01** (Vanilla Mossberg/SPAS = 0.01). **Ausnahme Sabre:** 0.15 als Standard-Sekundärwaffe für Default-Soldaten (siehe unten).
  - Explosiv/GL (XM25, alle GL-Varianten): **< 0.002** (Vanilla M79 = 0.002) → z. B. **0.001**.
  - Spezial-AR/DMR (M16 Support, M1 Garand, Gilboa, Tommy, AN-94, QBZ-95): **< 0.0002** (Vanilla AUG = 0.0002) → z. B. **0.0001** oder **0.00015**.
  - Elite (Truvelo, M200, QLZ-87, SBL, Golden Knife): **≤ 0.0001** (Vanilla Jackhammer = 0.0001) → **0.0001** oder **0.00005**.

Die folgende Mod-Tabelle wurde vor dieser Vanilla-Referenz erstellt; Werte mit **0.1** bzw. **0.05** für Tier-2-Spezialisten liegen **über** den Vanilla-Uniques (AUG 0.0002, M240 0.05). Bei Implementierung die Commonness-Werte **unter** die Referenz-Obergrenzen anpassen (siehe Abschnitt 3).

---

## 1. Denkprozess

<denkprozess>

**Grundlage:** Alle 32 Einträge aus `armory_common.resources`; Preis und Rolle aus `STASH_RP_PREISLISTE.md` und `.weapon`-Dateien.

- **Tier 1 (0.2):** Keine Stash-Waffe ist reines Standard-Infanterie-Rückgrat – die Basis-ARs (G36, M16A4, AK-47) sind nicht in der Stash. Stash-AR mit Schild (m16a4_support) ist bewusst gehobene Variante → **Tier 2**.

- **Tier 2 – Spezialisten (0.1 / 0.05 / 0.01):**
  - **0.1** für LMG/DMR/Spezial-AR: m16a4_support (AR+Schild), m1_garand_m (DMR), gilboa_dbr (AR Shotgun-Munition), gun_tommy (50 Schuss), an94_burst (Salven), qbz95/qbz95_us (Flex-AR). Sie prägen das Gefecht, aber limitiert.
  - **0.05** für schwere MGs: ultimax, ultimax_m, rpk16 (Referenz: M240/PKM/ULTIMAX). **rpk16_long** nur Brown-Miniboss (brown_miniboss.resources), nicht im KI-MG-Pool.
  - **0.15** für **Sabre (Standard-Sekundärwaffe):** Default-Soldaten (default/default_ai) laden `default_secondaries.resources` (nur sabre) vor den fraktionsspezifischen Secondaries; commonness 0.15 macht ihn zur bevorzugten Slot-1-Waffe.
  - **0.01** für CQB/Shotgun/Schild/Utility: origin_12, origin_12_s (Shotgun), tti (Schild+CQB), camo_shield (Schild), compound_bow, compound_bow_alt (Bogen), taser_medic (Heilen), fhj01 (FAE Utility). Schrotflinten und CQB strikt 0.01.

- **Tier 3 – Taktische Zerstörung (0.002):**
  - Explosiv, die das Spielgefühl sofort verändern: **xm25** (Luftdetonation), alle **GL-Varianten** (m16a4_w_m203, m16a4_w_m203_g, g36_w_ag36, g36_w_ag36_g, ak47_w_gp25, ak47_w_gp25_g). Vanilla-Referenz M79/44 Magnum; Mod-Referenz XM25. Nur ein Bruchteil der KI darf diese haben.

- **Tier 4 – Elite/Bosse (0.0001 bis 0.0005):**
  - **0.0005:** truvelo_amris (Explosiv-Sniper, 6 Schuss).
  - **0.0002:** m200 (CheyTac, maximaler Schaden/Reichweite).
  - **0.0001:** qlz87_b (schwerer Granatwerfer), sbl (Kreissägen), golden_knife (Prestige-Melee). Extreme Game-Breaker, fast nur Offiziers-Drops.

**KI-Tags:** Damit die KI eine Waffe aufheben kann, muss ein passender Tag (assault, sniper, bazooka, cqb, machinegun o.ä.) gesetzt sein. SBL hat aktuell nur `denied_in_penalty` → für KI-Spawn muss zusätzlich z. B. `bazooka` gesetzt werden. camo_shield erbt von riot_shield_base ohne Tag → für KI-Spawn optional `cqb` in der abgeleiteten Waffe ergänzen. ultimax/ultimax_m nutzen `machine gun` (Leerzeichen) – so in Datei belassen, sofern Engine das akzeptiert; andernfalls auf `machinegun` prüfen.

**Preis:** Alle Preise aus der bestehenden Stash-Preisliste übernommen; keine Änderung an `price` in den `.weapon`-Dateien für dieses Dokument. Commonness und Preis sind entkoppelt (commonness = Spawngewicht, price = Shop).

</denkprozess>

---

## 2. Ergebnis-Tabelle (Mod-Stash-Waffen)

**Hinweis:** Einige Commonness-Werte liegen noch **über** den Vanilla-Uniques (Abschnitt 0). Vor Implementierung: Werte gemäß Abschnitt 0.3 **absenken** (Mod-Spezialwaffen seltener als Vanilla-Uniques).

| Waffe | Fraktion | KI-Tag | Tier | Commonness | Preis (RP) | Begründung |
|-------|----------|--------|------|------------|------------|------------|
| taser_medic | all | assault | 2 | 0.000001 | 20 | Utility Heilen; bewusst extrem selten, kein Kampf-Fokus. |
| xm25 | USA | assault | 3 | 0.002 | 220 | Explosiv Luftdetonation; taktische Zerstörung, begrenzt Magazin. |
| xm25_r | USA | assault | 3 | (nur Stash) | 190 | Nur USA-Waffenkammer (armory_green); gedämpft, nicht im KI-Pool. |
| tti | EU | cqb | 2 | 0.005 | 150 | Schild + Secondary; nur EU-Waffenkammer (armory_grey); Support, Default, eod_light, eod, cover_troop. |
| truvelo_amris | EU | sniper | 4 | 0.0005 | 648 | Elite-Explosiv-Sniper; nur Bruchteil darf haben. |
| ultimax | EU | machine gun | 2 | 0.05 | 800 | Schwer-MG; 0.05 für schwere MGs. |
| ultimax_m | EU | machine gun | 2 | 0.05 | 800 | Wie ultimax, Magazin-Variante. |
| sabre | all | cqb | 2 | **0.15** | 333 | **Standard-Sekundärwaffe** für Default-Soldaten (`default_secondaries.resources`); CQB-Tag, häufig in Slot 1. |
| m16a4_support | USA | assault | 2 | 0.1 | 90 | AR+Schild Spezialist; LMG/DMR-Level Spawnrate. |
| sbl | all | bazooka* | 4 | 0 | 300 | Kreissägen Elite; commonness 0 = nur Stash/Boss. **Pools:** common.resources, common_eod_light.resources, common_eod.resources (Slot-1-AT). *Tag optional für KI-Spawn. |
| camo_shield | USA | (cqb)* | 2 | 0.01 | 100 | Schild; *Tag in camo_shield prüfen/ergänzen für KI. |
| golden_knife | all | cqb | 4 | 0.0001 | 1000 | Prestige-Melee; Elite-Band. |
| gilboa_dbr | EU | assault | 2 | 0.1 | 150 | Spezial-AR Shotgun-Munition; Spezialist. |
| gun_tommy | RU | assault | 2 | 0.02 | — | **Nicht in Waffenkammer.** Nur RU Support-AI (brown_mgs), selten. |
| m1_garand_m | USA | assault | 2 | 0.1 | 200 | DMR 8 Schuss; 0.1 für DMR. |
| origin_12 | all | cqb | **sehr selten** | **0.005** | 210 | CQB-Shotgun 30 Schuss; EOD + Special Forces Pools (common_eod, common_specialforces). |
| origin_12_s | all | assault | **sehr selten** | **0.005** | 210 | Wie Origin-12, Variante (next_in_chain). |
| compound_bow | all | stealth | 2 | 0.01 | 215 | Bogen; Spezial selten (KI nutzt Stealth nicht aktiv). |
| compound_bow_alt | all | assault | 2 | 0.01 | 215 | Bogen Explosiv; wie Bogen. |
| rpk16 | RU | machinegun | 2 | 0.05 | 216 | Leicht-MG 74 Mag; Waffenkammer + brown_mgs. |
| rpk16_long | RU | machinegun | — | **0.04** | 256 | RPK-16 Langrohr; **nur Brown-Miniboss-Drop**. commonness 0.04 = moderate Chance (~20 %) im Miniboss-Pool; nicht kaufbar. |
| m200 | USA | sniper | 4 | 0.0002 | 880 | CheyTac Elite-Sniper; fest 0.0002. |
| m16a4_w_m203 | USA | assault | 3 | 0.002 | 250 | GL; Tier 3 taktische Zerstörung. |
| m16a4_w_m203_g | USA | assault | 3 | 0.002 | 250 | GL Granat-Variante. |
| g36_w_ag36 | EU | assault | 3 | 0.002 | 250 | GL; Tier 3. |
| g36_w_ag36_g | EU | assault | 3 | 0.002 | 250 | GL Granat-Variante. |
| ak47_w_gp25 | RU | assault | 3 | 0.002 | 250 | GL; Tier 3. |
| ak47_w_gp25_g | RU | assault | 3 | 0.002 | 250 | GL Granat-Variante. |
| an94_burst | RU | assault | 2 | 0.1 | 250 | Salven-AR; Spezialist 0.1. |
| qbz95 | all | assault | 2 | 0.1 | 280 | Flex-AR + Shotgun-Modus; Spezialist. |
| qbz95_us | all | cqb | 2 | 0.1 | 280 | Wie QBZ-95, US-Variante. |
| qlz87_b | RU | machinegun | 4 | 0.0001 | 379 | Schwerer Granatwerfer; Elite 0.0001. |
| fhj01 | RU | bazooka | 2 | 0.01 | 20 | FAE Utility; Nischen-Explosiv, limitiert. |

---

## 3. Nächste Schritte (Implementierung)

- **Commonness an Vanilla-Referenz anpassen:** Vor dem Eintragen in die `.weapon`-Dateien die Tabellenwerte (Abschnitt 2) mit Abschnitt 0.3 abgleichen. Spezialwaffen **strikt unter** den Vanilla-Uniques (z. B. Tier-2-Spezialisten nicht 0.1, sondern ≤ 0.0002; schwere MG nicht 0.05, sondern < 0.05).
- **commonness** in jeder `.weapon`-Datei auf den **angepassten** Wert setzen (Ersetzen von `0` bzw. `0.0` wo KI-Spawn gewünscht; bei **0** bleibt die Waffe reine Stash-Waffe ohne KI-Drop).
- **SBL:** In `sbl.weapon` commonness 0 (nur Stash/Boss). Ressourcen: **common.resources**, **common_eod_light.resources**, **common_eod.resources** (Slot-1-AT). Optional `<tag name="bazooka" />` für KI-Spawn.
- **Sabre:** **Standard-Sekundärwaffe** für Default-Soldaten: `factions/default_secondaries.resources` (nur sabre) wird in brown/grey/green bei soldier `default` und `default_ai` vor den fraktionsspezifischen Secondaries geladen; commonness **0.15** in sabre.weapon.
- **camo_shield:** Wenn KI-Spawn für Tarnschild gewünscht, in der abgeleiteten Waffe `<tag name="cqb" />` ergänzen (riot_shield_base hat keinen Tag).
- **ultimax/ultimax_m:** Tag `machine gun` (mit Leerzeichen) beibehalten; bei Spawn-Problemen auf Vanilla-Tag `machinegun` prüfen.

---

## 4. Standard-Sekundärwaffe & SBL Resource-Pools

- **Sabre (Standard-Sekundärwaffe):** `factions/default_secondaries.resources` enthält nur `sabre.weapon`. Wird in **brown.xml**, **grey.xml**, **green.xml** bei soldier `default` und `default_ai` **vor** brown/grey/green_secondaries geladen. **commonness 0.15** in sabre.weapon → bevorzugte Slot-1-Waffe für Default-Soldaten.
- **SBL (Kreissägen):** Slot-1-AT; in **common.resources**, **common_eod_light.resources** (Slot-1-Block mit Javelin, M72, RPG-7, SMAW), **common_eod.resources** (neben UTS-15, Flamethrower, Microgun). commonness 0 = keine KI-Spawn-Rate, nur Stash/Boss/EOD-Pool.
- **Origin-12 (sehr selten, 0.005):** In **common_eod.resources** (EOD-Einheit) und **common_specialforces.resources** (Special Forces); Chance pro Spawn über commonness gewichtet.
