# Quick Start

Развёртывание шаблона 1C AI Workspace (opencode) под ваш проект.

## За 5 минут

### 1. Скопируйте шаблон в рабочий каталог проекта

```powershell
Copy-Item "D:\WorkFlow\1c-ai-workspace-template" -Destination "D:\WorkFlow\<project>" -Recurse
cd "D:\WorkFlow\<project>"
git init   # если ещё не git-репозиторий
```

### 2. Заполните `.v8-project.json`

Платформа, сервер, база и учётные данные (см. `.v8-project.json.template` в
`.claude/skills/1c-project-init/templates/`):

```json
{
  "v8path": "C:\\Program Files\\1cv8\\<VERSION>\\bin",
  "infobase": {
    "server": "<DB_SERVER>",
    "ref": "<BASE_NAME>",
    "user": "<ADMIN_USER>",
    "password": "<ADMIN_PWD>"
  },
  "publication": ""
}
```

### 3. Настройте `opencode.jsonc`

Замените плейсхолдеры на реальные пути:

- `{{WORKSPACE_ROOT}}` → абсолютный путь к корню проекта (напр. `D:\WorkFlow\<project>`)
- `{{AI_ENV}}` → каталог с бинарниками MCP-серверов (напр. `D:\1c-ai-env\.local\bin`)
- `{{NODE}}` → путь к `node.exe` из вашего окружения

### 4. Выгрузите исходники конфигурации

```bash
# через платформу: выгрузка в src/ (главная конфигурация) и ext/ (расширения)
# либо через skills:
/1c-project-init   # развернуть MCP и подготовить реестр
/db-dump-xml       # выгрузка src/ (главная конфигурация) и ext/ (расширения)
/rlm-projects      # зарегистрировать проект в RLM и построить индекс
```

После выгрузки исходники доступны для RLM-индексации и анализа.

### 5. Готово!

Запустите opencode в корне проекта:

```
Проверь код модуля <ОбщийМодуль.ВашМодуль>
```

AI автоматически использует skills и MCP-серверы для анализа.

## Настройка MCP (опционально)

Базовая конфигурация MCP уже есть в `opencode.jsonc` (playwright, rlm-tools-bsl, v8std,
bsl-language-server, context-mode). Настройка проектных MCP: [project-mcp-setup.md](docs/guides/project-mcp-setup.md).

## Что попробовать?

### Код-ревью

```
Проверь модуль src/Catalogs/ВашСправочник/Ext/ObjectModule.bsl
```

### Создание формы

```
Создай обработку "ЗагрузкаДанных" с формой для выбора файла
```

### Оптимизация запроса

```
Оптимизируй этот запрос:
[вставьте код запроса]
```

### Генерация тестов

```
Создай тесты для функции РассчитатьСумму в модуле ОбщегоНазначения
```

## Следующие шаги

- [Полное руководство по установке](docs/guides/installation.md)
- [Использование навыков](docs/guides/skills.md)
- [Настройка проектных MCP](docs/guides/project-mcp-setup.md)
- [FAQ](docs/FAQ.md)

## Проблемы?

- MCP не отвечает? Проверьте пути в `opencode.jsonc` и что `bsl-language-server` запускается (корень `-s` должен быть `{{WORKSPACE_ROOT}}\external`, а не весь workspace — иначе bsl-analyzer начнёт индексировать `src/`/`ext/`)
- RLM не индексирует? Проверьте, что выгрузка развёрнута в `src/` и проект зарегистрирован в реестре
- Другие проблемы? См. [Troubleshooting](docs/troubleshooting/README.md) (если присутствует)

## Помощь

- 🐛 Issues: репозиторий, куда вы опубликуете этот шаблон