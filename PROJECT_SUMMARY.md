# Project Summary: 1C AI Workspace (opencode template)

## Что это

Переиспользуемый шаблон (**рабочая заготовка**) для AI-разработки на 1С:Предприятие 8.3
в **opencode**. Адаптирован из [1c-ai-development-kit](https://github.com/Arman-Kudaibergenov/1c-ai-development-kit)
(формат Claude Code). Все проектно-специфичные значения вынесены в плейсхолдеры `{{...}}` /
`YOUR_USER`, поэтому шаблон можно скопировать под новый проект и заполнить только реальные данные.

### Структура

```
1c-ai-workspace-template/
├── .claude/
│   ├── skills/          # 55 skills + скрипты и шаблоны (формат Claude Code)
│   └── docs/            # 30 спецификаций XML-форматов 1С + гайды
├── .opencode/
│   ├── skills/          # навыки, нормализованные для opencode (SKILL.md)
│   ├── command/         # 55 slash-команд /<skill-name>
│   ├── plugin/          # контекст-монитор (package.json коммитится)
│   └── .gitignore       # node_modules/лок — вне git
├── src/                 # выгрузка главной конфигурации (пусто до развёртывания)
├── ext/                 # выгрузка расширений (пусто до развёртывания)
├── external/            # внешние обработки/отчёты (epf/, erf/)
├── docs/guides/         # инсталляция, проектные MCP, сессии
├── templates/           # mcp.json (готовый конфиг MCP)
├── scripts/             # мост bsl-language-server, санитайзер и др.
├── AGENTS.md            # правила AI-агента (редактируются при развёртывании)
├── opencode.jsonc       # MCP-конфигурация (плейсхолдеры {{...}})
├── .v8-project.json     # локальные креды 1С (НЕ коммитится, в .gitignore)
├── README.md / QUICK_START.md / SKILLS.md
└── LICENSE / COPYRIGHT / ACKNOWLEDGMENTS.md / CONTRIBUTING.md
```

### Статистика (шаблон)

- **Skills:** 55
- **Slash-команд:** 55
- **Спецификации форматов 1С:** 30 (`.claude/docs/`)
- **MCP-серверы:** `playwright`, `rlm-tools-bsl`, `v8std`, `bsl-language-server`, `context-mode`
  (+ общие `1c-*` после `/1c-project-init`)
- **Плагин:** контекст-монитор (70%/85% заполнения)

## Что сделано при шаблонизации

### 1. Изоляция от рабочего проекта ✅

- Шаблон создан копированием из рабочего воркспейса **BPEuro** (исходник не тронут).
- Локальные артефакты исключены: `.build/` (кэш bsl-ls), `.playwright-mcp/`,
  `node_modules`, одноразовые выгрузки `templates/unload_*`.

### 2. Очистка приватных данных ✅

- `.v8-project.json` → плейсхолдерный шаблон (`{{V8_BIN}}`, `{{DB_SERVER}}`, …).
- `opencode.jsonc` → параметризован (`{{WORKSPACE_ROOT}}`, `{{AI_ENV}}`, `{{NODE}}`).
- `init.ps1` → `YOUR_USER` вместо реального имени пользователя.
- `sanitize-files.ps1` → реальный Gitea-токен заменён на плейсхолдер.
- `rebuild-configuration-root.ps1` → пути заменены на `{{SRC_ROOT}}`, `{{WS1_ROOT}}`.
- `AGENTS.md` → сервер/база/платформа/реестр RLM/состав расширений → плейсхолдеры.

### 3. Документация актуализирована ✅

- `README.md` — переписан под шаблон: состав, развёртывание, MCP, changelog.
- `QUICK_START.md` — переписан: как развернуть за 5 минут.
- `docs/guides/installation.md` — переориентирован с Cursor на opencode; убраны
  следы `gitea.yourdomain`, `.cursor`, атрибуция оригинала сохранена.

### 4. Структура src/ext/dist ✅

- `src/`, `ext/`, `dist/` созданы с `.gitkeep` и README-заглушками.

### 5. Git-безопасность ✅

- `.gitignore`: `.build/`, `.playwright-mcp/`, `templates/unload_*.txt`, `session-notes.md`
  добавлены; `.v8-project.json`, `*.cf/cfe/epf/erf`, `*.log` уже игнорировались.
- `.opencode/.gitignore`: `package.json` больше НЕ игнорируется — плагин собирается на чистом клоне.

## Что НЕ включено

- Исходники конфигурации BPEuro (`src/`, `ext/`) — выгружаются при развёртывании.
- Локальные креды (`.v8-project.json`).
- Проектно-специфичные EPF из `external/epf` (ЕСУР, гастроном2) — рабочая разведка;
  оставлены `.gitkeep` и README.
- исторические `openspec/specs` и `Аудит/` (содержали персональные пути).

## Развёртывание (кратко)

1. Скопировать шаблон → `git init`.
2. Заполнить `.v8-project.json`, `opencode.jsonc`, `AGENTS.md`.
3. Выгрузить конфигурацию в `src/`, расширения в `ext/`.
4. `/1c-project-init` (+ реестр RLM и индексация).
5. Начать работу: `/brainstorm`, `/inspect`, `/meta-compile`, …

Подробно — в [QUICK_START.md](QUICK_START.md) и `AGENTS.md`.

## Лицензия

AGPL-3.0 (см. [LICENSE](LICENSE), `COPYRIGHT`). Благодарности исходным авторам —
[ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md).

---

**Создано:** 2026-09-23 (копия рабочего воркспейса BPEuro, очищенная и шаблонизированная)
**Статус:** готов к `git init` и публикации на GitHub.