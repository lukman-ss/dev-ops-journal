#!/usr/bin/env bash
set -euo pipefail

echo "== ps snapshot =="
ps aux | head -n 10
echo

echo "== top snapshot (batch) =="
top -b -n 1 | head -n 15
echo

echo "== nice + background process + kill =="
nice -n 10 sleep 300 &
PID=$!
echo "Started sleep with PID=$PID"
ps -p "$PID" -o pid,ni,cmd
echo "Renice to 15"
renice -n 15 -p "$PID" >/dev/null
ps -p "$PID" -o pid,ni,cmd
echo "Kill process"
kill -TERM "$PID"
sleep 1
ps -p "$PID" >/dev/null 2>&1 && echo "WARN: still running" || echo "OK: terminated"
