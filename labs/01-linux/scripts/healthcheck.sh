#!/usr/bin/env bash
set -euo pipefail

echo "== Host =="
hostname
echo

echo "== OS =="
. /etc/os-release
echo "$PRETTY_NAME"
echo

echo "== Uptime =="
uptime
echo

echo "== Load Avg (1/5/15) =="
awk '{print $1,$2,$3}' /proc/loadavg
echo

echo "== CPU =="
lscpu | awk -F: '
/Model name/ {print "Model:", $2}
/CPU\(s\)/ {print "vCPU:", $2; exit}
'
echo

echo "== Memory =="
free -h
echo

echo "== Disk / =="
df -h /
echo

echo "== Listening Ports =="
ss -lntup | head -n 30
echo

echo "== Top RSS Processes =="
ps aux --sort=-rss | head -n 11
