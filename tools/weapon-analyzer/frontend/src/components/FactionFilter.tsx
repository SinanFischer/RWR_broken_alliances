import type { FactionColor } from '../types.ts';

interface Props {
  active: FactionColor | 'all';
  onChange: (f: FactionColor | 'all') => void;
}

const FACTIONS = [
  { key: 'all' as const, label: 'Alle', active: 'border-gray-400 text-gray-200', idle: '' },
  { key: 'green' as const, label: 'USA', active: 'border-green-500 text-green-400', idle: '' },
  { key: 'grey' as const, label: 'EU', active: 'border-gray-400 text-gray-300', idle: '' },
  { key: 'brown' as const, label: 'RU', active: 'border-amber-500 text-amber-400', idle: '' },
] as const;

export function FactionFilter({ active, onChange }: Props) {
  return (
    <div className="flex gap-2 px-6 py-3 border-b border-gray-800 shrink-0">
      {FACTIONS.map((f) => {
        const on = active === f.key;
        return (
          <button
            key={f.key}
            onClick={() => onChange(f.key)}
            className={[
              'px-4 py-1.5 rounded-full text-sm font-medium border transition-all',
              on
                ? `bg-gray-800 ${f.active}`
                : 'border-transparent text-gray-500 hover:text-gray-300',
            ].join(' ')}
          >
            {f.label}
          </button>
        );
      })}
    </div>
  );
}
