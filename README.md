# 1C AI Workspace (opencode template)

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL_3.0-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![opencode](https://img.shields.io/badge/opencode-supported-blue.svg)](https://opencode.ai)

> Рабочая заготовка (скейлетон) для AI-ассистированной разработки на 1С:Предприятие 8.3
> в **opencode** с 55 skills, документацией по XML-форматам, JSON DSL-спецификациями
> и интеграцией с MCP-серверами.

Мета-проект развит из [1c-ai-development-kit](https://github.com/Arman-Kudaibergenov/1c-ai-development-kit)
(формат Claude Code) — см. [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md). В этом шаблоне конфигурация
адаптирована для opencode, а все проектно-специфичные значения вынесены в плейсхолдеры `{{...}}`.

---

## Что это?

Готовая экосистема для разработки на 1С с помощью AI:

- **55 skills** — автоматизация полного цикла разработки: объекты метаданных, формы, EPF/ERF,
  СКД, MXL, роли, подсистемы, конфигурация и расширения (CFE), базы данных, веб-публикация,
  тестирование. Вызываются как `/skill-name`.
- **Документация по форматам 1С** (`.claude/docs/`) — 30 спецификаций XML-форматов, JSON DSL
  для компиляции без знания XML, паттерны управляемых форм, гайды.
- **MCP-серверы** — готовый состав подключения: `playwright`, `rlm-tools-bsl`, `v8std`,
  `bsl-language-server`, `context-mode` (плюс общие `1c-*` после `/1c-project-init`).
- **Инфраструктура** — мост для bsl-language-server, скрипты, шаблоны, OpenSpec-рабочий процесс.

---

## Что внутри

### Skills (55)

Полный список и правила работы — в [SKILLS.md](SKILLS.md) и `AGENTS.md`.

| Группа | Skills |
|--------|--------|
| Объекты метаданных | `meta-compile`, `meta-edit`, `meta-remove`, `inspect`, `validate` |
| Формы | `form-compile`, `form-edit`, `form-add`, `form-remove`, `form-patterns`, `help-add` |
| Обработки и отчёты | `epf-expert`, `erf-expert`, `bsp-patterns` |
| СКД и макеты | `skd-compile`, `skd-edit`, `mxl-expert`, `img-grid` |
| Роли/конфигурация/расширения | `role-expert`, `cf-init`, `cf-edit`, `cfe-init`, `cfe-borrow`, `cfe-patch-method`, `cfe-diff`, `subsystem-expert` |
| База данных | `db-create`, `db-list`, `db-run`, `db-update`, `db-dump-cf`, `db-load-cf`, `db-dump-xml`, `db-load-xml`, `db-load-git` |
| Веб-клиент | `1c-web-session`, `web-publish`, `web-unpublish`, `web-info`, `web-stop`, `web-test` |
| Workflow | `brainstorm`, `write-plan`, `subagent-dev`, `1c-help-mcp`, `1c-query-opt`, `1c-project-init`, `1c-test-runner`, `playwright-test`, `session-save`, `session-restore`, `session-retro` |
| OpenSpec | `openspec-proposal`, `openspec-apply`, `openspec-archive` |

### Документация — 30 спецификаций

`.claude/docs/` — 30 спецификаций XML-форматов 1С (см. [1c-specs-index.md](.claude/docs/1c-specs-index.md)) и гайды.

### Шаблоны

- `templates/mcp.json` — готовый конфиг MCP-серверов для нового проекта (формат Claude Code);
  конвертация в секцию `mcp` файла `opencode.jsonc` описана в `AGENTS.md`.
- `src/`, `ext/`, `dist/` — структура для выгрузки конфигурации/расширений и артефактов сборки.

---

## Быстрый старт (развёртывание шаблона)

1. **Склонируйте/скопируйте** шаблон в рабочий каталог проекта (например `D:\WorkFlow\<project>`).
2. **Заполните `.v8-project.json`** — сервер, имя базы, учётные данные, путь к платформе 1С.
3. **Настройте `opencode.jsonc`** — замените плейсхолдеры `{{WORKSPACE_ROOT}}`, `{{AI_ENV}}`,
   `{{NODE}}` на реальные пути вашего окружения.
4. **Выгрузите исходники** конфигурации в `src/` и расширений в `ext/` (`db-dump-xml`/DumpConfigToFiles).
5. **(Опционально) выполните `/1c-project-init`** — развернёт общие MCP-серверы `1c-*`.
6. **Запустите opencode** в корне проекта — начните с `/brainstorm` для первой задачи.

Подробности — в [QUICK_START.md](QUICK_START.md) и `AGENTS.md`.

---

## MCP-серверы

Базовая конфигурация (в `opencode.jsonc`):

| Сервер | Назначение |
|--------|-----------|
| `rlm-tools-bsl` | Token-efficient анализ BSL-кодовых баз (поиск, вызовы, ссылки). Полная выгрузка конфигурации (`src/`, `ext/`) анализируется ТОЛЬКО здесь |
| `bsl-language-server` | Линт/диагностики BSL, карточки символов, справка по платформе (зона — только `external/` + `scripts/`) |
| `v8std` | Стандарты 1С: диагностики, пояснения «почему это нарушение» |
| `playwright` | Веб-клиент 1С в браузере, UI-тестирование |
| `context-mode` | Экономия контекста |
| `1c-help`, `1c-ssl`, `1c-templates`, `1c-forms` и др. | Разворачиваются через `/1c-project-init` |

Настройка MCP: [docs/guides/project-mcp-setup.md](docs/guides/project-mcp-setup.md).

---

## Требования

- 1С:Предприятие 8.3 (клиент-сервер или файловая база)
- PowerShell 5.1+
- Git
- opencode (актуальная версия)
- Локальное окружение с бинарниками MCP-серверов (`rlm-tools-bsl.exe`, `bsl-analyzer.exe`) — путь задаётся через `{{AI_ENV}}`

---

## Содействие

См. [CONTRIBUTING.md](CONTRIBUTING.md). Лицензия — [LICENSE](LICENSE), см. также `COPYRIGHT`.

## Благодарности

Проект построен на работе сообщества: [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md)

---

## Changelog

### v1.1.1 (2026-09-23)

**Шаблонизация для opencode:** проект подготовлен как переиспользуемая заготовка:

- Все проектно-специфичные значения (сервер/база/платформа, пути, реестр RLM, креды) вынесены
  в плейсхолдеры `{{...}}` / `YOUR_USER`.
- Создан состав структуры `src/`, `ext/`, `dist/` с README-заглушками.
- Конфигурация MCP параметризована (`{{WORKSPACE_ROOT}}`, `{{AI_ENV}}`, `{{NODE}}`);
  `.opencode/package.json` коммитится для самовоспроизводимости плагинов.
- Добавлены `.gitignore`-правила для локальных артефактов (`.build/`, `.playwright-mcp/`,
  `templates/unload_*.txt`, `session-notes.md`).

### v1.1.0 (2026-03-05)

**Консолидация skills: 14 granular skills объединены в 5 expert skills** (85 → 55 skills;
`epf-expert`, `mxl-expert`, `role-expert`, `subsystem-expert`, `inspect`, `validate`).

### v1.0.0

Первый публичный релиз в составе исходного [1c-ai-development-kit](https://github.com/Arman-Kudaibergenov/1c-ai-development-kit).