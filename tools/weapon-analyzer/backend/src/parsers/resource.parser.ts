import fs from 'fs/promises';
import path from 'path';
import { xmlParser, ensureArray } from '../utils/xml.js';
import { walkFiles } from '../utils/fs.js';
import { FACTIONS_DIR } from '../config.js';

/* eslint-disable @typescript-eslint/no-explicit-any */

async function parseResourceFile(filePath: string): Promise<string[]> {
  try {
    const raw = await fs.readFile(filePath, 'utf-8');
    const doc: any = xmlParser.parse(raw);
    const weapons = ensureArray<any>(doc?.resources?.weapon);
    return weapons.map((w: any) => w?.key).filter(Boolean) as string[];
  } catch (e) {
    console.error(`[resource-parser] ${filePath}: ${(e as Error).message}`);
    return [];
  }
}

export async function parseAllResources(): Promise<Map<string, string[]>> {
  const map = new Map<string, string[]>();
  const files = await walkFiles(FACTIONS_DIR, '.resources');
  await Promise.all(
    files.map(async (f) => {
      const rel = path.relative(FACTIONS_DIR, f).replace(/\\/g, '/');
      const keys = await parseResourceFile(f);
      if (keys.length) map.set(rel, keys);
    }),
  );
  return map;
}
