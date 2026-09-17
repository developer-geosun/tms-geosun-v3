# ADR: pragmatic DDD в TMS GeoSun

**Дата создания:** 17 сентября 2026, 14:32 (UTC+3)  
**Дата изменения:** 17 сентября 2026, 14:43 (UTC+3)  
**Статус:** принято (в силе для нового кода в core)  
**Клиент:** Angular + Java; Flutter вне scope

Связанные: [`docs/specs/BASELINE.ru.md`](../specs/BASELINE.ru.md), [`docs/dev-workflow.ru.md`](../dev-workflow.ru.md), глоссарий [`glossary.ru.en.ua.md`](glossary.ru.en.ua.md), правило [`.cursor/rules/ddd-boundaries.ru.mdc`](../../.cursor/rules/ddd-boundaries.ru.mdc).

## Решение

Внедряем **pragmatic Domain-Driven Design** внутри текущего модульного монолита (`backend-java`), без Big Bang и без микросервисов.

С **17 сентября 2026** новый и затрагиваемый код в **core**-контекстах пишется по правилам ниже. Существующий анемичный код не переписываем без явной задачи алгоритма **B**.

## Контексты (карта)

| Контекст | Пакет / зона | Тип | DDD-тактика |
|----------|--------------|-----|-------------|
| Identity | `auth` | generic | Spring Security; VO профиля — ок |
| Catalog | валюты, страны, НБУ | generic | CRUD / transaction script |
| Storage | `storage` | generic | порт + `fileId` |
| Fleet | ТС, водители, автопоезда | supporting | инварианты документов — да; простой CRUD — нет |
| Route Planning | `routes` (маршрут, точки, lock) | **core** | агрегат Route, правила точек |
| Freight Commercial | заявка, quote, `freight.cost` | **core** | заявка, quote, калькулятор как domain service |
| Trip Operations | `trips` | **core** | FSM рейса, expense report |
| Notification | `chatbot`, почта, SMS | generic | слушает события / порты, не тащит чужие агрегаты |

Соответствие канону продукта: строки B01–B17 в BASELINE. Слова домена: [`glossary.ru.en.ua.md`](glossary.ru.en.ua.md).

## Правила границ

1. Не импортировать JPA-сущности / `repository` **чужого** пакета. Ссылки — по id; стык — порт (пример: `ActiveTripGuard`).
2. Инварианты core — в методах агрегата или чистых правилах без Spring (эталон: `RoutePointOperationsRules`), не через публичные `setStatus` из трёх сервисов.
3. Application service (`…/service`) проводит сценарий: загрузка → метод агрегата → сохранение → при необходимости событие после commit.
4. Angular — UI и ACL к API; **не** дублировать FSM/формулы вторым доменом на TypeScript.
5. Один Maven-модуль; Modulith/ArchUnit — позже, по боли. События — точечно (Spring `ApplicationEvent` после commit), без Axon/ES.

## Что не делаем

- Микросервис на каждый пакет; отдельная «чистая» модель + MapStruct на каждую сущность.
- CQRS/Event Sourcing «с нуля»; DDD для CRUD справочников и для экранов Angular.
- Полный рефакторинг репозитория «под DDD» без задачи B.

## Как применять с алгоритмами A / B

| Алгоритм | Ожидание |
|----------|----------|
| **A** (новая фича в core / новый бэклог-домен) | С первого дня: use case → агрегат/правила → порт; план явно указывает границы контекста |
| **A** (CRUD / Identity / Storage) | Transaction script достаточно; не раздувать слои |
| **B** (доработка core) | При касании кода — перенести затронутый инвариант в агрегат/правила; не расширять анемию |
| **B** (только текст спеки / «как есть») | Код не трогать |

## Пилоты (рекомендуемый порядок B)

1. FSM статусов `Trip` (методы агрегата + тесты без Spring).
2. Lock маршрута после заявки.
3. Вынос чистого расчёта из `FreightCostCalculatorService` (репозиторий toll снаружи).

## Критерий успеха

Новый use case в core читается как **сервис приложения → метод агрегата → порт**; инвариант нельзя обойти сеттером статуса из чужого сервиса.
