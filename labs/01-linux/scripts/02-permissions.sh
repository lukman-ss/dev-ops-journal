#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${HOME}/labs/01-linux"
WORK_DIR="${LAB_DIR}/perm-lab"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "== Current umask =="
umask
echo

echo "== Create file & chmod demo =="
rm -f a.txt b.txt
touch a.txt
ls -la a.txt
chmod 600 a.txt
ls -la a.txt
echo

echo "== Directory permission demo =="
rm -rf d1
mkdir d1
ls -ld d1
chmod 700 d1
ls -ld d1
echo

echo "== umask demo (temporary) =="
OLD_UMASK="$(umask)"
umask 077
touch b.txt
ls -la b.txt
umask "$OLD_UMASK"
echo "Restored umask: $(umask)"
