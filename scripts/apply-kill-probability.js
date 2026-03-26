/**
 * Kill-Probability-Regelwerk:
 * - MP: 0.6-1.0 (unverändert, je nach Waffe)
 * - Rifles: 0.8-1.1 (Brown im oberen Bereich als Ausgleich)
 * - Sniper: 1.8-2.0 | MG: 1.4 | DMR: 1.1-1.2
 */
const fs = require('fs');
const path = require('path');

const WEAPONS_DIR = path.join(__dirname, '..', 'weapons');

// MP: 0.6-1.0 – unverändert lassen
const MP_WHITELIST = new Set([
  'p90', 'mp7', 'mp5sd', 'kriss_vector', 'scorpion-evo', 'steyr_tmp', 'mini_uzi',
  'qcw-05', 'aek_919k', 'bizon', 'ump40', 'mx4_storm', 'honey_badger', 'gun_tommy'
]);

const SNIPER_BOLT = new Set([
  'barrett_m107', 'm200', 'psg90', 'sv98', 'lahti_l39', 'm24_a2', 'truvelo_amris', 'ns2000'
]);

const DMR = new Set([
  'scarssr', 'apr', 'g28', 'm14_ebr', 'vss_vintorez', 'dragunov_svd', 'm4a1_scope'
]);

const EXCLUDE = new Set(['taser_medic', 'pepperdust']);

const MG = new Set([
  'mg4', 'stoner_lmg', 'ultimax', 'ultimax_m', 'pkm', 'm249', 'm240', 'imi_negev',
  'mg42', 'rpk74m', 'rpk16', 'rpk16_long', 'mg08_heavy_custom22', 'qjz89_volk',
  'm1917_savage_lewis', 'deployable_mg', 'fn_evolys', 'vulcan_tank_mg', 'gepard_m6_lynx',
  'pecheneg_bullpup', 'buggy_mg', 'humvee_mg', 'patrol_ship_mg', 'technical_mg',
  'tank_mg', 'tank_mg_1', 'tank_mg_2', 'wiesel_mg3', 'vfs_buggy_mg'
]);

// Brown-Rifles: oberer Bereich 1.0-1.1 (Ausgleich für retrigger-Nachteil)
const BROWN_RIFLE_UPPER = new Map([
  ['ak47', '1.1'], ['ak47_w_gp25', '1.1'], ['aks74u', '1.0'], ['an94_burst', '1.0'],
  ['saiga12k', '1.0'], ['pb', '0.95']  // PB Pistole
]);

// Green/Grey Rifles: 0.8-1.0
const RIFLE_MID = new Map([
  ['hk416', '0.9'], ['g36', '0.9'], ['m16a4', '0.9'], ['f2000', '0.9'], ['famasg1', '0.9'],
  ['steyr_aug', '0.9'], ['l85a2', '0.9'], ['sg552', '0.9'], ['xm8', '0.9'], ['g36_w_ag36', '0.9'],
  ['m16a4_w_m203', '0.9'], ['m16a4_support', '0.85'], ['qbz95', '0.9'], ['qbz95_us', '0.9'],
  ['qbz95_shotgun', '0.9'], ['qbs-09', '0.9'], ['gilboa_dbr', '0.9'], ['tti', '0.9'],
  // Shotguns
  ['benelli_m4', '0.9'], ['benelli_m4_supp', '0.85'], ['caws', '0.8'], ['uts15', '0.85'],
  ['mossberg', '0.9'], ['spas-12', '0.9'], ['aa-12', '0.85'], ['jackhammer', '0.85'],
  ['origin_12', '0.85'], ['origin_12_s', '0.85'],
  // Pistolen
  ['glock17', '0.85'], ['beretta_m9', '0.85'], ['beretta_93r', '0.85'], ['desert_eagle', '0.9'],
  ['desert_eagle_gold', '0.9'], ['m712', '0.85'], ['model_29', '0.85'],
  // Sonstige
  ['compound_bow', '0.9'], ['compound_bow_alt', '0.9'], ['sawnoff', '0.85'],
  ['m1_garand_m', '0.9']
]);

// Rest: 0.85 (Pistolen, Vehicle, etc.)
const DEFAULT_RIFLE = '0.85';

function getKey(filePath) {
  return path.basename(filePath, '.weapon');
}

function getTargetKillProb(key) {
  if (MP_WHITELIST.has(key) || EXCLUDE.has(key)) return null;
  if (SNIPER_BOLT.has(key)) {
    if (key === 'm200') return '2.0';
    if (key === 'barrett_m107') return '1.8';
    return '1.8';
  }
  if (DMR.has(key)) {
    if (key === 'vss_vintorez') return '1.1';
    return '1.2';
  }
  if (MG.has(key)) return '1.4';
  if (BROWN_RIFLE_UPPER.has(key)) return BROWN_RIFLE_UPPER.get(key);
  if (RIFLE_MID.has(key)) return RIFLE_MID.get(key);
  return DEFAULT_RIFLE;
}

function processFile(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  const key = getKey(filePath);
  const target = getTargetKillProb(key);
  if (target === null) return { changed: false, key, target: 'MP/excl' };

  const match = content.match(/kill_probability="([^"]+)"/);
  if (!match) return { changed: false, key, target: 'no match' };
  const current = match[1];
  if (current === target) return { changed: false, key, target };

  content = content.replace(/kill_probability="[^"]+"/, `kill_probability="${target}"`);
  fs.writeFileSync(filePath, content, 'utf8');
  return { changed: true, key, from: current, to: target };
}

function walkDir(dir, files = []) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const e of entries) {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) walkDir(full, files);
    else if (e.name.endsWith('.weapon') && fs.readFileSync(full, 'utf8').includes('kill_probability')) {
      files.push(full);
    }
  }
  return files;
}

const files = walkDir(WEAPONS_DIR);
const results = files.map(processFile);
const changed = results.filter(r => r.changed);

console.log(`Verarbeitet: ${files.length} Waffen`);
console.log(`Geändert: ${changed.length}`);
changed.forEach(r => console.log(`  ${r.key}: ${r.from} → ${r.to}`));
