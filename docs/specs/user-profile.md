# Technical Specification / Техническое задание: User Profile / Профиль пользователя

## Статус
**Реалізовано** (Angular + Java; Flutter не входить).

Целевой клиент — `frontend-angular`. `frontend-flutter/` не входит (заморозка Flutter).

## Language Rules / Правила языка
- **Primary language / Основной язык:** RU
- **Secondary language / Дополнительный язык:** EN
- **Terms to keep in English / Термины, которые оставляем на английском:** `auth`, `RBAC`, `E.164`, `EDRPOU` / `ЄДРПОУ`, `handset`, `Definition of Done`

## 1) Goal / Цель
- **Problem / Проблема:** учётка (`users`) хранит только email, роль и флаги auth. Нет ФИО, телефонов, типа лица и предпочтительных каналов связи — менеджер не знает, как и с кем связываться по заявке.
- **Value / Ценность:** пользователь заполняет контактную карточку; ADMIN/MANAGER видят, кому звонить / писать и от чьего имени действует человек.
- **Expected outcome / Ожидаемый результат:** страница `/profile`, API чтения/записи профиля, расширенный `GET /api/v1/auth/me`, ФИО и контакты в админке пользователей.

## 2) Context / Контекст
- **Project/module / Проект/модуль:** `backend-java` auth + `frontend-angular` (Angular Material).
- **Current behavior / Текущее поведение:**
  - `User` / `UserPublicDto`: `id`, `email`, `role`.
  - `GET /api/v1/auth/me` и блок `user` в login/refresh — без персональных данных.
  - Регистрация: email + password.
  - Страницы профиля нет; в toolbar после входа — только logout.
  - ФИО есть у кадровой карточки **водителя** (`drivers`) и **не** является профилем учётки.
- **Related docs / Связанные документы:**
  - [`auth-authentication-authorization.md`](auth-authentication-authorization.md)
  - [`admin-user-management.md`](admin-user-management.md)
  - [`drivers-and-vehicle-combinations.md`](drivers-and-vehicle-combinations.md) — правила ПІБ, отдельная сущность
- **Environment constraints / Ограничения окружения:** Java 21 / Spring Boot 3, Flyway (следующая миграция после `V39`), MySQL, Angular 21 + Material, i18n ua/en/ru (файлы `uk.json` / `en.json` / `ru.json` не переименовывать).

## 3) Scope (In) / Scope (входит в задачу)
- Профиль **учётки** (любая роль: `USER` / `MANAGER` / `DRIVER` / `ADMIN`).
- Поля: фамилия, имя, отчество; тип лица; код ЄДРПОУ (для представника юр. особи); список телефонов с мессенджерами; каналы связи.
- Self-service: страница `/profile` (GET + PUT своего профиля).
- Расширить публичный DTO пользователя (`/auth/me`, login, refresh).
- ADMIN: видеть ФИО/тип/контакты в списке и карточке `/admin/users`; редактировать профиль любого пользователя.
- MANAGER: **читать** профиль любого пользователя (операционный контакт по заявкам); писать — нет.
- Handset-адаптация `/profile` и отображения в `/admin/users`.
- i18n ua/en/ru.
- Нові таблиці `user_profiles` (1:1) і `user_contact_phones`. Таблицю **`users` не змінювати** (немає `ALTER TABLE users`).

## 4) Out of Scope / Out of Scope (не входит)
- Flutter-клиент.
- Смена email / пароля из профиля (остаётся forgot-password / admin out of scope).
- Название юр. лица, адрес, должность, ІПН приватного замовника (`INDIVIDUAL`), паспорт, довіреність. (10-значний код ФОП у полі `legalEntityEdrpou` — так, це код в ЄДР.)
- Справочник юр. осіб и внешний lookup ЄДРПОУ (YouControl и т.п.).
- Отдельный Telegram `@username` / WhatsApp, не привязанный к номеру телефона.
- Синхронизация ФИО/телефона профиля с карточкой `Driver`.
- Блокировка route-builder / заявок на фрахт при незаполненном профиле (только флаг `profileComplete` + баннер).
- Invite / создание пользователя админом.
- Верификация телефонов (SMS OTP).
- Аватар / фото.
- Будь-які нові колонки або індекси на існуючій таблиці `users`.

## 5) User Stories / Пользовательские сценарии
1. **Как** пользователь, **я хочу** указать ФИО, телефоны и мессенджеры, **чтобы** со мной можно было связаться по заявке.
2. **Как** представник юр. особи, **я хочу** указать код ЄДРПОУ, **чтобы** было понятно, от какой организации я действую.
3. **Как** пользователь, **я хочу** выбрать каналы связи (email / телефон / мессенджеры), **чтобы** со мной не писали туда, куда я не смотрю.
4. **Как** ADMIN/MANAGER, **я хочу** видеть контакты пользователя, **чтобы** согласовать перевозку.
5. **Как** ADMIN, **я хочу** поправить профиль за пользователя, **чтобы** дозаполнить данные с звонка.

## 6) Functional Requirements / Функциональные требования

### 6.1 Идентичность vs профиль
1. Auth-поля (`email`, `passwordHash`, `role`, `active`, `deleted`, `emailVerified`) **не** входят в форму профиля и **не** меняются этим API.
2. Профиль — 1:1 к `users` у **окремій** таблиці `user_profiles`. Схема `users` **без змін**. Телефони — `user_contact_phones` (FK на профіль). Рядок профілю створюється при першому успішному PUT (lazy); GET без рядка повертає порожній DTO.
3. Карточка `Driver` остаётся отдельной. Совпадение ФИО не требуется и не синхронизируется.

### 6.2 Персональные данные
| Поле | Обязательность | Правила |
|------|----------------|---------|
| `lastName` | да | ПІБ: літери UA/EN, дефіс, апостроф; max 128. Санітизація як у водіїв (`sanitizeDriverPersonNameInput` / той самий алгоритм на backend). |
| `firstName` | да | те саме |
| `patronymic` | ні | те саме; порожнє → `null` |
| `personType` | да | `INDIVIDUAL` \| `LEGAL_ENTITY_REPRESENTATIVE` |
| `legalEntityEdrpou` | так, якщо `LEGAL_ENTITY_REPRESENTATIVE` | **8 або 10** цифр + контрольна сума; інакше **має бути** `null`. 8 — юрособа (ЄДРПОУ), 10 — ФОП (код у ЄДР = РНОКПП) |

### 6.3 Телефони
4. Список `phones[]`: 0…5 записів. Порядок масиву = порядок у UI.
5. Кожен запис:
   - `id` — UUID; на PUT відсутній `id` = новий рядок; рядки, яких немає в масиві, видаляються.
   - `phone` — обов’язковий, нормалізація до E.164 (`+` і цифри), max 32, як у `drivers.phone`.
   - `telegram` / `whatsapp` / `viber` — boolean: «цей номер має цей месенджер». Нікнейми не зберігаємо.
   - `primary` — boolean. Якщо `phones.length ≥ 1`, рівно один `primary=true`. Якщо клієнт не позначив — перший у масиві стає primary.
6. Унікальність `phone` **всередині одного користувача**. Глобальна унікальність між користувачами — ні (сімейний/робочий номер).
7. Месенджер-прапорці дозволені навіть якщо канал `MESSENGERS` не вибраний (довідково).

### 6.4 Канали зв’язку
8. Багато вибір: `EMAIL`, `PHONE`, `MESSENGERS`. Хоча б один канал обов’язковий.
9. `EMAIL` — обліковий `users.email` (у формі read-only, зміна email поза scope).
10. `PHONE` → `phones.length ≥ 1`.
11. `MESSENGERS` → існує хоча б один телефон з `telegram \|\| whatsapp \|\| viber`.
12. Канали зберігаються трьома boolean-колонками на `user_profiles` (`contact_via_email`, `contact_via_phone`, `contact_via_messengers`).

### 6.5 Повнота профілю
13. `profileComplete = true`, якщо виконуються §6.2–6.4. Інакше `false`.
14. Існуючі користувачі після міграції: рядка в `user_profiles` немає → порожній DTO, `profileComplete=false`. Додаток **не** блокує маршрути й заявки.
15. На `/profile` і (за бажанням) після login — неповноцінний банер «Заповніть профіль» з кнопкою на `/profile`. Баннер не показувати на самій `/profile`.

### 6.6 Доступ
16. Читати/писати **свій** профіль — будь-який автентифікований користувач (не soft-deleted, `isActive`).
17. `GET` чужого профілю — `ADMIN` і `MANAGER`; `PUT` чужого — лише `ADMIN`.
18. Soft-deleted / inactive: власник не логіниться (як зараз); ADMIN може читати профіль deleted-користувача разом з карткою `/admin/users/{id}`. PUT профілю deleted → `409 USER_DELETED`.

## 7) Non-functional Requirements / Нефункциональные требования
- **Security / Безопасность:** телефони — персональні дані; не світити в логах повний номер (маска, напр. `+380*****1234`). Профіль не класти в JWT.
- **Performance / Производительность:** GET свого профілю p95 ≤ 200 ms локально; телефони — один JOIN / batch, без N+1.
- **Reliability / Надежность:** PUT профілю + телефонів в одній транзакції.
- **Logging/Monitoring / Логирование и мониторинг:** без password/token; профільні апдейти — стандартний API access log.
- **Accessibility/UX / Доступность и UX:** Angular Material; handset через `LayoutService` + `bp.handset`; тексти i18n ua/en/ru.

## 8) Data Contracts and API / Контракты данных и API

### 8.1 Зберігання

**Заборона:** Flyway `V40` лише `CREATE TABLE`. Немає `ALTER TABLE users` (колонки, індекси, FK з боку `users`).

#### Таблиця `user_profiles` (1:1 з `users`)
| Колонка | Тип | Опис |
|---------|-----|------|
| `user_id` | CHAR(36) PK | FK → `users(id)` ON DELETE CASCADE |
| `last_name` | VARCHAR(128) NULL | Прізвище |
| `first_name` | VARCHAR(128) NULL | Ім’я |
| `patronymic` | VARCHAR(128) NULL | По батькові |
| `person_type` | VARCHAR(32) NULL | `INDIVIDUAL` \| `LEGAL_ENTITY_REPRESENTATIVE` |
| `legal_entity_edrpou` | VARCHAR(10) NULL | 8 або 10 цифр; без пробілів і padding |
| `contact_via_email` | TINYINT(1) NOT NULL DEFAULT 0 | канал EMAIL |
| `contact_via_phone` | TINYINT(1) NOT NULL DEFAULT 0 | канал PHONE |
| `contact_via_messengers` | TINYINT(1) NOT NULL DEFAULT 0 | канал MESSENGERS |
| `created_at` / `updated_at` | DATETIME(6) | |

Індекс для адмін-пошуку: `(last_name, first_name)` на **цій** таблиці, не unique.

#### Таблиця `user_contact_phones`
| Колонка | Тип | Опис |
|---------|-----|------|
| `id` | CHAR(36) PK | UUID |
| `user_id` | CHAR(36) NOT NULL | FK → `user_profiles(user_id)` ON DELETE CASCADE |
| `phone` | VARCHAR(32) NOT NULL | E.164 |
| `sort_order` | INT NOT NULL | 0-based, = індекс у PUT |
| `is_primary` | TINYINT(1) NOT NULL | рівно один `1` на користувача, якщо є рядки |
| `has_telegram` | TINYINT(1) NOT NULL DEFAULT 0 | |
| `has_whatsapp` | TINYINT(1) NOT NULL DEFAULT 0 | |
| `has_viber` | TINYINT(1) NOT NULL DEFAULT 0 | |
| `created_at` / `updated_at` | DATETIME(6) | |

Унікальність: `UNIQUE (user_id, phone)`. Індекс `user_id`.

Admin list `/admin/users`: `LEFT JOIN user_profiles` (і за потреби телефони окремим запитом або fetch join). Без профілю `displayName` = `users.email`.

### 8.2 Валідація ЄДРПОУ / коду в ЄДР
- На вході прибрати пробіли, дефіси та інші роздільники. Залишити лише цифри.
- Довжина після нормалізації: **рівно 8 або рівно 10**. Інша довжина (7, 9, 11…) → `VALIDATION_ERROR`.
- **8 цифр** — ЄДРПОУ юридичної особи (Держстат):
  1. Ваги `1,2,3,4,5,6,7` для перших 7 цифр; `k = sum % 11`.
  2. Якщо `k < 10` — контрольна = `k`.
  3. Інакше ваги `3,4,5,6,7,8,9`; знову `k = sum % 11`; якщо `k < 10` — контрольна = `k`, інакше `0`.
  4. 8-ма цифра має дорівнювати контрольній.
- **10 цифр** — код ФОП у ЄДР (збігається з РНОКПП):
  1. Ваги `-1, 5, 7, 9, 4, 6, 10, 5, 7` для перших 9 цифр; `k = sum % 11`.
  2. Якщо `k == 10` — код невалідний.
  3. 10-та цифра має дорівнювати `k`.
- Невалідний код → `400 VALIDATION_ERROR` (поле `legalEntityEdrpou`).
- Колонку не падити до 10 символів: зберігати `"12345678"` або `"1234567890"` як є.

### 8.3 DTO

`UserProfileDto` (відповідь GET/PUT профілю; також вкладається в розширений публічний користувач):

```json
{
  "lastName": "Шевченко",
  "firstName": "Тарас",
  "patronymic": "Григорович",
  "personType": "LEGAL_ENTITY_REPRESENTATIVE",
  "legalEntityEdrpou": "12345678",
  "preferredChannels": ["EMAIL", "PHONE", "MESSENGERS"],
  "phones": [
    {
      "id": "p_uuid",
      "phone": "+380671112233",
      "primary": true,
      "telegram": true,
      "whatsapp": false,
      "viber": true
    }
  ],
  "profileComplete": true
}
```

`legalEntityEdrpou`: рядок з **8 або 10** цифр (приклад вище — юрособа; ФОП, напр. `"1234567890"`).

Розширений `UserPublicDto` / login `user`:

```json
{
  "id": "u_123",
  "email": "user@example.com",
  "role": "USER",
  "displayName": "Шевченко Тарас Григорович",
  "profile": { "...UserProfileDto..." }
}
```

- `displayName`: `[lastName, firstName, patronymic]` через пробіл; якщо ПІБ порожнє — `email`.
- `profile` завжди об’єкт; «ще не заповнював» = `null`-поля, `preferredChannels: []`, `phones: []`, `profileComplete: false`.
- `UserAdminDto` додає ті самі профільні поля (плоско або вкладений `profile`) + `displayName`, щоб список `/admin/users` показав ПІБ без другого запиту.

### 8.4 Endpoints

- `GET /api/v1/auth/me` — як зараз, але розширений `UserPublicDto` (див. вище). Login/refresh — той самий об’єкт `user`.
- `GET /api/v1/users/me/profile` — свій `UserProfileDto`.
- `PUT /api/v1/users/me/profile` — повна заміна профілю + колекції телефонів (транзакція). Response: `UserProfileDto`.
- `GET /api/v1/admin/users/{id}` — картка вже існує; додати профіль.
- `PUT /api/v1/admin/users/{id}/profile` — ADMIN, те саме тіло що self-PUT. `400 SELF_OPERATION_FORBIDDEN` не застосовується (адмін може правити й свій профіль тут або через `/users/me/profile`).

Self-GET/PUT не потребують ролі ADMIN.

#### Приклад PUT

```json
{
  "lastName": "Шевченко",
  "firstName": "Тарас",
  "patronymic": "Григорович",
  "personType": "INDIVIDUAL",
  "legalEntityEdrpou": null,
  "preferredChannels": ["EMAIL", "MESSENGERS"],
  "phones": [
    {
      "phone": "+380671112233",
      "primary": true,
      "telegram": true,
      "whatsapp": false,
      "viber": false
    }
  ]
}
```

### 8.5 Помилки
| Код | HTTP | Коли |
|-----|------|------|
| `VALIDATION_ERROR` | 400 | ПІБ, ЄДРПОУ, E.164, порожні обов’язкові, >5 телефонів |
| `PROFILE_CHANNEL_PHONE_REQUIRED` | 400 | канал `PHONE`, але немає телефонів |
| `PROFILE_CHANNEL_MESSENGER_REQUIRED` | 400 | канал `MESSENGERS`, але жоден телефон без месенджер-прапорця |
| `PROFILE_EDRPOU_FORBIDDEN` | 400 | `INDIVIDUAL` і непорожній ЄДРПОУ |
| `PROFILE_PHONE_DUPLICATE` | 400 | однаковий номер двічі в одному PUT |
| `PROFILE_PRIMARY_PHONE_INVALID` | 400 | 0 або >1 primary при непорожньому списку (якщо клієнт надіслав явні значення і вони суперечливі; інакше сервер нормалізує перший) |
| `USER_DELETED` | 409 | PUT профілю soft-deleted (admin) |
| `FORBIDDEN` | 403 | MANAGER пише чужий профіль; USER читає чужий |
| `NOT_FOUND` | 404 | admin GET/PUT неіснуючого id |

Політика primary: якщо рівно один `primary=true` — прийняти; якщо жоден — перший елемент; якщо кілька `true` — `PROFILE_PRIMARY_PHONE_INVALID`.

## 9) UX/UI Requirements (frontend) / UX/UI требования (frontend)
- **Маршрут:** `/profile`, `AuthGuard`, усі ролі. Пункт навігації `navigation.profile` (іконка `person`) + доступ з меню поруч із logout (кнопка акаунта).
- **Сторінка:** Material form (не ad-hoc HTML). Секції:
  1. ПІБ (`mat-form-field`).
  2. Тип особи — `mat-radio-group`: «Фізична особа» / «Представник юридичної особи».
  3. ЄДРПОУ — поле видиме й required лише при другому типі; підказка «8 або 10 цифр»; при перемиканні на фізособу значення очищається. maxLength 10.
  4. Канали зв’язку — `mat-checkbox` (email, телефон, месенджери). Email у підписі показує поточний `user.email` (read-only).
  5. Телефони — динамічний список (додати/видалити). У рядку: номер, `mat-checkbox` Telegram / WhatsApp / Viber, radio/slide «основний».
- **Стани:** `loading` / `error` / `success`. Submit — `mat-flat-button color="primary"`; скасування змін — `mat-stroked-button` (перечитати GET). Snackbar через `showAppSnack`.
- **Handset:** одна колонка, sticky actions внизу або стандартний page padding; діалоги не потрібні (форма на сторінці).
- **Адмінка `/admin/users`:** колонка `displayName` (ПІБ або email); у фільтрі — пошук contains по прізвищу/імені (плюс існуючий email). Картка/діалог деталей — ті самі поля профілю; редагування форми — лише ADMIN.
- **Тексти:** `pages.profile.*`, `navigation.profile`. Помилки каналів — окремі ключі, не generic «invalid».

## 10) Architecture Changes / Изменения в архитектуре
- **Components/services / Компоненты/сервисы:**
  - Backend: entity `UserProfile` + `UserContactPhone` (окремо від `User`); `UserProfileService`; `UserProfileController` (`/api/v1/users/me/profile`); методи в `AdminUserController`; розширити `UserDtoMapper`, `UserPublicDto`, `UserAdminDto`. Не додавати профільні поля в entity `User`.
  - Frontend: `UserProfileApiService`, `ProfileComponent` (`/profile`), пункт toolbar, розширити auth user model і admin users.
- **Data storage / Хранилище данных:** Flyway `V40` — лише `user_profiles` + `user_contact_phones`. Таблиця `users` не змінюється. Існуючі акаунти без рядка профілю.
- **Integrations / Интеграции:** немає.
- **Compatibility / Совместимость:** старі клієнти, що читають лише `id/email/role`, не ламаються (додаються поля). Flutter не оновлюємо.

## 11) Implementation Constraints / Ограничения реализации
- Існуючий стек і стиль (Spotless / `lint:fix` на здачі).
- Без нових залежностей (checksum ЄДРПОУ — свій код).
- **Не змінювати таблицю `users`** (немає ALTER, немає профільних колонок на entity `User`).
- Не міняти unrelated модулі (routes, trips, drivers).
- Коментарі в коді — українською.
- ПІБ: винести спільну санітизацію, якщо це можна зробити без рефактору водіїв «заодно»; інакше дублювати правила 1:1 і дати посилання в коментарі.
- UI — Angular Material.

## 12) Implementation Plan / План реализации
1. Flyway `V40`: `CREATE TABLE user_profiles`, `user_contact_phones` (без `ALTER users`) + entity/enum + валідатори (ПІБ, E.164, ЄДРПОУ).
2. `UserProfileService` + self/admin API + розширення `/auth/me` і admin DTO; інтеграційні тести.
3. Angular API + `/profile` (desktop + handset) + i18n + nav.
4. `/admin/users`: колонка ПІБ, фільтр, перегляд/редагування профілю.
5. Оновити `docs/system.md` і цей файл (статус «реалізовано»).

## 13) Acceptance Criteria (Definition of Done) / Критерии приемки
- [x] Користувач зберігає ПІБ, тип особи, ЄДРПОУ (для юрособи), телефони з месенджерами і канали зв’язку.
- [x] `INDIVIDUAL` не приймає ЄДРПОУ; представник юрособи не зберігається без валідного ЄДРПОУ.
- [x] Канал `PHONE` вимагає ≥1 телефон; `MESSENGERS` — ≥1 месенджер-прапорець.
- [x] `GET /auth/me` і login повертають `displayName` + `profile`.
- [x] `/profile` працює на desktop і handset, i18n ua/en/ru.
- [x] ADMIN бачить і редагує профіль у `/admin/users`; MANAGER лише читає.
- [x] Незаповнений профіль не блокує маршрути/заявки; `profileComplete` коректний.
- [x] Documentation updated / Документация обновлена (`system.md`, статус цієї спеки).
- [x] Tests added/updated and passing / Тесты добавлены или обновлены и проходят.
- [x] Схема таблиці `users` не змінена (немає ALTER).

## 14) Test Plan / Тест-план
- **Unit:** checksum 8 цифр (гілка ваг 3–9) і 10 цифр (РНОКПП, у т.ч. `k==10`); відхилення довжини 7/9; санітизація ПІБ; `profileComplete`.
- **Integration (MockMvc):** self GET/PUT; валідації каналів і ЄДРПОУ; унікальність телефону в межах user; транзакційна заміна колекції; RBAC (USER чужий 403, MANAGER PUT 403, ADMIN PUT 200); `/auth/me` після PUT; PUT deleted → `USER_DELETED`.
- **E2E/Manual:** заповнити фізособу з email+telegram; перемкнути на юрособу — з’являється ЄДРПОУ; handset `/profile`; адмін-список показує ПІБ.
- **Edge cases / Граничные случаи:** 0 телефонів + лише EMAIL; 5 телефонів; 6-й відхилити; порожнє по батькові; ЄДРПОУ 8 і 10 цифр; user без рядка `user_profiles` (GET порожній DTO).

## 15) Risks and Assumptions / Риски и допущения
- **Assumptions / Допущения:** месенджери живуть на номері телефону, окремих акаунтів немає. Код у ЄДР — український, **8 або 10** цифр (юрособа / ФОП); іноземні юрособи в v1 не потрібні. 10 цифр у цьому полі — код організації-ФОП, не ІПН приватного замовника (`INDIVIDUAL`). Профіль водія і профіль учётки — різні картки.
- **Risks / Риски:** менеджер чекає блокування заявок без профілю — свідомо відкладено; можна увімкнути окремим ТЗ. Роз’їзд ФІО driver vs user — прийнятний.
- **Rollback plan / План отката:** відкат PR / `DROP TABLE user_contact_phones, user_profiles`. Таблиця `users` не зачіпається.

## 16) Release Artifacts / Артефакты релиза
- PR: —
- Version/tag / Версия/тег: —
- Release date / Дата релиза: —
- Owner / Ответственный: —

---

## Instructions for LLM / Инструкции для LLM
Use these rules when implementing this specification / Используй правила ниже при реализации по этому ТЗ:

1. Ask clarifying questions first if ambiguity exists. / Якщо є неоднозначність, спочатку уточни.
2. Stay within `Scope` and `Out of Scope`. / Не виходь за рамки `Scope` і `Out of Scope`.
3. Follow current architecture and project style. / Дотримуйся стеку й стилю проєкту.
4. Show a brief plan before code changes. / Перед кодом покажи короткий план.
5. Do not edit `frontend-flutter/`.
6. Do not `ALTER TABLE users` and do not add profile fields to the `User` entity.
7. Do not add dependencies without explicit justification.
8. Comments in code: Ukrainian.
9. After changes provide: changed files, what/why, how to verify, risks/gaps.

## Appendices / Приложения

### A. Обчислення `displayName`
```
parts = [lastName, firstName, patronymic].filter(nonBlank)
displayName = parts.length ? parts.join(" ") : email
```

### B. Чому окремі таблиці, а не колонки / JSON на `users`
Таблиця `users` лишається auth-ідентичністю (email, hash, роль, flags). Профіль і телефони — нові таблиці: унікальність номера, CASCADE, адмін-пошук по ПІБ через JOIN, відкат без міграції назад по `users`.
