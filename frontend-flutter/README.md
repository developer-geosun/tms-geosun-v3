# TMS GeoSun — Flutter client

Flutter Web client for TMS GeoSun. Shares the same Java backend (`/api/v1`) as the Angular app.

## Requirements

- Flutter stable (SDK `^3.13`)
- Running backend at `http://localhost:8080` (see root [`RUN.md`](../RUN.md))

## Getting started

Install dependencies:

```bash
flutter pub get
```

Run dev server on port **4300** (CORS is preconfigured for this port):

```bash
flutter run -d chrome --web-port=4300 --dart-define=API_URL=http://localhost:8080
```

Open `http://localhost:4300`.

## Configuration

| Variable | Description | Default |
| --- | --- | --- |
| `API_URL` | Backend base URL without trailing slash | `http://localhost:8080` |

Example for a public API:

```bash
flutter run -d chrome --web-port=4300 --dart-define=API_URL=https://your-api.example.com
```

## Build

Локально:

```bash
flutter build web --dart-define=API_URL=http://localhost:8080
```

GitHub Pages (подпапка `/flutter/`):

```bash
flutter build web --release \
  --base-href="/<repo-name>/flutter/" \
  --dart-define=API_URL=https://your-api.example.com
```

Output: `build/web/`

## GitHub Pages

При push в `master`/`main` workflow [`.github/workflows/deploy.yml`](../.github/workflows/deploy.yml) выкладывает:

- Angular → `https://developer-geosun.github.io/<repo-name>/`
- Flutter → `https://developer-geosun.github.io/<repo-name>/flutter/`

`API_URL` для Flutter берётся из GitHub Secret `API_URL` (тот же, что для Angular). Deep links на Pages обрабатываются через общий `404.html` в корне `gh-pages`. Ссылки из писем ведут на клиент, который отправил запрос (`X-App-Client`).

## Tests

```bash
flutter test
dart format lib test
```

## Scope (v1)

- Material 3 UI, Inter font (bundled), i18n `uk` / `en` / `ru`
- Auth: login, refresh, logout, `/auth/me`, session restore from `localStorage`
- Routes: `/login`, `/register`, `/verify-email`, `/forgot-password`, `/reset-password`, `/home`

Business screens (trips, routes, admin) and mobile targets are planned for later phases.

## Project layout

```
lib/
  app.dart              # MaterialApp.router
  main.dart             # bootstrap + ProviderScope
  auth/                 # auth API, session, login/home UI
  core/                 # config, Dio, router, theme, l10n
```

Angular remains the primary admin UI; this client is a parallel frontend for Web → Android/iOS migration.
