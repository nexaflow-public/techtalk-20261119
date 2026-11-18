#!/usr/bin/env bash
# Назначение: smoke-тест, доказывающий, что поднят именно гейт, а не кеш.
# Статус: НЕ ПРОВЕРЕНО (скрипт не запускался в среде автора: нет Docker).
#         Логика четырёх кейсов описана; запуск в вашей среде обязателен.
# Версии инструментов: Docker Compose v2, npm 9+/10, curl.
# Пункты CHECKLIST.md: 7, 15, 16, 18.
#
# Запуск: chmod +x tests/gate-smoke.sh && bash tests/gate-smoke.sh
# Ответ на вопрос «а у вас точно гейт?» — это вывод PASS по всем четырём кейсам.

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_DIR="$ROOT/layer-1-mirror"
REGISTRY="${NPM_REGISTRY_URL:-http://localhost:4873}"

FAILED=0
BROUGHT_UP=0

pass() { printf 'PASS  %s\n' "$1"; }
fail() { printf 'FAIL  %s\n' "$1"; FAILED=1; }

cleanup() {
  if [ "$BROUGHT_UP" -eq 1 ]; then
    (cd "$COMPOSE_DIR" && docker compose down) >/dev/null 2>&1 || true
  fi
  [ -n "${TMPROOT:-}" ] && rm -rf "$TMPROOT" || true
}
trap cleanup EXIT

command -v docker >/dev/null 2>&1 || { printf 'FAIL  docker не найден\n'; exit 1; }
command -v npm >/dev/null 2>&1 || { printf 'FAIL  npm не найден\n'; exit 1; }
command -v curl >/dev/null 2>&1 || { printf 'FAIL  curl не найден\n'; exit 1; }

printf 'Поднимаем окружение: %s\n' "$COMPOSE_DIR"
if (cd "$COMPOSE_DIR" && docker compose up -d --wait) >/dev/null 2>&1; then
  BROUGHT_UP=1
  pass 'окружение поднято'
else
  fail 'окружение не поднялось'
fi

TMPROOT="$(mktemp -d)"
mkdir -p "$TMPROOT/allowed" "$TMPROOT/denied" "$TMPROOT/fake"

if npm install --prefix "$TMPROOT/allowed" --registry="$REGISTRY" \
    --no-audit --no-fund --loglevel=error ms >"$TMPROOT/allowed.log" 2>&1; then
  pass 'разрешённый пакет ms установлен'
else
  fail 'разрешённый пакет ms не установлен'
  sed -n '1,20p' "$TMPROOT/allowed.log"
fi

if npm install --prefix "$TMPROOT/denied" --registry="$REGISTRY" \
    --no-audit --no-fund --loglevel=error lodash >"$TMPROOT/denied.log" 2>&1; then
  fail 'пакет вне каталога (lodash) установился — это кеш, не гейт'
else
  pass 'пакет вне каталога (lodash) отклонён на резолвинге'
fi

if npm install --prefix "$TMPROOT/fake" --registry="$REGISTRY" \
    --no-audit --no-fund --loglevel=error nexaflow-hallucinated-package-9f3a2b \
    >"$TMPROOT/fake.log" 2>&1; then
  fail 'выдуманное имя зарезолвилось — это кеш, не гейт'
else
  pass 'выдуманное имя отклонено'
fi

if curl --max-time 5 -sS -o /dev/null https://registry.npmjs.org/ms >/dev/null 2>&1; then
  fail 'публичный реестр доступен напрямую'
else
  pass 'публичный реестр недоступен напрямую'
fi

exit "$FAILED"
