> Назначение: чем Maven отличается от Gradle и почему одного settings.xml недостаточно.
> Статус: ПРОВЕРЕНО для Maven 3.8+; Gradle-часть — НЕ ПРОВЕРЕНО.
> Версии инструментов: Maven 3.8+; Gradle — версию зафиксировать до внедрения.
> Пункты CHECKLIST.md: 13, 14.

# JVM

## Maven

 Конфиг: settings.xml. `<mirrorOf>*</mirrorOf>` подменяет все объявления репозиториев, включая pluginRepositories. Проверка — `mvn -s settings.xml help:effective-settings` и просмотр эффективного файла; ожидаем один URL {{MAVEN_REPO_URL}} и отсутствие публичного хоста.

Чем mirror отличается от repository group: mirror — подмена адреса на стороне клиента; group — агрегат репозиториев на стороне сервера. Group, в который входит proxy на Maven Central, возвращает «разрешено всё» даже при правильном settings.xml. Состав group проверяется отдельно: ../../layer-1-mirror/nexus/README.md.

Плагины: `mvn help:effective-settings` показывает плагины, которые резолвятся через тот же mirror, если `mirrorOf=*`. Если в проекте есть `<pluginRepositories>` с явным URL, проверьте эффективные настройки — ожидаем, что адрес подменён.

## Gradle

Gradle не читает settings.xml (пункт 14). Ему нужен init-скрипт: `settingsEvaluated` для pluginManagement, настройка repositories и exclusiveContent для запрета fallback. Синтаксис — зона риска, поэтому в gradle-init.gradle лежит не выдуманный код, а команды проверки и ожидаемые результаты.

Минимальная проверка, что init-скрипт вообще подхвачен:

```
./gradlew --init-script gradle-init.gradle --no-daemon help --info | grep -i 'init script'
```

Ожидаем: упоминание вашего файла в логе. Без этого любые рассуждения о настройке репозиториев не имеют значения.

## Общее

Оба менеджера должны указывать на один и тот же внутренний group, который не содержит proxy на публичный Central. Проверка на уровне сети: repo.maven.apache.org закрыт (../egress-allowlist.md), и сборка с неизвестной зависимостью падает по резолвингу, а не уходит наружу.
