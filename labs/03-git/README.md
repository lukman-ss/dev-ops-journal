# Lab 03 — Git Workflow DevOps (Branching, Tagging, Rebase/Merge, Conflict, Bisect)

## Target
Selesai lab ini, kamu bisa:
- Branching: feature / release / hotfix (minimal paham alur)
- Tagging + semantic versioning (`vMAJOR.MINOR.PATCH`)
- Bedain rebase vs merge dan kapan dipakai
- Resolve conflict dengan benar
- Pakai `git bisect` untuk nemuin commit penyebab bug

## Prasyarat
- Repo sudah ada branch `main`
- Sudah bisa commit dan push ke origin

---

## 0) Setup file versi (biar latihan nyata)
Di root repo, buat file versi:
```bash
echo "0.1.0" > VERSION
git add VERSION
git commit -m "chore: add VERSION file"
```

Cek graph:

```bash
git log --oneline --decorate --graph --all
```

---

## 1) Branching Workflow (feature → main)

### 1.1 Buat feature branch

```bash
git checkout -b feature/add-git-notes
```

Tambah file:

```bash
mkdir -p notes
cat > notes/git.md << 'EOF'
# Git Notes
- feature/release/hotfix
- semver tags
EOF
git add notes/git.md
git commit -m "feat: add git notes"
```

### 1.2 Update `main` dan sync feature (contoh rebase)

```bash
git checkout main
git pull origin main || true

git checkout feature/add-git-notes
git rebase main
```

### 1.3 Merge feature ke main (fast-forward kalau bersih)

```bash
git checkout main
git merge feature/add-git-notes
```

Bersihin branch feature (opsional):

```bash
git branch -d feature/add-git-notes
```

**Cek:**

```bash
git log --oneline --decorate --graph --all
```

---

## 2) Release Workflow + Tagging SemVer

### 2.1 Buat release branch

```bash
git checkout -b release/1.0.0 main
```

### 2.2 Set versi 1.0.0

```bash
echo "1.0.0" > VERSION
git add VERSION
git commit -m "chore(release): bump version to 1.0.0"
```

### 2.3 Merge release ke main

```bash
git checkout main
git merge --no-ff release/1.0.0 -m "merge: release 1.0.0"
```

### 2.4 Tag rilis (annotated tag)

```bash
git tag -a v1.0.0 -m "release: v1.0.0"
git tag -n
```

### 2.5 Push branch + tags

```bash
git push origin main
git push origin --tags
```

Opsional hapus branch release:

```bash
git branch -d release/1.0.0
```

**Cek:**

```bash
git show v1.0.0
git log --oneline --decorate --graph --all
```

---

## 3) Hotfix Workflow (patch release)

Simulasi ada bug kecil di `notes/git.md`.

### 3.1 Buat hotfix dari main (atau dari tag terakhir)

```bash
git checkout main
git checkout -b hotfix/1.0.1
```

Fix:

```bash
echo "- conflict + bisect basics" >> notes/git.md
git add notes/git.md
git commit -m "fix: extend git notes"
```

Bump patch:

```bash
echo "1.0.1" > VERSION
git add VERSION
git commit -m "chore(release): bump version to 1.0.1"
```

Merge ke main + tag:

```bash
git checkout main
git merge --no-ff hotfix/1.0.1 -m "merge: hotfix 1.0.1"
git tag -a v1.0.1 -m "release: v1.0.1"
git push origin main
git push origin --tags
```

Opsional:

```bash
git branch -d hotfix/1.0.1
```

---

## 4) Rebase vs Merge (kapan dipakai)

### Merge cocok saat:

* Mau mempertahankan “history percabangan” (audit trail jelas)
* Release/hotfix biasanya pakai `--no-ff` biar terlihat

Contoh:

```bash
git merge --no-ff release/1.0.0
```

### Rebase cocok saat:

* Mau history linear dan bersih untuk feature branch
* Sebelum merge feature ke main (biar tidak banyak merge commit)

Contoh:

```bash
git checkout feature/xyz
git rebase main
```

Catatan: **jangan rebase branch yang sudah dipakai banyak orang** (shared branch), karena rewrite history.

---

## 5) Conflict Resolution (latihan bikin conflict)

### 5.1 Buat branch A ubah baris yang sama

```bash
git checkout main
git checkout -b feature/conflict-a
sed -i '' 's/Git Notes/Git Notes (A)/' notes/git.md 2>/dev/null || \
perl -pi -e 's/Git Notes/Git Notes (A)/' notes/git.md
git add notes/git.md
git commit -m "feat: change title A"
```

### 5.2 Buat branch B ubah baris yang sama

```bash
git checkout main
git checkout -b feature/conflict-b
sed -i '' 's/Git Notes/Git Notes (B)/' notes/git.md 2>/dev/null || \
perl -pi -e 's/Git Notes/Git Notes (B)/' notes/git.md
git add notes/git.md
git commit -m "feat: change title B"
```

### 5.3 Merge A dulu ke main

```bash
git checkout main
git merge feature/conflict-a
```

### 5.4 Merge B → harus conflict

```bash
git merge feature/conflict-b
```

Resolve:

* Buka `notes/git.md`, pilih final text yang benar
* Hapus marker conflict `<<<<<<< ======= >>>>>>>`

Lanjutkan:

```bash
git add notes/git.md
git commit -m "merge: resolve conflict on git notes"
```

Cleanup:

```bash
git branch -d feature/conflict-a feature/conflict-b
```

---

## 6) Git Bisect (cari commit penyebab bug)

### 6.1 Buat “bug” disengaja + beberapa commit

Kita bikin file `app.txt` yang harus mengandung string `OK`.

```bash
git checkout main
echo "OK" > app.txt
git add app.txt
git commit -m "test: app status OK"

echo "OK" >> app.txt
git add app.txt
git commit -m "chore: add extra OK line"

# commit yang bikin bug (hapus OK)
echo "BROKEN" > app.txt
git add app.txt
git commit -m "bug: break app status"

echo "BROKEN v2" >> app.txt
git add app.txt
git commit -m "chore: extend broken status"
```

### 6.2 Tentukan good dan bad

Cari hash commit terakhir (bad) dan commit pertama yang good:

```bash
git log --oneline -- app.txt
```

Misal:

* GOOD = commit `test: app status OK`
* BAD  = commit paling atas sekarang

Jalankan bisect:

```bash
git bisect start
git bisect bad
git bisect good <GOOD_COMMIT_HASH>
```

### 6.3 “Test” manual tiap step

Rule: commit dianggap **good** jika file mengandung `OK`.

```bash
grep -q "OK" app.txt && echo "GOOD" || echo "BAD"
```

Kalau hasil GOOD:

```bash
git bisect good
```

Kalau BAD:

```bash
git bisect bad
```

Sampai ketemu:

```bash
git bisect reset
```

**Output akhir** akan nunjuk 1 commit penyebab bug.

---

## Bukti (wajib untuk centang modul)

* [ ] Screenshot / copy output: `git log --graph --decorate --oneline --all`
* [ ] Ada tag: `v1.0.0` dan `v1.0.1` (`git tag -n`)
* [ ] Pernah resolve conflict (commit “resolve conflict” ada di history)
* [ ] Pernah jalankan bisect dan ketemu 1 commit penyebab bug

---

## Cheat Sheet (ringkas)

```bash
# branching
git checkout -b feature/x
git checkout -b release/1.2.0
git checkout -b hotfix/1.2.1

# merge / rebase
git merge feature/x
git merge --no-ff release/1.2.0 -m "merge: release 1.2.0"
git rebase main

# tag semver
git tag -a v1.2.0 -m "release: v1.2.0"
git push origin --tags

# conflict resolve
git status
# edit file -> git add -> git commit

# bisect
git bisect start
git bisect bad
git bisect good <hash>
git bisect good|bad
git bisect reset
```




---

## Lab Execution Result

✅ **Lab sudah selesai dikerjakan!**

Lihat hasil lengkap di: `labs/03-git/RESULT.md`

**Summary:**
- ✅ Feature branch workflow (feature/add-git-notes)
- ✅ Release workflow dengan tag v1.0.0
- ✅ Hotfix workflow dengan tag v1.0.1
- ✅ Conflict resolution (via GUI)
- ✅ Git bisect untuk mencari bug commit
- ✅ Memahami rebase vs merge

**Tags Created:**
- `v1.0.0` - First release
- `v1.0.1` - Hotfix release
