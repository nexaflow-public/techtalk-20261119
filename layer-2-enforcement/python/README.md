> Назначение: dependency confusion в Python и три разных механизма выбора индекса.
> Статус: ПРОВЕРЕНО (pip 23+, uv 0.4+); часть про Poetry — НЕ ПРОВЕРЕНО.
> Версии инструментов: pip 23+; uv 0.4+; Poetry — версию зафиксировать до внедрения.
> Пункты CHECKLIST.md: 10, 11, 12, 15.

# Python

## pip: index-url против extra-index-url

Конфиг: pip.conf. При наличии двух индексов pip ищет пакет в обоих и выбирает лучшую версию среди найденных. Если публичный индекс доступен, пакет с совпадающим именем и большой версией может быть взят оттуда — это dependency confusion. Утверждение проверяемое:

```
pip install -vv --index-url {{PYPI_INDEX_URL}} \
  --extra-index-url https://pypi.org/simple <имя-пакета> 2>&1 | grep -E 'Looking in|Downloading'
```

Ожидаем: в логе видны оба индекса и источник скачивания выбран по версии, а не по приоритету индекса. Отсюда правило пункта 10: только `index-url`, никакого `extra-index-url`.

## files.pythonhosted.org

Это отдельный хост, с которого pip загружает архивы. Закрытие одного `pypi.org` не останавливает скачивание (пункт 15). Проверить:

```
pip download -vv --no-deps -d /tmp/pipcheck <пакет> 2>&1 | grep -E 'Downloading|Saved'
```

Ожидаем: URL архива виден в логе; если он ведёт на files.pythonhosted.org, хост нужно закрывать в egress rules отдельно. Список — ../egress-allowlist.md.

## Poetry

Источники задаются в pyproject.toml, а не в poetry.toml; приоритеты и неявный fallback на PyPI менялись между версиями. Готовый конфиг источников здесь не приведён — смотрите poetry.toml, где даны команды проверки и ожидаемые результаты. Пока вы не выполнили эти проверки на своей версии, считайте, что fallback существует.

## uv: first-index против unsafe-best-match

Конфиг: uv.toml. `index-strategy=first-index` означает, что пакет берётся из первого индекса, где он найден. Альтернатива `unsafe-best-match` сравнивает версии между индексами и тем самым воспроизводит логику dependency confusion через лучшую версию. Проверить:

```
uv pip install --index-strategy unsafe-best-match -v <пакет> 2>&1 | grep -i 'index'
uv pip install --index-strategy first-index -v <пакет> 2>&1 | grep -i 'index'
```

Ожидаем: в первом случае видны обращения к нескольким индексам, во втором — только к внутреннему {{PYPI_INDEX_URL}}.

## Граница

Даже правильно настроенный индекс не контролирует код, который выполняется во время установки, и код, который агент пишет сам: ../../BOUNDARIES.md.
