// Startskript fuer PvP-Invasion (Team-PvP + KI).
// client_faction = Whitelist der Fraktionen, die Spieler joinen duerfen.

#include "path://media/packages/vanilla/scripts"
#include "path://media/packages/RWR_broken_alliances/scripts"

#include "gamemodes/invasion/gamemode_invasion.as"

void main(dictionary@ inputData) {
	_log(">>> BROKEN_ALLIANCES PVP SCRIPT EXECUTED <<<");
	XmlElement inputSettings(inputData);
	_setupLog(inputSettings);
	_log(">>> BROKEN_ALLIANCES OVERLAY ACTIVE <<<");

	UserSettings settings;
	settings.fromXmlElement(inputSettings);

	// 0=Greenbelts, 1=Greycollars, 2=Brownpants (Standardauswahl im Menü).
	settings.m_factionChoice = 0;

	array<string> overlays = {
		"media/packages/invasion",              // vanilla invasion overlay (wird bei dir sowieso genutzt)
		"media/packages/RWR_broken_alliances"   // DEIN overlay LAST = overrides
	};
	settings.m_overlayPaths = overlays;

	// mode='PvPvE' = Spieler gegen Spieler + KI-Unterstuetzung auf den Seiten.
	settings.m_startServerCommand = """
<command class='start_server'
	server_name='RWR Broken Alliances PvP Invasion'
	server_port='1240'
	comment='PvP Invasion: alle Fraktionen spielbar'
	url=''
	register_in_serverlist='1'
	mode='PvPvE'
	persistency='forever'
	max_players='64'>
	<client_faction id='0' />
	<client_faction id='1' />
	<client_faction id='2' />
</command>
""";

	settings.print();

	GameModeInvasion metagame(settings);
	metagame.init();
	metagame.run();
	metagame.uninit();

	_log("ending execution");
}
