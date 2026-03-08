import {
  Crosshair,
  Target,
  Shield,
  Zap,
  Circle,
  Sword,
  Bomb,
  LayoutList,
  type LucideIcon,
} from 'lucide-react';

const ICONS: Record<string, LucideIcon> = {
  assault: Crosshair,
  sniper: Target,
  mg: Shield,
  smg: Zap,
  shotgun: Circle,
  melee: Sword,
  explosive: Bomb,
};

interface Props {
  categories: string[];
  counts: Record<string, number>;
  active: string;
  onSelect: (cat: string) => void;
}

export function CategoryTabs({ categories, counts, active, onSelect }: Props) {
  return (
    <aside className="w-52 bg-gray-900 border-r border-gray-800 flex flex-col shrink-0">
      <div className="px-4 py-4 border-b border-gray-800">
        <h2 className="text-xs font-semibold text-gray-500 uppercase tracking-widest">
          Kategorien
        </h2>
      </div>
      <nav className="flex-1 overflow-y-auto py-1">
        {categories.map((cat) => {
          const Icon = ICONS[cat] ?? LayoutList;
          const isActive = cat === active;
          return (
            <button
              key={cat}
              onClick={() => onSelect(cat)}
              className={[
                'w-full flex items-center gap-3 px-4 py-2.5 text-sm transition-colors',
                'border-l-2',
                isActive
                  ? 'bg-gray-800 text-white border-blue-400'
                  : 'text-gray-400 hover:bg-gray-800/40 hover:text-gray-200 border-transparent',
              ].join(' ')}
            >
              <Icon size={15} className={isActive ? 'text-blue-400' : 'text-gray-600'} />
              <span className="flex-1 capitalize text-left">{cat}</span>
              <span className={`text-xs tabular-nums ${isActive ? 'text-blue-400' : 'text-gray-600'}`}>
                {counts[cat] ?? 0}
              </span>
            </button>
          );
        })}
      </nav>
    </aside>
  );
}
