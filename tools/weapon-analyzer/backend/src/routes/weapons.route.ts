import { Router } from 'express';
import type { ModParserService } from '../services/mod-parser.service.js';

export function createWeaponsRouter(parser: ModParserService): Router {
  const router = Router();

  router.get('/weapons', (_req, res) => {
    res.json(parser.getData());
  });

  return router;
}
