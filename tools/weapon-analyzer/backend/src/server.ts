import express from 'express';
import path from 'path';
import { ModParserService } from './services/mod-parser.service.js';
import { FileWatcherService } from './services/file-watcher.service.js';
import { createWeaponsRouter } from './routes/weapons.route.js';
import { PORT } from './config.js';

export async function createServer(): Promise<void> {
  const parser = new ModParserService();
  const watcher = new FileWatcherService(() => parser.refresh());

  await parser.refresh();
  watcher.start();

  const app = express();

  // In production: serve built frontend
  const frontendDist = path.resolve(__dirname, '../../frontend/dist');
  app.use(express.static(frontendDist));

  app.use('/api', createWeaponsRouter(parser));

  // SPA fallback (nur wenn frontend gebaut ist)
  app.get('*', (_req, res, next) => {
    if (_req.path.startsWith('/api')) return next();
    res.sendFile(path.join(frontendDist, 'index.html'), (err) => {
      if (err) next();
    });
  });

  const server = app.listen(PORT, () => {
    console.log(`\n  ✔ API: http://localhost:${PORT}/api/weapons\n`);
  });

  server.on('error', (err: NodeJS.ErrnoException) => {
    if (err.code === 'EADDRINUSE') {
      console.log(`[server] Port ${PORT} belegt, versuche ${PORT + 1}...`);
      app.listen(PORT + 1, () => {
        console.log(`\n  ✔ API: http://localhost:${PORT + 1}/api/weapons\n`);
      });
    } else {
      throw err;
    }
  });
}
