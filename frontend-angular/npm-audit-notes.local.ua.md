# npm audit — коментар

**Дата:** 2026-09-02  
**Каталог:** `frontend-angular`  
**Команда:** `npm audit fix`

---

## Підсумок

`npm audit fix` **нічого не виправив** — «up to date». Залишилось 5 вразливостей, які npm **не може безпечно закрити** звичайним `fix`; для `image-size` пропонує `--force`, що **ламає проєкт**.

---

## 1. `image-size` (3 high) — через `less` → `@angular-devkit/build-angular`

**Ланцюжок:** `@angular-devkit/build-angular@21.2.20` → `less@4.4.2` → `image-size@0.5.5`

**Суть:** DoS у парсерах ICNS/JXL/HEIF при обробці **спеціально crafted** зображень.

**Чому `fix` не допоміг:** вразливість у транзитивній залежності Angular build toolchain. У проєкті вже свіжий Angular 21.2.x; npm пропонує `--force` → `@angular-devkit/build-angular@0.1002.1` — це **Angular 10**, повний відкат, не варіант.

**Реальний ризик:** **низький для продакшену**

- `devDependency`, лише на етапі збірки
- спрацьовує при парсингу зображень через `less` (якщо проєкт не використовує LESS з такими форматами — практично не зачіпає runtime)

**Що можна:** чекати оновлення `less` / Angular CLI; за бажанням — `overrides` на безпечну версію `image-size`, якщо вона вже є (потрібно перевірити сумісність з `less`).

---

## 2. `qs` (2 moderate) — через `karma` і `webpack-dev-server`

**Ланцюжок:**

- `karma` → `body-parser` → `qs`
- `webpack-dev-server@5.2.6` (у `package.json` уже є override) → `body-parser` / `qs`

**Суть:** DoS у `qs.stringify` / парсингу query string.

**Чому `fix` не допоміг:** вкладені копії `qs` у `karma` і `webpack-dev-server`; npm не може підняти їх без оновлення батьківських пакетів.

**Реальний ризик:** **низький**

- `karma` — лише тести
- `webpack-dev-server` — лише `ng serve` локально, не production bundle

---

## Рекомендації

| Дія | Вердикт |
|-----|---------|
| `npm audit fix --force` | **Не запускати** — зламає Angular 21 |
| Ігнорувати як «критичну діру в prod» | **Допустимо** — усе dev/build-time |
| `overrides` для `qs` / `image-size` | Опційно, якщо потрібен «зелений» audit |
| Стежити за `@angular/cli` / `karma` | Розумно — fix прийде upstream |

---

## Висновок

Звіт типовий для Angular-проєктів: **шум від dev-залежностей**, не від runtime-коду застосунку. `npm audit fix` відпрацював коректно — просто безпечних автофіксів немає. Для production (`ng build`) ці CVE **не потрапляють у бандл**; ризик переважно при локальній розробці та CI-тестах.
