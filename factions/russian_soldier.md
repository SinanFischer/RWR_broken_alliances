# russian_soldier — Combat Bark Design

**Fraktion:** Brown (Russische Föderation)  
**Datei:** `factions/russian_soldier.character`  
**Sprache:** Englisch + russische Einsprengsel (Blyat, Cyka, Tovarishch, Spasibo, Da, Sanitar, Ranen, Bratan)

---

## 1. Psychologisches Profil

**Archetyp:** Der zynische Überlebende  
**Kernmotivation:** "Wir hatten recht. Und das wussten wir schon immer."

Die russischen Soldaten sind Bakhmut-Veteranen — abgehärtet durch einen der blutigsten Stellungskriege seit dem Zweiten Weltkrieg. Sie sehen die westliche Allianz zerbrechen und fühlen sich in ihrer Weltanschauung bestätigt: Der Westen ist moralisch bankrott (Epstein), frisst sich selbst auf, und hat sie jahrelang als Böse dargestellt. Ihr Zynismus ist keine Schwäche, sondern Überlebensmechanismus.

**Schlüsselspannung:** "Wir sind die Bösen? Schaut euch ihre Eliten an."

---

## 2. Slang & Jargon

| Zielgruppe | Bezeichnung | Erklärung |
| :--- | :--- | :--- |
| USA | "Touristen" | Sehen Krieg als Abenteuer, keine Ausdauer |
| USA | "Burgers" | Kulturell abwertend |
| EU | "Vassals" | Marionetten der USA |
| EU | "Softies" | Zu verwöhnt für echten Krieg |
| Kamerad | "Bratan" | Bruder, kameradschaftlich |
| Kamerad | "Tovarishch" | Genosse, formeller |
| Stressfluchen | "Blyat", "Cyka" | Härtestes russisches Schimpfen, kurz und hart |
| Medic | "Sanitar" | Russisch für Sanitäter |
| Verwundet | "Ranen" | Russisch für "Verwundet" |

---

## 3. Combat Barks — Design-Tabelle

| Situation | Bark |
| :--- | :--- |
| **Feindkontakt (vs USA)** | "Tourists spotted! Send them home in bags!" |
| **Feindkontakt (vs EU)** | "Vassals! They fight for nothing!" |
| **Feindkontakt (allgemein)** | "Contact!" / "Enemy spotted!" / "Hostiles!" |
| **Unter Beschuss / Artillerie** | "Blyat, grenade!" / "Look out!" |
| **Unter Beschuss (Verzweiflung)** | "I thought I'd be safe outside Bakhmut..." |
| **Idle / Ruhe (Veteran-Zynismus)** | "Bakhmut was just the warm-up. Great." |
| **Idle / Ruhe (Epstein als Bestätigung)** | "Their elites... the island... and we're the bad guys?" |
| **Idle / Ruhe (Desillusionierung)** | "Why are we even here..." |
| **Idle / Ruhe (Propaganda-Rhetorik)** | "In Russia, bullet finds you." |
| **Verwundet (traurig)** | "Tell my mother I tried" / "It's so cold..." |
| **Verwundet (Patriot)** | "For the Motherland... get me up!" |
| **Verwundet (Bakhmut-Flashback)** | "Shit... like Bakhmut all over again..." |
| **Verwundet (Meta/Absurd)** | "Not how I imagined Special Military Operation" |
| **Nach Heilung** | "Spasibo, tovarishch!" / "For the Motherland!" |
| **Kameradhilfe** | "Hold on, bratan!" / "Almost there!" |
| **Nachladen** | "Cover me, tovarishchi!" |
| **Befehlsbestätigung** | "Da, comrade" / "On it" / "Roger" |
| **Granate** | "Blyat, grenade!" |
| **Flashbang** | "Flashbang!" |
| **Sieg** | "Survived. Unlike their elites on that island." / "Ura!" |
| **Kapitulation** | "We give up! At least we're not on their list." |

---

## 4. Geplante XML-Keys (Referenz)

```
Key: Medic!           → ~35 Zeilen (Militärisch, Brutal, Kameradschaftlich, Halluzination, Traurig, Patrioten, Bakhmut, Meta)
Key: All quiet here   → ~18 Zeilen (Desillusionierung, Epstein, Bakhmut-Zynismus, Neutrale)
Key: I feel good!     → ~6 Zeilen (Nach Heilung, russische Würze)
Key: Hold on!         → ~5 Zeilen (Bratan, Tovarishch)
Key: Reloading        → ~4 Zeilen
Key: enemy seen       → ~5 Zeilen
Key: grenade alert    → ~7 Zeilen (grenade / flashbang / rocket)
Key: Yes sir          → ~6 Zeilen (Da, Comrade)
Key: celebrating      → ~9 Zeilen (Ura!, Motherland, Epstein-Seitenhieb)
Key: Good job, soldiers → ~3 Zeilen (Tovarishchi)
Key: We surrender!    → ~5 Zeilen (mit Epstein-Insider)
```

---

## 5. Voice-Design-Regeln

- **Russisch als Würze:** Blyat, Cyka, Tovarishch, Bratan, Sanitar, Spasibo — nie ganze Sätze, nur einzelne Wörter als kulturelle Authentizität.
- **Bakhmut als Trauma-Anker:** Der Bakhmut-Stellungskrieg (2022–2023) ist das Prägeerlebnis der russischen Soldaten. Referenzen dazu sind authentisch.
- **Epstein als Bestätigung, nicht als Anklage:** Russische Soldaten nutzen die Files als Beweis, dass sie immer recht hatten — kein Mitleid, nur Überlegenheitsgefühl.
- **Propagandasprache mit Bruch:** "Special Military Operation", "denazification", "liberation" — immer mit einem Hauch Ironie oder Desillusion.
- **Keine Sentimentalität:** Kurze, harte Barks. Trauer ist erlaubt, aber komprimiert.
