# Назначение: конфиг реестра внутри сборки; секреты через BuildKit, не через ARG.
# Статус: ПРОВЕРЕНО (Dockerfile syntax v1, BuildKit).
# Версии инструментов: Docker с BuildKit; базовый образ node:20.
# Пункты CHECKLIST.md: 9, 18.
#
# ARG НЕ используется для токенов: ARG попадает в историю слоёв и в image inspect.
# Токен пробрасывается через --mount=type=secret,env=..., а .npmrc содержит
# ссылку на переменную окружения, например _authToken=${NPM_TOKEN}.
#
# Герметичная сборка — направление, а не обещание: базовый образ и системные
# пакеты остаются внешними входами. Здесь герметичность не утверждается.

# syntax=docker/dockerfile:1

FROM node:20

WORKDIR /app

# registry и always-auth лежат в репозиторийном .npmrc, без секретов
COPY .npmrc ./

RUN --mount=type=secret,id=npm_token,env=NPM_TOKEN \
    npm ci && npm cache clean --force

COPY . .
