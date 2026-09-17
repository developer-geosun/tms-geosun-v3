# Структура репозитория TMS GeoSun v3

**Дата создания:** 15 сентября 2026, 00:00 (UTC+3)  
**Дата изменения:** 17 сентября 2026, 14:12 (UTC+3)  
**Дата фиксации:** 15 сентября 2026 (структура); процесс/baseline/archive — 17 сентября 2026.  
**Файл:** снимок структуры. Назначение и API — [`docs/system.ru.md`](system.ru.md); канон — [`docs/specs/BASELINE.ru.md`](specs/BASELINE.ru.md); реестр — [`docs/specs/README.ru.md`](specs/README.ru.md); процесс — [`docs/dev-workflow.ru.md`](dev-workflow.ru.md).

## 1. Что это за проект

`tms-geosun-v3` — Transport Management System компании GeoSun: маршруты, заявки на фрахт, котировки, справочники (ТС, водители, валюты, страны), рейсы и отчёты по затратам.

**Активная разработка (на дату документа):** только `frontend-angular/` и `backend-java/`.  
`frontend-flutter/` в репозитории есть, но **заморожен** до прямого распоряжения.

Поток данных:

```
Пользователь → Angular (порт 4200) → Spring Boot `/api/v1` (порт 8080) → MySQL 8
                                      ↘ файлы: локальный диск или S3/MinIO
                                      ↘ внешние: HERE, НБУ, Telegram, SMTP
```

Публичный контур: статика Angular на GitHub Pages; API — ngrok или статический IP. Запуск локально описан в [`RUN.ru.md`](../RUN.ru.md).

## 2. Корень репозитория

```
tms-geosun-v3/
├── frontend-angular/     # основной UI (Angular 21 + Material)
├── backend-java/         # API (Java 21 + Spring Boot 3.3)
├── frontend-flutter/     # Flutter Web — заморожен
├── docs/                 # ТЗ, runbook, этот файл
├── .cursor/rules/        # правила агента и соглашения команды
├── .github/workflows/    # CI и деплой Pages
├── secrets/              # локальные секреты, в git не попадают
├── testdata/             # заготовка под тестовые данные
├── docker-compose.yml    # mysql, minio, backend, frontend, gateway, ngrok
├── docker-compose.override.yml  # frontend-dev / gateway-dev (профиль dev)
├── nginx.gateway.conf / nginx.gateway.dev.conf
├── .env.example          # шаблон окружения (копировать в .env)
└── RUN.ru.md             # как запускать стек
```

## 3. Backend Java (`backend-java/`)

Стек: **Java 21**, **Spring Boot 3.3.5**, Spring Security + JWT, JPA/Hibernate, Flyway, MySQL 8, springdoc OpenAPI, Spotless (Google Java Format), JaCoCo. Точка входа: `com.geosun.tms.auth.TmsGeosunBackendJavaApplication`.

Профили: `application.yml` + `application-dev.yml` / `application-test.yml` / `application-prod.yml`. Тесты — H2 in-memory, Flyway выключен, почта замокана.

### 3.1. Дерево модуля

```
backend-java/
├── pom.xml
├── Dockerfile
├── docker-compose.yml          # урезанный compose только для backend
├── MAVEN-COMMANDS.ru.en.md
├── src/main/java/com/geosun/tms/
│   ├── auth/
│   ├── chatbot/
│   ├── freight/cost/
│   ├── reference/
│   ├── routes/
│   ├── storage/
│   └── trips/
├── src/main/resources/
│   ├── db/migration/           # Flyway V1…V43 (только incremental)
│   ├── geo/countries/          # GeoJSON границ для offline country-breakdown
│   ├── mail/                   # HTML/txt шаблоны писем
│   └── application*.yml
└── src/test/java/com/geosun/tms/   # те же пакеты, что и main
```

Внутри каждого домена обычно: `api` → `service` → `repository` → `domain` / `dto`. Это вертикальные срезы, не слои «все контроллеры в одном месте».

### 3.2. Домены и ответственность

| Пакет | Назначение | Типичные HTTP-контроллеры |
|-------|------------|---------------------------|
| `auth` | Регистрация, login/JWT/refresh, RBAC, профиль учётки, admin users, почта, SMS-заглушка, rate limit | `AuthController`, `UserProfileController`, `AdminUserController`, `AdminSuperAdminController` |
| `routes` | Маршруты, заявки на фрахт, quotes, HERE/GeoJSON breakdown, lock после заявки | `RouteController`, `RouteRequestController`, `AdminRouteRequestController`, `AdminQuoteController` |
| `freight.cost` | Числовые сценарии фрахта, тарифы дорог, preview/расчёт по НБУ | `AdminFreightNumericScenarioController`, `AdminTollTariffSetController`, `AdminFreightCostCalculationController` |
| `reference` | Справочники: валюты/НБУ, страны, ТС, водители, автопоезда, виды документов | `AdminCurrencyController`, `AdminCountryReferenceController`, `AdminVehicleController`, `AdminDriverController`, `AdminVehicleCombinationController`, `AdminDocumentTypeController` |
| `trips` | Рейсы, статусы, expense report | `AdminTripController`, `MyTripController` |
| `storage` | Метаданные `StoredFile`, local disk или S3 | `AdminStoredFileController` |
| `chatbot` | Telegram verify, webhook, admin journal, исходящие уведомления | `TelegramWebhookController`, `UserBotIdentityController`, `AdminChatbotController` |

Базовый префикс API: `/api/v1`. Health: `/actuator/health`. Swagger: `/swagger-ui.html`.

### 3.3. Схема БД (Flyway)

Миграции только вперёд, без правок уже применённых файлов. Логические группы:

| Версии | Тема |
|--------|------|
| V1–V2, V9, V27, V40–V41 | Auth, токены, профили |
| V3, V8, V10–V12 | Маршруты, операции точек, country distances |
| V4, V13 | Заявки на фрахт |
| V5 | Кэш HERE breakdown |
| V6–V7 | Quotes |
| V14–V15, V21–V23, V25, V28 | Сценарии и расчёт фрахта (AI-сценарии сняты в V28) |
| V16–V19, V38 | Валюты и курсы НБУ |
| V20, V24, V26 | Справочник стран |
| V29 | Роль `employee` → `driver` |
| V30 | `stored_files` |
| V31–V33, V36–V37 | ТС, документы ТС, водители, автопоезда |
| V34 | Рейсы и expense reports |
| V35, V39 | Виды документов + UA-каталог (актуальные UUID `c2000000-…`) |
| V42–V43 | Chatbot и верификация телефона |

## 4. Frontend Angular (`frontend-angular/`)

Стек: **Angular 21.2**, **Angular Material/CDK 21.2**, TypeScript 5.9, `@ngx-translate`, Leaflet. Node 22.14 LTS (`.nvmrc`). UI: Inter Variable + Material Symbols Outlined (без Google Fonts).

Standalone-компоненты, lazy `loadComponent` в `app.routes.ts`. Сборка: `dist/tms-geosun`. Dev: `npm start` → `http://localhost:4200/` с proxy `/api` на backend.

### 4.1. Дерево приложения

```
frontend-angular/src/
├── app/
│   ├── app.config.ts / app.routes.ts / app.component.*
│   ├── core/                 # инфраструктура, не фичи
│   │   ├── api/              # HTTP-клиенты + *contracts.model.ts
│   │   ├── guards/
│   │   ├── interceptors/
│   │   ├── services/         # auth, config, theme, i18n, page-loading
│   │   ├── layout/           # breakpoints + LayoutService
│   │   ├── http/             # ngrok headers
│   │   └── utils/
│   ├── layout/               # оболочка: toolbar, footer
│   ├── pages/                # экраны по одному каталогу на маршрут
│   └── shared/               # диалоги, logo, snackbar, константы
├── assets/
│   ├── i18n/                 # en.json, ru.json, uk.json
│   └── app-config.js         # runtime API_URL (подставляется при деплое)
└── styles/                   # _theme, _fonts, _breakpoints, _page-layout, toolbar
```

Правило раскладки: **по экранам/фичам**, не по типам (`components/` как корень). Общие виджеты — только в `shared/`.

### 4.2. Экраны и роли

Гостевые (без сессии): `/login`, `/register`, `/verify-email`, `/forgot-password`, `/reset-password`.

| Маршрут | Роли | Каталог |
|---------|------|---------|
| `/main`, `/profile` | admin, manager, driver, user | `main`, `profile` |
| `/route-builder`, `/routes`, `/my-freight-requests` | user | одноимённые |
| `/my-trips` | admin, manager, driver | `my-trips` |
| `/admin/route-requests` | admin, manager | `admin-route-requests` |
| `/admin/currencies`, `/admin/country-reference` | admin, manager | одноимённые |
| `/admin/freight-numeric-scenarios`, `/admin/toll-tariff-sets` | admin, manager | одноимённые |
| `/admin/chatbots`, `/admin/users` | admin, manager | одноимённые |
| `/admin/vehicles`, `/admin/drivers`, `/admin/vehicle-combinations` | admin, manager | одноимённые |
| `/admin/trips`, `/admin/trips/:id` | admin, manager | `admin-trips` |
| `/admin/document-types`, `/admin/file-storage-test` | admin | одноимённые |
| `/stop-service`, `/404` | публично | одноимённые |

Guards: `authAvailabilityGuard` → `guestGuard` или `serviceStopGuard` + `authGuard` (роли в `data.roles`).

### 4.3. API-слой

Базовый `BackendApiService`; доменные сервисы рядом с контрактами:

- маршруты / заявки: `routes-api`, `route-requests-api`
- справочники: `vehicles`, `drivers`, `vehicle-combinations`, `currencies`, `country-reference`, `document-types`
- фрахт: `freight-numeric-scenarios`, `toll-tariff-sets`
- рейсы: `trips-api`
- пользователи: `users-admin-api`, `user-profile-api`
- прочее: `chatbot-api`, `stored-files-api`

Интерцепторы: `AuthInterceptor` (refresh при 401), `AppClientInterceptor`, `NgrokSkipInterceptor`.

### 4.4. Качество

- ESLint: `npm run lint:fix` (`eslint.config.js`).
- Тесты Karma/Jasmine: `npm test` (ChromeHeadless). CI: `.github/workflows/frontend-ci.yml`.

## 5. Flutter (`frontend-flutter/`) — заморозка

Каркас Flutter Web: `lib/auth`, `lib/core`, `lib/features/directories`. Порт dev `:4300`, на Pages — подпапка `/flutter/`. Workflow деплоя всё ещё собирает этот клиент.

**Не менять код и не запускать `flutter run` / `flutter test`**, пока нет явного снятия заморозки в текущем сообщении пользователя.

## 6. Документация (`docs/`)

| Путь | Роль |
|------|------|
| `docs/dev-workflow.ru.md` | Алгоритмы **A** (новая фича) и **B** (доработка) |
| `docs/specs/BASELINE.ru.md` | Канон реализованного vs бэклог |
| `docs/specs/README.ru.md` | Реестр ТЗ: статус, роль, остаток |
| `docs/specs/*.<lang>.md` | Источники истины по фичам (канонические имена с языковым суффиксом) |
| `docs/archive/` | Исторический MVP auth, rollout notes — **не** источник истины |
| `docs/templates/` | Briefs, шаблон ТЗ, промпты (plan / implement / bugfix / review / release) |
| `docs/system.ru.md` | Обзор системы, сущности, основные API |
| `docs/auth-mvp-runbook.ru.md`, `docs/auth-validation-checklist.ru.md` | → [`docs/archive/`](archive/README.ru.md) (устаревшие MVP-процедуры) |
| `docs/examples/` | Пример JSON расчёта фрахта |
| **этот файл** | Карта каталогов |

Перед новой задачей: [`BASELINE.ru.md`](specs/BASELINE.ru.md) / реестр → алгоритм A или B → один файл ТЗ → «Связанные». Не читать все спеки подряд.

Сводка: см. [`BASELINE.ru.md`](specs/BASELINE.ru.md) и [`README.ru.md`](specs/README.ru.md) (канон vs бэклог: document-types v2, chatbot post-v1, OCR и т.д.).

## 7. Инфраструктура и CI

Docker Compose (корень):

- всегда: `mysql`, `backend`, `frontend` (nginx + production-сборка), `gateway` (`:8081`)
- опционально: `minio` + `minio-init` (S3)
- профили: `dev` (`frontend-dev` hot reload), `ngrok` (публичный туннель только на API)

GitHub Actions:

- `frontend-ci.yml` — lint + unit tests Angular на PR/`main`
- `deploy.yml` — сборка Angular (+ Flutter Web) на GitHub Pages при push в `main`/`master`

Cursor (`.cursor/rules/`): заморозка Flutter, `dev-workflow` (A/B), реестр/BASELINE спек, Angular Material/UI, null-safety Java, Spotless, ESLint, Problems = 0 при сдаче.

## 8. Как ориентироваться при новой задаче

1. Клиент = **Angular**. Backend = **Java**. Flutter не трогать.
2. Открыть [`docs/dev-workflow.ru.md`](dev-workflow.ru.md): алгоритм **A** или **B**.
3. [`docs/specs/BASELINE.ru.md`](specs/BASELINE.ru.md) / [`docs/specs/README.ru.md`](specs/README.ru.md) → одна спека.
4. Код домена: `backend-java/.../<пакет>/` и экран в `frontend-angular/src/app/pages/<имя>/`.
5. Контракт HTTP: Java `*Controller` + Angular `*-api.service.ts` / `*-contracts.model.ts`.
6. Схема: новая Flyway `Vnn__….sql`, предыдущие файлы не править.
7. Сдача: Spotless / `lint:fix`, тесты, **Problems = 0** по изменённым файлам (включая Java-тесты); обновить Статус / реестр / BASELINE.
