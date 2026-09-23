# Руководство по установке

## Системные требования

### Обязательные

- **opencode** (актуальная версия, с поддержкой MCP и skills)
- **1С:Предприятие 8.3** (любая редакция: базовая, КОРП, УТ и т.д.; клиент-сервер или файловая база)
- **PowerShell 5.1+** (Windows) или **Bash** (Linux/macOS)
- **Git** 2.20+

### Рекомендуемые

- **Локальное окружение с бинарниками MCP-серверов** (`rlm-tools-bsl.exe`, `bsl-analyzer.exe`) —
  путь задаётся через `{{AI_ENV}}` в `opencode.jsonc`
- **Node.js 18+** (для MCP-серверов/плагинов opencode)
- **Python 3.10+** (для некоторых утилит)
- **Docker** (для запуска MCP-серверов локально)

## Установка базового набора

### Шаг 1: Копирование шаблона

Скопируйте этот шаблон в рабочий каталог проекта (или склонируйте форк вашего публичного репозитория):

```bash
git clone https://github.com/<you>/<template-repo>.git
cd <template-repo>
```

### Шаг 2: Интеграция в существующий проект

Если у вас уже есть проект 1С — разверните шаблон поверх него или перенесите конфигурацию в него:

```bash
# Выгрузите исходники конфигурации в src/ (главная конфигурация) и ext/ (расширения)
# через /1c-project-init, /db-dump-xml или напрямую DumpConfigToFiles
```

### Шаг 3: Создание нового проекта

Если вы начинаете с нуля, используйте навык `1c-project-init`:

```bash
# В opencode: "Инициализируй проект 1С из базы Srvr='server'; Ref='database'"
# или команда /1c-project-init
```

Навык автоматически:
- Определит версию 1С
- Создаст/заполнит `.v8-project.json`
- Выгрузит конфигурацию и расширения в XML (`src/`, `ext/`)
- Настроит реестр проектов RLM и построит индекс
- Инициализирует Git

## Настройка MCP-серверов

### Бесплатные MCP-серверы

#### BSL LSP Bridge

**Назначение:** Интеграция с BSL Language Server для анализа кода

**Автор:** [Vladimir Akimov (SteelMorgan)](https://github.com/SteelMorgan)

**Установка:**

1. Клонируйте репозиторий:
```bash
git clone https://github.com/SteelMorgan/mcp-bsl-lsp-bridge.git
cd mcp-bsl-lsp-bridge
```

2. Установите зависимости:
```bash
npm install
```

3. Скачайте BSL Language Server:
```bash
# Скачайте jar файл с https://github.com/1c-syntax/bsl-language-server/releases
# Положите в папку bsl-lsp-bridge/
```

4. Запустите сервер:
```bash
node server.js
```

5. Добавьте в конфиг MCP вашего клиента (в opencode — секция `mcp` в `opencode.jsonc`):
```json
{
  "mcpServers": {
    "bsl-lsp-bridge": {
      "command": "curl",
      "args": [
        "-X", "POST",
        "http://localhost:5007/mcp",
        "-H", "Content-Type: application/json",
        "-d", "@-"
      ]
    }
  }
}
```

#### rlm-tools-bsl

**Назначение:** RLM-анализ кодовых баз 1С (BSL): поиск по исходникам, граф вызовов, ссылки на объекты — экономия токенов

**Установка** ([Dach-Coin/rlm-tools-bsl](https://github.com/Dach-Coin/rlm-tools-bsl), Python 3.10+):

1. Установите пакет:
```bash
uv tool install rlm-tools-bsl
```

2. Запустите HTTP-сервер (рекомендуется):
```bash
rlm-tools-bsl --transport streamable-http
```

3. Добавьте в конфиг MCP-клиента:
```json
{
  "mcpServers": {
    "rlm-tools-bsl": {
      "type": "http",
      "url": "http://127.0.0.1:9000/mcp"
    }
  }
}
```

### Платные MCP-серверы

Платные MCP-серверы предоставляются по подписке. Они включают:

- `1c-help` — документация 1С
- `1c-ssl` — БСП (Библиотека Стандартных Подсистем)
- `1c-templates` — шаблоны кода
- `1c-syntax-checker` — проверка синтаксиса BSL
- `1c-code-checker` — проверка логики (1С:Напарник)
- `1c-forms` — схемы управляемых форм

**Получение доступа:**

1. Приобретите на [vibecoding1c.ru/mcp_server](https://vibecoding1c.ru/mcp_server)
2. Получите Docker-контейнеры и инструкции по развертыванию
3. Запустите контейнеры на своем сервере (Linux/Windows/macOS)
4. Настройте свои API-ключи:
   - OpenAI/Anthropic (для embeddings) — или используйте локальные модели
   - 1С:Напарник (для проверки кода) — ваш ключ
   - Neo4j (для графового поиска) — локальная установка
5. Добавьте серверы в конфиг MCP вашего клиента (шаблон — `templates/mcp.json`; для opencode сконвертируйте в секцию `mcp` файла `opencode.jsonc`)

**Важно:**
- ✅ **Не SaaS** — вы разворачиваете у себя
- ✅ **Ваши данные** — ничего не уходит на сторонние серверы
- ✅ **Ваши ключи** — используете свои API-ключи
- ✅ **Локальные модели** — можно использовать LMStudio, Ollama, Qwen
- ✅ **Полный контроль** — настраиваете под свои нужды

**Автор MCP:** Олег Филиппов ([@comol_foa](https://t.me/comol_foa))  
**Документация:** [vibecoding1c.ru](https://vibecoding1c.ru/)  
**Сообщество:** [t.me/comol_it_does_matter](https://t.me/comol_it_does_matter)

### Проектные MCP-серверы

Для каждого проекта 1С можно создать специализированные MCP-серверы:

1. **Metadata & Code Search MCP** — семантический поиск по вашей конфигурации
2. **Graph MCP** — граф зависимостей объектов

См. [Создание проектных MCP](project-mcp-setup.md) для деталей.

## Проверка установки

### Проверка МСП-профиля

1. В opencode откройте палитру MCP (например `/mcp`)
2. Убедитесь, что серверы `rlm-tools-bsl`, `bsl-language-server`, `v8std`, `playwright`, `context-mode` подключены
3. Проверьте пути в `opencode.jsonc` (`{{WORKSPACE_ROOT}}`, `{{AI_ENV}}`, `{{NODE}}`) указывают на существующие файлы
4. Убедитесь, что корень `-s` у `bsl-language-server` = `{{WORKSPACE_ROOT}}\external` — bsl-language-server НЕ должен сканировать `src/`/`ext/` (это зона `rlm-tools-bsl`)

### Проверка навыков

1. В чате opencode напишите: "Покажи доступные skills"
2. AI должен перечислить навыки из `.opencode/skills/` и `.claude/skills/`

### Проверка MCP-серверов

1. В чате opencode напишите: "Найди документацию по методу СтрРазделить"
2. `bsl-language-server` (`search`/`syntax_help`) или `1c-help` (после `/1c-project-init`) найдёт документацию
3. Если сервер не настроен — предложит подключить

## Решение проблем

### Skills не видны

**Проблема:** opencode не находит навыки

**Решение:**
1. Проверьте структуру `.opencode/skills/<name>/SKILL.md` и slash-команды в `.opencode/command/`
2. Убедитесь, что `AGENTS.md` подключён как instructions в `opencode.jsonc`
3. Перезапустите opencode после изменения конфигурации

### MCP-серверы не работают

**Проблема:** Ошибка "MCP server not responding"

**Решение:**
1. Проверьте пути в `opencode.jsonc` — `{{AI_ENV}}` должен содержать `rlm-tools-bsl.exe` / `bsl-analyzer.exe`
2. Проверьте, что мост `scripts/mcp-bsl-analyzer-bridge.cjs` существует в `{{WORKSPACE_ROOT}}`
3. Проверьте зону сканирования `bsl-language-server`: корень `-s` в `opencode.jsonc` должен указывать на `{{WORKSPACE_ROOT}}\external` (не на весь корень проекта). Если `-s` указывает на корень workspace, профиль `workspace` начнёт индексировать конфигурацию 1С из `src/`/`ext/` целиком (десятки тысяч файлов) и загрузит CPU/RAM на минуты/часы. Полная выгрузка анализируется через `rlm-tools-bsl`, а не через bsl-language-server
4. Проверьте логи сервера в консоли opencode

### Навыки не выполняются

**Проблема:** AI не использует навыки

**Решение:**
1. Проверьте, что файлы `SKILL.md` на месте
2. Проверьте права выполнения для скриптов (`.ps1`, `.bat`)
3. Попросите AI явно: "/используй навык form-compile"

## Следующие шаги

- [Настройка MCP-серверов](mcp-setup.md)
- [Работа с агентами](agents.md)
- [Использование навыков](skills.md)
- [Первый проект](first-project.md)
