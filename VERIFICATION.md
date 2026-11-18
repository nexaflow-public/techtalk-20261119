> Назначение: дисциплина проверки — что проверено, что нет и чего в репозитории сознательно нет.
> Статус: РАЗБОР БЕЗ РЕШЕНИЯ (сводка проверок)
> Версии инструментов: см. колонку матрицы
> Пункты CHECKLIST.md: 1–54 (покрытие по файлам)

# Верификация

Статусы в шапках файлов: ПРОВЕРЕНО — синтаксис и семантика известны и приведена команда проверки; НЕ ПРОВЕРЕНО — вместо выдуманного конфига даны (а) что проверить, (б) команда, (в) ожидаемый результат, (г) ссылка на документацию; РАЗБОР БЕЗ РЕШЕНИЯ — текстовый разбор без готового решения, обещаний не содержит.

## Матрица

| Файл | Статус | Версии инструментов | Команда проверки | Дата |
|---|---|---|---|---|
| README.md | РАЗБОР БЕЗ РЕШЕНИЯ | не привязано | прочитать; проверить ссылки на файлы | {{VERIFICATION_DATE}} |
| CHECKLIST.md | РАЗБОР БЕЗ РЕШЕНИЯ | не привязан | `grep -cE '^ ?[0-9]+\.' CHECKLIST.md` → 54 | {{VERIFICATION_DATE}} |
| ARCHITECTURE.md | РАЗБОР БЕЗ РЕШЕНИЯ | не привязано | прочитать; сверить номера слоёв с CHECKLIST.md | {{VERIFICATION_DATE}} |
| BOUNDARIES.md | РАЗБОР БЕЗ РЕШЕНИЯ | не привязано | прочитать; сверить с README.md на противоречия | {{VERIFICATION_DATE}} |
| VERIFICATION.md | РАЗБОР БЕЗ РЕШЕНИЯ | не привязано | `grep -R -o '{{[A-Z_]*}}' . \| sort -u` — сверить со списком ниже | {{VERIFICATION_DATE}} |
| layer-1-mirror/docker-compose.yml | ПРОВЕРЕНО (синтаксис); теги образов — плейсхолдеры | Docker Compose v2, Verdaccio 5.x | `cd layer-1-mirror && docker compose config` | {{VERIFICATION_DATE}} |
| layer-1-mirror/verdaccio/cache.yaml | ПРОВЕРЕНО (синтаксис) | Verdaccio 5.x | `npm view <выдуманное-имя> --registry=http://localhost:4873 --loglevel=http` | {{VERIFICATION_DATE}} |
| layer-1-mirror/verdaccio/gate.yaml | ПРОВЕРЕНО (синтаксис); порядок матчинга — проверить в среде | Verdaccio 5.x | `bash tests/gate-smoke.sh` | {{VERIFICATION_DATE}} |
| layer-1-mirror/devpi/README.md | НЕ ПРОВЕРЕНО | devpi-server, версию зафиксировать | `devpi index -l; devpi use http://localhost:3141/<user>/<index>` | {{VERIFICATION_DATE}} |
| layer-1-mirror/nexus/README.md | НЕ ПРОВЕРЕНО | Nexus Repository Manager 3 | `curl -u <admin> -s .../service/rest/v1/repositories` | {{VERIFICATION_DATE}} |
| layer-2-enforcement/npm/.npmrc | ПРОВЕРЕНО (registry, always-auth); replace-registry-host — по проверке | npm 9+/10 | `npm config get replace-registry-host; npm config get registry` | {{VERIFICATION_DATE}} |
| layer-2-enforcement/npm/README.md | ПРОВЕРЕНО | npm 9+/10 | `grep -n '"resolved"' package-lock.json` до и после пересборки | {{VERIFICATION_DATE}} |
| layer-2-enforcement/python/pip.conf | ПРОВЕРЕНО | pip 23+ | `pip install -vv --index-url {{PYPI_INDEX_URL}} <пакет>` | {{VERIFICATION_DATE}} |
| layer-2-enforcement/python/poetry.toml | НЕ ПРОВЕРЕНО (источники и приоритеты) | Poetry 1.2+ | `poetry --version; poetry source list; poetry lock -vv` | {{VERIFICATION_DATE}} |
| layer-2-enforcement/python/uv.toml | ПРОВЕРЕНО | uv 0.4+ | `uv --version; uv pip install --index-strategy first-index <пакет>` | {{VERIFICATION_DATE}} |
| layer-2-enforcement/python/README.md | ПРОВЕРЕНО (pip, uv); Poetry — НЕ ПРОВЕРЕНО | pip 23+, uv 0.4+ | `pip download -vv --no-deps -d /tmp/pipcheck <пакет>` | {{VERIFICATION_DATE}} |
| layer-2-enforcement/jvm/settings.xml | ПРОВЕРЕНО | Maven 3.8+ | `mvn -s settings.xml help:effective-settings -Doutput=/tmp/eff.xml` | {{VERIFICATION_DATE}} |
| layer-2-enforcement/jvm/gradle-init.gradle | НЕ ПРОВЕРЕНО | Gradle, версию зафиксировать | `gradle --version; ./gradlew --init-script <путь> --no-daemon dependencies` | {{VERIFICATION_DATE}} |
| layer-2-enforcement/jvm/README.md | ПРОВЕРЕНО (Maven); Gradle — НЕ ПРОВЕРЕНО | Maven 3.8+ | `mvn -s settings.xml help:effective-settings` | {{VERIFICATION_DATE}} |
| layer-2-enforcement/egress-allowlist.md | ПРОВЕРЕНО (перечень хостов) | не привязано | `curl -sS -o /dev/null -w '%{http_code}\n' https://registry.npmjs.org/` | {{VERIFICATION_DATE}} |
| layer-2-enforcement/ci/github-actions.yml | ПРОВЕРЕНО | actions/checkout@v4, actions/setup-node@v4 | `grep -n 'registry' .npmrc; npm config get registry` в job | {{VERIFICATION_DATE}} |
| layer-2-enforcement/ci/gitlab-ci.yml | ПРОВЕРЕНО | GitLab Runner, node:20 | `npm config get registry` в before_script | {{VERIFICATION_DATE}} |
| layer-2-enforcement/ci/Dockerfile | ПРОВЕРЕНО | Dockerfile syntax v1, BuildKit | `docker build --secret id=npm_token,env=NPM_TOKEN .` | {{VERIFICATION_DATE}} |
| layer-3-catalog/catalog.yaml | РАЗБОР БЕЗ РЕШЕНИЯ (внутренняя схема) | не привязано | `grep -n 'review_by' catalog.yaml` | {{VERIFICATION_DATE}} |
| layer-3-catalog/admission-criteria.md | РАЗБОР БЕЗ РЕШЕНИЯ | не привязано | прочитать; сверить пункты 19–21 | {{VERIFICATION_DATE}} |
| layer-3-catalog/break-glass-policy.md | РАЗБОР БЕЗ РЕШЕНИЯ | не привязано | прочитать; сверить пункты 22–24, 26, 45 | {{VERIFICATION_DATE}} |
| layers-4-7-notes/rebuild-from-source.md | РАЗБОР БЕЗ РЕШЕНИЯ | не привязано | прочитать; сверить пункты 27–33 | {{VERIFICATION_DATE}} |
| layers-4-7-notes/backport-versioning.md | РАЗБОР БЕЗ РЕШЕНИЯ | не привязано | прочитать; сверить пункты 34–41 | {{VERIFICATION_DATE}} |
| layers-4-7-notes/freshness-slo.md | РАЗБОР БЕЗ РЕШЕНИЯ | не привязано | прочитать; сверить пункты 42–48 | {{VERIFICATION_DATE}} |
| layers-4-7-notes/mcp-threat-model.md | РАЗБОР БЕЗ РЕШЕНИЯ | не привязано | прочитать; сверить пункты 49–54 | {{VERIFICATION_DATE}} |
| tests/gate-smoke.sh | НЕ ПРОВЕРЕНО (нет Docker в среде автора) | Docker Compose v2, npm 9+, curl | `bash tests/gate-smoke.sh` | {{VERIFICATION_DATE}} |
| .github/ISSUE_TEMPLATE/stack-survey.yml | ПРОВЕРЕНО | GitHub issue forms | открыть New Issue в репозитории | {{VERIFICATION_DATE}} |
| LICENSE | РАЗБОР БЕЗ РЕШЕНИЯ (юридические тексты) | не привязано | прочитать; сверить с README.md | {{VERIFICATION_DATE}} |

## Что мы НЕ проверили и почему

1. Порядок матчинга правил Verdaccio в конкретной инсталляции — в среде автора нет запущенного Verdaccio. Команда проверки приведена в gate.yaml, полный прогон — в tests/gate-smoke.sh.
2. Поведение devpi и Nexus при запросе неизвестного пакета — нет инстансов этих продуктов и уверенности в семантике конкретных версий. Вместо конфигов даны процедуры проверки в соответствующих README.
3. Синтаксис Gradle init-скрипта и поведение exclusiveContent — зависит от версии Gradle; выдуманный код создал бы видимость гейта.
4. Приоритеты источников Poetry и наличие неявного fallback на PyPI — семантика менялась между версиями. Конфиг источников не приведён, дана проверка.
5. Значение и умолчание `replace-registry-host` для разных версий npm — не утверждается наизусть; дана команда `npm config get`.
6. Запуск tests/gate-smoke.sh — в среде автора нет Docker. Скрипт содержит четыре кейса и ненулевой exit при провале; запуск в вашей среде обязателен.
7. Реальные правила egress на сетевом оборудовании — зависят от вашей инфраструктуры; приведён только перечень хостов и команда проверки доступности.
8. Герметичность сборки и воспроизводимость артефактов — это направление и отдельное измерение, а не утверждаемое свойство репозитория.

## Чего здесь нет

- Terraform/Ansible-манифестов для egress: зависят от вашего сетевого стека и были бы заглушкой.
- Реализации каталога как сервиса: в репозитории лежит схема данных и процессы, а не готовое приложение.
- Готового init-скрипта Gradle и конфига источников Poetry — см. пункты 3–4 выше.
- MCP-сервера: mcp-threat-model.md — модель угроз, не реализация.
- Генератора SBOM и пайплайна пересборки из исходников: это отдельные системы, обещать их наличие здесь было бы обещанием.
- Реестра патчей и CI на снятие патча как готового кода: описаны как процесс в backport-versioning.md, пункты 39–40.
- Дашборда метрик: главная метрика здоровья описана в freshness-slo.md, но сама по себе не делает процесс рабочим.
- Конфигов для ArgoCD и произвольных частных реестров: их нет, потому что они не были проверены.
- Скриншотов, логотипов клиентов, кейсов, отзывов и метрик продукта: запрещено условиями раздаточного материала.

## Placeholders

Все плейсхолдеры используют один формат {{PLACEHOLDER_NAME}} и перечислены здесь:

- {{TALK_TITLE}} — название доклада
- {{EVENT_DATE}} — дата мероприятия
- {{CONTACT}} — контакт для дизайн-партнёрства
- {{VERIFICATION_DATE}} — дата проверки матрицы
- {{NPM_REGISTRY_URL}} — внутренний реестр npm
- {{PYPI_INDEX_URL}} — внутренний индекс Python
- {{MAVEN_REPO_URL}} — внутренний репозиторий JVM
- {{GATE_HOST}} — внутреннее DNS-имя гейта
- {{VERDACCIO_IMAGE_TAG}} — конкретный тег образа Verdaccio
- {{DEVPY_IMAGE}} — образ devpi с зафиксированной версией
- {{NEXUS_IMAGE_TAG}} — тег образа Nexus Repository Manager 3
- {{CATALOG_OWNER}} — владелец каталога
- {{CATALOG_DEPUTY}} — замещающий владельца
- {{TICKET_PREFIX}} — префикс тикетов
- {{REVIEW_DATE}} — дата пересмотра записи каталога
