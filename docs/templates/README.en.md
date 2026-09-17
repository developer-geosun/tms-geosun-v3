# Templates Guide

This folder contains reusable templates for specifications, briefs, and AI prompts.

Канон процесса: [`docs/dev-workflow.ru.md`](../dev-workflow.ru.md) (алгоритмы **A** и **B**).

## Structure

- `business-brief.ru.md` / `change-brief.ru.md` — briefs перед спекой
- `specs/` — technical specification templates
- `prompts/` — prompt templates for common development workflows

## Briefs

- `business-brief.ru.md` — **алгоритм A** (новая разработка): проблема, роли, ценность, out of scope
- `change-brief.ru.md` — **алгоритм B** (доработка реализованного): текущее vs желаемое, ссылка на канон-спеку

## Specification templates

- `specs/_template.ru.en.md` — bilingual RU/EN technical specification (блок **Статус** обязателен)
- Живые ТЗ: `docs/specs/`. Реестр: `docs/specs/README.ru.md`. Baseline: `docs/specs/BASELINE.ru.md`.

## Prompt templates

- `prompts/spec-to-plan.en.ru.md` — plan from a specification, without coding
- `prompts/feature-implementation.en.md` — implement by specification
- `prompts/bugfix.en.md` — minimal safe bugfix
- `prompts/code-review.en.md` — risk-focused review
- `prompts/release-checklist.en.md` — Go/No-Go before release

## Recommended flows

### Algorithm A — new feature

1. Fill `business-brief.ru.md` → user «+»
2. Copy `specs/_template.ru.en.md` into `docs/specs/<feature>.<lang>….md` → user «+»
3. Run `prompts/spec-to-plan.en.ru.md` → user «+»
4. Run `prompts/feature-implementation.en.md`
5. Update registry / DoD / BASELINE as needed; optional `code-review` / `release-checklist`

### Algorithm B — change existing

1. Fill `change-brief.ru.md` (link to canon spec) → user «+»
2. Edit the **existing** source-of-truth spec (do not duplicate) → user «+»
3. Delta plan via `prompts/spec-to-plan.en.ru.md` → user «+»
4. Implement; sync registry / BASELINE / DoD

Keep templates stable; create task-specific copies instead of editing templates directly.

## Naming

- Specs: `docs/specs/<feature-name>.<lang>[.<lang>…].md`
- Prompts for experiments: `docs/prompts/<date>-<topic>.<lang>[.<lang>…].md`
