#!/usr/bin/env bash

set -euo pipefail

WARNING_LIMIT=80

get_disk_status() {
    local usage="$1"
    if [ "$usage" -ge "$WARNING_LIMIT" ]; then
        echo "WARNING"
    else
        echo "OK"
    fi
}

GENERATED_AT="$(date '+%d.%m.%Y %H:%M:%S %Z')"
UPTIME_TEXT="$(uptime -p)"
DISK_PERCENT="$(df -P / | awk 'NR == 2 {print $5}' | tr -d '%')"
DISK_STATUS="$(get_disk_status "$DISK_PERCENT")"
MEM_TOTAL="$(free -m | awk '/^Mem:/ {print $2}')"
MEM_AVAILABLE="$(free -m | awk '/^Mem:/ {print $7}')"

echo "aika: $GENERATED_AT"
echo "uptime: $UPTIME_TEXT"
echo "levy: $DISK_PERCENT % ($DISK_STATUS)"
echo "ram: $MEM_AVAILABLE / $MEM_TOTAL MiB vapaana"
