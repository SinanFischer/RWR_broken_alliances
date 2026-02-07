// Bullet-Flyby-Effekt: Bei Spieler-Treffer (player_wound) Zusatz-Sound an Spielerposition.
// Echter "Near-Miss" (Kugel fliegt vorbei ohne Treffer) ist mit der aktuellen Script-API nicht
// möglich – die Engine sendet kein Event für nahe vorbeifliegende Projektile.

#include "tracker.as"
#include "helpers.as"
#include "log.as"

class BulletFlybyEffect : Tracker {
	protected Metagame@ m_metagame;
	// Vanilla-Sound für "nahe" Wirkung (Flugzeug-Flyby klingt ähnlich wie starker Vorbeiflug)
	protected string m_flybySound = "barrier_bullet_01.wav";

	BulletFlybyEffect(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	protected void handlePlayerWoundEvent(const XmlElement@ event) {
		array<const XmlElement@>@ targetNodes = event.getElementsByTagName("target");
		if (targetNodes.size() == 0) return;

		string position = targetNodes[0].getStringAttribute("position");
		if (position == "") return;

		// Sound an Trefferposition abspielen (wirkt für lokalen Spieler nah/zentral)
		XmlElement cmd("command");
		cmd.setStringAttribute("class", "play_sound");
		cmd.setStringAttribute("filename", m_flybySound);
		cmd.setStringAttribute("position", position);
		m_metagame.getComms().send(cmd);

		// Optional: Falls die Engine jemals "camera_shake" unterstützt, hier testbar:
		// m_metagame.getComms().send("<command class='camera_shake' intensity='0.1' duration='0.15' />");
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }
}
