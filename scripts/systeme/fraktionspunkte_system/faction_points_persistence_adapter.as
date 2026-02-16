#include "metagame.as"
#include "query_helpers.as"
#include "log.as"

const string FP_SAVE_FILENAME = "faction_points.xml";
const string FP_SAVE_LOCATION = "savegame";

// Persistenz-Adapter (Adapter = austauschbare Schicht zwischen Store und Speicher-Backend).
// Diese Implementierung nutzt Engine-Kommandos save_data/saved_data.
class FactionPointsPersistenceAdapter {
	protected Metagame@ m_metagame;

	FactionPointsPersistenceAdapter(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	bool load(array<int> &out pointsByFaction, int expectedFactionCount) {
		if (expectedFactionCount < 0) expectedFactionCount = 0;

		XmlElement@ query = XmlElement(
			makeQuery(m_metagame, array<dictionary> = {
				dictionary = { {"TagName", "data"}, {"class", "saved_data"}, {"filename", FP_SAVE_FILENAME}, {"location", FP_SAVE_LOCATION} }
			})
		);
		const XmlElement@ doc = m_metagame.getComms().query(query);
		if (doc is null) return false;

		const XmlElement@ root = doc.getFirstChild();
		if (root is null || root.getName() != "faction_points") return false;

		pointsByFaction.resize(expectedFactionCount);
		for (int i = 0; i < expectedFactionCount; ++i) {
			pointsByFaction[i] = 0;
		}

		array<const XmlElement@>@ nodes = root.getElementsByTagName("faction");
		for (uint i = 0; i < nodes.size(); ++i) {
			const XmlElement@ node = nodes[i];
			int factionId = node.getIntAttribute("id");
			if (factionId < 0 || factionId >= expectedFactionCount) continue;

			int value = node.getIntAttribute("points");
			if (value < 0) value = 0;
			pointsByFaction[factionId] = value;
		}

		_log("FactionPointsPersistenceAdapter: FP aus Savegame geladen.", 1);
		return true;
	}

	void save(const array<int>@ pointsByFaction) {
		if (pointsByFaction is null) return;

		XmlElement root("faction_points");
		for (uint i = 0; i < pointsByFaction.size(); ++i) {
			XmlElement faction("faction");
			faction.setIntAttribute("id", int(i));
			int value = pointsByFaction[i];
			if (value < 0) value = 0;
			faction.setIntAttribute("points", value);
			root.appendChild(faction);
		}

		XmlElement command("command");
		command.setStringAttribute("class", "save_data");
		command.setStringAttribute("filename", FP_SAVE_FILENAME);
		command.setStringAttribute("location", FP_SAVE_LOCATION);
		command.appendChild(root);
		m_metagame.getComms().send(command);
	}
}

