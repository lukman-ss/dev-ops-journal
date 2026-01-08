# DevOps Roadmap (Beginner → Expert) — Progress Checklist

> Fokus: kompetensi + proyek. Checklist ini dipakai untuk tracking harian/mingguan.

## Cara pakai
- Centang item saat **sudah bisa dipraktikkan**, bukan sekadar “sudah baca”.
- Setiap modul wajib punya **bukti output** (repo / catatan / screenshot / demo).

---

## 0. Setup & Baseline
- [x] Buat repo roadmap ini
- [x] Buat folder `notes/`, `labs/`, `runbooks/`
- [x] Siapkan 1 VM Linux (local/cloud) untuk latihan
- [x] Pasang SSH key (public key auth) + verifikasi login pakai key
- [ ] Hardening akses SSH dalam batas hak akses:
  - [x] Permission `~/.ssh` benar (700) & `authorized_keys` (600)
  - [x] Paksa penggunaan key dari client via `~/.ssh/config`
  - [x] Catat constraint: tidak punya akses root untuk disable password
  - [x] Terapkan hardening server: fail2ban + MaxAuthTries
- [x] Pasang editor + terminal tooling (git, curl, htop)

**Bukti:**
- [x] `labs/00-baseline/README.md` berisi:
  - spec server (OS, CPU/RAM/disk)
  - cara akses SSH (tanpa password di repo)
  - hasil verifikasi key login
  - daftar tooling terpasang
  - constraint + admin-request hardening

---

## 1. Linux Fundamentals
### 1.1 Filesystem & Permission
- [x] Navigasi filesystem, symlink, mount dasar
- [x] Ownership/permission (chmod/chown/umask)
- [x] Users & groups

### 1.2 Process & Service
- [x] Process (ps/top/htop, kill, nice)
- [x] systemd (start/stop/enable/status)
- [x] journalctl (filter, follow)

### 1.3 Shell & Automation
- [x] Bash scripting dasar (args, if, loop)
- [x] Text tools: grep/sed/awk
- [x] Cron + log rotation konsep dasar

**Bukti:**
- [x] Script `labs/01-linux/scripts/01-filesystem.sh`
- [x] Script `labs/01-linux/scripts/02-permissions.sh`
- [x] Script `labs/01-linux/scripts/03-users-groups.sh`
- [x] Script `labs/01-linux/scripts/04-process.sh`
- [x] Script `labs/01-linux/scripts/05-systemd-journal.sh`
- [x] Script `labs/01-linux/scripts/06-cron-logrotate.sh`
- [x] Script `labs/01-linux/scripts/healthcheck.sh`
- [x] Output `labs/01-linux/healthcheck.out`
- [x] Catatan `notes/linux.md`

---

## 2. Networking Basics
### 2.1 Core Concepts
- [x] TCP/UDP, ports, sockets
- [x] DNS (A/AAAA/CNAME/TXT), propagation
- [x] HTTP/HTTPS, TLS, certificates

### 2.2 Debug Tools
- [x] `curl` untuk cek endpoint + headers
- [x] `dig/nslookup` untuk DNS
- [x] `ss/netstat` untuk port check
- [ ] `tcpdump` dasar (capture + filter)
- [x] Traceroute / mtr konsep

### 2.3 Firewall & Reverse Proxy
- [x] UFW/iptables/nftables dasar
- [x] Konsep reverse proxy + forwarding headers

**Bukti:**
- [x] Script `labs/02-networking/scripts/netcheck.sh`
- [x] Script `labs/02-networking/scripts/proxy_tcpdump_lab.sh`
- [x] Output `labs/02-networking/netcheck.redacted.out`
- [x] Artifacts `labs/02-networking/artifacts/direct-backend.json`
- [x] Artifacts `labs/02-networking/artifacts/via-proxy.json`
- [x] Artifacts `labs/02-networking/artifacts/tcpdump-proxy-backend.out`
- [x] Catatan `notes/networking.md`

---

## 3. Git (Workflow DevOps)
- [ ] Branching (feature/release/hotfix) minimal paham
- [ ] Tagging & semantic versioning (vMAJOR.MINOR.PATCH)
- [ ] Rebase vs merge (kapan dipakai)
- [ ] Conflict resolution
- [ ] Git bisect (basic)

**Bukti:**
- [ ] `labs/03-git/README.md` (simulasi release + tag)

---

## 4. CI/CD Fundamentals
### 4.1 Pipeline Basics
- [ ] Lint stage
- [ ] Test stage
- [ ] Build artifact
- [ ] Security scan (minimal dependency atau image scan)
- [ ] Deploy stage (staging)

### 4.2 Environments & Secrets
- [ ] Environment variables per env (dev/staging/prod)
- [ ] Secrets storage (GitHub/GitLab secrets)
- [ ] Artifact versioning

**Bukti:**
- [ ] `.github/workflows/ci.yml` atau `.gitlab-ci.yml`
- [ ] `labs/04-cicd/README.md` (cara run + hasil)

---

## 5. Docker (Containerization)
### 5.1 Core
- [ ] Dockerfile best practices
- [ ] Multi-stage build
- [ ] Image tagging strategy
- [ ] Container logs + exec debug

### 5.2 Docker Compose
- [ ] Compose: networks, volumes
- [ ] Healthcheck
- [ ] Service dependency (bukan sekadar `depends_on`)

### 5.3 Registry & Scanning
- [ ] Push image ke registry
- [ ] Scan image (Trivy atau setara)
- [ ] Minimal SBOM konsep

**Bukti:**
- [ ] `labs/05-docker/Dockerfile`
- [ ] `labs/05-docker/docker-compose.yml`
- [ ] `labs/05-docker/README.md`

---

## 6. Web Server & Reverse Proxy (NGINX/Traefik)
- [ ] NGINX basic site + upstream
- [ ] TLS cert (Let’s Encrypt / certbot) atau via proxy manager
- [ ] Redirect HTTP → HTTPS
- [ ] Rate limiting dasar
- [ ] Basic auth / auth proxy konsep

**Bukti:**
- [ ] `labs/06-reverse-proxy/nginx/`
- [ ] `labs/06-reverse-proxy/README.md`

---

## 7. Infrastructure as Code (Terraform)
### 7.1 Terraform Core
- [ ] Providers, resources, variables, outputs
- [ ] State file & remote backend konsep
- [ ] Modules dasar
- [ ] Plan/apply discipline + drift awareness

### 7.2 Workflow
- [ ] `terraform fmt` / `validate`
- [ ] Workspace atau folder per environment
- [ ] CI gate untuk terraform (plan on PR)

**Bukti:**
- [ ] `labs/07-terraform/README.md`
- [ ] `labs/07-terraform/main.tf`

---

## 8. Configuration Management (Ansible)
- [ ] Inventory
- [ ] Roles (struktur minimal)
- [ ] Idempotency (run 2x hasil sama)
- [ ] Handlers
- [ ] Secure SSH & bootstrap server

**Bukti:**
- [ ] `labs/08-ansible/`
- [ ] `labs/08-ansible/README.md`

---

## 9. Kubernetes (Core)
### 9.1 Fundamental Objects
- [ ] Namespace, Pod, Deployment, ReplicaSet
- [ ] Service (ClusterIP/NodePort/LoadBalancer)
- [ ] ConfigMap & Secret
- [ ] Ingress

### 9.2 Reliability
- [ ] Liveness/Readiness probes
- [ ] Requests/limits
- [ ] Rolling update + rollback
- [ ] PDB (PodDisruptionBudget)

### 9.3 Storage
- [ ] PVC/PV konsep
- [ ] StorageClass konsep

**Bukti:**
- [ ] `labs/09-kubernetes/manifests/`
- [ ] `labs/09-kubernetes/README.md`

---

## 10. Helm (Packaging)
- [ ] Buat Helm chart sederhana
- [ ] Values per environment
- [ ] Upgrade/rollback
- [ ] Template helpers

**Bukti:**
- [ ] `labs/10-helm/chart/`
- [ ] `labs/10-helm/README.md`

---

## 11. Observability (Monitoring, Logging, Tracing)
### 11.1 Monitoring
- [ ] Prometheus scrape target
- [ ] Grafana dashboard basic
- [ ] Alertmanager rule basic (actionable)

### 11.2 Logging
- [ ] Centralized logs (Loki/ELK)
- [ ] Structured logging konsep + correlation id

### 11.3 Tracing
- [ ] OpenTelemetry konsep
- [ ] Trace end-to-end (minimal satu request)

**Bukti:**
- [ ] `labs/11-observability/README.md`
- [ ] Dashboard/export contoh

---

## 12. Security (DevSecOps)
- [ ] Secrets management policy (minimal)
- [ ] Dependency scanning di CI
- [ ] Image scanning gate (block on critical)
- [ ] TLS best practices dasar
- [ ] K8s security baseline (PSA / RBAC minimal)
- [ ] Network policy minimal (deny-by-default untuk namespace tertentu)

**Bukti:**
- [ ] `labs/12-security/README.md`
- [ ] CI pipeline menunjukkan scan berjalan

---

## 13. SRE & Reliability (Operasional Produksi)
- [ ] Definisikan SLI/SLO untuk 1 service
- [ ] Error budget konsep
- [ ] Runbook incident (service down, latency, DB issue)
- [ ] Backup + restore drill (yang dinilai restore)
- [ ] Postmortem template (blameless)

**Bukti:**
- [ ] `runbooks/service-down.md`
- [ ] `runbooks/backup-restore.md`
- [ ] `notes/slo.md`

---

## 14. GitOps & Platform Engineering (Expert Track)
### 14.1 GitOps
- [ ] Argo CD/Flux install
- [ ] App-of-apps atau struktur repo yang rapi
- [ ] PR-based deployment (audit trail)
- [ ] Progressive delivery konsep (canary/blue-green)

### 14.2 Policy & Guardrails
- [ ] Policy as code (OPA/Kyverno) minimal 1-2 policy
- [ ] Resource quota/limit range baseline
- [ ] Cost visibility konsep (requests/limits discipline)

### 14.3 Developer Platform
- [ ] Template repo + pipeline standar (“golden path”)
- [ ] Self-service environment (minimal staging per branch atau per PR)
- [ ] Dokumentasi internal “how to deploy” 1 halaman

**Bukti:**
- [ ] `labs/14-gitops/README.md`
- [ ] `platform/README.md`

---

# Capstone Projects (Wajib)
## P1 — Single Server Production
- [ ] App dockerized
- [ ] NGINX reverse proxy + TLS
- [ ] CI/CD deploy otomatis
- [ ] Monitoring + alert minimal
- [ ] Backup + restore drill

**Bukti:**
- [ ] `projects/p1-single-server/README.md`

## P2 — Kubernetes Production-like
- [ ] App di K8s + Helm
- [ ] Ingress + cert-manager
- [ ] HPA + PDB + rollback tested
- [ ] Observability stack
- [ ] Incident simulation 2 skenario

**Bukti:**
- [ ] `projects/p2-kubernetes/README.md`

## P3 — IaC End-to-End
- [ ] Terraform provision infra
- [ ] Ansible bootstrap
- [ ] GitOps deploy
- [ ] Security gates di CI

**Bukti:**
- [ ] `projects/p3-iac-gitops/README.md`

---

# Progress Log (Ringkas)
## Minggu 1
- [ ] Target selesai: Linux + Networking dasar + Git workflow

## Minggu 2
- [ ] Target selesai: CI/CD + Docker + Reverse proxy

## Minggu 3–4
- [ ] Target selesai: Terraform + Ansible + mulai K8s

## Minggu 5–6
- [ ] Target selesai: K8s + Helm + Observability

## Minggu 7+
- [ ] Target selesai: Security + SRE + GitOps/Platform

---

# Definition of Done (DoD)
Sebuah item dianggap selesai jika:
- [ ] Bisa dijelaskan ulang dengan kata sendiri (1 paragraf)
- [ ] Bisa dipraktikkan dari nol di environment baru
- [ ] Ada bukti di repo (`labs/` / `projects/` / `runbooks/`)
- [ ] Bisa troubleshoot minimal 1 kegagalan umum pada topik itu
