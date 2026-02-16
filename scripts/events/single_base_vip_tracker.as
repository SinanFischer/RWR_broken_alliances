// single_base_vip_tracker.as
// Wenn eine Fraktion nur eine Base hat: VIP-Squad spawnen (Captain + Bodyguards + 5 Soldaten + Miniboss),
// 60 Sekunden an der Base halten, dann Release (KI läuft frei).
// Baut auf CaptainSpawnCommandTracker auf (Marker, Tod, Spawn-Logik).

#include "tracker.as"
#include "log.as"
#include "helpers.as"
#include "query_helpers.as"
#include "events/captain_spawn_command_tracker.as"
// MAX_FACTIONS kommt aus captain_spawn_command_tracker.as

const float CHECK_INTERVAL = 5.0f;   // Abstand zwischen Prüfungen
const float FIRST_CHECK_DELAY = 5.0f;  // Erste Prüfung erst 5s nach Match-Start (Karte/Basen stabil)

// --------------------------------------------
class SingleBaseVipTracker : Tracker {
	protected Metagame@ m_metagame;
	protected CaptainSpawnCommandTracker@ m_captainTracker;
	protected bool m_started = false;
	protected float m_timer = FIRST_CHECK_DELAY;  // Erste Prüfung nach 5s
	// Pro Fraktion: bereits VIP für diese Fraktion gespawnt (einmalig pro Match-Zustand "1 Base")
	protected array<bool> m_vipSpawnedByFaction;

	SingleBaseVipTracker(Metagame@ metagame, CaptainSpawnCommandTracker@ captainTracker) {
		@m_metagame = metagame;
		@m_captainTracker = captainTracker;
		m_vipSpawnedByFaction.resize(MAX_FACTIONS);
		for (int i = 0; i < MAX_FACTIONS; ++i) m_vipSpawnedByFaction[i] = false;
	}

	void start() { m_started = true; }

	void update(float time) {
		if (m_captainTracker is null) return;
		m_timer -= time;
		if (m_timer > 0.0f) return;
		m_timer = CHECK_INTERVAL;

		array<const XmlElement@>@ bases = getBases(m_metagame);
		if (bases is null) return;

		for (int fid = 0; fid < MAX_FACTIONS; ++fid) {
			if (m_vipSpawnedByFaction[fid]) continue;
			int count = 0;
			string positionStr = "";
			int baseId = -1;
			for (uint i = 0; i < bases.size(); ++i) {
				int ownerId = bases[i].getIntAttribute("owner_id");
				if (ownerId == fid) {
					count++;
					if (count == 1) {
						positionStr = bases[i].getStringAttribute("position");
						baseId = bases[i].getIntAttribute("id");
					}
				}
			}
			if (count != 1 || baseId < 0) continue;

			Vector3 pos = stringToVector3(positionStr);
			m_captainTracker.spawnSingleBaseVipSquadAt(fid, pos, baseId);
			m_vipSpawnedByFaction[fid] = true;
			_log("SingleBaseVipTracker: VIP gespawnt für Fraktion " + fid + " (nur 1 Base)", 1);
		}
	}

	bool hasStarted() const { return m_started; }
	bool hasEnded() const { return false; }
}
