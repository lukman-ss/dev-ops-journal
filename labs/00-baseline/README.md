# 00 - Baseline

## Status
- SSH key login: **OK** (public key auth sudah terpasang & diuji)
- Permission `~/.ssh` dan `authorized_keys`: **OK**
- Client enforce key via `~/.ssh/config`: **OK**
- Tooling minimal: **OK** (git/curl/htop/nano/vim sudah ada)
- Spec server: **OK** (OS/CPU/RAM/Disk/IP sudah dicatat)
- Constraint: **tidak punya akses root** (tidak bisa disable password dari sisi user)

## Akses SSH (tanpa password di repo)
Client (MacBook) `~/.ssh/config`:

```conf
Host svr-tthi1
  HostName 192.168.0.48
  User svr-tthi1
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
````

Login:

```bash
ssh svr-tthi1
```

Verifikasi key-only (harus berhasil tanpa prompt password):

```bash
ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no svr-tthi1@192.168.0.48
```

## Hardening yang sudah dilakukan (tanpa root)

Di server:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
ls -ld ~/.ssh
ls -la ~/.ssh/authorized_keys
```

Expected:

* `~/.ssh` = `drwx------`
* `authorized_keys` = `-rw-------`

## Constraint

* Tidak punya akses root untuk mengubah `/etc/ssh/sshd_config`
* Tidak bisa mematikan `PasswordAuthentication` dari sisi user

## Spec Server (Current)

* OS: Ubuntu 24.04.2 LTS (Noble Numbat)
* Kernel: 6.8.0-90-generic
* CPU: 4 vCPU (QEMU Virtual CPU, KVM)
* RAM: 7.6Gi (available ~5.3Gi)
* Swap: 4.0Gi
* Disk `/`: 223G total, 34G used, 180G available (16%)
* IP utama: 192.168.0.48/24 (ens18)
* Catatan network: ada Docker bridges (172.17.0.1/16, 172.18/19/20/21) + tailscale0

## Tooling Minimal (Installed)

* git: 2.43.0
* curl: 8.5.0 (OpenSSL 3.0.13)
* htop: 3.3.0
* nano: 7.2
* vim: 9.1

Verifikasi:

```bash
git --version
curl --version
htop --version
nano --version
vim --version | head -n 2
```

## TODO (belum dikerjakan)

* [ ] Kirim request ke admin untuk hardening SSH (karena butuh akses root):

  * fail2ban untuk SSH
  * allowlist IP kantor/VPN untuk port 22 (jika memungkinkan)
  * `PermitRootLogin no`
  * `MaxAuthTries 3`
  * ideal: `PasswordAuthentication no` (kalau tidak memungkinkan, minimal fail2ban + rate limit)

## Template Pesan ke Admin (copy-paste)

```
Request hardening SSH untuk server lab (user: svr-tthi1).
Constraint: saya tidak punya akses root untuk ubah sshd_config.

Mohon bantu set:
1) fail2ban untuk SSH
2) allowlist IP kantor/VPN untuk port 22 (jika memungkinkan)
3) PermitRootLogin no
4) MaxAuthTries 3
5) Ideal: PasswordAuthentication no
   (kalau belum bisa, minimal fail2ban + rate limit)

Tujuan: mengurangi risiko brute-force pada SSH.
```