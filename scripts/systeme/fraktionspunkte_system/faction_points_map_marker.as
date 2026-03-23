// FP Event Map Marker Utility
// Marker-ID-Raum: 80000 + factionId * 10 + eventSlot (0..4 fuer event1..5)
// Pro Fraktion maximal 5 gleichzeitige FP-Marker (einer pro Event-Typ).
//
// Atlas-Indizes laut Doku:
//   10 = Paradrop-Symbol (Paratrooper-Events)
//   17 = VIP-Ziel-Shield (Defense/Vehicle)

const int FP_MARKER_ID_BASE   = 80000;
const int FP_MARKER_ID_STRIDE = 10;

const int FP_MARKER_ATLAS_SHIELD   = 17; // VIP-Ziel-Shield → Defense / Vehicle
const int FP_MARKER_ATLAS_PARADROP = 10; // Paradrop-Symbol → Paratrooper-Events

const int FP_MARKER_SLOT_EVENT1 = 0;
const int FP_MARKER_SLOT_EVENT2 = 1;
const int FP_MARKER_SLOT_EVENT3 = 2;
const int FP_MARKER_SLOT_EVENT4 = 3;
const int FP_MARKER_SLOT_EVENT5 = 4;

// Setzt oder aktualisiert einen Marker. position muss immer mitgegeben werden (Pflichtfeld laut Doku).
void fpSetEventMarker(Metagame@ metagame, int factionId, int eventSlot,
	const string &in label, const string &in positionStr, int atlasIndex) {
	if (metagame is null) return;
	if (positionStr.length() == 0) return; // keine Position → kein Marker

	int markerId = FP_MARKER_ID_BASE + factionId * FP_MARKER_ID_STRIDE + eventSlot;

	XmlElement c("command");
	c.setStringAttribute("class", "set_marker");
	c.setIntAttribute("id", markerId);
	c.setIntAttribute("faction_id", factionId);
	c.setIntAttribute("atlas_index", atlasIndex);
	c.setFloatAttribute("size", 0.75f);
	c.setFloatAttribute("range", 0.0f);
	c.setIntAttribute("enabled", 1);
	c.setStringAttribute("position", positionStr);
	c.setStringAttribute("text", "[FP] " + label);
	c.setStringAttribute("type_key", "default");
	c.setBoolAttribute("show_in_map_view", true);
	c.setBoolAttribute("show_in_game_view", false);  // nur Karte, nicht 3D-Welt
	c.setBoolAttribute("show_at_screen_edge", true);
	metagame.getComms().send(c);
}

// Aktualisiert Text eines bestehenden Markers — position MUSS mitgegeben werden.
void fpUpdateEventMarker(Metagame@ metagame, int factionId, int eventSlot,
	const string &in label, const string &in positionStr, int atlasIndex) {
	fpSetEventMarker(metagame, factionId, eventSlot, label, positionStr, atlasIndex);
}

// Entfernt den Marker.
void fpClearEventMarker(Metagame@ metagame, int factionId, int eventSlot) {
	if (metagame is null) return;
	int markerId = FP_MARKER_ID_BASE + factionId * FP_MARKER_ID_STRIDE + eventSlot;

	XmlElement c("command");
	c.setStringAttribute("class", "set_marker");
	c.setIntAttribute("id", markerId);
	c.setIntAttribute("faction_id", factionId);
	c.setIntAttribute("enabled", 0);
	metagame.getComms().send(c);
}
