#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${HOME}/labs/01-linux"
CRON_LOG="${LAB_DIR}/cron.log"
TAG="# DEVOPS_JOURNAL_LAB01"
ROT_DIR="${LAB_DIR}/logs"
STATE_FILE="${LAB_DIR}/logrotate.state"
CONF_FILE="${LAB_DIR}/logrotate-lab.conf"
APP_LOG="${ROT_DIR}/app.log"

install_cron() {
  mkdir -p "$LAB_DIR"
  (crontab -l 2>/dev/null | grep -vF "$TAG" || true; \
   echo "* * * * * /bin/date '+%F %T cron-ok' >> $CRON_LOG $TAG") | crontab -
  echo "Cron installed. Check: tail -n 5 $CRON_LOG (after next minute)."
}

remove_cron() {
  (crontab -l 2>/dev/null | grep -vF "$TAG" || true) | crontab -
  echo "Cron removed."
}

status_cron() {
  crontab -l 2>/dev/null | grep -F "$TAG" && echo "Cron: PRESENT" || echo "Cron: NOT SET"
  [ -f "$CRON_LOG" ] && tail -n 5 "$CRON_LOG" || true
}

run_logrotate() {
  mkdir -p "$ROT_DIR"
  # bikin log agak besar
  : > "$APP_LOG"
  for i in $(seq 1 4000); do echo "line $i $(date +%s)" >> "$APP_LOG"; done

  cat > "$CONF_FILE" <<EOF
$APP_LOG {
  size 50k
  rotate 3
  missingok
  notifempty
  compress
  delaycompress
  copytruncate
}
EOF

  echo "== Before =="
  ls -lah "$ROT_DIR" | sed -n '1,20p'
  echo

  logrotate -s "$STATE_FILE" -f "$CONF_FILE"

  echo "== After =="
  ls -lah "$ROT_DIR" | sed -n '1,30p'
}

case "${1:-}" in
  install-cron) install_cron ;;
  remove-cron) remove_cron ;;
  status-cron) status_cron ;;
  run-logrotate) run_logrotate ;;
  *)
    echo "Usage:"
    echo "  $0 install-cron"
    echo "  $0 status-cron"
    echo "  $0 remove-cron"
    echo "  $0 run-logrotate"
    exit 1
    ;;
esac

