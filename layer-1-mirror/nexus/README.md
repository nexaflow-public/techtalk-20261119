> Назначение: как выглядит гейт для JVM-экосистемы на Nexus Repository Manager 3.
> Статус: НЕ ПРОВЕРЕНО (конкретный механизм deny-all и имена репозиториев в вашей инсталляции).
> Версии инструментов: Nexus Repository Manager 3; версию зафиксировать до внедрения (см. {{NEXUS_IMAGE_TAG}} в ../docker-compose.yml).
> Пункты CHECKLIST.md: 7, 13, 25.

# Nexus: repository group не равен гейту

Nexus разделяет proxy-репозитории (зеркало upstream), hosted-репозитории (свои артефакты) и group (агрегат нескольких репозиториев). Частая ошибка — отдать разработчикам group, в который входит proxy-репозиторий: это тот же catch-all с proxy, только в другом интерфейсе. Любой координатный запрос уходит в Maven Central и резолвится.

Гейт получается, когда наружу отдан group (или hosted), в состав которого proxy-репозиторий **не входит**, а разрешённые артефакты попали туда явной загрузкой. Дополнительно запрет можно закрепить routing rule или content selector, но я не уверен в точной семантике этих механизмов в разных версиях Nexus 3, поэтому готовый конфиг не привожу.

## (а) Что именно проверить

1. Какие репозитории входят в выданный разработчикам group; есть ли среди них proxy на Maven Central.
2. Отдаёт ли group 404 на координату, которой нет в hosted-репозитории.
3. Покрываются ли `pluginRepositories` тем же путём (пункт 13) — плагины часто идут мимо основного репозитория.
4. Есть ли routing rule / content selector, запрещающий доступ к произвольным удалённым URL, и как он применяется к anonymous.
5. Отдаётся ли отозванный upstream-артефакт из кеша (пункт 25).

## (б) Команды проверки

```
curl -u <admin> -s 'http://localhost:8081/service/rest/v1/repositories' | jq '.[] | {name,type,url}'
curl -u <admin> -s 'http://localhost:8081/service/rest/v1/routing/rules' | jq .
curl -I 'http://localhost:8081/repository/<group>/org/apache/commons/commons-lang3/3.12.0/commons-lang3-3.12.0.pom'
curl -I 'http://localhost:8081/repository/<group>/com/example/несуществующий/1.0/несуществующий-1.0.pom'
```

## (в) Ожидаемый результат

- В выданном group нет proxy-репозитория, который ведёт на публичный Central.
- Разрешённая координата отдаёт 200, неизвестная — 404, без обращения к внешней сети.
- Запрос плагина идёт через тот же group и тоже получает отказ для неизвестного.
- Routing rule / content selector, если используется, блокирует обходные URL и не применяется к нужным читателям.

## (г) Документация

- https://help.sonatype.com/en/sonatype-nexus-repository.html — разделы про Repository Groups и Routing Rules;
- https://help.sonatype.com/en/sonatype-nexus-repository.html — раздел про Content Selectors и Privileges.

Настройки Maven и Gradle, которые обязаны указывать на этот group: ../../layer-2-enforcement/jvm/settings.xml и ../../layer-2-enforcement/jvm/README.md.

## Отдельно про repository group

`mirrorOf` в Maven — это подмена адреса на стороне клиента: все запросы уходят на один URL. Repository group в Nexus — это агрегат на стороне сервера. Это разные вещи: group может включать proxy-репозиторий и тем самым вернуть гейту «разрешено всё», даже если клиент настроен правильно. Проверяйте состав group, а не только `settings.xml`.
