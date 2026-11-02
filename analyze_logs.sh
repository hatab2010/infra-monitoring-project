#!/usr/bin/env bash

set -euo pipefail

log_file=access.log

# Создаём тестовые данные, если файла ещё нет. Существующий лог сохраняем.
if [[ ! -e "$log_file" ]]; then
    awk 'BEGIN {
        for (i = 1; i <= 300; i++) {
            if (i <= 150) ip = "192.168.1.10"
            else if (i <= 225) ip = "10.0.0.5"
            else if (i <= 270) ip = "172.16.0.3"
            else if (i <= 290) ip = "192.168.1.20"
            else ip = "10.0.0.8"

            method = (i % 5 == 0) ? "POST" : "GET"
            path = (method == "POST") ? "/api/login" : "/api/users"
            if (i % 10 == 0) status = 500
            else if (i % 10 == 1) status = 404
            else if (i % 10 == 2) status = 401
            else status = 200

            printf "%s - - [15/Aug/2026:10:%02d:%02d] \"%s %s HTTP/1.1\" %d\n", \
                ip, 15 + int((i - 1) / 60), (i - 1) % 60, method, path, status
        }
    }' > "$log_file"
fi

if [[ ! -f "$log_file" || ! -r "$log_file" ]]; then
    printf 'Не удалось прочитать файл %s\n' "$log_file" >&2
    exit 1
fi

printf 'Общее количество запросов: '
awk 'END { print NR + 0 }' "$log_file"

printf 'Топ-3 IP-адреса (количество запросов / адрес):\n'
octet='(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])'
ip_pattern="^${octet}(\\.${octet}){3}[[:space:]]"

# grep возвращает 1 при отсутствии совпадений; пустой лог не является ошибкой.
{
    grep -E "$ip_pattern" "$log_file" || [[ $? -eq 1 ]]
} | awk '{ print $1 }' | sort | uniq -c | sort -k1,1nr -k2,2 | \
    awk 'NR <= 3 { printf "%d %s\n", $1, $2 }'

awk '
    $NF ~ /^4[0-9][0-9]$/ { errors4xx++ }
    $NF ~ /^5[0-9][0-9]$/ { errors5xx++ }
    END {
        printf "Количество запросов с кодами 4xx: %d\n", errors4xx
        printf "Количество запросов с кодами 5xx: %d\n", errors5xx
    }
' "$log_file"
