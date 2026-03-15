/**
 * Rifle-Preisberechnung nach waffenwert_formeln_v2.md
 * Berechnet Waffenwert und Preis für alle Rifles.
 * 
 * Formel: Preis = 14 × (Waffenwert / Waffenwert_G36)^0.6
 * GL-Varianten: +25%, Honey Badger (suppressed): +100%
 */
const fs = require('fs');
const path = require('path');

const RIFLES = [
  { key: 'g36', file: 'green/g36.weapon', gl: false, suppressed: false },
  { key: 'hk416', file: 'green/hk416.weapon', gl: false, suppressed: false },
  { key: 'm16a4', file: 'green/m16a4.weapon', gl: false, suppressed: false },
  { key: 'm16a4_support', file: 'green/m16a4_support.weapon', gl: false, suppressed: false },
  { key: 'm16a4_w_m203', file: 'green/m16a4_w_m203.weapon', gl: true, suppressed: false },
  { key: 'f2000', file: 'green/f2000.weapon', gl: false, suppressed: false },
  { key: 'famasg1', file: 'green/famasg1.weapon', gl: false, suppressed: false },
  { key: 'steyr_aug', file: 'green/steyr_aug.weapon', gl: false, suppressed: false },
  { key: 'l85a2', file: 'green/l85a2.weapon', gl: false, suppressed: false },
  { key: 'sg552', file: 'green/sg552.weapon', gl: false, suppressed: false },
  { key: 'xm8', file: 'green/xm8.weapon', gl: false, suppressed: false },
  { key: 'g36_w_ag36', file: 'green/g36_w_ag36.weapon', gl: true, suppressed: false },
  { key: 'honey_badger', file: 'green/honey_badger.weapon', gl: false, suppressed: true },
  { key: 'm1_garand_m', file: 'green/m1_garand_m.weapon', gl: false, suppressed: false },
  { key: 'gilboa_dbr', file: 'green/gilboa_dbr.weapon', gl: false, suppressed: false, projectiles_per_shot: 2 },
  { key: 'ak47', file: 'brown/ak47.weapon', gl: false, suppressed: false },
  { key: 'aks74u', file: 'brown/aks74u.weapon', gl: false, suppressed: false },
  { key: 'an94_burst', file: 'brown/an94_burst.weapon', gl: false, suppressed: false },
  { key: 'ak47_w_gp25', file: 'brown/ak47_w_gp25.weapon', gl: true, suppressed: false },
  { key: 'qbz95', file: 'grey/qbz95.weapon', gl: false, suppressed: false },
];

// Parameter-Ranges (Formel v2, erweitert für Ausreißer)
const RANGES = {
  retrigger_time: { min: 0.0333, max: 0.1, lowerBetter: true },
  magazine_size: { min: 25, max: 48, lowerBetter: false },
  accuracy_factor: { min: 0.70, max: 1.0, lowerBetter: false },
  kill_probability: { min: 0.85, max: 1.1, lowerBetter: false },
  projectile_speed: { min: 148, max: 170, lowerBetter: false },
  sight_range_modifier: { min: 1.0, max: 1.2, lowerBetter: false },
  sustained_fire_grow_step: { min: 0.15, max: 0.54, lowerBetter: true },
  sustained_fire_diminish_rate: { min: 0.60, max: 2.0, lowerBetter: false },
};

const WEIGHTS = {
  retrigger_time: 0.22,
  magazine_size: 0.12,
  accuracy_factor: 0.20,
  kill_probability: 0.18,
  projectile_speed: 0.06,
  sight_range_modifier: 0.08,
  sustained_fire_grow_step: 0.06,
  sustained_fire_diminish_rate: 0.08,
};

const EXPONENTS = {
  retrigger_time: 0.65,
  magazine_size: 0.7,
  accuracy_factor: 0.75,
  kill_probability: 0.8,
  projectile_speed: 0.5,
  sight_range_modifier: 0.7,
  sustained_fire_grow_step: 0.6,
  sustained_fire_diminish_rate: 0.6,
};

function clamp(n, lo, hi) {
  return Math.max(lo, Math.min(hi, n));
}

function norm(val, range) {
  if (val == null) return 0;
  const { min, max, lowerBetter } = range;
  let n;
  if (lowerBetter) {
    n = (max - val) / (max - min);
  } else {
    n = (val - min) / (max - min);
  }
  return clamp(n, 0, 1);
}

function score(normVal, param) {
  return Math.pow(normVal, EXPONENTS[param]);
}

function parseWeaponFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const data = {};
  const specs = [
    'retrigger_time', 'magazine_size', 'accuracy_factor', 'sight_range_modifier',
    'projectile_speed', 'sustained_fire_grow_step', 'sustained_fire_diminish_rate',
  ];
  for (const s of specs) {
    const m = content.match(new RegExp(`${s}="([^"]+)"`));
    data[s] = m ? parseFloat(m[1]) : null;
  }
  const killM = content.match(/kill_probability="([^"]+)"/);
  data.kill_probability = killM ? parseFloat(killM[1]) : null;
  if (!data.sight_range_modifier) data.sight_range_modifier = 1.0;
  data.sight_range_modifier = Math.min(data.sight_range_modifier, 1.2);
  return data;
}

const WEAPONS_DIR = path.join(__dirname, '..', 'weapons');
const ANKER = 'g36';
const BASIS = 14;
const ALPHA = 0.6;

const results = [];

for (const r of RIFLES) {
  const filePath = path.join(WEAPONS_DIR, r.file);
  if (!fs.existsSync(filePath)) continue;

  const data = parseWeaponFile(filePath);

  const priceMatch = fs.readFileSync(filePath, 'utf8').match(/price="(\d+)"/);
  const currentPrice = priceMatch ? parseInt(priceMatch[1], 10) : 0;

  let waffenwert = 0;
  const norms = {};
  const scores = {};

  for (const [param, range] of Object.entries(RANGES)) {
    const val = data[param];
    norms[param] = norm(val, range);
    scores[param] = score(norms[param], param);
    waffenwert += WEIGHTS[param] * scores[param];
  }

  results.push({
    key: r.key,
    data,
    norms,
    waffenwert,
    currentPrice,
    gl: r.gl,
    suppressed: r.suppressed,
    projectiles_per_shot: r.projectiles_per_shot,
  });
}

// G36-Waffenwert für Anker (falls nicht in results, Fallback 0.38 aus Formel-Doc)

// Zweiter Durchlauf: Waffenwert_G36 als Anker
const g36Result = results.find(r => r.key === ANKER);
const g36Waffenwert = (g36Result && g36Result.waffenwert > 0) ? g36Result.waffenwert : 0.38;

for (const r of results) {
  let mult = 1;
  if (r.gl) mult *= 1.25;
  if (r.suppressed) mult *= 2;
  if (r.projectiles_per_shot === 2) mult *= 3; // +200% Aufschlag für Doppelschuss
  r.formulaPrice = Math.round(BASIS * Math.pow(r.waffenwert / g36Waffenwert, ALPHA) * mult);
}

// Sort by waffenwert descending
results.sort((a, b) => b.waffenwert - a.waffenwert);

// Output
console.log('=== RIFLE-PREISFORMEL (Anker: G36, Basis 14, α=0.6) ===\n');
console.log('Parameter-Ranges: retrigger 0.0333-0.1 | mag 25-48 | acc 0.70-1.0 | kill 0.85-1.1 | proj 148-170 | sight 1.0-1.2 | grow 0.15-0.54 | diminish 0.60-2.0');
console.log('GL-Varianten: +25% | Honey Badger (suppressed): +100% | Gilboa (projectiles_per_shot=2): +200%\n');

const headers = ['Rifle', 'retrig', 'mag', 'acc', 'kill', 'proj', 'sight', 'grow', 'dim', 'Waffenwert', 'Preis (Formel)', 'Preis (aktuell)'];
console.log(headers.join(' | '));
console.log('-'.repeat(120));

for (const r of results) {
  const d = r.data;
  const row = [
    r.key.padEnd(18),
    (d.retrigger_time ?? '-').toString().padStart(6),
    (d.magazine_size ?? '-').toString().padStart(4),
    (d.accuracy_factor ?? '-').toFixed(2).padStart(5),
    (d.kill_probability ?? '-').toFixed(2).padStart(5),
    (d.projectile_speed ?? '-').toString().padStart(5),
    (d.sight_range_modifier ?? 1).toFixed(2).padStart(5),
    (d.sustained_fire_grow_step ?? '-').toFixed(2).padStart(5),
    (d.sustained_fire_diminish_rate ?? '-').toFixed(2).padStart(5),
    r.waffenwert.toFixed(3).padStart(8),
    r.formulaPrice.toString().padStart(12),
    r.currentPrice.toString().padStart(14),
  ];
  console.log(row.join(' | '));
}

console.log('\n=== Dominanz-Check (Waffenwert > 0.45 = stark) ===');
const strong = results.filter(r => r.waffenwert > 0.45);
console.log(strong.map(r => `${r.key}: ${r.waffenwert.toFixed(3)}`).join(', '));
