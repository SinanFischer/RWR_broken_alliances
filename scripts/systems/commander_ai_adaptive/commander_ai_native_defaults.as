// =============================================================================
// Commander AI — Native Defaults (Vanilla Maps)
// =============================================================================
// Erfasst aus: vanilla/maps/*/init_match.xml
// Zweck: Option A — "Neutrale Defaults" pro Fraktion; Revert nach Events nutzt
//        diese Werte statt die native AI dauerhaft zu ueberschreiben.
// Wenn eine Map keinen commander_ai-Block hat: Fallback verwenden.
// =============================================================================

/*
  VANILLA MAPS — commander_ai Defaults (base_defense, border_defense)
  Quelle: C:\...\vanilla\maps\<map>\init_match.xml

  Map      | F0        | F1        | F2        | F3        | Anmerkung
  ---------|-----------|-----------|-----------|-----------|------------------
  map7     | 0.3 / 0.1 | 0.3 / 0.1 | 0.3 / 0.1 | 0.64/0.24 | 4 Fraktionen
  map8     | 0.2 / 0.1 | 0.2 / 0.1 | 0.2 / 0.4 | —         | 3 Fraktionen
  map1_2   | 0.5 / 0.2 | 0.6 / 0.2 | 0.6 / 0.3 | —         | 3 Fraktionen
  map11    | 0.0 / 0.0 | 1.0 / 0.0 | 1.0 / 0.0 | —         | active="0" (AI aus)
  map13    | 0.5 / 0.2 | 0.5 / 0.2 | 0.5 / 0.2 | 0.64/0.14 | 4 Fraktionen
  map13_2  | 0.3 / 0.1 | 0.3 / 0.1 | 0.3 / 0.1 | 0.9 / 0.1| 4 Fraktionen
  map14    | 0.1 / 0.1 | 0.6 / 0.3 | —         | —         | 2 Fraktionen
  map15    | FEHLT     | FEHLT     | FEHLT     | —         | kein commander_ai
  map16    | 0.4 / 0.3 | 0.6 / 0.3 | 0.8 / 0.18| —         | 3 Fraktionen
  map18    | 0.1 / 0.2 | 0.6 / 0.2 | —         | —         | 2 Fraktionen
  map19    | 0.6 / 0.2 | 0.6 / 0.2 | —         | —         | 2 Fraktionen
  lobby    | FEHLT     | FEHLT     | —         | —         | Tutorial/Lobby

  FEHLT = init_match.xml enthaelt keinen commander_ai fuer diese Map/Fraktion
          → Fallback verwenden.
  map11: Sonderfall (AI deaktiviert); bei Nutzung trotzdem Fallback sinnvoll.
*/

// --- Fallback: wenn Map keinen commander_ai hat oder Map unbekannt ---
// Neutrale Mitte aus typischen Vanilla-Werten (base ~0.3–0.5, border ~0.15–0.25)
const float AI_NATIVE_FALLBACK_BASE   = 0.40f;
const float AI_NATIVE_FALLBACK_BORDER = 0.25f;

// --- Laufzeit-Formel fuer unbekannte Maps (abgeleitet aus Vanilla-Musterdaten) ---
// Beobachtung: Mehr Basen = hoehere base_defense (Fraktion hat mehr zu verlieren).
// border_defense bleibt relativ stabil (0.10–0.35), unabhaengig von Basenanzahl.
//
// factionShare = factionBases / totalBases  (Anteil der Fraktion an der Gesamtkarte)
//
//   base_defense   = clamp(0.20 + factionShare * 0.50,  0.20, 0.70)
//   border_defense = clamp(0.10 + factionShare * 0.25,  0.10, 0.35)
//
// Beispiele (validiert gegen Vanilla):
//   factionShare 0.20 → base=0.30, border=0.15  (passt: map7/map8 kleine Fraktionen)
//   factionShare 0.30 → base=0.35, border=0.175 (passt: map13 ausgeglichene Maps)
//   factionShare 0.50 → base=0.45, border=0.225 (passt: map16/map19 grosse Fraktionen)
//   factionShare 0.70 → base=0.55, border=0.275 (passt: map16 F2 defensive Fraktion)
//
// NUTZUNG: computeNativeFallbackFromBases(factionBases, totalBases, baseDef, borderDef)
// Wird vom Tracker beim Start einmalig pro Fraktion berechnet und gecacht.

void computeNativeFallbackFromBases(int factionBases, int totalBases,
	float &out baseDef, float &out borderDef) {

	if (totalBases <= 0) {
		baseDef   = AI_NATIVE_FALLBACK_BASE;
		borderDef = AI_NATIVE_FALLBACK_BORDER;
		return;
	}
	float share = float(factionBases) / float(totalBases);
	baseDef   = 0.20f + share * 0.50f;
	borderDef = 0.10f + share * 0.25f;
	// clamp
	if (baseDef   < 0.20f) baseDef   = 0.20f;
	if (baseDef   > 0.70f) baseDef   = 0.70f;
	if (borderDef < 0.10f) borderDef = 0.10f;
	if (borderDef > 0.35f) borderDef = 0.35f;
}

// Normalisiert Map-Pfad zu kurzem Key (z.B. "maps/map16" -> "map16") fuer Lookup.
string normalizeMapKey(const string &in mapPath) {
	if (mapPath.length() == 0) return "";
	int lastSlash = mapPath.findLast("\\");
	if (lastSlash < 0) lastSlash = mapPath.findLast("/");
	if (lastSlash >= 0 && int(lastSlash) < int(mapPath.length()) - 1)
		return mapPath.substr(lastSlash + 1, int(mapPath.length()) - (lastSlash + 1));
	return mapPath;
}

// --- Lookup: Native-Werte pro Map (mapPath = z.B. getMapId() oder "map16") ---
// Gibt (base_defense, border_defense) fuer eine Fraktion zurueck.
// Wenn mapPath leer oder unbekannt: Fallback. factionId typisch 0..3.
void getNativeCommanderAiValues(const string &in mapPath, int factionId,
	float &out baseDef, float &out borderDef) {

	baseDef   = AI_NATIVE_FALLBACK_BASE;
	borderDef = AI_NATIVE_FALLBACK_BORDER;

	string mapKey = normalizeMapKey(mapPath);

	// Map-spezifische Defaults (Vanilla: "map7", "map8", "map16" etc.)
	if (mapKey == "map7") {
		if (factionId == 0) { baseDef = 0.30f; borderDef = 0.10f; return; }
		if (factionId == 1) { baseDef = 0.30f; borderDef = 0.10f; return; }
		if (factionId == 2) { baseDef = 0.30f; borderDef = 0.10f; return; }
		if (factionId == 3) { baseDef = 0.64f; borderDef = 0.24f; return; }
		return;
	}
	if (mapKey == "map8") {
		if (factionId == 0) { baseDef = 0.20f; borderDef = 0.10f; return; }
		if (factionId == 1) { baseDef = 0.20f; borderDef = 0.10f; return; }
		if (factionId == 2) { baseDef = 0.20f; borderDef = 0.40f; return; }
		return;
	}
	if (mapKey == "map1_2") {
		if (factionId == 0) { baseDef = 0.50f; borderDef = 0.20f; return; }
		if (factionId == 1) { baseDef = 0.60f; borderDef = 0.20f; return; }
		if (factionId == 2) { baseDef = 0.60f; borderDef = 0.30f; return; }
		return;
	}
	if (mapKey == "map11") {
		// active="0" in Vanilla; Fallback sinnvoller als 0/0 oder 1/0
		return;
	}
	if (mapKey == "map13") {
		if (factionId == 0) { baseDef = 0.50f; borderDef = 0.20f; return; }
		if (factionId == 1) { baseDef = 0.50f; borderDef = 0.20f; return; }
		if (factionId == 2) { baseDef = 0.50f; borderDef = 0.20f; return; }
		if (factionId == 3) { baseDef = 0.64f; borderDef = 0.14f; return; }
		return;
	}
	if (mapKey == "map13_2") {
		if (factionId == 0) { baseDef = 0.30f; borderDef = 0.10f; return; }
		if (factionId == 1) { baseDef = 0.30f; borderDef = 0.10f; return; }
		if (factionId == 2) { baseDef = 0.30f; borderDef = 0.10f; return; }
		if (factionId == 3) { baseDef = 0.90f; borderDef = 0.10f; return; }
		return;
	}
	if (mapKey == "map14") {
		if (factionId == 0) { baseDef = 0.10f; borderDef = 0.10f; return; }
		if (factionId == 1) { baseDef = 0.60f; borderDef = 0.30f; return; }
		return;
	}
	// map15, lobby: kein commander_ai → Fallback (bereits gesetzt)
	if (mapKey == "map16") {
		if (factionId == 0) { baseDef = 0.40f; borderDef = 0.30f; return; }
		if (factionId == 1) { baseDef = 0.60f; borderDef = 0.30f; return; }
		if (factionId == 2) { baseDef = 0.80f; borderDef = 0.18f; return; }
		return;
	}
	if (mapKey == "map18") {
		if (factionId == 0) { baseDef = 0.10f; borderDef = 0.20f; return; }
		if (factionId == 1) { baseDef = 0.60f; borderDef = 0.20f; return; }
		return;
	}
	if (mapKey == "map19") {
		if (factionId == 0) { baseDef = 0.60f; borderDef = 0.20f; return; }
		if (factionId == 1) { baseDef = 0.60f; borderDef = 0.20f; return; }
		return;
	}

	// Unbekannte Map oder leer → statischer Fallback (Formel-Variante via computeNativeFallbackFromBases)
	// baseDef/borderDef sind bereits auf AI_NATIVE_FALLBACK_BASE/BORDER gesetzt (Zeilenanfang der Funktion).
}
