#!/usr/bin/env bash
set -euo pipefail

schedule="${CODEX_CRON_SCHEDULE:-}"

if [[ -z "$schedule" ]]; then
  echo "CODEX_CRON_SCHEDULE must be set" >&2
  exit 1
fi

fields=$(awk 'END { print NF }' <<<"$schedule")
if [[ "$fields" -ne 5 ]]; then
  echo "CODEX_CRON_SCHEDULE must be a standard 5-field cron expression, got: $schedule" >&2
  exit 1
fi

mkdir -p /home/codex /app/runtime
chown -R codex:codex /home/codex /app/runtime

if [[ -f "/usr/share/zoneinfo/${TZ:-UTC}" ]]; then
  ln -snf "/usr/share/zoneinfo/${TZ:-UTC}" /etc/localtime
  echo "${TZ:-UTC}" > /etc/timezone
else
  echo "Invalid TZ value: ${TZ:-UTC}" >&2
  exit 1
fi

cat > /etc/cron.d/codex-cron <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOME=/home/codex
CODEX_WORKDIR=/app/runtime

${schedule} codex /app/codex-wakeup.sh >/proc/1/fd/1 2>/proc/1/fd/2
EOF

chmod 0644 /etc/cron.d/codex-cron

echo "Configured cron schedule: ${schedule}"

exec "$@"
