# european_soldier — Combat Bark Design

**Fraktion:** Grey (Europäische Union)  
**Datei:** `factions/european_soldier.character`  
**Sprache:** Englisch + deutsche Einsprengsel (NEIN, Scheiße, Sanitäter, Jawohl, Kamerad)

---

## 1. Psychologisches Profil

**Archetyp:** Der verzweifelte Verteidiger  
**Kernmotivation:** "Für das Haus – nicht für die Herren in Brüssel."

Die EU-Soldaten sind die einzige Fraktion, die rein defensiv denkt. Sie kämpfen nicht für eine Ideologie, sondern für ihre Heimatländer. Ihre größte kognitive Dissonanz: Die USA – einst Verbündete unter NATO – sind nun Feinde. Gleichzeitig verachten sie ihre eigene Brüsseler Führung, die in die Epstein-Files verstrickt ist. Ergebnis: Galgenhumor über Bürokratie, tiefer Patriotismus ohne Glauben an die Elite.

**Schlüsselspannung:** "Ich kämpfe für Europa, aber die, für die ich sterbe, standen auf der Liste."

---

## 2. Slang & Jargon

| Zielgruppe | Bezeichnung | Erklärung |
| :--- | :--- | :--- |
| USA | "Yanks" | Abkürzung für Yankees, klassisch abfällig |
| USA | "Cowboys" | Impliziert Impulsivität, keine Strategie |
| Russland | "Bears" | Klassisches Russienbild |
| Russland | "Invaders" | Sachlich, kein Respekt |
| Eigene Führung | "Brussels" | Schimpfwort für Inkompetenz |
| Stressfluchen | "Scheiße", "Verdammt", "NEIN" | Deutsches Einsprengsel als kulturelle Authentizität |

---

## 3. Combat Barks — Design-Tabelle

| Situation | Bark |
| :--- | :--- |
| **Feindkontakt (vs USA)** | "Yanks! They're attacking us?!" |
| **Feindkontakt (vs USA)** | "Cowboys on us! Open fire!" |
| **Feindkontakt (vs Russland)** | "Bears! Hold the line!" |
| **Feindkontakt (vs Russland)** | "Invaders! Contact front!" |
| **Feindkontakt (allgemein)** | "Enemy spotted!" / "Contact!" / "Hostiles!" |
| **Unter Beschuss / Artillerie** | "Take cover! Artillery!" |
| **Unter Beschuss (Verzweiflung)** | "Scheiße! Where is our support?!" |
| **Idle / Ruhe (Bürokratie)** | "I filled out the wrong form" |
| **Idle / Ruhe (Elite-Zynismus)** | "Brussels sends orders, we send bodies." |
| **Idle / Ruhe (Verwirrung)** | "How did we end up shooting at the Americans?" |
| **Idle / Ruhe (Epstein)** | "Dying for the Union... while they were on the list." |
| **Verwundet (traurig)** | "It's so cold..." |
| **Verwundet (Patriot)** | "For Europe... get me up!" |
| **Verwundet (Epstein-Zynismus)** | "Dying for the guys in the files... great" |
| **Nach Heilung** | "Feeling much better!" / "Thanks Sani!" |
| **Kameradhilfe** | "Coming!" / "Hold on, Kamerad!" |
| **Nachladen** | "Give me cover!" |
| **Befehlsbestätigung** | "Copy" / "On my way" / "Jawohl!" |
| **Granate** | "SCHEISSE! Granate!" |
| **Flashbang** | "Flashbang!" |
| **Sieg** | "Made it. Unlike some people in the files." |
| **Kapitulation** | "Don't shoot!" / "We surrender!" |

---

## 4. Geplante XML-Keys (Referenz)

```
Key: Medic!           → ~30 Zeilen (Militärisch, Brutal, Kameradschaftlich, Panisch, Traurig, Patrioten, Epstein)
Key: All quiet here   → ~18 Zeilen (Bürokratie, Post-Ukraine, Epstein, Neutrale)
Key: I feel good!     → ~6 Zeilen (Nach Heilung)
Key: Hold on!         → ~5 Zeilen (Kamerad kommt)
Key: Reloading        → ~4 Zeilen
Key: enemy seen       → ~5 Zeilen
Key: grenade alert    → ~7 Zeilen (grenade / flashbang / rocket)
Key: Yes sir          → ~6 Zeilen
Key: celebrating      → ~9 Zeilen
Key: Good job, soldiers → ~3 Zeilen
Key: We surrender!    → ~4 Zeilen
```

---

## 5. Voice-Design-Regeln

- **Deutsch als Würze:** NEIN, Scheiße, Verdammt, Sani, Sanitäter, Kamerad, Jawohl — nicht als Hauptsprache, sondern als kultureller Einschlag.
- **Keine Hollywood-Klischees:** Kein "For freedom!", kein "Yippee ki-yay". Militärische Kürze.
- **Epstein organisch einbauen:** Nie erklärend, immer Subtext ("the list", "the files", "the guys").
- **Ersatzschreibweise im XML:** ä → ae, ö → oe, ü → ue, ß → ss (Engine-Limitierung).
