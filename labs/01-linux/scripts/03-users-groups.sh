#!/usr/bin/env bash
set -euo pipefail

echo "== Who am I =="
whoami
id
groups
echo

echo "== passwd/group entries (read-only) =="
getent passwd "$(whoami)" || true
getent group | head -n 20
