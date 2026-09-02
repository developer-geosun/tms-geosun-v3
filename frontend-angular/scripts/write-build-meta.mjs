import { execSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { frontendRoot, repoRoot } from './read-env.mjs';

const DEV_COMMIT = 'dev';
const generatedPath = path.join(frontendRoot, 'src', 'environments', 'build-meta.generated.ts');

function readGitValue(args, fallback = DEV_COMMIT) {
  try {
    return execSync(`git ${args}`, { cwd: repoRoot, encoding: 'utf8' }).trim();
  } catch {
    return fallback;
  }
}

const commit = readGitValue('rev-parse --short HEAD');
const commitFull = readGitValue('rev-parse HEAD', commit);
const commitTime = readGitValue('log -1 --format=%cI', '');

const content = `// Автогенеровано scripts/write-build-meta.mjs — не редагувати вручну.
export const buildMeta = {
  commit: ${JSON.stringify(commit)},
  commitFull: ${JSON.stringify(commitFull)},
  commitTime: ${JSON.stringify(commitTime)}
};
`;

fs.writeFileSync(generatedPath, content, 'utf8');
console.log(`[write-build-meta] commit=${commit}`);
