# usa_soldier — Combat Bark Design

**Fraktion:** Green (USA)  
**Datei:** `factions/usa_soldier.character`  
**Sprache:** Amerikanisches Militär-Englisch (NATO-Phonetik, Militär-Slang, Fluchen)

---

## 1. Psychologisches Profil

**Archetyp:** Der betrogene Profi  
**Kernmotivation:** "Ich tue meinen Job. Aber frag mich nicht, warum."

Die US-Soldaten sind die hochtechnisierteste Truppe auf dem Schlachtfeld, aber moralisch vollständig am Boden. Zwei Schocks haben sie geprägt:
1. **Epstein-Files:** Die Enthüllungen haben ihr Vertrauen in die gesamte politische und militärische Führung ("The Suits") zerstört. Sie kämpfen, aber sie wissen nicht mehr wofür.
2. **Blue on Blue:** Sie kämpfen gegen die EU — NATO-Verbündete, Partner von gestern. Das ergibt schlicht keinen Sinn. Das ist ihre zentrale kognitive Dissonanz.

**Schlüsselspannung:** "Weren't we supposed to be on the same side?"

---

## 2. Slang & Jargon

| Zielgruppe | Bezeichnung | Erklärung |
| :--- | :--- | :--- |
| Russland | "Ivans" / "Reds" | Klassische Bezeichnungen aus dem Kalten Krieg |
| EU | "Euros" / "Krauts" | Abfällig für Europäer generell |
| EU | "Turncoats" | "Verräter" — ironisch, denn USA hat als erstes die Allianz verlassen |
| Eigene Führung | "The Suits" | Generäle, Politiker, alle die nie an der Front sind |
| Epstein | "The Island" / "The List" | Code für Epstein — nie beim Namen genannt |
| FUBAR | Fucked Up Beyond All Recognition | Militär-Akronym für totales Chaos |
| SNAFU | Situation Normal: All Fucked Up | Ironie: das Chaos ist der Normalzustand |
| Paycheck | "Paycheck" | Einziger Grund zu kämpfen, wenn der Rest keinen Sinn ergibt |
| Medic (Marine) | "Corpsman" | US Navy / Marines bezeichnen ihren Sanitäter so |
| Granatenwurf | "Frag out" | Spezifisches US-Militär-Kommando vor dem Werfen einer Granate |

---

## 3. Combat Barks — Design-Tabelle

| Situation | Bark |
| :--- | :--- |
| **Feindkontakt (vs Russland)** | "Ivans! Contact front!" |
| **Feindkontakt (vs EU)** | "Euros spotted! Shit..." |
| **Feindkontakt (vs EU — Verwirrung)** | "Were we supposed to be on the same side?!" |
| **Feindkontakt (allgemein)** | "Contact front!" / "Tangos! 12 o'clock!" |
| **Unter Beschuss / Artillerie** | "Incoming! Get some cover!" |
| **Unter Beschuss (Verzweiflung)** | "Where's our air support?! Classic." |
| **Idle / Ruhe (Desillusionierung)** | "My contract didn't say shit about fighting Europe." |
| **Idle / Ruhe (The Suits)** | "Bet the Suits are watching this from a yacht." |
| **Idle / Ruhe (Epstein)** | "Wonder which island the General is on." |
| **Idle / Ruhe (Blue on Blue)** | "Fighting the Euros... this is FUBAR." |
| **Idle / Ruhe (Kein Plan)** | "I should have stayed in college." |
| **Verwundet** | "Medic! I'm hit!" / "Corpsman! Up!" |
| **Verwundet (Frustration)** | "Not today. Not for this bullshit." |
| **Nach Heilung** | "Back in the fight." / "Thanks, Doc. I owe you." |
| **Kameradhilfe** | "I got you, buddy!" / "On my way! Hang tight!" |
| **Nachladen** | "Reloading! Cover me!" / "Mag change!" |
| **Befehlsbestätigung** | "Roger." / "Solid copy." / "Moving." |
| **Granate** | "Frag out! Move!" / "Grenade! Get down!" |
| **Flashbang** | "Flash! Watch your eyes!" |
| **Rakete** | "Incoming! RPG!" |
| **Sieg** | "That's how it's done. Whatever 'it' even is." |
| **Kapitulation** | "Don't shoot! We're done." |

---

## 4. Geplante XML-Keys (Referenz)

```
Key: Medic!           → ~20 Zeilen (Militärisch, Corpsman, Brutal, Frustration, Erschöpfung)
Key: All quiet here   → ~15 Zeilen (FUBAR/SNAFU, The Suits, The Island, Blue-on-Blue-Verwirrung)
Key: I feel good!     → ~5 Zeilen (pragmatisch, kein Jubel)
Key: Hold on!         → ~4 Zeilen (Buddy, Hang tight)
Key: Reloading        → ~4 Zeilen (Mag change, Frag out)
Key: enemy seen       → ~6 Zeilen (Reds vs Euros, beide mit unterschiedlichem Tonfall)
Key: grenade alert    → ~6 Zeilen (grenade / flashbang / rocket)
Key: Yes sir          → ~5 Zeilen (Roger, Solid copy, Moving)
Key: celebrating      → ~6 Zeilen (gedämpft, kein Jubel — "whatever that means")
Key: Good job, soldiers → ~3 Zeilen
Key: We surrender!    → ~4 Zeilen
```

---

## 5. Voice-Design-Regeln

- **NATO-Phonetik als Authentizität:** "Contact front", "Solid copy", "Frag out", "Corpsman up" — echtes US-Militär-Vokabular.
- **Blue-on-Blue als Kerntrauma:** Der Kampf gegen die EU ist für US-Soldaten das psychologisch unverständlichste Szenario. Jeder EU-Feindkontakt-Bark sollte einen Hauch Verwirrung transportieren.
- **Epstein als "The Island" / "The List":** Nie beim Namen nennen. Die Soldaten wissen es, sprechen es aber nicht direkt aus.
- **The Suits als Feindbild nach oben:** Nicht der Feind vorne, sondern die Führung hinten ist das eigentliche Problem.
- **FUBAR/SNAFU-Logik:** Galgenhumor als Überlebensstrategie. Sie wissen, dass alles kaputt ist — und machen trotzdem weiter.
- **Kein übertriebenes Pathos:** US-Militär ist professionell und nüchtern. Weniger "For America!", mehr "Let's just get this done."
