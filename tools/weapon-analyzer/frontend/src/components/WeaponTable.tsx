import { useMemo } from 'react';
import type { Weapon, FactionColor } from '../types.ts';

// ─── Column Config ────────────────────────────────────────────────────────

const STAT_COLS = [
  { key: 'accuracy', label: 'Accuracy', higher: true },
  { key: 'killProbability', label: 'Kill%', higher: true },
  { key: 'killDecayStart', label: 'Decay Start', higher: true },
  { key: 'killDecayEnd', label: 'Decay End', higher: true },
  { key: 'price', label: 'Preis', higher: false },
  { key: 'commonness', label: 'Commonness', higher: true },
] as const;

type ColKey = (typeof STAT_COLS)[number]['key'];

// ─── Highlighting ─────────────────────────────────────────────────────────

interface MinMax {
  best: number;
  worst: number;
}

function computeHighlights(weapons: Weapon[]): Partial<Record<ColKey, MinMax>> {
  const result: Partial<Record<ColKey, MinMax>> = {};

  for (const col of STAT_COLS) {
    const values = weapons
      .map((w) => parseFloat((w as Record<string, string>)[col.key]))
      .filter((v) => !isNaN(v) && v > 0);
    if (values.length < 2) continue;

    result[col.key] = {
      best: col.higher ? Math.max(...values) : Math.min(...values),
      worst: col.higher ? Math.min(...values) : Math.max(...values),
    };
  }

  return result;
}

function highlightClass(value: string, key: ColKey, hl: Partial<Record<ColKey, MinMax>>): string {
  const num = parseFloat(value);
  const mm = hl[key];
  if (isNaN(num) || !mm || mm.best === mm.worst) return '';
  if (num === mm.best) return 'bg-green-500/15 text-green-400';
  if (num === mm.worst) return 'bg-red-500/15 text-red-400';
  return '';
}

// ─── Faction Badges ───────────────────────────────────────────────────────

const FACTION_STYLE: Record<FactionColor, string> = {
  green: 'bg-green-900/40 text-green-400 border-green-800/60',
  brown: 'bg-amber-900/40 text-amber-400 border-amber-800/60',
  grey: 'bg-gray-700/40 text-gray-300 border-gray-600/60',
  other: 'bg-gray-800/40 text-gray-500 border-gray-700/60',
};

const FACTION_LABEL: Record<FactionColor, string> = {
  green: 'USA',
  brown: 'RU',
  grey: 'EU',
  other: '?',
};

// ─── Component ────────────────────────────────────────────────────────────

export function WeaponTable({ weapons }: { weapons: Weapon[] }) {
  const highlights = useMemo(() => computeHighlights(weapons), [weapons]);

  if (!weapons.length) {
    return (
      <div className="py-20 text-center text-gray-600">
        Keine Waffen in dieser Auswahl.
      </div>
    );
  }

  return (
    <table className="w-full text-sm mt-4">
      <thead>
        <tr className="border-b border-gray-800 text-gray-500 text-xs uppercase tracking-wider">
          <th className="text-left py-3 px-3 font-medium">Name</th>
          <th className="text-left py-3 px-3 font-medium">Fraktionen</th>
          {STAT_COLS.map((col) => (
            <th key={col.key} className="text-right py-3 px-3 font-medium">
              {col.label}
            </th>
          ))}
        </tr>
      </thead>
      <tbody>
        {weapons.map((w) => (
          <tr
            key={w.key}
            className="border-b border-gray-800/40 hover:bg-gray-800/30 transition-colors"
          >
            <td className="py-2.5 px-3">
              <div className="font-medium text-gray-100">{w.name}</div>
              <div className="text-xs text-gray-600 font-mono">{w.key}</div>
            </td>
            <td className="py-2.5 px-3">
              <div className="flex gap-1 flex-wrap">
                {w.factions.length
                  ? w.factions.map((f) => (
                      <span
                        key={f}
                        className={`px-2 py-0.5 text-xs rounded border ${FACTION_STYLE[f]}`}
                      >
                        {FACTION_LABEL[f]}
                      </span>
                    ))
                  : <span className="text-gray-700 text-xs">–</span>}
              </div>
            </td>
            {STAT_COLS.map((col) => {
              const val = (w as Record<string, string>)[col.key];
              return (
                <td
                  key={col.key}
                  className={`py-2.5 px-3 text-right font-mono tabular-nums ${highlightClass(val, col.key, highlights)}`}
                >
                  {val === 'N/A'
                    ? <span className="text-gray-700 italic">N/A</span>
                    : val}
                </td>
              );
            })}
          </tr>
        ))}
      </tbody>
    </table>
  );
}
