# Vehicle & Damage Balancing (Final umgesetzt)

## Kurzlogik nach Waffentyp

| Waffentyp | Finaler Schaden | Ziel-Verhalten |
| --- | --- | --- |
| Vulcan Minigun (Kinetik-AP) | 0.5 / Schuss | Hohe Kadenz, gut gegen Soft/Light, gegen MBT praktisch ineffektiv |
| Wiesel Mk20 (Kinetik-AP) | 5.0 / Schuss | Solide gegen Light, gegen Heavy nur mit Dauerfeuer sinnvoll |
| AT Leicht (RPG-7 175 / LAW 150 / M202 175) | 150–175 | ~2 Treffer auf Wiesel, 1 Treffer auf Soft/Light |
| AT Mittel (SMAW 350 / Carl Gustaf 250) | 250–350 | SMAW stärker; Carl Gustaf ~2 Treffer auf Wiesel/APC |
| AT Schwer (Javelin / TOW / alle Typen) | 800 | 1 Treffer auf Wiesel, ~2 auf FV101, ~4 auf MBT |
| Heavy Artillery / Coastal Gun | 600 | Trifft Medium hart, Heavy beschädigt |
| Tactical Strike (bomb1) | 400 | Luftangriff, zwischen AT Leicht und Mittel |
| Railway Artillery | 3000 | Instakill bis T4, T5 schwer beschädigt, T6 ~75% |

---

## Tabelle 1 - Finale HP (Fahrzeuge & Emplacements)

| Einheit | Klasse | Finale HP |
| --- | --- | --- |
| ATV / Quad (`atv_base`) | Tier 1 Soft | 30 |
| Rubber Boat | Tier 1 Soft | 30 |
| Tractor | Tier 1 Soft | 35 |
| Jeep / Jeep_1 / Jeep_2 | Tier 1 Soft | 40 |
| Buggy | Tier 1 Soft | 40 |
| Technical | Tier 1 Soft | 50 |
| Guntruck | Tier 1 Soft | 50 |
| Transport Truck (alle Varianten) | Tier 1 Soft | 60 |
| Cargo Truck | Tier 1 Soft | 60 |
| VFS Base / Sport / Para | Tier 2 Light | 100 |
| Hovercraft | Tier 2 Light | 100 |
| Humvee / Humvee GL | Tier 2 Light | 200 |
| M120 Heavy Mortar | Emplacement leicht | 100 |
| Deployable MG / Minig (alle Varianten) | Emplacement leicht | 80 |
| Coastal Gun | Emplacement mittel | 200 |
| Heavy Artillery Gun | Emplacement mittel | 200 |
| Radar Tank | Tier 3 Medium | 350 |
| Wiesel Mk20 / Wiesel TOW | Tier 3 Medium | 350 |
| Noxe | Tier 3 Medium | 400 |
| SEV-90 | Tier 3 Medium | 450 |
| Patrol Ship | Tier 3 Medium | 450 |
| APC / APC_1 / APC_2 | Tier 3 Medium | 500 |
| Vulcan Tank | Tier 3 Medium | 500 |
| FV101 | Tier 4 Heavy | 900 |
| Flamer Tank | Tier 4 Heavy | 1000 |
| M551 | Tier 4 Heavy | 1200 |
| M528 | Tier 4 Heavy | 1400 |
| Doublecannon Tank (Fallback) | Tier 5 Battle (Sonderfall) | 2000 |
| Tank / Tank_1 / Tank_2 | Tier 5 Battle | 2500 |
| Legion | Tier 6 Superheavy | 4000 |

---

## Tabelle 2 - Finale AT-/Artillerie-Projektile

| Projektil | Finaler Schaden | Radius |
| --- | --- | --- |
| `rpg-7_rocket` | 175 | 6.0 |
| `m72_law_rocket` | 150 | 6.0 |
| `m202` | 175 | 8.0 |
| `smaw_rocket` | 350 | 7.0 |
| `m2_carlgustav_rocket` | 250 | 7.0 |
| `javelin` | 800 | 8.0 |
| `tow` | 800 | 8.0 |
| `javelin_type2` | 800 | 9.0 |
| `javelin_elite` | 800 | 10.0 |
| `at_mine` | 400 | 6.0 |
| `artillery_shell` | 100 | 15.0 |
| `heavy_artillery_shell` | 600 | 25.0 |
| `coastal_gun` | 600 | 25.0 |
| `bomb1` | 400 | 20.0 |
| `railway_artillery_shell` | 3000 | 50.0 |

---

## Tabelle 3 - Finale Autokanonen & Infanterie-Explosiva

| Projektil | Finaler Schaden | Radius | Rolle |
| --- | --- | --- | --- |
| `vulcan` | 0.5 | 0.5 | Kinetik-AP per Blast-Workaround |
| `wiesel_mk20` | 5.0 | 1.0 | Kinetik-AP per Blast-Workaround |
| `lahti` | 20 | 1.0 | 20mm AT-Gewehr, klar unter Raketen-AT |
| `hand_grenade` | 2 | 9.0 | Leichte Splitter-/Druckwelle; Fokus Infanterie, kaum Fahrzeugschaden |
| `impact_grenade` | 4 | 8.0 | Etwas stärker als Handgranate, weiterhin kein Fahrzeug-Fokus |
| `at_grenade` | 200 | 8.0 | Brücke zwischen Granate und Rakete |
| `c4` | 500 | 10.0 | Schwerer Nahbereichssprengsatz |
| `cluster_grenade_sub` | 3.0 | 4.0 | Submunition, leichte Splitterwirkung |
| `fhj01_rocket_sub` | 3.0 | 4.0 | FAE-Submunition, anti-infanteriebetont |
| `m528_apj_sub` | 2.5 | 3.5 | Leichte AP-Submunition |
