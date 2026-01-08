# 00 - Baseline

## Status

- SSH key login: **OK** (public key auth terpasang & diuji)
- Permission `~/.ssh` dan `authorized_keys`: **OK**
- Client enforce key via `~/.ssh/config`: **OK**
- SSH hardening: **OK** (MaxAuthTries=10 + fail2ban jail `sshd` aktif)
- Tooling minimal: **OK** (git/curl/htop/nano/vim tersedia)
- Spec server: **OK** (OS/CPU/RAM/Disk/IP dicatat)
- Password login: **ON** (keputusan: tidak dimatikan)

## Akses SSH (tanpa password di repo)

Client (MacBook) `~/.ssh/config`:

```conf
Host <server-alias>
  HostName <server-ip>
  User <username>
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
```

Login:

```bash
ssh <server-alias>
```

Verifikasi key-only (harus berhasil tanpa prompt password):

```bash
ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no <username>@<server-ip>
```

## Hardening yang sudah dilakukan

### 1) SSH key file permission (user-level)

Di server:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
ls -ld ~/.ssh
ls -la ~/.ssh/authorized_keys
```

Expected:

- `~/.ssh` = `drwx------`
- `authorized_keys` = `-rw-------`

### 2) SSH server hardening (system-level)

- MaxAuthTries: 10
- fail2ban: enabled (jail `sshd`; backend systemd)

Config files:

- `/etc/ssh/sshd_config.d/99-maxauthtries.conf`
- `/etc/fail2ban/jail.d/sshd.local`

Verification:

```bash
sudo sshd -T | grep -i maxauthtries
sudo systemctl is-active fail2ban
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

## Spec Server (Current)

- OS: Ubuntu 24.04.2 LTS (Noble Numbat)
- Kernel: 6.8.0-90-generic
- CPU: 4 vCPU (QEMU Virtual CPU, KVM)
- RAM: 7.6Gi (available ~5.3Gi)
- Swap: 4.0Gi
- Disk `/`: 223G total, 34G used, 180G available (16%)
- IP utama: Internal network (ens18)
- Catatan network: Docker bridges (172.17/18/19/20/21) + tailscale0

## Tooling Minimal (Installed)

- git: 2.43.0
- curl: 8.5.0 (OpenSSL 3.0.13)
- htop: 3.3.0
- nano: 7.2
- vim: 9.1

Verifikasi:

```bash
git --version
curl --version
htop --version
nano --version
vim --version | head -n 2
```
