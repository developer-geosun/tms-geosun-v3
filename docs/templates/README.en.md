# Templates Guide

This folder contains reusable templates for specifications and AI prompts.

## Structure
- `specs/` - technical specification templates.
- `prompts/` - prompt templates for common development workflows.

## Specification templates
- `specs/_template.ru.en.md`  
  Universal bilingual (RU/EN) technical specification template (блок **Статус** обязателен).
- Живые ТЗ: `docs/specs/`. Реестр статусов: `docs/specs/README.ru.md`.

## Prompt templates
- `prompts/spec-to-plan.en.ru.md`  
  Use when you need an implementation plan from a specification, without coding.

- `prompts/feature-implementation.en.md`  
  Use when you want full feature implementation based on a specification.

- `prompts/bugfix.en.md`  
  Use when fixing a specific bug with minimal safe changes.

- `prompts/code-review.en.md`  
  Use for risk-focused review of a diff or pull request.

- `prompts/release-checklist.en.md`  
  Use before release to run a quality gate and decide Go/No-Go.

## Recommended flow
1. Copy `specs/_template.ru.en.md` into a feature-specific file and fill it.
2. Run `prompts/spec-to-plan.en.ru.md` to confirm scope and implementation steps.
3. Run `prompts/feature-implementation.en.md` (or `prompts/bugfix.en.md`) to implement.
4. Run `prompts/code-review.en.md` before merge.
5. Run `prompts/release-checklist.en.md` before release.

## Naming suggestions
- Specs: `docs/specs/<feature-name>.<lang>[.<lang>…].md`
- Prompts for experiments: `docs/prompts/<date>-<topic>.<lang>[.<lang>…].md`

Keep templates stable, and create task-specific copies instead of editing templates directly.
