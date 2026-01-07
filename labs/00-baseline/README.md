# 00 - Baseline

## Status
- SSH key login: **OK** (public key auth sudah terpasang & diuji)
- Permission `~/.ssh` dan `authorized_keys`: **OK**
- Client enforce key via `~/.ssh/config`: **OK**
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

## TODO (belum dikerjakan)

* [ ] Kirim request ke admin untuk hardening SSH:

  * fail2ban untuk SSH
  * allowlist IP kantor/VPN untuk port 22 (jika memungkinkan)
  * `PermitRootLogin no`
  * `MaxAuthTries 3`
  * ideal: `PasswordAuthentication no`
* [ ] Pasang tooling di server: `git`, `curl`, `htop` (+ editor kalau perlu)
* [ ] Isi spec server (OS/CPU/RAM/Disk) setelah tooling siap / akses tersedia