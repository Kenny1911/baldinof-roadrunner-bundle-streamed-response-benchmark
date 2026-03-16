#!/usr/bin/env bash

RR_URL="${RR_URL:-http://localhost:8000}"
RR_FORK_URL="${RR_FORK_URL:-http://localhost:8001}"
FPM_URL="${FPM_URL:-http://localhost:8002}"

benchmark_request() {
    NAME="$1"
    URL_PATH="$2"

    echo "# ${NAME}"
    echo
    echo '| Runtime  | Status   | Time         | Speed, M/s | Size, M    |'
    echo '|----------|----------|--------------|------------|------------|'
    benchmark_request_row rr "${RR_URL}${URL_PATH}"
    benchmark_request_row rr-fork "${RR_FORK_URL}${URL_PATH}"
    benchmark_request_row fpm "${FPM_URL}${URL_PATH}"
    echo
}

benchmark_request_row() {
    NAME="$1"
    URL="$2"

    # Получаем данные от curl
    read HTTP TIME SPEED SIZE <<< $(curl -s -o /dev/null \
        -w "%{http_code} %{time_total} %{speed_download} %{size_download}" \
        --max-time 30 "$URL" 2>/dev/null)

    # Конвертируем в читаемый вид
    TIME=$(LC_NUMERIC=C printf "%.3f" $TIME)
    SPEED_MB=$(echo "scale=1; $SPEED/1024/1024" | bc 2>/dev/null || echo "0")
    SIZE_MB=$(echo "scale=1; $SIZE/1024/1024" | bc 2>/dev/null || echo "0")

    # Определяем статус эмодзи
    if [ "$HTTP" = "200" ] && [ "$SIZE" -gt "0" ]; then
        STATUS="✅ $HTTP"
    else
        STATUS="❌ $HTTP"
    fi

    # Выводим строку таблицы
    printf "| %-8s | %-10s | %-12s | %-10s | %-10s |\n" \
        "$NAME" "$STATUS" "$TIME" "$SPEED_MB" "$SIZE_MB"
}


benchmark_request 'Streamed'
benchmark_request 'Streamed echo'   '/echo'
benchmark_request 'Streamed json'   '/json'
benchmark_request 'File'            '/file'
benchmark_request 'Common'          '/common'
