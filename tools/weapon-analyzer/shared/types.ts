export type FactionColor = 'green' | 'brown' | 'grey' | 'other';

// ─── API Response (shared between backend + frontend) ────────────────────────

export interface Weapon {
  key: string;
  name: string;
  category: string;
  factions: FactionColor[];
  accuracy: string;
  price: string;
  commonness: string;
  killProbability: string;
  killDecayStart: string;
  killDecayEnd: string;
  filePath: string | null;
  isModWeapon: boolean;
}

export interface ApiResponse {
  categories: Record<string, Weapon[]>;
  lastUpdated: number;
  stats: {
    total: number;
    categoryCount: number;
  };
}

// ─── Backend-internal (parser output) ────────────────────────────────────────

export interface WeaponStats {
  key: string;
  name: string;
  tag: string;
  accuracy: string;
  retrigger: string;
  magazineSize: string;
  price: string;
  commonness: string;
  canRespawnWith: string;
  inStock: string;
  killProbability: string;
  killDecayStart: string;
  killDecayEnd: string;
  filePath: string | null;
  isModWeapon: boolean;
}

export interface ParsedSoldier {
  name: string;
  spawnScore: number;
  copyFrom: string | null;
  resourceFiles: string[];
  inlineKeys: string[];
  faction: string;
  factionColor: FactionColor;
}
