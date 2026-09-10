# Реестр спецификаций

Единая точка входа перед работой по ТЗ. Сами требования — в файлах ниже; этот файл отвечает только на вопросы «сделано ли», «это источник истины или дополнение», «что ещё открыто».

Клиент реализации: **Angular + Java**. `frontend-flutter/` в ТЗ не входит (заморозка).

## Как читать

| Поле | Значения |
|------|----------|
| **Реализация** | `реализовано` — в проде, не открывать как новую фичу. `частично` — часть scope в коде, хвост описан в «Остаток». `не реализовано` — только спека. `в силе` — контракт/правила, не отдельная фича. |
| **Роль** | `источник истины` — при расхождении править код под этот файл (или сначала обновить файл). `дополнение` — формулы, seed, канон правил; не дублировать в родительском ТЗ. `исторический MVP` — зафиксированный старт; актуальный контур смотри в связанном источнике истины. |

Перед кодом: этот реестр → нужный файл → поле «Связанные» в шапке той спеки. Не читать все 19 файлов подряд.

## Сводка

**19** файлов.

| Для планирования работ | Кол-во |
|------------------------|--------|
| Готово в продукте (включая контракты «в силе») | **16** |
| Частично | **2** (`document-types-reference`, `chatbots-telegram-whatsapp-viber`) |
| Не сделано | **1** (`document-ocr`) |

`freight-cost-scenario-nbu-pricing` — **реализовано (v1)**; опциональный хвост не блокирует v1.

## Auth и пользователи

| Файл | Реализация | Роль | Остаток |
|------|------------|------|---------|
| [auth-authentication-authorization.md](auth-authentication-authorization.md) | реализовано | источник истины по login/JWT/RBAC и Angular auth-слою | нет |
| [TECHNICAL_SPECIFICATION_API_SERVER_v1.0.md](TECHNICAL_SPECIFICATION_API_SERVER_v1.0.md) | реализовано | исторический MVP Java-сервера auth | не расширять; новые правила auth — в файле выше |
| [admin-user-management.md](admin-user-management.md) | реализовано | источник истины по `/admin/users` | MANAGER **читает** список/карточку (см. user-profile); мутации — только ADMIN. Исходный Out of Scope про MANAGER устарел |
| [user-profile.md](user-profile.md) | реализовано | источник истины по профилю учётки | нет |
| [admin-notify-new-user-registration.md](admin-notify-new-user-registration.md) | реализовано | источник истины: после `POST /auth/register` все активные ADMIN получают служебное сообщение по каналам своего профиля (EMAIL / PHONE / MESSENGERS) | реальный SMS-провайдер; WhatsApp template (сейчас SKIP) |

## Маршруты и фрахт

| Файл | Реализация | Роль | Остаток |
|------|------------|------|---------|
| [routes-server-workflow-and-freight-quoting.md](routes-server-workflow-and-freight-quoting.md) | реализовано | источник истины по routes / route-requests / quotes | детали блокировки, фильтров и отложенного breakdown — в immutability-спеке; расчёт ставки — в NBU-спеке |
| [route-immutability-list-filters-deferred-country-breakdown.md](route-immutability-list-filters-deferred-country-breakdown.md) | реализовано | источник истины по lock / `view` / restore / отложенному country-breakdown | §7.1 = вариант A (любая заявка). §7.2 = несколько заявок на один маршрут **разрешены** (нет UNIQUE на `route_id`) |
| [route-point-operations-rules.md](route-point-operations-rules.md) | в силе | источник истины по операциям точек | менять валидацию UI и backend только вместе с этим файлом |
| [freight-cost-scenario-nbu-pricing.md](freight-cost-scenario-nbu-pricing.md) | реализовано (v1) | источник истины по сценариям, НБУ, cost-preview, quote из расчёта | опционально: PATCH сценариев/тарифов (есть PUT); `nameUk` в таблице breakdown на заявке; эталонный unit-тест сумм — вне v1 |
| [freight-trip-cost-calculation-rules-margin30-ua8150-driverpct.md](freight-trip-cost-calculation-rules-margin30-ua8150-driverpct.md) | в силе | дополнение: формулы калькулятора | при расхождении с NBU-ТЗ приоритет у этого файла |
| [currencies-reference.md](currencies-reference.md) | реализовано | источник истины по валютам и курсам НБУ | выбор валюты в котировке и cron — вне v1 |

## Справочники и файлы

| Файл | Реализация | Роль | Остаток |
|------|------------|------|---------|
| [file-storage.md](file-storage.md) | реализовано | источник истины по `StoredFile` | CDN/virus scan — вне v1 |
| [vehicles-reference.md](vehicles-reference.md) | реализовано | источник истины по справочнику ТС | привязка вида документа из каталога — v2 document-types |
| [drivers-and-vehicle-combinations.md](drivers-and-vehicle-combinations.md) | реализовано | источник истины по водителям и автопоездам | виды документов всё ещё enum, не FK на `document_types` |
| [trips-and-driver-expense-reports.md](trips-and-driver-expense-reports.md) | реализовано | источник истины по рейсам и expense report | сверка с FreightCostCalculation — вне scope |

## Виды документов и OCR

| Файл | Реализация | Роль | Остаток |
|------|------------|------|---------|
| [document-types-reference.md](document-types-reference.md) | частично | источник истины по CRUD справочника видов | интеграция с карточками ТС/водителей (v2). Seed UUID `c1000000-…` **устарели** |
| [document-types-ua-default-catalog.md](document-types-ua-default-catalog.md) | реализовано | источник истины по UA-seed (`V39`, UUID `c2000000-…`) | не менять другие спеки ради этого каталога |
| [document-ocr.md](document-ocr.md) | не реализовано | источник истины по будущему OCR/suggest | после v2 интеграции document-types с ТС/водителями |

## Каналы связи (мессенджеры)

| Файл | Реализация | Роль | Остаток |
|------|------------|------|---------|
| [chatbots-telegram-whatsapp-viber.md](chatbots-telegram-whatsapp-viber.md) | частично | источник истины по чат-ботам Telegram / WhatsApp / Viber | v1 backend: verify Telegram+телефон **реализован**. Остаток: Angular UI `/profile`+admin; уведомления quote/trip; status/lang; WhatsApp; Viber; полный admin journal |

## Как обновлять этот реестр

После сдачи фичи или смены решения в коде:

1. Обновить блок **Статус** в самой спеке (те же поля: Реализация, Роль, Остаток).
2. Синхронизировать строку в таблице выше.
3. Проставить `[x]` в Definition of Done, если критерий действительно выполнен.
4. Не оставлять пустой DoD у уже живущей фичи — это главный источник путаницы.
