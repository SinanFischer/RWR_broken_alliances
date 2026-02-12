# Troop Rank Balance – Übersicht & Anpassungshilfe

**Ziel:** Elite-Truppen/Specialforces/Minibosses sollen durch höheren Spawn-XP oft **Squad-Leader** werden.  
Stürmer (EOD), reguläre Soldaten und Unterstützungseinheiten sollen **Follower-Ränge** haben.

---

## 1. Mechanik: XP → Rank → Squad Leader

| Konzept | Erklärung |
|--------|-----------|
| **xp** | `attribute_config class="xp"` – XP-Wert bei Spawn. Bestimmt direkt den **Rang**. |
| **Rank** | Wird aus XP über die `<rank xp="…" name="…">`-Tabelle in der Faction-XML ermittelt. |
| **Squad Leader** | Der KI-Soldat mit dem **höchsten XP** in der Nähe wird bevorzugt zum Anführer gewählt. |

→ **Höherer XP bei Spawn = höherer Rang = eher Anführer.**

---

## 2. Rang-Tabelle (XP-Thresholds)

| XP Min | Rang | Index |
|--------|------|-------|
| 0.00 | Private | 0 |
| 0.05 | Private 1st Class | 1 |
| 0.10 | Corporal | 2 |
| 0.20 | Sergeant | 3 |
| 0.30 | Staff Sergeant | 4 |
| 0.40 | Staff Sergeant 1st Class | 5 |
| 0.60 | 2nd Lieutenant | 6 |
| 0.80 | Lieutenant | 7 |
| 1.00 | Captain | 8 |
| 1.20 | Major | 9 |
| 1.40 | Lieutenant Colonel | 10 |
| 2.00 | Colonel | 11 |
| 5.00 | Brigadier General | 12 |
| 10.0 | Major General | 13 |
| 20.0 | Lieutenant General | 14 |
| 50.0 | General | 15 |
| 100.0 | General of the Army | 16 |

---

## 3. Aktuelle XP-Verteilung pro Truppentyp (brown.xml)

| Truppentyp | XP Min | XP Max | Typischer Rang-Bereich | Spawn-Score | Kategorie |
|------------|--------|--------|------------------------|-------------|-----------|
| **default** | 0.0 | 1.0 | Private → Captain | 0.0 | Follower |
| **default_ai** | 0.0 | 1.0 | Private → Captain | 0.783 | Follower |
| **shotgun** | 0.0 | 1.0 | Private → Captain | 0.167 | Follower |
| **sniper** | 0.0 | 1.0 | Private → Captain | 0.05 | Follower |
| **support** | 0.2 | 0.6 | Sergeant → 2nd Lt (MG-Follower) | 0.27 | Follower |
| **medic** | 0.0 | 0.2 | Private bis Sergeant | 0.07 | Follower |
| **eod_light** | 0.2 | 1.2 | Sergeant → Major | 0.048 | Follower |
| **mortar_operator** | 0.0 | 1.0 | Private → Captain | 0.012 | Follower |
| **cover_troop** | 0.0 | 1.0 | Private → Captain | 0.06 | Follower |
| **grenadier** | 0.5 | 1.5 | 2nd Lt → Lt Colonel | 0.04 | Mittlere Ränge |
| **specialforces** | 0.4 | 1.4 | Staff Sgt 1st → Lt Colonel | 0.02 | **Elite** |
| **miniboss** | 1.2 | 50.0 | Major → General | 0.054 | **Elite** |
| **eod** | 1.6 | 3.7 | Captain → Major General | 0.02 | Leader (starke Truppe) |
| **prisoner** | 0.0 | 0.45 | Private → Corporal | 0.0 | Sonderfall |
| **supply** | 0.0 | 0.05 | Private bis PFC | 0.0 | Sonderfall |

---

## 4. Visuelle Rang-Skala (XP → Leader-Potenzial)

```
XP     0.0    0.2    0.4    0.6    0.8    1.0    1.2    1.4    2.0    5.0+
       │      │      │      │      │      │      │      │      │      │
Rank   Pvt    Sgt    SSgt1  Lt     Capt   Maj    Col    ...
       ├──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┤
       │ Follower-Bereich (0.0–0.5)        │ Leader-Bereich (0.6+)    │
       └─────────────────────────────────┴─────────────────────────┘

Aktuelle Verteilung:
  medic             ████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  default/shotgun   ████████████████████████████████████████
  support           ██████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  eod_light         ████████████████████████████████████████
  grenadier         ░░░░░░░░░░░░░░░████████████████████████
  specialforces     ░░░░░░░░░░░░░░░░░░░░░░░░░░░████████████
  miniboss          ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░████████████████
  eod               ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░████████████████
```

---

## 5. Balance-Empfehlungen

### Ziel-Matrix (umgesetzt)

| Kategorie | XP-Bereich | Typischer Rang | Truppentyp |
|-----------|------------|----------------|------------|
| **Follower** | 0.0 – 1.0 | Private bis Captain | default, shotgun, sniper, medic, mortar, cover_troop |
| **Follower (MG)** | 0.2 – 0.6 | Sergeant bis 2nd Lt | support |
| **Follower (bis Major)** | 0.2 – 1.2 | Sergeant bis Major | eod_light |
| **Elite** | 0.4 – 1.4 | Staff Sgt 1st → Lt Colonel | specialforces |
| **Leader/Miniboss** | 1.2 – 50.0 | Major → General | miniboss, miniboss_female |
| **Leader (starke Truppe)** | 1.6 – 3.7 | Captain → Major General | eod (Stürmer führen mit) |

---

## 6. XP anpassen in den Faction-XMLs

Beispiel für **specialforces** (0.4–1.4):

```xml
<attribute_config class="xp">
    <attribute weight="1.0" min="0.4" max="1.4" />
</attribute_config>
```

**Betroffene Dateien:** `brown.xml`, `green.xml`, `grey.xml` (gleiche Änderungen pro Truppentyp).

---

## 7. Zusätzliche Parameter

| Parameter | Bedeutung |
|-----------|-----------|
| `squad_size_xp_cap` | Begrenzt maximale Squad-Größe bei hohem XP (z.B. miniboss: 0.5, eod: 0.0). |
| `spawn_score` | Relative Spawn-Häufigkeit; beeinflusst **nicht** den Rang. |

---

## 8. Checkliste für Balance-Iteration

- [x] Follower (default, mortar, cover) max Captain (XP 1.0)
- [x] support: 0.2–0.6 (MG-Schützen eher Follower)
- [x] Medic max Sergeant (XP 0.2)
- [x] eod_light: Sergeant bis Major (0.2–1.2)
- [x] specialforces: 0.4–1.4 (Staff Sgt 1st bis Lt Colonel)
- [x] miniboss: Major bis General (1.2–50.0)
- [x] eod: unverändert (1.6–3.7), starke Truppe führt mit
- [x] Änderungen in allen drei Faction-XMLs (brown, green, grey) konsistent
