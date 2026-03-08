import { useState, useEffect, useCallback, useRef } from 'react';
import type { Weapon, ApiResponse } from '../types.ts';

interface WeaponsState {
  categories: Record<string, Weapon[]>;
  stats: ApiResponse['stats'] | null;
  loading: boolean;
  error: string | null;
}

export function useWeaponsData(pollInterval = 3000): WeaponsState {
  const [state, setState] = useState<WeaponsState>({
    categories: {},
    stats: null,
    loading: true,
    error: null,
  });

  const tsRef = useRef(0);

  const fetchData = useCallback(async () => {
    try {
      const res = await fetch('/api/weapons');
      if (!res.ok) throw new Error(`HTTP ${res.status}`);

      const json: ApiResponse = await res.json();
      if (json.lastUpdated === tsRef.current) return;

      tsRef.current = json.lastUpdated;
      setState({
        categories: json.categories,
        stats: json.stats,
        loading: false,
        error: null,
      });
    } catch (e) {
      setState((prev) => ({
        ...prev,
        loading: false,
        error: (e as Error).message,
      }));
    }
  }, []);

  useEffect(() => {
    fetchData();
    const id = setInterval(fetchData, pollInterval);
    return () => clearInterval(id);
  }, [fetchData, pollInterval]);

  return state;
}
