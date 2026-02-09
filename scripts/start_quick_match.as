// Quick-Match-Einstieg: Wird von der Engine aufgerufen, wenn mit diesem Mod
// „Schnelles Spiel“ / Quick Match gestartet wird (quick_match_entry_script in package_config.xml).
#include "path://media/packages/vanilla/scripts"
#include "path://media/packages/RWR_total_conversion_mod/scripts"

#include "gamemode_quick_match.as"

void main(dictionary@ inputData) {
	XmlElement inputSettings(inputData);
	_setupLog(inputSettings);

	GameModeQuickMatch metagame(inputSettings);
	metagame.init();
	metagame.run();
	metagame.uninit();

	_log("ending execution");
}
