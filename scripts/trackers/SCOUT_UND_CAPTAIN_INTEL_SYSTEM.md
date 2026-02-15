# Scout- und Captain-Intel-System

Übersicht über die Funktionsweise von Basis-Scouting, Feindstärke-Meldung und der Verknüpfung mit dem Captain-System (Enemy Commander auf der Karte).

---

## 1. Basis-Scouting (IntelManager)

### Grundprinzip

- Jede Fraktion kann **feindliche Basen** scouten.
- Feind-Basis = Basis mit `owner_id ≠ eigene Fraktion`, capturable.
- Gescoutete Basen zeigen einen Marker mit Stärke-Einschätzung und Zeitstempel.

### Wann gilt eine Basis als „gescoutet“?

**Scout-Methode 1 – Präsenz im Basis-Block**

- Eine Einheit der eigenen Fraktion steht im `center_block` der Basis.
- Dann wird die Basis sofort als gescoutet gewertet.

**Scout-Methode 2 – Fadenkreuz**

- Keine Einheit im Basis-Block, aber Spieler der eigenen Fraktion zielt mit dem Fadenkreuz auf einen Punkt innerhalb von **25 m** der Basis-Mitte.
- Dann wird die Basis ebenfalls als gescoutet gewertet.

**Scout-Methode 3 – Hauptangriffsziel**

- Ein Offizier setzt die Basis als **Hauptangriffsziel**.
- Die Basis muss vorher noch auf der „to investigate“-Liste gewesen sein.
- Dann wird sie ohne physische Präsenz als gescoutet gewertet und Intel wird sofort aktualisiert.

### Nach dem Scout

- Feindanzahl im Umkreis von **60 m** um die Basis-Mitte wird gezählt.
- Basis wechselt von „investigate“-Marker (Lupe) zu „capture“-Marker (Ziel-Icon).
- Marker-Text zeigt Stärke + „vor X Min“.
- Commander meldet Stärke per Sprach-Key (very weak, weak, medium, heavy).
- Spieler, der gescoutet hat, erhält RP-Reward.

---

## 2. Stärke-Bezeichnungen (Base Strength)

Die Bezeichnung richtet sich nach der **Anzahl feindlicher Einheiten im 60-m-Radius** um die Basis-Mitte:

| Feindanzahl | Bezeichnung      | Commander-Meldung (u. a.) | Truppen-Bereich |
|-------------|------------------|---------------------------|------------------|
| 0–4         | very weak        | „sehr leicht verteidigt“  | 0–4 Truppen      |
| 5–10        | weak             | „leicht verteidigt“       | 5–10 Truppen     |
| 11–15       | medium           | „mittel verteidigt“       | 11–15 Truppen    |
| 16+         | heavy            | „stark verteidigt“        | 16+ Truppen      |

- Die Truppenanzahl bezieht sich ausschließlich auf Einheiten der **Basisbesitzer-Fraktion** im 60-m-Umkreis.
- Bei mehreren Feindfraktionen in derselben Basis (mind. 2 Fraktionen oder stärkere andere Fraktion) wird **keine** Meldung abgegeben.

---

## 3. Stale-Reset (Intel veraltet)

- Intel ist **5 Minuten** gültig.
- Danach gilt die Basis wieder als **nicht gescoutet** und wechselt zurück auf „investigate“.
- Spieler müssen die Basis erneut scouten, um aktuelle Stärke zu erhalten.

---

## 4. Besitzerwechsel

- Wenn eine Basis die Fraktion wechselt, wird das Intel für alle anderen Fraktionen **verworfen**.
- Die Basis wird für alle wieder auf „to investigate“ gesetzt.
- Ausnahme: Spieler der eigenen Fraktion steht bereits in der Basis → sofortige Neu-Einstufung ohne erneuten Scout.

---

## 5. Captain-Scout-Verknüpfung (Enemy Commander)

### Ablauf

- Der Captain gehört zu einer Basis (typisch: Cargo Truck spawnt dort).
- Wird diese Basis **gescoutet** oder als **Hauptangriffsziel** gesetzt **und** der Captain ist dort:
  - Die scoutende bzw. angreifende Fraktion sieht den **Enemy Commander** auf der Karte.
  - Es erscheinen die entsprechenden Meldungen.

### Erkennung „Captain bei Basis“

**Variante 1 – Basis-ID**

- Die Basis-ID, an der der Captain gespawnt ist, stimmt mit der gescouteten Basis überein → sofort als „Captain entdeckt“ gewertet.

**Variante 2 – 120-m-Radius**

- Basis-ID stimmt nicht (z. B. andere Base derselben Fraktion).
- Fallback: Captain-Spawn-Position liegt **innerhalb von 120 m** der gescouteten Basis-Mitte → ebenfalls als „Captain entdeckt“ gewertet.

### Wann wird der Enemy Commander angezeigt?

- Wenn die scoutende/angreifende Fraktion den Captain an der Basis **entdeckt** hat (durch Scout oder Hauptangriffsziel).
- **Periodische Prüfung (alle 5 Sek):** Gescoutete Basen werden regelmäßig geprüft – spawnt ein Captain erst danach (z. B. per Cargo Truck), wird er beim nächsten Lauf erkannt und sofort als Enemy Commander markiert.
- Der Enemy Commander-Marker wird nur für die betreffende Fraktion gesetzt und zeigt die aktuelle Captain-Position.
- Der Captain bleibt sichtbar, solange er lebt; nach seinem Tod werden die Marker entfernt.

### Commander erledigt (Kill-Meldungen)

- **Captain-Fraktion (Verlierer):** „Our Commander has been eliminated!“
- **Killer-Fraktion:** „Enemy Commander eliminated!“
- Beide Meldungen erscheinen gleichzeitig als Commander-Nachricht.
- Bei Umgebungstod (Artillerie, Sturz etc.) erhält nur die Captain-Fraktion die Meldung.

---

## 6. Marker-System (Übersicht)

| Marker-Typ        | Zweck                               | Sichtbarkeit                    |
|-------------------|-------------------------------------|---------------------------------|
| Investigate       | Basis noch zu scouten               | Eigene Fraktion, Karte          |
| Capture           | Basis gescoutet, Stärke bekannt     | Eigene Fraktion, Karte          |
| Captain (VIP)     | Eigener Captain                     | Eigene Fraktion, Karte + Welt   |
| Enemy Commander   | Feindlicher Captain entdeckt        | Eigene Fraktion, Karte, Rand    |

- Marker-IDs sind pro Fraktion und Basis/Commander getrennt, damit keine Überschneidungen entstehen.

---

## 7. Regeln im Überblick

| Regel                          | Verhalten                                              |
|--------------------------------|--------------------------------------------------------|
| Scout-Erkennung                | Einheit im Basis-Block ODER Fadenkreuz 25 m von Mitte  |
| Stärke-Zählung                 | Feinde im 60-m-Radius um Basis-Mitte                   |
| Intel gültig                   | 5 Minuten, danach Stale-Reset                          |
| Captain bei Basis              | Basis-ID-Match ODER Captain in 120 m um Basis-Mitte    |
| Keine Meldung bei gemischter Besatzung | 2+ Fraktionen oder stärkere andere Fraktion    |
