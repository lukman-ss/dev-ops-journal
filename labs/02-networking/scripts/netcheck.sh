#!/usr/bin/env bash
set -euo pipefail

echo "== Host =="
hostname
echo

echo "== IP / Interfaces =="
ip -br a
echo

echo "== Routes =="
ip route
echo

echo "== TCP/UDP sockets (listening) =="
ss -tulpen | head -n 80
echo

echo "== DNS resolver (systemd-resolved) =="
resolvectl status 2>/dev/null | sed -n '1,120p' || cat /etc/resolv.conf
echo

echo "== DNS query (dig / nslookup) =="
if command -v dig >/dev/null 2>&1; then
  dig +short A google.com
  dig +short AAAA google.com
  dig +short TXT google.com
elif command -v nslookup >/dev/null 2>&1; then
  nslookup google.com | sed -n '1,40p'
else
  echo "SKIP: dig/nslookup not installed"
fi
echo

echo "== HTTP check (curl) =="
curl -I https://example.com | sed -n '1,20p'
echo

echo "== TLS cert summary (openssl) =="
echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates
echo

echo "== Trace route (traceroute/mtr) =="
if command -v traceroute >/dev/null 2>&1; then
  traceroute -n -m 8 1.1.1.1 | sed -n '1,20p'
elif command -v mtr >/dev/null 2>&1; then
  mtr -r -c 5 1.1.1.1 | sed -n '1,40p'
else
  echo "SKIP: traceroute/mtr not installed"
fi
echo

echo "== Firewall quick check (ufw/nft/iptables) =="
if command -v ufw >/dev/null 2>&1; then
  sudo ufw status verbose || true
else
  echo "ufw: not installed"
fi

if command -v nft >/dev/null 2>&1; then
  sudo nft list ruleset | sed -n '1,120p' || true
else
  echo "nft: not installed"
fi

if command -v iptables >/dev/null 2>&1; then
  sudo iptables -S | sed -n '1,80p' || true
else
  echo "iptables: not installed"
fi
