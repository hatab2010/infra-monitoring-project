#!/usr/bin/env bash

set -u

if [[ $# -ne 1 ]]; then
    printf 'Использование: %s <URL API>\n' "$0" >&2
    exit 1
fi

case "$1" in
    http://*|https://*) ;;
    *)
        printf 'API недоступен, код ответа: 000\n'
        printf 'URL должен начинаться с http:// или https://\n' >&2
        exit 1
        ;;
esac

# При ошибке соединения curl возвращает ненулевой код и HTTP-код 000.
if ! http_code=$(curl --silent --show-error --output /dev/null \
    --write-out '%{http_code}' --connect-timeout 5 --max-time 15 -- "$1"); then
    printf 'API недоступен, код ответа: %s\n' "${http_code:-000}"
    exit 1
fi

if [[ "$http_code" == 200 ]]; then
    printf 'API доступен\n'
    exit 0
fi

printf 'API недоступен, код ответа: %s\n' "$http_code"
exit 1
