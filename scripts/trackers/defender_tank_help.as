// Panzer-Spawn bei 2 Basen in Folge: Wenn die Verteidiger-Fraktion (faction 0) zwei
// aufeinanderfolgende Basen verliert, spawnt ein Panzer an deren Hauptbasis – immer
// für die Fraktion, die gerade verloren hat (damit die Verteidiger unterstützt werden).

#include "tracker.as"
#include "helpers.as"
#include "log.as"
#include "query_helpers.as"

class DefenderTankHelp : Tracker {
	protected Metagame@ m_metagame;

	// Anzahl Verluste in Folge, um Panzer-Spawn auszulösen (AngelScript: kein const für Klasseneigenschaften)
	protected uint CONSECUTIVE_LOSSES_TRIGGER = 2;
	// Cooldown in Sekunden (10 Min) – verhindert Spam bei schnellem Base-Rush
	protected float COOLDOWN_SECONDS = 600.0f;

	protected uint m_consecutiveLosses = 0;
	protected float m_cooldownTimer = 0.0f;

	// Verteidiger-Fraktion (Spieler/Alliierte in Campaign)
	protected int DEFENDER_FACTION_ID = 0;

	// Fahrzeug-Key: tank_2.vehicle = Hauptkampfpanzer der Mod
	protected string m_tankKey = "tank_2.vehicle";

	DefenderTankHelp(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		int previousOwnerId = event.getIntAttribute("previous_owner_id");
		int newOwnerId = event.getIntAttribute("owner_id");

		// Nur relevant, wenn Verteidiger (faction 0) eine Base verliert
		if (previousOwnerId != DEFENDER_FACTION_ID) {
			m_consecutiveLosses = 0;
			return;
		}

		// Base ging an andere Fraktion – Verteidiger haben verloren
		m_consecutiveLosses++;

		if (m_consecutiveLosses < CONSECUTIVE_LOSSES_TRIGGER) {
			return;
		}

		// Cooldown prüfen
		if (m_cooldownTimer > 0.0f) {
			return;
		}

		// Panzer spawnen für Verteidiger-Fraktion
		spawnTankForDefenders();
		m_consecutiveLosses = 0;
		m_cooldownTimer = COOLDOWN_SECONDS;
	}

	void update(float time) {
		if (m_cooldownTimer > 0.0f) {
			m_cooldownTimer -= time;
		}
	}

	protected void spawnTankForDefenders() {
		const XmlElement@ base = getStartingBase(m_metagame, DEFENDER_FACTION_ID);
		if (base is null) {
			_log("DefenderTankHelp: Keine Basis mehr für Fraktion " + DEFENDER_FACTION_ID + ", kein Panzer-Spawn", 1);
			return;
		}

		string position = base.getStringAttribute("position");
		if (position == "") {
			return;
		}

		// Position leicht erhöhen (Y), damit Spawn sauber auf dem Boden liegt
		Vector3 pos = stringToVector3(position);
		pos.m_values[1] += 5.0f;

		string cmd = "<command class='create_instance' faction_id='" + DEFENDER_FACTION_ID +
			"' position='" + pos.toString() +
			"' instance_class='vehicle' instance_key='" + m_tankKey + "' />";
		m_metagame.getComms().send(cmd);

		// Commander-Meldung: eigener Key (languages/*/defender_tank_mod.character)
		sendFactionMessageKey(m_metagame, DEFENDER_FACTION_ID, "Defender tank reinforcement", dictionary(), 2.0);

		_log("DefenderTankHelp: Panzer gespawnt für Fraktion " + DEFENDER_FACTION_ID + " an " + pos.toString(), 1);
	}

	protected void handleChatEvent(const XmlElement@ event) {
		Tracker::handleChatEvent(event);

		string message = event.getStringAttribute("message");
		if (!startsWith(message, "/")) return;

		string sender = event.getStringAttribute("player_name");
		int senderId = event.getIntAttribute("player_id");
		if (!m_metagame.getAdminManager().isAdmin(sender, senderId)) return;

		// Test-Command: Panzer-Spawn simulieren (Admin only)
		if (checkCommand(message, "test_defender_tank")) {
			spawnTankForDefenders();
			m_cooldownTimer = 0.0f;  // Cooldown für Test zurücksetzen
		}
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }
}
