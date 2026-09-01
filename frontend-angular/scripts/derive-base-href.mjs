const FRONTEND_ROUTE_SUFFIXES = ['verify-email', 'reset-password'];

/**
 * Визначає Angular base-href з ANGULAR_APP_BASE_URL.
 * Приклад: https://developer-geosun.github.io/tms-geosun-v3 → /tms-geosun-v3/
 */
export function deriveBaseHrefFromAppBase(appBase) {
  const trimmed = (appBase ?? '').trim();
  if (!trimmed) {
    return '/';
  }

  let pathname = trimmed;
  try {
    pathname = new URL(trimmed).pathname;
  } catch {
    pathname = trimmed.startsWith('/') ? trimmed : `/${trimmed}`;
  }

  const normalizedPath = pathname.replace(/\/+$/, '') || '/';
  for (const route of FRONTEND_ROUTE_SUFFIXES) {
    const routeSuffix = `/${route}`;
    if (normalizedPath === route || normalizedPath.endsWith(routeSuffix)) {
      const prefix = normalizedPath.slice(0, normalizedPath.length - routeSuffix.length);
      return prefix ? `${prefix}/` : '/';
    }
  }

  if (normalizedPath === '/') {
    return '/';
  }

  return `${normalizedPath}/`;
}
