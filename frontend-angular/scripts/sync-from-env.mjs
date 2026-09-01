import fs from 'node:fs';
import path from 'node:path';
import { deriveBaseHrefFromAppBase } from './derive-base-href.mjs';
import { frontendRoot, readEnvVar } from './read-env.mjs';

const appConfigLocalPath = path.join(frontendRoot, 'src', 'assets', 'app-config.local.js');

function syncLocalApiKeys() {
  const hereApiKey = readEnvVar('HERE_API_KEY');
  const cartoApiKey = readEnvVar('CARTO_API_KEY');
  const localConfigContent = `// Локальний runtime-конфіг (генерується автоматично, не комітити).
window.__APP_CONFIG__ = {
  ...(window.__APP_CONFIG__ || {}),
  hereApiKey: ${JSON.stringify(hereApiKey)},
  cartoApiKey: ${JSON.stringify(cartoApiKey)}
};
`;
  fs.writeFileSync(appConfigLocalPath, localConfigContent, 'utf8');
}

function validateLinkBases() {
  const angularAppBase = readEnvVar('ANGULAR_APP_BASE_URL');
  const baseHref = deriveBaseHrefFromAppBase(angularAppBase);

  if (angularAppBase) {
    console.log(`[sync-from-env] Angular base-href (з ANGULAR_APP_BASE_URL): ${baseHref}`);
  }

  return baseHref;
}

syncLocalApiKeys();
validateLinkBases();
