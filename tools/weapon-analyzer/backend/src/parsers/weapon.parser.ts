import fs from 'fs/promises';
import path from 'path';
import type { WeaponStats } from '../types.js';
import { xmlParser, ensureArray } from '../utils/xml.js';
import { walkFiles } from '../utils/fs.js';
import { BASE_PATH, WEAPONS_DIR } from '../config.js';

// fast-xml-parser liefert untypisierte Objekte – bewusster any-Cast für XML-Rohdaten
/* eslint-disable @typescript-eslint/no-explicit-any */

async function parseWeaponFile(filePath: string): Promise<WeaponStats | null> {
  try {
    const raw = await fs.readFile(filePath, 'utf-8');
    const doc: any = xmlParser.parse(raw);
    const w = doc?.weapon;
    if (!w?.key) return null;

    const spec = w.specification ?? {};
    const results = ensureArray<any>(w.projectile?.result);
    const hit = results.find((r: any) => r?.class === 'hit') ?? results[0] ?? {};
    const cmn = w.commonness ?? {};
    const tags = ensureArray<any>(w.tag)
      .map((t: any) => t?.name)
      .filter(Boolean);

    return {
      key: w.key,
      name: spec.name ?? 'N/A',
      tag: tags.join(', '),
      accuracy: spec.accuracy_factor ?? 'N/A',
      retrigger: spec.retrigger_time ?? 'N/A',
      magazineSize: spec.magazine_size ?? 'N/A',
      price: w.inventory?.price ?? 'N/A',
      commonness: cmn.value ?? '0',
      canRespawnWith: cmn.can_respawn_with ?? '0',
      inStock: cmn.in_stock ?? '0',
      killProbability: hit.kill_probability ?? 'N/A',
      killDecayStart: hit.kill_decay_start_time ?? 'N/A',
      killDecayEnd: hit.kill_decay_end_time ?? 'N/A',
      filePath: path.relative(BASE_PATH, filePath).replace(/\\/g, '/'),
      isModWeapon: true,
    };
  } catch (e) {
    console.error(`[weapon-parser] ${filePath}: ${(e as Error).message}`);
    return null;
  }
}

export async function parseAllWeapons(): Promise<Map<string, WeaponStats>> {
  const map = new Map<string, WeaponStats>();
  const files = await walkFiles(WEAPONS_DIR, '.weapon');
  const results = await Promise.all(files.map(parseWeaponFile));
  for (const w of results) {
    if (w) map.set(w.key, w);
  }
  return map;
}
