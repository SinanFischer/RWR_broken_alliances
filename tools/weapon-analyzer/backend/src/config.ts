import path from 'path';

// RWR_MOD_PATH kann als Env-Variable gesetzt werden (z.B. via .env).
// Fallback: 4 Ebenen nach oben vom dist/-Ordner (Standard-Position innerhalb der Mod).
export const BASE_PATH = process.env.RWR_MOD_PATH
  ? path.resolve(process.env.RWR_MOD_PATH)
  : path.resolve(__dirname, '..', '..', '..', '..');

export const WEAPONS_DIR = path.join(BASE_PATH, 'weapons');
export const FACTIONS_DIR = path.join(BASE_PATH, 'factions');
export const PORT = parseInt(process.env.PORT || '3001', 10);

// Startup-Log zur schnellen Verifikation des genutzten Pfades
console.log(`[config] MOD_PATH = ${BASE_PATH}`);
