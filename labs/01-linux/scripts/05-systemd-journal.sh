#!/usr/bin/env bash
set -euo pipefail

SVC="fail2ban"

echo "== systemd: status =="
systemctl status "$SVC" --no-pager -l | head -n 30
echo

echo "== systemd: restart (safe) =="
sudo systemctl restart "$SVC"
systemctl is-active "$SVC"
echo

echo "== systemd: enable check =="
systemctl is-enabled "$SVC" || true
echo

echo "== journalctl: last 50 lines =="
journalctl -u "$SVC" --no-pager -n 50
echo

echo "== journalctl: follow 5s (timeout) =="
timeout 5s journalctl -u "$SVC" -f || true
