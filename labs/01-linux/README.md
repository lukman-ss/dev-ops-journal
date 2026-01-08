# 01 - Linux Fundamentals

## Goal
Menguasai dasar Linux yang wajib dipakai DevOps: filesystem/permission, process & service, dan shell automation.

## Environment
- Host: `svr-tthi1` (internal)
- OS: Ubuntu 24.04.2 LTS
- Akses: SSH key auth (lihat `labs/00-baseline/README.md`)

## Yang Sudah Dipelajari

### 1.1 Filesystem & Permission
**Script:** `01-filesystem.sh`, `02-permissions.sh`, `03-users-groups.sh`

- Navigasi filesystem dasar (`pwd`, `ls -lah`)
- Symlink: membuat dan membaca symbolic link dengan `ln -s` dan `readlink`
- Disk & mount: melihat disk usage (`df -h`), block devices (`lsblk`), dan mount points (`findmnt`)
- tmpfs mount demo (optional dengan sudo)
- File permission: `chmod` untuk mengubah permission (contoh: `chmod 600`, `chmod 700`)
- Directory permission dan perbedaannya dengan file
- `umask`: melihat dan mengatur default permission untuk file/directory baru
- User & groups: `whoami`, `id`, `groups`, `getent passwd`, `getent group`

### 1.2 Process & Service
**Script:** `04-process.sh`, `05-systemd-journal.sh`

- Process monitoring: `ps aux`, `top -b` untuk snapshot proses
- Process priority: `nice` untuk menjalankan proses dengan priority tertentu
- Process management: `renice` untuk mengubah priority, `kill` untuk terminate proses
- systemd service management:
  - `systemctl status` - cek status service
  - `systemctl restart` - restart service
  - `systemctl is-active` - cek apakah service aktif
  - `systemctl is-enabled` - cek apakah service auto-start
- journalctl untuk membaca logs:
  - `journalctl -u <service>` - filter by service
  - `journalctl -n 50` - last 50 lines
  - `journalctl -f` - follow mode (real-time)

### 1.3 Shell & Automation
**Script:** `06-cron-logrotate.sh`, `healthcheck.sh`

- Bash scripting best practices:
  - Shebang: `#!/usr/bin/env bash`
  - Error handling: `set -euo pipefail`
  - Variables dan string interpolation
  - Functions untuk modular code
  - Case statement untuk command routing
- Cron job management:
  - `crontab -l` - list cron jobs
  - `crontab -e` - edit (via script: pipe to crontab)
  - Cron syntax dan scheduling
  - Logging output dari cron job
- Log rotation dengan `logrotate`:
  - Config file format
  - Options: size, rotate, compress, copytruncate
  - State file untuk tracking
  - Force rotation dengan `-f`
- Text processing tools:
  - `awk` untuk parsing dan formatting output
  - `grep` untuk filtering
  - `sed` untuk text manipulation
- Healthcheck script yang comprehensive:
  - System info: hostname, OS version, uptime
  - Resource monitoring: CPU, memory, disk, load average
  - Network: listening ports dengan `ss`
  - Process: top memory consumers

## Output (Bukti)
- Scripts: `labs/01-linux/scripts/*.sh` (7 scripts)
- Healthcheck output: `labs/01-linux/healthcheck.out`
- Output (redacted untuk repo public): `labs/01-linux/healthcheck.redacted.out`
- Notes: `notes/linux.md`

---

## 1.3 Shell & Automation — Healthcheck Script

### File
`labs/01-linux/scripts/healthcheck.sh`

### Run di server
```bash
chmod +x ~/labs/01-linux/scripts/healthcheck.sh
~/labs/01-linux/scripts/healthcheck.sh | tee ~/labs/01-linux/healthcheck.out
````

### Copy ke repo (jalankan di MacBook, dari root repo)

```bash
mkdir -p labs/01-linux/scripts
scp svr-tthi1:~/labs/01-linux/scripts/healthcheck.sh labs/01-linux/scripts/
scp svr-tthi1:~/labs/01-linux/healthcheck.out labs/01-linux/
```

### Redact untuk repo public (jalankan di MacBook)

```bash
awk '
/^== Host ==/ {print; getline; print "(REDACTED)"; next}
/^== Uptime ==/ {print; getline; print "(REDACTED)"; next}
/^== Listening Ports ==/ {print; print "(REDACTED)"; skip=1; next}
/^== Top RSS Processes ==/ {print; print "(REDACTED)"; skip=1; next}
skip && /^$/ {skip=0; print ""; next}
skip {next}
{print}
' labs/01-linux/healthcheck.out > labs/01-linux/healthcheck.redacted.out
```

Opsional (hindari commit file mentah):

```gitignore
labs/**/healthcheck.out
```

---

## 1.1 Filesystem & Permission — Checklist Praktik

Jalankan di server dan catat ringkas di `notes/linux.md` (atau tambah di sini):

```bash
pwd
ls -lah
ln -s /etc/hosts ~/hosts.link
ls -l ~/hosts.link
umask
```

Permission drill:

```bash
mkdir -p ~/tmp-perm && cd ~/tmp-perm
touch a.txt
chmod 600 a.txt
ls -la a.txt
```

---

## 1.2 Process & Service — Checklist Praktik

Process:

```bash
ps aux | head
htop
```

systemd:

```bash
systemctl status ssh --no-pager
systemctl status fail2ban --no-pager
```

journalctl:

```bash
journalctl -u ssh --no-pager -n 50
journalctl -u fail2ban --no-pager -n 50
```


