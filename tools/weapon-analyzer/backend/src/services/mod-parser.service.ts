import type { Weapon, WeaponStats, ParsedSoldier, FactionColor, ApiResponse } from '../types.js';
import { parseAllWeapons } from '../parsers/weapon.parser.js';
import { parseAllResources } from '../parsers/resource.parser.js';
import { parseAllFactions } from '../parsers/faction.parser.js';

export class ModParserService {
  private cache: Record<string, Weapon[]> = {};
  private lastUpdated = 0;
  private parsing = false;

  async refresh(): Promise<void> {
    if (this.parsing) return;
    this.parsing = true;

    try {
      const t0 = Date.now();
      const [weaponMap, resourceMap, soldiers] = await Promise.all([
        parseAllWeapons(),
        parseAllResources(),
        parseAllFactions(),
      ]);

      this.cache = this.buildCategories(weaponMap, resourceMap, soldiers);
      this.lastUpdated = Date.now();

      const total = Object.values(this.cache).flat().length;
      console.log(
        `[parser] ${Date.now() - t0}ms | ${weaponMap.size} weapons | ` +
          `${resourceMap.size} resources | ${soldiers.length} soldiers | ` +
          `${Object.keys(this.cache).length} categories | ${total} total`,
      );
    } catch (e) {
      console.error('[parser] Refresh failed:', (e as Error).message);
    } finally {
      this.parsing = false;
    }
  }

  getData(): ApiResponse {
    const total = Object.values(this.cache).flat().length;
    return {
      categories: this.cache,
      lastUpdated: this.lastUpdated,
      stats: {
        total,
        categoryCount: Object.keys(this.cache).length,
      },
    };
  }

  // ─── Core Linking ────────────────────────────────────────────────────────

  /**
   * 1. Baut eine FactionMap: weaponKey → Set<FactionColor>
   * 2. Transformiert WeaponStats → Weapon (mit category + factions)
   * 3. Gruppiert nach Kategorie
   */
  private buildCategories(
    weaponMap: Map<string, WeaponStats>,
    resourceMap: Map<string, string[]>,
    soldiers: ParsedSoldier[],
  ): Record<string, Weapon[]> {
    const factionMap = this.buildFactionMap(resourceMap, soldiers);
    const categories: Record<string, Weapon[]> = {};

    for (const [key, stats] of weaponMap) {
      const weapon = this.toWeapon(key, stats, factionMap.get(key));
      (categories[weapon.category] ??= []).push(weapon);
    }

    for (const [key, factions] of factionMap) {
      if (weaponMap.has(key)) continue;
      const weapon = this.toWeaponFromKey(key, factions);
      (categories[weapon.category] ??= []).push(weapon);
    }

    for (const list of Object.values(categories)) {
      list.sort((a, b) => a.name.localeCompare(b.name));
    }

    return categories;
  }

  private toWeapon(key: string, stats: WeaponStats, factions?: Set<FactionColor>): Weapon {
    return {
      key,
      name: stats.name,
      category: stats.tag.split(', ')[0] || 'uncategorized',
      factions: this.normalizeFactions(factions),
      accuracy: stats.accuracy,
      price: stats.price,
      commonness: stats.commonness,
      killProbability: stats.killProbability,
      killDecayStart: stats.killDecayStart,
      killDecayEnd: stats.killDecayEnd,
      filePath: stats.filePath,
      isModWeapon: true,
    };
  }

  private toWeaponFromKey(key: string, factions: Set<FactionColor>): Weapon {
    return {
      key,
      name: key.replace('.weapon', ''),
      category: 'uncategorized',
      factions: this.normalizeFactions(factions),
      accuracy: 'N/A',
      price: 'N/A',
      commonness: '0',
      killProbability: 'N/A',
      killDecayStart: 'N/A',
      killDecayEnd: 'N/A',
      filePath: null,
      isModWeapon: false,
    };
  }

  private normalizeFactions(factions?: Set<FactionColor>): FactionColor[] {
    if (!factions) return [];
    return [...factions].filter((f): f is Exclude<FactionColor, 'other'> => f !== 'other').sort();
  }

  // ─── Faction Mapping ────────────────────────────────────────────────────

  private buildFactionMap(
    resourceMap: Map<string, string[]>,
    soldiers: ParsedSoldier[],
  ): Map<string, Set<FactionColor>> {
    const map = new Map<string, Set<FactionColor>>();

    for (const soldier of soldiers) {
      const keys = this.collectWeaponKeys(soldier, resourceMap);
      for (const key of keys) {
        if (!map.has(key)) map.set(key, new Set());
        map.get(key)!.add(soldier.factionColor);
      }
    }

    return map;
  }

  private collectWeaponKeys(
    soldier: ParsedSoldier,
    resourceMap: Map<string, string[]>,
  ): Set<string> {
    const keys = new Set<string>();
    for (const resFile of soldier.resourceFiles) {
      for (const k of resourceMap.get(resFile) ?? []) keys.add(k);
    }
    for (const k of soldier.inlineKeys) keys.add(k);
    return keys;
  }
}
