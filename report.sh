#!/usr/bin/env bash

set -euo pipefail

GENERATED_AT="$(date '+%d.%m.%Y %H:%M:%S %Z')"
UPTIME_TEXT="$(uptime -p)"
DISK_PERCENT="$(df -P / | awk 'NR == 2 {print $5}' | tr -d '%')"
MEM_TOTAL="$(free -m | awk '/^Mem:/ {print $2}')"
MEM_AVAILABLE="$(free -m | awk '/^Mem:/ {print $7}')"

echo "aika: $GENERATED_AT"
echo "uptime: $UPTIME_TEXT"
echo "levy: $DISK_PERCENT %"
echo "ram: $MEM_AVAILABLE / $MEM_TOTAL MiB vapaana"
