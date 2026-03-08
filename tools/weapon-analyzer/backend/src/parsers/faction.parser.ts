import fs from 'fs/promises';
import path from 'path';
import type { FactionColor, ParsedSoldier } from '../types.js';
import { xmlParser, ensureArray } from '../utils/xml.js';
import { FACTIONS_DIR } from '../config.js';

/* eslint-disable @typescript-eslint/no-explicit-any */

function factionColorFromFile(filePath: string): FactionColor {
  const name = path.basename(filePath, '.xml').toLowerCase();
  if (name.startsWith('green')) return 'green';
  if (name.startsWith('brown')) return 'brown';
  if (name.startsWith('grey')) return 'grey';
  return 'other';
}

async function parseFactionFile(filePath: string): Promise<ParsedSoldier[]> {
  try {
    const raw = await fs.readFile(filePath, 'utf-8');
    const doc: any = xmlParser.parse(raw);
    const faction = doc?.faction;
    if (!faction) return [];

    const factionName: string = faction.name ?? path.basename(filePath, '.xml');
    const color = factionColorFromFile(filePath);
    const soldiers = ensureArray<any>(faction.soldier);
    const out: ParsedSoldier[] = [];

    for (const s of soldiers) {
      if (!s?.name) continue;
      const resList = ensureArray<any>(s.resources);
      const resourceFiles: string[] = [];
      const inlineKeys: string[] = [];

      for (const r of resList) {
        if (typeof r === 'string') continue;
        if (r?.file) resourceFiles.push((r.file as string).replace(/\\/g, '/'));
        for (const w of ensureArray<any>(r?.weapon)) {
          if (w?.key) inlineKeys.push(w.key);
        }
      }

      out.push({
        name: s.name,
        spawnScore: parseFloat(s.spawn_score ?? '0'),
        copyFrom: s.copy_from ?? null,
        resourceFiles,
        inlineKeys,
        faction: factionName,
        factionColor: color,
      });
    }
    return out;
  } catch (e) {
    console.error(`[faction-parser] ${filePath}: ${(e as Error).message}`);
    return [];
  }
}

/**
 * copy_from-Auflösung: Soldier erbt Resources vom Quell-Soldaten
 * derselben Fraktion. Kettenauflösung mit Zykluserkennung.
 */
function resolveCopyFrom(soldiers: ParsedSoldier[]): void {
  const byFaction = new Map<string, Map<string, ParsedSoldier>>();
  for (const s of soldiers) {
    if (!byFaction.has(s.faction)) byFaction.set(s.faction, new Map());
    byFaction.get(s.faction)!.set(s.name, s);
  }

  function resolve(soldier: ParsedSoldier, visited = new Set<string>()): void {
    if (!soldier.copyFrom || visited.has(soldier.name)) return;
    visited.add(soldier.name);

    const src = byFaction.get(soldier.faction)?.get(soldier.copyFrom);
    if (!src) return;
    resolve(src, visited);

    soldier.resourceFiles = [...new Set([...src.resourceFiles, ...soldier.resourceFiles])];
    soldier.inlineKeys = [...new Set([...src.inlineKeys, ...soldier.inlineKeys])];
  }

  for (const s of soldiers) resolve(s);
}

export async function parseAllFactions(): Promise<ParsedSoldier[]> {
  let entries;
  try {
    entries = await fs.readdir(FACTIONS_DIR, { withFileTypes: true });
  } catch {
    return [];
  }

  const xmlFiles = entries
    .filter((e) => !e.isDirectory() && e.name.endsWith('.xml'))
    .map((e) => path.join(FACTIONS_DIR, e.name));

  const nested = await Promise.all(xmlFiles.map(parseFactionFile));
  const all = nested.flat();
  resolveCopyFrom(all);
  return all;
}
