#include "metagame.as"

// Event-Strategy (Strategy = austauschbare Event-Logik in eigener Klasse).
interface FactionPointsEvent {
	string getCommandToken() const;
	string getDisplayName() const;
	int getCost() const;
	bool isPlayerEvent() const;
	float getAnnouncementDelaySeconds() const;
	string getFriendlyAnnouncementText() const;
	string getFriendlyExecutionText() const;
	string getEnemyAnnouncementText() const;
	string getEnemyExecutionText() const;

	// reason = Fehlergrund bei false
	bool canExecute(int playerId, int factionId, string &out reason);
	// result = Erfolgstext bei true, Fehlertext bei false
	bool execute(int playerId, int factionId, string &out result);
}

