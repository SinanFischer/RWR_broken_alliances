| Waffentyp              | Empfohlener Schaden | Ziel-Verhalten                                                                           |
| ---------------------- | ------------------- | ---------------------------------------------------------------------------------------- |
| Tank Cannon (Standard) | 1.200 – 1.500       | Killt MBT (T5) in 3–4 Treffern; One-Shot für T3.                                         |
| Heavy Artillery Gun    | 1.500               | Größere Reichweite als Coastal gun.                                                      |
| Coastal Gun            | 1.500               | Kürzere Reichweite, massiver Schaden.                                                    |
| Tactical Strike (bomb1)| 600                 | Wie 120mm Heavy Mortar, Präzisionsschlag.                                                |

---

### Klasse A: Anti-Infanterie & Kleinkaliber (HE / Kinetisch AP)

Waffen: MGs (0.50 cal), Granatwerfer (XM25), Autokanonen (Vulcan, MK20).

Schaden: 0.5 – 20

Logik: RWR benötigt zwingend einen `blast`-Wert in der XML, um Fahrzeuge mit `metal_heavy`-Tag (wie euren Humvee) überhaupt zu beschädigen. Wir nutzen diesen "Blast" bei Autokanonen aber mit winzigem Radius als reinen **Kinetischen Armor-Piercing-Schaden**.
- **Vulcan Minigun:** Feuert 50 Schuss/s. Macht **0.5 Schaden pro Treffer**. Resultat: 25 DPS. Zerstört Humvee (150 HP) in 6 Sekunden Vollfeuer. Braucht für einen MBT (5.000 HP) über 3 Minuten Dauertreffer (faktisch immun).
- **Wiesel Mk20:** Feuert 3 Schuss/s. Macht **5.0 Schaden pro Treffer**. Resultat: 15 DPS. Zerstört Humvee in 10 Sekunden.

---

### Klasse B: Anti-Materiel & Leichte AT

Waffen: Truvelo Amris, RPG-7, LAW, M202 FLASH.

Schaden: 400

Logik: Vernichtet T1/T2 mit einem Schuss. Braucht 12-15 Treffer für einen MBT.

---

### Klasse C: Schwere Panzerabwehr & Panzerkanonen

Waffen: Javelin, TOW, Tank Cannon, SMAW, Carl Gustaf.

Schaden: 800 – 1.300

Logik: Die Standardwaffe für den Kampf Panzer-gegen-Panzer. SMAW (Mittel) liegt bei ca. 800, TOW/Javelin (Schwer) bei ca. 1.300 (Killt T4 in 2 Treffern).

---

### Klasse D: "Bunkerbrecher" & Super-AT

Waffen: Coastal Gun, Javelin Elite, Railway Artillery.

Schaden: 2.600 – 11.000

Logik: Bedrohung für die Legion (T6). Alles andere ist bei einem Volltreffer fast garantiert Schrott. Javelin Elite macht ca. 2.600 Dmg (2 Hits für MBT). Railway Artillery (11.000) ist der einzige Instakill für T6.

---

### Rebalanced Schadenstabelle (Explosiv & AT)

| Waffe / Projektil | Alter Schaden | Neuer Schaden | Splash-Radius | Gegen Leicht gepanzert (T1/T2) | Gegen Schwer gepanzert (T4/T5) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Handgranate** | 1.01 | **15** | 4.0 | Gefährlich (3-4 Treffer unter Boden) | Wirkungslos (Kratzer) |
| **AT-Granate** | 9.99 | **500** | 3.5 | Overkill (Zerstört T1 in 1 Hit) | Mühsam (3-4 Hits für Heavy) |
| **C4 Sprengladung** | *k.A.* | **1.700** | 5.0 | Absoluter Overkill | Gefährlich (3 Hits für MBT) |
| **40mm HE** (APC HMG, GL) | 0.60 – 1.10 | **20** | 4.5 | Tödlich (1-3 Treffer für Soft) | Immun (Nur Stun der Besatzung) |
| **Wiesel Mk20 (Kinetisch AP)** | 0.30 | **5.0** | 1.0 | 15 DPS (Zerstört T2 in ~10s) | Immun (Munitionsverschwendung) |
| **Vulcan Minigun (Kinetisch AP)**| 0.03 | **0.5** | 0.5 | 25 DPS (Zerstört T2 in ~6s) | Immun (Munitionsverschwendung) |
| **RPG-7 / M72 LAW** (AT Leicht) | 3.60 – 4.00 | **400** | 6.0 | Instakill (Totaler Overkill) | Mückenstiche (12-15 Treffer) |
| **SMAW / Carl G.** (AT Mittel) | 5.20 – 6.00 | **800** | 7.0 | Instakill | Mühsam (6-8 Treffer) |
| **Tactical Strike / 120mm Mortar**| 17.00 / 8.00 | **600** | 20.0 / 18.0 | Instakill | Spürbar (Zieht ca. 10-15% HP ab) |
| **Javelin / TOW** (AT Schwer) | 7.20 – 8.70 | **1.300** | 8.0 | Instakill | Primärgefahr (3-4 Treffer) |
| **Javelin Elite** (AT Top) | 13.05 | **2.600** | 10.0 | Instakill | Endboss-Killer (2 Treffer MBT) |
| **Heavy Art. Shell / Gun** | 7.00 | **1.500** | 25.0 | Pulverisiert Zielgebiet | Schwerer Schaden |
| **Railway Artillery** | 30.00 | **11.000** | 50.0 | Atomisiert Grid-Sektor | Einziger Instakill für Legion |
