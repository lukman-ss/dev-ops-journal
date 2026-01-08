# Linux Fundamentals Notes

## 1. Filesystem & Permission

### Navigasi & Symlink
- `pwd` - print working directory
- `ls -lah` - list dengan detail (hidden files, human-readable size)
- `ln -s <target> <link>` - buat symbolic link
- `readlink -f <link>` - baca target dari symlink (full path)

### Disk & Mount
- `df -h` - disk free space (human-readable)
- `lsblk` - list block devices (disk, partisi)
- `findmnt` - list semua mount points
- `mount -t tmpfs -o size=16m tmpfs /path` - mount tmpfs (RAM disk)
- `umount /path` - unmount filesystem

### Permission
- **Format permission**: `rwxrwxrwx` (owner, group, others)
- `chmod 600 file` - owner read/write only
- `chmod 700 dir` - owner full access only
- `chmod u+x file` - tambah execute untuk owner
- `chown user:group file` - ubah ownership

### umask
- `umask` - lihat default permission mask
- `umask 077` - set mask (file baru jadi 600, dir jadi 700)
- Default umask biasanya `0022` (file: 644, dir: 755)
- Formula: permission = 666 - umask (file), 777 - umask (dir)

### Users & Groups
- `whoami` - username saat ini
- `id` - user ID, group ID, dan groups
- `groups` - list groups user saat ini
- `getent passwd <user>` - info user dari /etc/passwd
- `getent group` - list semua groups

**Key Learning:**
- Directory butuh `x` (execute) untuk bisa di-cd
- File dengan `x` bisa dijalankan sebagai program
- umask mengontrol default permission file/dir baru

---

## 2. Process & Service

### Process Management
- `ps aux` - snapshot semua process
- `ps -p <PID> -o pid,ni,cmd` - detail process tertentu
- `top` / `htop` - monitoring real-time
- `top -b -n 1` - batch mode (sekali jalan, untuk script)

### Process Priority
- `nice -n <priority> <command>` - jalankan dengan priority tertentu
  - Range: -20 (highest) sampai 19 (lowest)
  - Default: 0
- `renice -n <priority> -p <PID>` - ubah priority process yang running

### Process Control
- `kill -TERM <PID>` - terminate gracefully (SIGTERM)
- `kill -9 <PID>` - force kill (SIGKILL)
- `kill -HUP <PID>` - reload config (SIGHUP)
- `<command> &` - jalankan di background
- `$!` - PID dari background process terakhir

### systemd Service
- `systemctl status <service>` - cek status service
- `systemctl start <service>` - start service
- `systemctl stop <service>` - stop service
- `systemctl restart <service>` - restart service
- `systemctl enable <service>` - auto-start saat boot
- `systemctl disable <service>` - disable auto-start
- `systemctl is-active <service>` - cek apakah running
- `systemctl is-enabled <service>` - cek apakah auto-start

### journalctl (systemd logs)
- `journalctl -u <service>` - logs untuk service tertentu
- `journalctl -n 50` - last 50 lines
- `journalctl -f` - follow mode (tail -f)
- `journalctl --since "1 hour ago"` - filter by time
- `journalctl -p err` - filter by priority (err, warning, info)
- `--no-pager` - output langsung tanpa pager

**Key Learning:**
- systemd adalah init system modern di Linux
- journalctl menyimpan logs binary (lebih efisien dari text logs)
- nice/renice berguna untuk CPU-intensive tasks yang tidak urgent

---

## 3. Shell & Automation

### Bash Scripting Best Practices
```bash
#!/usr/bin/env bash
set -euo pipefail
```
- `set -e` - exit jika ada command yang error
- `set -u` - error jika pakai undefined variable
- `set -o pipefail` - pipe gagal jika salah satu command gagal

### Variables & String
```bash
VAR="value"
echo "$VAR"           # interpolation
echo "${VAR}/path"    # clear boundary
```

### Functions
```bash
function_name() {
  local var="local scope"
  echo "$1"  # first argument
}
```

### Case Statement
```bash
case "${1:-}" in
  option1) command1 ;;
  option2) command2 ;;
  *) echo "Usage: ..." ;;
esac
```

### Cron
- `crontab -l` - list cron jobs
- `crontab -e` - edit cron jobs
- Format: `* * * * * command`
  - Minute (0-59)
  - Hour (0-23)
  - Day of month (1-31)
  - Month (1-12)
  - Day of week (0-7, 0=Sunday)
- Example: `0 2 * * * /path/script.sh` - run at 2 AM daily
- Redirect output: `command >> /path/log 2>&1`

### Log Rotation
```bash
logrotate -s <state-file> -f <config-file>
```

Config format:
```
/path/to/log {
  size 50k          # rotate jika > 50KB
  rotate 3          # keep 3 old logs
  compress          # gzip old logs
  delaycompress     # compress next rotation
  copytruncate      # copy then truncate (safe for running apps)
  missingok         # ok jika file tidak ada
  notifempty        # jangan rotate jika kosong
}
```

### Text Processing Tools

**awk** - pattern scanning & processing
```bash
awk '{print $1,$2}'              # print kolom 1 dan 2
awk -F: '{print $1}'             # custom delimiter
awk '/pattern/ {print $0}'       # filter by pattern
awk 'NR==1,NR==10 {print}'       # line 1-10
```

**grep** - search text
```bash
grep "pattern" file              # search in file
grep -r "pattern" dir/           # recursive
grep -v "pattern"                # invert match
grep -i "pattern"                # case insensitive
```

**sed** - stream editor
```bash
sed 's/old/new/'                 # replace first occurrence
sed 's/old/new/g'                # replace all
sed -n '1,10p'                   # print line 1-10
```

### Healthcheck Script Pattern
Script yang comprehensive untuk monitoring:
- System info: hostname, OS, uptime
- Resources: CPU, memory, disk, load average
- Network: listening ports
- Processes: top consumers

**Key Learning:**
- `set -euo pipefail` adalah must-have untuk production scripts
- cron untuk scheduled tasks, logrotate untuk log management
- awk sangat powerful untuk parsing structured output
- Healthcheck script penting untuk monitoring dan troubleshooting

---

## Tips & Tricks

1. **Debugging bash script**: tambahkan `set -x` untuk print setiap command
2. **Check command exists**: `command -v <cmd> >/dev/null 2>&1`
3. **Default value**: `${VAR:-default}` - use default jika VAR kosong
4. **Redirect stderr**: `2>&1` - redirect stderr ke stdout
5. **Discard output**: `>/dev/null 2>&1` - buang semua output
6. **Here document**: `cat <<EOF ... EOF` - multi-line string
7. **Process substitution**: `<(command)` - treat command output as file
8. **Command substitution**: `$(command)` atau `` `command` ``

## Common Patterns

### Safe file operations
```bash
mkdir -p /path/to/dir           # create with parents, no error if exists
rm -f file                      # remove, no error if not exists
cp -r source dest               # recursive copy
```

### Conditional execution
```bash
command && echo "success"       # run if previous success
command || echo "failed"        # run if previous failed
[ -f file ] && echo "exists"    # test file exists
```

### Loop
```bash
for i in $(seq 1 10); do
  echo "$i"
done

while read line; do
  echo "$line"
done < file
```

---

## References
- Lab: `labs/01-linux/`
- Scripts: `labs/01-linux/scripts/*.sh`
- Server: Ubuntu 24.04.2 LTS
