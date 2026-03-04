# projectile_speed – Regeln für das Waffen-Balancing

**Zweck:** Feste, prüfbare Regeln für den Wert `projectile_speed` in RWR-Waffen-XML. Zwei Anker: **(1)** Realgeschwindigkeit der Patrone in m/s, **(2)** die bereits gut spürbare Geschwindigkeitsskala im Spiel (Broken Alliances).

**Detaillierte Skala & Referenzwerte:** Siehe `docs/waffen/PROJEKTILGESCHWINDIGKEIT_REFERENZ.md`.

---

## Die zwei Anker

| Anker | Bedeutung | Nutzung |
|-------|-----------|--------|
| **Real (m/s)** | Mündungsgeschwindigkeit der echten Patrone | Kategorie einordnen; grobe Plausibilität prüfen. |
| **Spiel-Skala** | Aktuell getestete, gut spielbare Werte (Skala +50) | **Maßgebend** für den finalen `projectile_speed`-Wert. |

**Regel:** Der Wert in der XML kommt **immer** aus der Spiel-Skala. Die Realgeschwindigkeit dient nur zur Einordnung (z. B. „Subsonic → untere Spanne“, „5.56 Rifle → Referenz 155–165“).

---

## Harte Grenzen (Engine & Spielgefühl)

- **Untere Grenze:** `projectile_speed` **≥ 138**.  
  Alles darunter wirkt träge und ist nicht erlaubt (außer Sonderregel für sehr langsame Projektile, siehe unten).
- **Obere Grenze konventionelle Geschosse:** **220**.  
  Sniper/Großkaliber bis 180–220; darüber nur für Sonderprojektile (z. B. bestimmte Explosivgeschosse) mit Begründung.
- **Sonderprojektile (Granaten, Raketen, Pfeile):** Eigenwerte laut Kategorietabelle; können unter 138 liegen, dann explizit in der .weapon dokumentieren.

---

## Zuordnungsregel (Schritt für Schritt)

### Schritt 1: Waffenkategorie wählen

Eindeutig eine Kategorie aus der Tabelle unten wählen (z. B. „5.56 Rifle“, „9 mm MP“, „Sniper/Großkaliber“).

### Schritt 2: Spanne der Spiel-Skala anwenden

Den **erlaubten Bereich** aus der Tabelle übernehmen und einen Wert **innerhalb** dieses Bereichs setzen. Kein Wert außerhalb der Spanne ohne schriftliche Ausnahme (z. B. in der Waffen-Doku).

### Schritt 3: Optional – Realität prüfen

- Liegt die reale Mündungsgeschwindigkeit (m/s) für diese Waffenart in der erwarteten Größenordnung?  
  (z. B. Subsonic ~300 m/s → untere Spanne; 5.56 ~900 m/s → Referenz-Rifle.)
- Wenn die gewählte Kategorie und die Realgeschwindigkeit stark widersprechen (z. B. „Rifle“-Speed für eine typische Pistolenpatrone), Kategorie oder Wert nochmal prüfen.

---

## Kategorietabelle (Spiel-Skala, verbindlich)

| Kategorie | projectile_speed (min–max) | Real (m/s) grob | Anmerkung |
|-----------|---------------------------|------------------|-----------|
| **Referenz: 5.56/5.45 Rifle** | **155–165** | 900–940 | Anker; G36, M16, HK416, AK-74M; **RU:** AN-94 Salve 158 |
| 7.62 MG / Battle Rifle | 156–160 | 830–870 | Leicht unter/auf Rifle |
| DMR / Präzisionsgewehr | 165–180 | 830–900 | Eigenständig, oberhalb Standard-Rifle |
| **Sniper / Großkaliber** | **175–220** | 850–900+ | Mit sight_range_modifier 1,3–1,65 |
| 5.56 Leicht-MG (M249, MG4, RPK) | 143–150 | 900+ | Unter Rifle, Dauerfeuer; **RU:** RPK-16 146, RPK-16 Langrohr 148 |
| Kurzgewehr (AKS-74U, kurze AR) | 146–150 | ~735 | Unter Rifle |
| .300 BLK / kurze Gasanlage | 153–157 | ~900 | Auf Rifle-Niveau |
| **PDW (5.7 / 4.6 mm)** | **146–150** | 715–725 | P90, MP7, QCW |
| **9 mm MP** | **142–148** | 380–400 | Uzi, Scorpion, TMP |
| .45 ACP MP | 140–144 | ~280–350 | Kriss Vector etc. |
| **9 mm + SD / Subsonic** | **138–140** | ~300 | MP5SD; untere Spielgrenze |
| **Pistole** | **138–142** | ~340 | PB, Glock; ≥ 138 einhalten |
| **Shotgun / Nahbereich** | **80–95** | — | CQB; zu BALANCING_REGELWERK Rule 7 |
| **Pfeil (Bogen)** | **75–90** | ~50–80 | Stealth; untere Spanne erlaubt |
| **Granate / Mörser (Flugkörper)** | **35–55** | — | Bogenbahn; ballistics-Tag nutzen |
| **Rakete / RPG-ähnlich** | **40–70** | — | Schwer; oft mit ballistics |
| **SBL / Spezial (Kreissäge etc.)** | **30–50** | — | Eigenlogik; kann unter 138 |

---

## Faustformel (Reihenfolge der Kategorien)

Von langsam nach schnell (Wert-Bereiche nicht überlappen, außer wo Spannen erlaubt):

1. Granate/Rakete/SBL (30–70)  
2. Bogen (75–90)  
3. Shotgun/Nah (80–95)  
4. Pistole (138–142)  
5. Subsonic/SD (138–140)  
6. .45 MP (140–144)  
7. 9 mm MP (142–148)  
8. PDW (146–150)  
9. Kurzgewehr / LMG (143–150)  
10. Rifle (155–165) ≈ 7.62 (156–160)  
11. DMR (165–180)  
12. Sniper (175–220)

---

## Konflikte mit anderen Balancing-Regeln

- **BALANCING_REGELWERK Rule 7 (Range & Decay):**  
  Nahkampf/Shotgun: Speed 80–90; Sturmgewehr ~100 **ersetzt** durch **155–165** (aktuelle Spiel-Skala).  
  Sniper/DMR: 130–180 dort → hier **175–220** (Sniper) bzw. **165–180** (DMR) für Konsistenz mit der Referenz.
- Wenn in einer Waffen-Datei ein Wert außerhalb dieser Regeln steht, beim nächsten Balancing-Pass auf die Tabelle anpassen und ggf. in der Doku vermerken.

---

## Schnell-Check vor Commit

- [ ] Kategorie aus Tabelle gewählt?
- [ ] `projectile_speed` **innerhalb** der Spanne (min–max)?
- [ ] **≥ 138** (außer Granate/Rakete/Bogen/Shotgun/SBL)?
- [ ] Sniper/DMR: zusätzlich **sight_range_modifier** 1,3–1,65 gesetzt?
- [ ] Detaillierte Werte bei Unsicherheit: `docs/waffen/PROJEKTILGESCHWINDIGKEIT_REFERENZ.md` geprüft?
