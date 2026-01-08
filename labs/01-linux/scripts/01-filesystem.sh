#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${HOME}/labs/01-linux"
WORK_DIR="${LAB_DIR}/work"
MNT_DIR="${LAB_DIR}/mnt/tmpfs"

mkdir -p "$WORK_DIR"

echo "== Filesystem navigation =="
pwd
ls -lah | head -n 15
echo

echo "== Symlink demo =="
ln -sf /etc/hosts "${WORK_DIR}/hosts.link"
ls -l "${WORK_DIR}/hosts.link"
readlink -f "${WORK_DIR}/hosts.link"
echo

echo "== Disk & mounts (read-only) =="
df -h | head -n 10
echo
lsblk | head -n 30
echo
findmnt | head -n 30
echo

echo "== Optional: tmpfs mount demo (needs sudo) =="
if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
  sudo mkdir -p "$MNT_DIR"
  sudo mount -t tmpfs -o size=16m tmpfs "$MNT_DIR"
  echo "Mounted tmpfs at $MNT_DIR"
  df -h "$MNT_DIR"
  sudo umount "$MNT_DIR"
  echo "Unmounted tmpfs"
else
  echo "SKIP: sudo non-interactive not available. Run manually if you want:"
  echo "  sudo mkdir -p $MNT_DIR && sudo mount -t tmpfs -o size=16m tmpfs $MNT_DIR && df -h $MNT_DIR && sudo umount $MNT_DIR"
fi

