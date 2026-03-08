import fs from 'fs/promises';
import path from 'path';

export async function walkFiles(dir: string, ext: string): Promise<string[]> {
  const out: string[] = [];
  let entries;
  try {
    entries = await fs.readdir(dir, { withFileTypes: true });
  } catch {
    return out;
  }
  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...(await walkFiles(full, ext)));
    else if (entry.name.endsWith(ext)) out.push(full);
  }
  return out;
}
