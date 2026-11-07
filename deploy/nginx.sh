#!/usr/bin/env bash
set -euo pipefail

HOST="${HOST:-oba.ssalhub.xyz}"
PORT="${PORT:-18107}"
CONF="${CONF:-/etc/nginx/conf.d/upstreams.conf}"

if grep -qE "^\s*${HOST//./\\.}\s" "$CONF"; then
  echo "이미 등록됨: $(grep -E "^\s*${HOST//./\\.}\s" "$CONF" | xargs)"
  exit 0
fi

if ss -ltn | grep -q ":${PORT} " ; then :; else
  echo "경고: 127.0.0.1:${PORT} 에서 듣는 프로세스가 없음 (컨테이너 먼저 띄우기)" >&2
fi

BACKUP="${CONF}.bak.$(date +%Y%m%d%H%M%S)"
sudo cp "$CONF" "$BACKUP"

sudo awk -v line="    ${HOST} ${PORT};" '
  !done && /^map \$host \$upstream_port \{/ { inmap=1 }
  inmap && /^[[:space:]]*default[[:space:]]/ { print line; inmap=0; done=1 }
  { print }
' "$BACKUP" | sudo tee "$CONF" >/dev/null

if sudo nginx -t; then
  sudo systemctl reload nginx
  echo "등록 완료: https://${HOST} -> ${PORT} (백업: ${BACKUP})"
else
  sudo cp "$BACKUP" "$CONF"
  echo "nginx -t 실패, 원복함" >&2
  exit 1
fi
