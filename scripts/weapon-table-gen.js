/**
 * Generiert eine Markdown-Tabelle aller Waffen aus RWR_broken_alliances/weapons.
 * Sortierung: Fraktion (EU, USA, RU, Neutral), dann Preis aufsteigend.
 */
const fs = require('fs');
const path = require('path');

const WEAPONS_DIR = path.join(__dirname, '..', 'weapons');

// Fraktion: Ordner → Anzeigename. User-Wunsch: EU, USA, RU, Neutral unten.
const FACTION_MAP = {
  green: 'EU',
  brown: 'RU',
  grey: 'USA',
  common: 'Neutral',
};

// class (RWR weapon class) → Typ-Bezeichnung
const CLASS_MAP = {
  0: 'Gewehr/SMG',
  1: 'Pistol',
  2: 'Sniper',
  3: 'Raketenwerfer',
  4: 'Shotgun',
  5: 'Schwer/Sonstiges',
};

const FACTION_ORDER = ['EU', 'USA', 'RU', 'Neutral'];

function walkWeapons(dir, files = []) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const e of entries) {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) walkWeapons(full, files);
    else if (e.name.endsWith('.weapon') && !e.name.startsWith('base_')) files.push(full);
  }
  return files;
}

function parseWeapon(filePath) {
  const raw = fs.readFileSync(filePath, 'utf-8');
  const rel = path.relative(WEAPONS_DIR, filePath);
  const parts = path.dirname(rel).split(path.sep).filter(Boolean);
  const folder = parts[0] || 'common';
  const faction = FACTION_MAP[folder] ?? 'Neutral';

  // name nur aus <specification>; unterstützt name="..." und name='...'
  const specMatchD = raw.match(/<specification[\s\S]*?\bname="([^"]+)"/);
  const specMatchS = raw.match(/<specification[\s\S]*?\bname='([^']+)'/);
  const name = (specMatchD && specMatchD[1]) || (specMatchS && specMatchS[1]) || path.basename(filePath, '.weapon');
  const priceMatch = raw.match(/price="([^"]+)"/);
  const price = priceMatch ? parseFloat(priceMatch[1]) : 0;
  const classMatch = raw.match(/<specification[\s\S]*?\bclass="([^"]+)"/);
  const cls = classMatch ? classMatch[1] : '5';
  const type = CLASS_MAP[cls] ?? CLASS_MAP[5];

  return { name, faction, type, price };
}

const files = walkWeapons(WEAPONS_DIR);
const weapons = files.map(parseWeapon);

// Sort: Fraktion (EU, USA, RU, Neutral), dann Preis
weapons.sort((a, b) => {
  const idxA = FACTION_ORDER.indexOf(a.faction);
  const idxB = FACTION_ORDER.indexOf(b.faction);
  if (idxA !== idxB) return idxA - idxB;
  return a.price - b.price;
});

// Markdown-Tabelle
const rows = weapons.map((w) => `| ${w.name} | ${w.faction} | ${w.type} | ${w.price} |`);
const md = [
  '| Waffenname | Fraktion | Typ | Preis |',
  '|------------|----------|-----|-------|',
  ...rows,
].join('\n');

const outPath = path.join(__dirname, '..', 'WEAPON_TABLE.md');
fs.writeFileSync(outPath, md, 'utf-8');
console.log(`Tabelle geschrieben: ${outPath} (${weapons.length} Waffen)`);
