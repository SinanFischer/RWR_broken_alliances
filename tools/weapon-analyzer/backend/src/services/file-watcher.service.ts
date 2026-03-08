import chokidar from 'chokidar';
import path from 'path';
import { WEAPONS_DIR, FACTIONS_DIR } from '../config.js';

export class FileWatcherService {
  private watcher: chokidar.FSWatcher | null = null;
  private debounceTimer: ReturnType<typeof setTimeout> | null = null;

  constructor(private readonly onChange: () => void) {}

  start(): void {
    this.watcher = chokidar.watch(
      [
        path.join(WEAPONS_DIR, '**/*.weapon'),
        path.join(FACTIONS_DIR, '**/*.resources'),
        path.join(FACTIONS_DIR, '**/*.xml'),
      ],
      {
        ignoreInitial: true,
        awaitWriteFinish: { stabilityThreshold: 300 },
      },
    );

    this.watcher.on('all', (event, fp) => {
      console.log(`[watcher] ${event} ${path.basename(fp)}`);
      this.scheduleRefresh();
    });
  }

  stop(): void {
    this.watcher?.close();
    if (this.debounceTimer) clearTimeout(this.debounceTimer);
  }

  private scheduleRefresh(): void {
    if (this.debounceTimer) clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(this.onChange, 400);
  }
}
