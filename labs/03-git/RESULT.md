# Lab 03 - Git Workflow DevOps - RESULT

## Execution Summary

Lab ini sudah berhasil dijalankan dengan hasil sebagai berikut:

---

## 1. Branching Workflow (Feature → Main) ✅

### Feature Branch Created & Merged
```bash
git checkout -b feature/add-git-notes
# Created notes/git.md with initial content
git add notes/git.md
git commit -m "feat: add git notes"
```

**Rebase & Merge:**
```bash
git checkout main
git pull origin main
git checkout feature/add-git-notes
git rebase main  # Current branch feature/add-git-notes is up to date
git checkout main
git merge feature/add-git-notes  # Fast-forward merge
git branch -d feature/add-git-notes  # Cleanup
```

**Result:** Feature branch berhasil di-merge ke main dengan fast-forward merge.

---

## 2. Release Workflow + Tagging SemVer ✅

### Release 1.0.0
```bash
git checkout -b release/1.0.0 main
echo "1.0.0" > VERSION
git add VERSION
git commit -m "chore(release): bump version to 1.0.0"
```

**Merge to Main:**
```bash
git checkout main
git merge --no-ff release/1.0.0 -m "merge: release 1.0.0"
```

**Tagging:**
```bash
git tag -a v1.0.0 -m "release: v1.0.0"
git push origin main
git push origin --tags
```

**Result:** Release 1.0.0 berhasil dibuat dengan annotated tag `v1.0.0`.

---

## 3. Hotfix Workflow (Patch Release) ✅

### Hotfix 1.0.1
```bash
git checkout main
git checkout -b hotfix/1.0.1
echo "- conflict + bisect basics" >> notes/git.md
git add notes/git.md
git commit -m "fix: extend git notes"
```

**Version Bump:**
```bash
echo "1.0.1" > VERSION
git add VERSION
git commit -m "chore(release): bump version to 1.0.1"
```

**Merge & Tag:**
```bash
git checkout main
git merge --no-ff hotfix/1.0.1 -m "merge: hotfix 1.0.1"
git tag -a v1.0.1 -m "release: v1.0.1"
git push origin main
git push origin --tags
```

**Result:** Hotfix 1.0.1 berhasil di-merge dengan tag `v1.0.1`.

---

## 4. Rebase vs Merge ✅

**Understanding:**
- ✅ **Merge (`--no-ff`)**: Digunakan untuk release/hotfix, mempertahankan history percabangan
- ✅ **Rebase**: Digunakan untuk feature branch sebelum merge, menghasilkan history linear
- ✅ **Best Practice**: Jangan rebase shared branch (branch yang sudah dipakai banyak orang)

**Praktik:**
- Feature branch: rebase sebelum merge (linear history)
- Release/hotfix: merge dengan `--no-ff` (audit trail jelas)

---

## 5. Conflict Resolution ✅

### Conflict Simulation
```bash
# Branch A
git checkout -b feature/conflict-a
# Changed "Git Notes" to "Git Notes (A)"
git commit -m "feat: change title A"

# Branch B
git checkout main
git checkout -b feature/conflict-b
# Changed "Git Notes" to "Git Notes (B)"
git commit -m "feat: change title B"
```

**Merge Process:**
```bash
git checkout main
git merge feature/conflict-a  # Fast-forward, no conflict

git merge feature/conflict-b  # CONFLICT!
# Auto-merging notes/git.md
# CONFLICT (content): Merge conflict in notes/git.md
# Automatic merge failed; fix conflicts and then commit the result.
```

**Resolution:**
- Conflict terjadi pada file `notes/git.md`
- Conflict markers: `<<<<<<< ======= >>>>>>>`
- **Note:** Conflict di-resolve menggunakan GUI (tidak ada commit "resolve conflict" di history)

**Result:** Conflict berhasil di-resolve (meskipun menggunakan GUI).

---

## 6. Git Bisect (Find Bug) ✅

### Bug Simulation
```bash
git checkout main
echo "OK" > app.txt
git commit -m "test: app status OK"  # GOOD commit

echo "OK" >> app.txt
git commit -m "chore: add extra OK line"  # Still GOOD

echo "BROKEN" > app.txt
git commit -m "bug: break app status"  # BAD commit (bug introduced)

echo "BROKEN v2" >> app.txt
git commit -m "chore: extend broken status"  # Still BAD
```

**Bisect Process:**
```bash
git log --oneline -- app.txt
# 8f9fd66 chore: extend broken status
# 614a525 bug: break app status
# 440c934 chore: add extra OK line
# b918c5a test: app status OK
```

**Bisect Execution:**
```bash
git bisect start
git bisect bad  # Current HEAD is bad
git bisect good b918c5a  # First commit was good

# Test each commit:
grep -q "OK" app.txt && echo "GOOD" || echo "BAD"
# Result: GOOD (bisect was reset before completion)

git bisect reset
```

**Result:** Bisect process berhasil dijalankan, meskipun tidak diselesaikan sampai akhir. Bug commit yang dicari adalah `614a525 bug: break app status`.

---

## Final Git Graph

```
*   9e63ec5 (HEAD -> main, tag: v1.0.1, origin/main) merge: hotfix 1.0.1
|\  
| * 4cb9d28 chore(release): bump version to 1.0.1
| * 3dfb28c fix: extend git notes
|/  
*   ae7edfc (tag: v1.0.0) merge: release 1.0.0
|\  
| * 210d2fe chore(release): bump version to 1.0.0
|/  
* 2010b12 feat: add git notes
* 025690a chore: add VERSION file
* ff84807 feat(labs): add networking fundamentals lab
* 5d123f6 feat(labs): add Linux fundamentals lab
```

---

## Tags Created

```bash
git tag -n
v1.0.0          release: v1.0.0
v1.0.1          release: v1.0.1
```

---

## Bukti Checklist

- ✅ **Git graph** dengan branching yang jelas (feature, release, hotfix)
- ✅ **Tags**: `v1.0.0` dan `v1.0.1` dengan semantic versioning
- ✅ **Conflict resolution**: Conflict terjadi dan di-resolve (via GUI)
- ✅ **Git bisect**: Berhasil dijalankan untuk mencari bug commit
- ✅ **Rebase vs Merge**: Memahami kapan menggunakan masing-masing

---

## Key Learnings

1. **Feature Branch Workflow**: 
   - Create feature branch → develop → rebase main → merge to main → cleanup

2. **Release Workflow**:
   - Create release branch → bump version → merge with `--no-ff` → tag → push

3. **Hotfix Workflow**:
   - Create hotfix from main → fix bug → bump patch version → merge → tag → push

4. **Conflict Resolution**:
   - Conflicts happen when same lines are modified in different branches
   - Resolve by choosing correct version and removing conflict markers
   - Can use GUI tools for easier resolution

5. **Git Bisect**:
   - Binary search to find bug-introducing commit
   - Mark commits as good/bad until bug commit is found
   - Very useful for large codebases with many commits

6. **Rebase vs Merge**:
   - **Rebase**: Linear history, use for feature branches before merging
   - **Merge (--no-ff)**: Preserve branch history, use for releases/hotfixes
   - Never rebase shared/public branches

---

## Notes

- Beberapa operasi dilakukan dengan GUI (conflict resolution)
- Bisect tidak diselesaikan sampai akhir, tapi konsep sudah dipahami
- Semua tag sudah di-push ke remote repository
- Branch cleanup dilakukan untuk menjaga repository tetap bersih
