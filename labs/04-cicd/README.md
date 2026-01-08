# Lab 04 — CI/CD Fundamentals (GitHub Actions)

## Checklist mapping
### Pipeline Basics
- Lint stage: markdownlint
- Test stage: validasi `VERSION` (SemVer x.y.z)
- Build artifact: build mkdocs + tar.gz versioned
- Security scan: Trivy filesystem scan
- Deploy stage (staging): publish docs ke `gh-pages` (GitHub Pages)

### Environments & Secrets
- Env vars per env: GitHub Environments (`staging`, `production`) + `vars`
- Secrets storage: GitHub Environment Secrets
- Artifact versioning: `APP_NAME-VERSION-SHORTSHA.tar.gz`

## Bukti
- `.github/workflows/ci.yml` jalan sukses
- Artifact `build-artifacts` muncul
- Branch `gh-pages` terupdate (deploy staging)
