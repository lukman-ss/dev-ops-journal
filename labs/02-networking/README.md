Siap — ini versi **README 02** yang sudah di-update sesuai progress kamu **(tinggal 2 item: tcpdump + reverse proxy/forwarded headers)**, plus gue rapihin bagian bukti & step lab biar gampang dicentang dan file outputnya jelas. Copy-paste aja jadi `labs/02-networking/README.md`.

````md
# 02 - Networking Basics

## Target Checklist

### 2.1 Core Concepts
- [x] TCP/UDP, ports, sockets
- [x] DNS (A/AAAA/CNAME/TXT), propagation
- [x] HTTP/HTTPS, TLS, certificates

### 2.2 Debug Tools
- [x] `curl` untuk cek endpoint + headers
- [x] `dig`/`nslookup` untuk DNS
- [x] `ss`/`netstat` untuk port check
- [ ] `tcpdump` dasar (capture + filter) ✅ (lab tersedia, tinggal generate traffic biar cepat)
- [x] traceroute / mtr (konsep & praktik)

### 2.3 Firewall & Reverse Proxy
- [x] UFW/iptables/nftables dasar (cek status/ruleset)
- [ ] Konsep reverse proxy + forwarding headers ✅ (lab tersedia, tinggal eksekusi + output)

---

## Bukti (Artifacts)

### Sudah ada
- Script: `labs/02-networking/scripts/netcheck.sh`
- Output mentah (jangan commit): `labs/02-networking/netcheck.out`
- Output redacted untuk repo public: `labs/02-networking/netcheck.redacted.out`

### Akan ditambah (setelah lab dijalankan)
- `labs/02-networking/artifacts/headers-local.out`
- `labs/02-networking/artifacts/headers-simulated-forwarded.out`
- `labs/02-networking/artifacts/tcpdump-dns.out`
- `labs/02-networking/artifacts/tcpdump-http-8088.out`

---

## Cara Run (di server)

```bash
cd ~/labs/02-networking
chmod +x scripts/netcheck.sh
./scripts/netcheck.sh | tee netcheck.out
````

---

## Copy ke repo (jalankan di MacBook, dari root repo)

```bash
mkdir -p labs/02-networking/scripts
scp <server>:~/labs/02-networking/scripts/netcheck.sh labs/02-networking/scripts/
scp <server>:~/labs/02-networking/netcheck.out labs/02-networking/
```

> Note: kalau folder artifacts sudah ada di server, tarik sekalian:

```bash
mkdir -p labs/02-networking/artifacts
scp -r <server>:~/labs/02-networking/artifacts/* labs/02-networking/artifacts/ || true
```

---

## Redact untuk repo public (jalankan di MacBook)

```bash
awk '
/^== Host ==/ {print; getline; print "(REDACTED)"; next}
/^== IP \/ Interfaces ==/ {print; print "(REDACTED)"; skip=1; next}
/^== Routes ==/ {print; print "(REDACTED)"; skip=1; next}
/^== TCP\/UDP sockets/ {print; print "(REDACTED)"; skip=1; next}
/^Current DNS Server:/ {print "Current DNS Server: (REDACTED)"; next}
/DNS Servers:/ {print "       DNS Servers: 8.8.8.8 8.8.4.4 (REDACTED)"; next}
/DNS Domain:/ {print "        DNS Domain: (REDACTED)"; next}
/^HOST:/ {sub(/HOST: [^ ]+/, "HOST: (REDACTED)"); print; next}
/^\s+[0-9]+\.\|--/ && !/162\.158|172\.69|one\.one/ {
  sub(/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/, "(REDACTED)"); print; next
}
skip && /^$/ {skip=0; print ""; next}
skip {next}
{print}
' labs/02-networking/netcheck.out > labs/02-networking/netcheck.redacted.out
```

Opsional (hindari commit file mentah):

```gitignore
labs/**/netcheck.out
```

---

## Lab Tambahan (untuk centang yang masih kosong)

### A) Reverse proxy + forwarding headers (nginx)

> Goal: paham konsep `X-Forwarded-For`, `X-Forwarded-Proto`, `X-Real-IP` dan bagaimana service membaca header itu.

Di server:

```bash
mkdir -p ~/labs/02-networking/artifacts
```

Buat config nginx lab:

```bash
sudo tee /etc/nginx/sites-available/lab-headers.conf > /dev/null <<'CONF'
server {
  listen 8088;
  server_name _;

  location /headers {
    return 200
"remote_addr=$remote_addr
http_host=$http_host
scheme=$scheme
x_forwarded_for=$http_x_forwarded_for
x_forwarded_proto=$http_x_forwarded_proto
x_real_ip=$http_x_real_ip
";
  }
}
CONF
```

Enable + reload:

```bash
sudo ln -sf /etc/nginx/sites-available/lab-headers.conf /etc/nginx/sites-enabled/lab-headers.conf
sudo nginx -t
sudo systemctl reload nginx
```

Test local (tanpa forwarded headers):

```bash
curl -sS http://127.0.0.1:8088/headers | tee ~/labs/02-networking/artifacts/headers-local.out
```

Simulasi forwarded headers:

```bash
curl -sS \
  -H "X-Forwarded-For: 203.0.113.10" \
  -H "X-Forwarded-Proto: https" \
  -H "X-Real-IP: 203.0.113.10" \
  http://127.0.0.1:8088/headers | tee ~/labs/02-networking/artifacts/headers-simulated-forwarded.out
```

✅ Setelah output ini ada, item berikut boleh dicentang:

* [x] Konsep reverse proxy + forwarding headers

---

### B) tcpdump dasar (capture + filter) — biar nggak “lama”

> Problem umum: `tcpdump` menunggu trafik yang match filter.
> Solusi: **generate traffic sendiri** (DNS & HTTP) supaya cepat selesai.

**DNS capture (port 53)**
Terminal 1:

```bash
sudo tcpdump -i any -nn -c 20 port 53 | tee ~/labs/02-networking/artifacts/tcpdump-dns.out
```

Terminal 2:

```bash
dig +short google.com @8.8.8.8
dig +short cloudflare.com @8.8.8.8
```

**HTTP capture (port 8088)**
Terminal 1:

```bash
sudo tcpdump -i any -nn -c 20 tcp port 8088 | tee ~/labs/02-networking/artifacts/tcpdump-http-8088.out
```

Terminal 2:

```bash
curl -sS http://127.0.0.1:8088/headers >/dev/null
curl -sS http://127.0.0.1:8088/headers >/dev/null
```

✅ Setelah output ini ada, item berikut boleh dicentang:

* [x] tcpdump dasar (capture + filter)
