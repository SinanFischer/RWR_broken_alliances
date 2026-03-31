// Minimales Interface fuer gegenseitigen HUD-Ausschluss (kein zirkulaerer Include).
// Beide HUD-Tracker includen diese Datei; keiner includet den anderen.
// Die Registry verdrahtet die Referenzen nach der Installation.
interface IToggleableHud {
	void setEnabled(bool on);
	bool isEnabled() const;
}
