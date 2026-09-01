import { spawnSync } from 'node:child_process';
import { deriveBaseHrefFromAppBase } from './derive-base-href.mjs';
import { readEnvVar } from './read-env.mjs';

const angularAppBase = readEnvVar('ANGULAR_APP_BASE_URL');
const baseHref = deriveBaseHrefFromAppBase(angularAppBase);

console.log(`[deploy] base-href=${baseHref} (from ANGULAR_APP_BASE_URL)`);

function run(command, args) {
  const result = spawnSync(command, args, {
    stdio: 'inherit',
    shell: process.platform === 'win32'
  });
  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }
}

run('npx', ['ng', 'build', '--configuration', 'production', `--base-href=${baseHref}`]);
run('npx', ['gh-pages@latest', '-d', 'dist/tms-geosun']);
