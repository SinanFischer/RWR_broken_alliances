import { useState, useMemo, useEffect } from 'react';
import { useWeaponsData } from './hooks/useWeaponsData.ts';
import { CategoryTabs } from './components/CategoryTabs.tsx';
import { FactionFilter } from './components/FactionFilter.tsx';
import { WeaponTable } from './components/WeaponTable.tsx';
import type { FactionColor } from './types.ts';

const CATEGORY_ORDER = ['assault', 'sniper', 'mg', 'smg', 'shotgun', 'pistol', 'melee', 'explosive'];

function sortCategories(names: string[]): string[] {
  return [...names].sort((a, b) => {
    const ia = CATEGORY_ORDER.indexOf(a);
    const ib = CATEGORY_ORDER.indexOf(b);
    if (ia >= 0 && ib >= 0) return ia - ib;
    if (ia >= 0) return -1;
    if (ib >= 0) return 1;
    return a.localeCompare(b);
  });
}

export function App() {
  const { categories, stats, loading, error } = useWeaponsData();
  const [activeCategory, setActiveCategory] = useState('');
  const [activeFaction, setActiveFaction] = useState<FactionColor | 'all'>('all');

  const categoryNames = useMemo(
    () => sortCategories(Object.keys(categories)),
    [categories],
  );

  const counts = useMemo(
    () => Object.fromEntries(Object.entries(categories).map(([k, v]) => [k, v.length])),
    [categories],
  );

  useEffect(() => {
    if (categoryNames.length && !categoryNames.includes(activeCategory)) {
      setActiveCategory(categoryNames[0]);
    }
  }, [categoryNames, activeCategory]);

  const weapons = useMemo(() => {
    const list = categories[activeCategory] ?? [];
    if (activeFaction === 'all') return list;
    return list.filter((w) => w.factions.includes(activeFaction));
  }, [categories, activeCategory, activeFaction]);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen bg-gray-950 text-gray-500 text-lg">
        Lade Daten…
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-screen bg-gray-950 text-red-400 text-lg">
        Fehler: {error}
      </div>
    );
  }

  return (
    <div className="flex h-screen bg-gray-950 text-gray-100">
      <CategoryTabs
        categories={categoryNames}
        counts={counts}
        active={activeCategory}
        onSelect={setActiveCategory}
      />

      <main className="flex-1 flex flex-col overflow-hidden">
        <header className="flex items-center justify-between px-6 py-4 border-b border-gray-800 shrink-0">
          <div>
            <h1 className="text-xl font-semibold tracking-tight">RWR Weapon Analyzer</h1>
            <p className="text-sm text-gray-500 mt-0.5">
              <span className="capitalize font-medium text-gray-300">{activeCategory || '…'}</span>
              {' · '}
              {weapons.length} Waffen
            </p>
          </div>
          {stats && (
            <div className="text-xs text-gray-600">
              {stats.total} total · {stats.categoryCount} Kategorien
            </div>
          )}
        </header>

        <FactionFilter active={activeFaction} onChange={setActiveFaction} />

        <div className="flex-1 overflow-auto px-6 pb-8">
          <WeaponTable weapons={weapons} />
        </div>
      </main>
    </div>
  );
}
