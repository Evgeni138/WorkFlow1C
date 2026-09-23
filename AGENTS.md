# 1C AI Workspace — opencode Configuration

## О проекте

Портативная AI-конфигурация для разработки на 1С:Предприятие 8.3, адаптированная для **opencode** (оригинал: [1c-ai-development-kit](https://github.com/Arman-Kudaibergenov/1c-ai-development-kit), формат Claude Code). Содержит 55 skills, документацию по XML форматам, JSON DSL спецификации, интеграцию с MCP серверами.

> **ШАБЛОН:** все проектно-специфичные значения ниже — плейсхолдеры в `{{...}}`.
> При развёртывании замените их (см. `QUICK_START.md`): сервер/база/платформа берутся из `.v8-project.json`,
> реестр RLM — из `rlm_projects list`, состав расширений — из вашей конфигурации.

## 1C Project

- **Тип**: Конфигурация + Расширения (основная БД на сервере; локальная XML-выгрузка НЕ развёрнута)
- **Сервер**: `{{DB_SERVER}}` (по умолчанию `localhost`)
- **База**: `{{BASE_NAME}}` (например `BPEuro`)
- **Платформа**: `{{V8_VERSION}}` → `C:\Program Files\1cv8\{{V8_VERSION}}\bin`
- **Локальные исходники**: в этом workspace не выгружены `src/` (главная конфигурация) и `ext/` (расширения) — разверни выгрузку (см. `src/README.md`), чтобы стала доступна RLM-индексация
- **Артефакты**: `dist/` (сборки CFE/CF/EPF — по запросу через skills)
- **Веб-публикация**: не используется (клиент-серверный режим)
- **Учётные данные**: см. `.v8-project.json` (`{{ADMIN_USER}}`)

### Development zone

**Текущий workspace — инфраструктурный**: рабочие зоны `external/` (EPF/ERF), `docs/`, `templates/`, `scripts/`, `openspec/`. Исходники 1С (`src/`, `ext/`) здесь не развёрнуты. Для доработок по расширениям предварительно разверни выгрузку либо работай по проектам реестра RLM (`rlm_projects list` → `{{RLM_PROJECTS}}`).

## Структура

```
src/                   — исходники конфигурации (выгрузка подключается при развёртывании)
ext/                   — исходники расширений (выгрузка подключается при развёртывании)
external/              — внешние обработки/отчёты (epf/, erf/)
.claude/skills/        — исходники skills + скрипты и шаблоны (формат Claude Code)
.opencode/skills/      — те же skills, нормализованные для opencode (SKILL.md)
.claude/docs/          — спецификации и гайды по форматам 1С
.opencode/command/     — slash-команды /<skill-name>
openspec/              — Specification-Driven Development
scripts/               — инфраструктурные скрипты (в т.ч. мост bsl-language-server)
dist/                  — собранные артефакты (CFE/CF/EPF)
```

Важно: тела skills ссылаются на скрипты по путям `.claude/skills/<skill>/scripts/*.ps1` — эти пути рабочие, не переносить.

## MANDATORY: MCP-First Rule

**These rules apply to initialized 1C projects (where MCP tools are connected via `/1c-project-init`).**
**This workspace itself has `playwright`, `rlm-tools-bsl`, `v8std`, `bsl-language-server` and `context-mode` enabled (`rlm-tools-bsl` starts automatically via stdio at opencode launch).**

### When to use which MCP tool (in 1C projects)

| Situation | Tool | Action |
|-----------|------|--------|
| Token-efficient analysis of BSL codebase (search, callers, refs по выгрузкам конфигурации) | `rlm-tools-bsl` | Call `rlm_start` at session start, then `rlm_execute` |
| Линт/диагностики, карточка символа, справка по платформе (код в текущем workspace) | `bsl-language-server` | `diagnostics`, `symbol_info`, `search` (find_docs/search_docs), `syntax_help` |
| Why a diagnostic fires / which standard applies | `v8std` | `v8std_explain_diagnostics`, `v8std_search` (публичный сервис — не слать проприетарный код) |
| Working with BSP subsystems | `1c-ssl` *(после `/1c-project-init`)* | Call `ssl_search` to find correct BSP patterns |
| Need a code template / pattern | `1c-templates` *(после `/1c-project-init`)* | Call `template_search` BEFORE writing from scratch |
| Complex logic / architecture review | `1c-code-checker` *(после `/1c-project-init`)* | Call to verify logic via 1C Companion |
| Working with managed forms XML | `1c-forms` *(после `/1c-project-init`)* | Call `get_form_schema` for structure reference |
| Work with 1C in browser (forms, data, testing) | `playwright` | Use `/1c-web-session` skill |

> `1c-help`, `1c-ssl`, `1c-templates`, `1c-code-checker`, `1c-forms`, `1c-syntax-checker` разворачиваются
> `1c-syntax-checker` командой `/1c-project-init` (общие MCP-серверы 1С). Пока их нет в этом workspace,
> их локальные аналоги: **линт/синтаксис → `bsl-language-server` `diagnostics`**, **паттерны БСП → схема в `1c-ssl` отсутствует — используй `bsp-patterns` skill**, **справка по платформе → `bsl-language-server` `search`/`syntax_help`**.

### Non-negotiable rules (in 1C projects)

Серверы `1c-help`, `1c-ssl`, `1c-templates`, `1c-syntax-checker`, `1c-code-checker`, `1c-forms`
становятся доступны после `/1c-project-init`. В текущем workspace до инициализации используй
локальные аналоги: синтаксис/справка → `bsl-language-server` (`search`, `syntax_help`, `diagnostics`),
стандарты → `v8std`, паттерны БСП → `/bsp-patterns`.

- **NEVER** write 1C code without first checking syntax — через `bsl-language-server` (`syntax_help`, `search`) или `1c-help` (после инициализации)
- **NEVER** use a BSP subsystem without checking `1c-ssl` for correct pattern
- **NEVER** skip syntax-check after writing BSL code — через `bsl-language-server` `diagnostics` или `1c-syntax-checker` (после инициализации)
- **NEVER** guess a code template — search `1c-templates` (после инициализации) или `bsp-patterns` skill first
- If MCP server is unavailable — say so explicitly, don't silently fall back

### MCP vs Grep decision (in 1C projects)

| Task | Use |
|------|-----|
| Поиск по исходникам 1С (BSL/XML выгрузок конфигурации) | `rlm-tools-bsl` (брать вместо Grep/Glob всегда) |
| Grep/Glob — только файл-система workspace: MD, JSON, PS1, CJS, внешние EPF/ERF-исходники | Grep/Glob (инфраструктурные файлы) |
| 1C platform docs / syntax | `1c-help` (после `/1c-project-init`); до инициализации — `bsl-language-server` `search`/`syntax_help` |
| BSP patterns | `1c-ssl` (после `/1c-project-init`); до инициализации — `bsp-patterns` skill |
| Code templates | `1c-templates` (после `/1c-project-init`); до инициализации — `bsp-patterns` skill |

---

## MANDATORY: Skills-First Rule

**BEFORE writing any script, code, or solution — check if a skill exists.**

Workflow:
1. User asks for something → scan skill list below
2. Skill exists → use it immediately (slash-команда или skill tool), do NOT reinvent
3. No skill → only then write custom code

This applies to ALL 1C operations: creating bases, loading configs, compiling objects, working with forms, BSP, SKD, roles, etc. **Never generate your own PowerShell/BAT scripts for operations that skills cover.**

## MANDATORY: Autonomy After Approval

**One approval point per task. After user says "ok" — execute autonomously.**

- Ask clarifying questions BEFORE showing the plan
- Show design+plan → get ONE approval
- After "ok": do NOT ask "can I proceed with step N?", "is this part ok?", "should I continue?"
- Only stop for blockers (impossible to continue, contradictory requirements)
- Report results at the end

## Task Routing (automatic)

AI determines the mode based on task complexity:

| Complexity | Mode | What to do |
|-----------|------|-----------|
| 1-2 objects, obvious | **direct** | Use skills directly, no ceremony |
| 3-5 tasks, needs design | **standard** | `/brainstorm` → brief plan → execute |
| 6+ tasks, architectural | **full** | `/brainstorm` → `/write-plan` → `/subagent-dev` |
| Formal spec management | **openspec** | `/openspec-proposal` → `/openspec-apply` |

## Skills (ключевые команды)

Полный список — в `SKILLS.md`. Все команды доступны как `/command-name`.

### Объекты метаданных
- `/meta-compile`, `/meta-edit`, `/meta-remove` — CRUD для 23 типов объектов
- `/inspect` — анализ структуры объекта (реквизиты, ТЧ, формы, движения, типы)
- `/validate` — валидация объектов, форм, СКД, макетов, ролей, подсистем

### Формы
- `/form-compile`, `/form-edit`, `/form-add`, `/form-remove`, `/form-patterns`, `/help-add`

### Обработки и отчёты (EPF/ERF)
- `/epf-expert` (init, build, dump, bsp-init, bsp-add-command)
- `/erf-expert` (init, build, dump)
- `/bsp-patterns` — паттерны работы с подсистемами БСП

### СКД и макеты
- `/skd-compile`, `/skd-edit`
- `/mxl-expert` (compile, decompile, template-add, template-remove)
- `/img-grid` — наложить сетку на изображение для определения пропорций колонок

### Роли, конфигурация, расширения
- `/role-expert` — компиляция ролей + аудит прав
- `/cf-init`, `/cf-edit`
- `/cfe-init`, `/cfe-borrow`, `/cfe-patch-method`, `/cfe-diff`
- `/subsystem-expert` (compile, edit, interface-edit)

### База данных
- `/db-create`, `/db-list`, `/db-run`, `/db-update`
- `/db-dump-cf`, `/db-load-cf`, `/db-dump-xml`, `/db-load-xml`, `/db-load-git`

### Веб-клиент и публикация
- `/1c-web-session` — управление 1С в браузере
- `/web-publish`, `/web-unpublish`, `/web-info`, `/web-stop`, `/web-test`

### Инициализация и тестирование
- `/1c-project-init` — инициализация/обогащение 1С проекта (skills, docs, MCP)
- `/1c-test-runner` — AI-тестирование бизнес-логики
- `/playwright-test` — scaffold UI-теста после деплоя

### Workflow
- `/brainstorm` — **основной**: обсуждение → план → автономное выполнение
- `/write-plan` — создать tasks.md из design.md
- `/subagent-dev` — выполнить tasks.md субагентами
- `/1c-help-mcp` — поиск по документации платформы
- `/1c-query-opt` — оптимизация запросов
- `/session-save`, `/session-restore`, `/session-retro` — управление сессиями

### OpenSpec
- `/openspec-proposal`, `/openspec-apply`, `/openspec-archive`

## Правила разработки

### 1С кодирование
- Следовать стандартам БСП и ITS
- Кириллица для кода 1С (BSL), латиница для инфраструктуры
- Табы для отступов в BSL коде
- UTF-8 BOM для PowerShell скриптов с кириллицей
- ASCII-only в PowerShell выводе ([OK], [!], [*] вместо emoji)

### Workflow доработок
- Для любых доработок: `/brainstorm` (сам выберет режим express/standard/full)
- Для формальных спецификаций: `/openspec-proposal` → `/openspec-apply`
- Одно одобрение → автономная реализация → отчёт в конце
- НИКОГДА не спрашивать разрешения после одобрения плана

### Git безопасность
- НИКОГДА force push на main/master
- НЕ коммитить .env, credentials, ключи
- НЕ пропускать hooks без явного запроса
- Предупреждать перед деструктивными операциями

### Контекст
- RLM-first: для анализа больших BSL-кодовых баз используй `rlm-tools-bsl` (`rlm_start` → `rlm_help` → `rlm_execute`) вместо прямого чтения файлов
- ⚠️ Пока в workspace нет выгрузки `src/`-cf/EDT, RLM работает в режиме `foreign_with_bsl`: объектные хелперы (например `get_object_profile`, `find_attributes`) не надёжны — используй `find_module`, поиск по BSL-текстам и файловые хелперы
- Сохраняй решения в RLM после завершения задач
- Task agents (subagents) для параллельных задач (изоляция контекста)

## MCP серверы

Конфигурация — в `opencode.jsonc` этого workspace (пути — плейсхолдеры `{{AI_ENV}}`, `{{WORKSPACE_ROOT}}`, `{{NODE}}`, см. `QUICK_START.md`).

- `playwright` — ✅ включён и работает: управление браузером (веб-клиент 1С, тестирование)
- `rlm-tools-bsl` — ✅ включён и работает. ⚠️ Без локальной cf/EDT-выгрузки в текущем workspace RLM работает в режиме `foreign_with_bsl`: объектные/метаданные-хелперы ненадёжны, доступны поиск по BSL-текстам и файловые хелперы. Реестр проектов: `{{RLM_PROJECTS}}` — для полноценного анализа по выгрузкам используй их ([Dach-Coin/rlm-tools-bsl](https://github.com/Dach-Coin/rlm-tools-bsl))
- `v8std` — ✅ включён и работает: `v8std_search`, `v8std_explain_diagnostics`, `v8std_get_page` и др. ([ai.v8std.ru/mcp](https://ai.v8std.ru/mcp); текст запроса уходит во внешний сервис — не слать проприетарный код)
- `bsl-language-server` — ✅ включён: `bsl-analyzer.exe mcp serve --profile workspace` (0.2.71) через прозрачный мост `scripts/mcp-bsl-analyzer-bridge.cjs` (newline-JSON ↔ newline-JSON; исправлено 2026-09-23 — ранее мост ждал LSP-frames и сервер не подключался)
- `context-mode` — ✅ включён и работает (экономия контекста). Ранее был помчен как «выключен по умолчанию» — статус обновлён

Разграничение поиска по коду 1С: `rlm-tools-bsl` — навигация по XML-выгрузкам и файлам (RLM-индекс), `v8std` — «почему это нарушение стандарта».

При инициализации 1С проекта (`/1c-project-init`) разворачиваются общие MCP-серверы (1c-help, 1c-ssl, 1c-templates, 1c-syntax-checker, 1c-code-checker, 1c-forms) — см. `.claude/skills/1c-project-init/templates/mcp.json.template`. Шаблон в формате Claude (`.mcp.json`) — при разворачивании в opencode-проект конвертируйте его в секцию `mcp` файла `opencode.jsonc` целевого проекта (type http → remote, stdio → local с массивом command).

- **Какой сервер использовать (критерий — «где живёт код»):**
  - **Код в выгрузках конфигурации** (`src/`, `ext/` → проекты реестра RLM) → `rlm-tools-bsl`: поиск модулей/методов/объектов, граф вызовов, ссылки на объекты метаданных, путь данных (`find_module`, `search_methods`, `find_call_hierarchy`, `find_callers_context`, `find_references_to_object`, `find_data_path`, `git_search`).
  - **Код в текущем workspace** (`external/`, `scripts/`, развернутые выгрузки → тоже bsl-language-server) → `bsl-language-server`: линт/диагностики, карточка символа, структура модуля/форм, справка по платформе.
  - **Линт/проверка кода BSL** → `bsl-language-server` `diagnostics` (file/workspace, 180+ правил) + `v8std` («почему это нарушение»).
  - **Карточка символа / тип / кто вызывает одним запросом** → `bsl-language-server` `symbol_info`.
  - **Структура модуля / области / методы** → `bsl-language-server` `outline`.
  - **Формы и метаданные workspace-объектов** → `bsl-language-server` `metadata` / `outline`.
  - **Справка по платформе / синтаксис** → `bsl-language-server` `search` (`find_docs`/`search_docs`) и `syntax_help` (до включения `1c-help`).
  - **Разграничение графов вызовов:** `bsl-language-server` `graph` (callers/callees/neighbors) — только для кода, развёрнутого в текущем workspace; `rlm-tools-bsl` `find_call_hierarchy` / `find_references_to_object` / `find_definition` — для полной конфигурации по реестру (`{{RLM_PROJECTS}}`). Не дублируй: если цель в реестре RLM — сразу RLM, если в workspace — bsl-ls.
  - Не использовать инструменты bsl-ls `definition`, `hover`, `find_references` — их нет в текущей MCP-поверхности (ошибка валидации `file not found` в bridge): роль закрывают `graph`/`symbol_info` (workspace) и RLM-хелперы (полная конфигурация).

## OpenSpec

Методология Specification-Driven Development:
- `openspec/project.md` — контекст и соглашения проекта
- `openspec/changes/` — активные предложения изменений
- `openspec/specs/` — текущие спецификации возможностей

Skills: `/openspec-proposal`, `/openspec-apply`, `/openspec-archive`
