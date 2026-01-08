#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${HOME}/labs/02-networking"
ART_DIR="${LAB_DIR}/artifacts"
SCRIPT_NAME="$(basename "$0")"

PROXY_HOST="127.0.0.1"
PROXY_PORT="18080"
BACKEND_HOST="127.0.0.1"
BACKEND_PORT="18081"

mkdir -p "$ART_DIR"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "❌ Missing command: $1"
    exit 1
  }
}

wait_port() {
  local host="$1" port="$2" tries=30
  for _ in $(seq 1 "$tries"); do
    if ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE "(${host}|\\[${host}\\]):${port}\$|:${port}\$"; then
      return 0
    fi
    sleep 0.1
  done
  return 1
}

cleanup() {
  set +e
  if [[ -n "${NGINX_PREFIX:-}" && -n "${NGINX_CONF:-}" ]]; then
    nginx -p "$NGINX_PREFIX" -c "$NGINX_CONF" -s stop >/dev/null 2>&1 || true
  fi
  if [[ -n "${BACKEND_PID:-}" ]]; then
    kill "$BACKEND_PID" >/dev/null 2>&1 || true
  fi
  if [[ -n "${TMPDIR_LAB:-}" && -d "${TMPDIR_LAB:-}" ]]; then
    rm -rf "$TMPDIR_LAB" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

echo "== ${SCRIPT_NAME} =="
echo "Artifacts => ${ART_DIR}"
echo

need_cmd ss
need_cmd curl
need_cmd python3
need_cmd nginx

TMPDIR_LAB="$(mktemp -d)"
BACKEND_PY="${TMPDIR_LAB}/backend.py"

cat > "$BACKEND_PY" <<'PY'
import json, sys
from http.server import BaseHTTPRequestHandler, HTTPServer

port = int(sys.argv[1])

class H(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        return

    def do_GET(self):
        data = {
            "path": self.path,
            "client_ip": self.client_address[0],
            "client_port": self.client_address[1],
            "headers": {k: v for k, v in self.headers.items()},
        }
        body = json.dumps(data, indent=2).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

HTTPServer(("127.0.0.1", port), H).serve_forever()
PY

echo "== Start backend (Python) on ${BACKEND_HOST}:${BACKEND_PORT} =="
python3 "$BACKEND_PY" "$BACKEND_PORT" > "${ART_DIR}/backend.log" 2>&1 &
BACKEND_PID="$!"

if ! wait_port "$BACKEND_HOST" "$BACKEND_PORT"; then
  echo "❌ Backend port not listening: ${BACKEND_HOST}:${BACKEND_PORT}"
  exit 1
fi
echo "✅ Backend up (pid=${BACKEND_PID})"
echo

NGINX_PREFIX="${TMPDIR_LAB}/nginx"
mkdir -p "${NGINX_PREFIX}/logs"
NGINX_CONF="${NGINX_PREFIX}/nginx.conf"

cat > "$NGINX_CONF" <<EOF
worker_processes  1;
pid               nginx.pid;

events { worker_connections  1024; }

http {
  access_log logs/access.log;
  error_log  logs/error.log info;

  server {
    listen ${PROXY_HOST}:${PROXY_PORT};

    location / {
      proxy_pass http://${BACKEND_HOST}:${BACKEND_PORT};

      # Forwarding headers (inti reverse proxy)
      proxy_set_header Host              \$host;
      proxy_set_header X-Real-IP         \$remote_addr;
      proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto \$scheme;
      proxy_set_header X-Forwarded-Host  \$host;
      proxy_set_header X-Forwarded-Port  \$server_port;
    }
  }
}
EOF

echo "== Start reverse proxy (nginx) on ${PROXY_HOST}:${PROXY_PORT} => ${BACKEND_HOST}:${BACKEND_PORT} =="
nginx -p "$NGINX_PREFIX" -c "$NGINX_CONF"

if ! wait_port "$PROXY_HOST" "$PROXY_PORT"; then
  echo "❌ Proxy port not listening: ${PROXY_HOST}:${PROXY_PORT}"
  echo "nginx error log: ${NGINX_PREFIX}/logs/error.log"
  exit 1
fi
echo "✅ Proxy up (nginx prefix=${NGINX_PREFIX})"
echo

echo "== Test: direct backend vs via proxy =="
DIRECT_OUT="${ART_DIR}/direct-backend.json"
PROXY_OUT="${ART_DIR}/via-proxy.json"

curl -s "http://${BACKEND_HOST}:${BACKEND_PORT}/?mode=direct" > "$DIRECT_OUT"
curl -s -H "X-Demo: via-proxy" "http://${PROXY_HOST}:${PROXY_PORT}/?mode=proxy" > "$PROXY_OUT"

echo "Saved:"
echo "- ${DIRECT_OUT}"
echo "- ${PROXY_OUT}"
echo

echo "== What to compare (forwarded headers) =="
echo "Open files and compare these keys inside .headers:"
echo "- X-Real-IP"
echo "- X-Forwarded-For"
echo "- X-Forwarded-Proto"
echo "- Host"
echo

TCPDUMP_OUT="${ART_DIR}/tcpdump-proxy-backend.out"
if command -v tcpdump >/dev/null 2>&1; then
  echo "== tcpdump capture (ports ${PROXY_PORT} and ${BACKEND_PORT}) =="
  echo "You may be prompted for sudo password."
  # capture for max 8 seconds, while we generate a bit of traffic
  sudo timeout 8s tcpdump -i any -nn -l "(tcp port ${PROXY_PORT} or tcp port ${BACKEND_PORT})" \
    | tee "$TCPDUMP_OUT" >/dev/null &

  TCPDUMP_PID=$!
  sleep 0.5

  # generate traffic while tcpdump runs
  for i in 1 2 3; do
    curl -s -H "X-Demo: via-proxy-$i" "http://${PROXY_HOST}:${PROXY_PORT}/?i=$i" >/dev/null
    curl -s "http://${BACKEND_HOST}:${BACKEND_PORT}/?i=$i" >/dev/null
  done

  wait "$TCPDUMP_PID" || true
  echo "✅ tcpdump saved: ${TCPDUMP_OUT}"
else
  echo "⚠️ tcpdump not installed. If you want this part:"
  echo "sudo apt update && sudo apt install -y tcpdump"
fi

echo
echo "== Done =="
echo "Artifacts in: ${ART_DIR}"
echo "- direct-backend.json"
echo "- via-proxy.json"
echo "- (optional) tcpdump-proxy-backend.out"
