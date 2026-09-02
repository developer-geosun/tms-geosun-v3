# tms-geosun

Angular 21 застосунок для сценаріїв управління транспортом GeoSun.

## Технологічний стек

- Angular `21.2.x`
- Angular Material/CDK `21.2.x`
- TypeScript `5.9.x`
- i18n: `@ngx-translate/core` + `@ngx-translate/http-loader`

## Вимоги

- Node.js `>=20`
- npm `>=10`

## Початок роботи

Встановіть залежності:

```bash
npm install
```

Запустіть dev-сервер:

```bash
npm start
```

Застосунок доступний за адресою `http://localhost:4200/`.

### Dev-сервер у Docker (hot reload)

З кореня проєкту (`tms-geosun-v3`) використайте профіль dev:

```bash
docker compose stop frontend
docker compose --profile dev up -d frontend-dev
```

Відкрийте `http://localhost:4200`.

Примітки:
- `frontend-dev` оптимізовано для швидкої ітерації UI (Angular `ng serve` з hot reload).
- `frontend` — контейнер попереднього перегляду production-збірки (статична збірка + nginx).
- Docker-режим розробки використовує `proxy.docker.conf.json` і проксує `/api` на `http://backend:8080`.
- Для публічного доступу до API використовуйте `ngrok` / `ngrok-dev` (лише backend). Frontend для публічного використання розміщено на GitHub Pages.
- Під час першого запуску `frontend-dev` встановлюються залежності; наступні запуски швидші.

## Збірка

Production-збірка:

```bash
npm run build
```

Артефакти генеруються в `dist/tms-geosun`.

## Тести

Модульні тести тимчасово вимкнено в `package.json` (`npm test` повертає повідомлення-заглушку).

Щоб відновити тести Karma, встановіть скрипт `test` знову на:

```bash
ng test
```

## Розгортання

### GitHub Actions

Розгортання налаштовано через `.github/workflows/deploy.yml` і запускається при push у `main` або `master`, коли змінюється `frontend-angular/**` (або вручну через `workflow_dispatch`).

Необхідні секрети репозиторію:

- `API_URL` — публічна базова URL бекенду (ngrok), записується в `assets/app-config.js` під час деплою
- `CARTO_API_KEY` — ключ CARTO Basemaps (прибирає водяний знак «API KEY REQUIRED»)

Джерело GitHub Pages: **GitHub Actions** (workflow `Deploy to GitHub Pages`).

### Ручний деплой на GitHub Pages

Production-деплой — через GitHub Actions: **Actions → Deploy to GitHub Pages → Run workflow**.

Локальна команда `npm run deploy` збирає production-бандл і пушить у гілку `gh-pages` через npm-пакет `gh-pages`; за source **GitHub Actions** це **не** оновлює публічний сайт. Використовуйте її лише для відладки або якщо Pages знову перемкнуть на гілку.

## Корисні команди

```bash
npm run watch
npm run ng -- version
```

## Налаштування AI (Cursor)

Щоб використовувати Angular AI-інструменти з Cursor у цьому проєкті:

1. Створіть `frontend-angular/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "angular-cli": {
      "command": "npx",
      "args": ["-y", "@angular/cli", "mcp"]
    }
  }
}
```

2. Необов’язковий безпечний режим (MCP-інструменти лише для читання):

```json
{
  "mcpServers": {
    "angular-cli": {
      "command": "npx",
      "args": ["-y", "@angular/cli", "mcp", "--read-only"]
    }
  }
}
```

3. Додайте файл правил Angular AI: `frontend-angular/.cursor/rules/angular-best-practices.mdc`.

4. Перезавантажте вікно/workspace Cursor.

### Швидка перевірка

- Відкрийте новий чат Cursor з `frontend-angular`.
- Запитайте поради щодо Angular (наприклад, best practices для signals або сучасного control flow у шаблонах).
- Переконайтеся, що асистент відповідає з урахуванням Angular і контексту проєкту.
