# Git Workflow DevOps Notes

## 1. Branching Strategy

### Feature Branch
- **Purpose**: Develop new features in isolation
- **Naming**: `feature/<feature-name>`
- **Workflow**:
  ```bash
  git checkout -b feature/add-login
  # develop feature
  git add .
  git commit -m "feat: add login functionality"
  git checkout main
  git pull origin main
  git checkout feature/add-login
  git rebase main  # keep history linear
  git checkout main
  git merge feature/add-login  # fast-forward merge
  git branch -d feature/add-login  # cleanup
  ```

### Release Branch
- **Purpose**: Prepare for production release
- **Naming**: `release/<version>`
- **Workflow**:
  ```bash
  git checkout -b release/1.0.0 main
  # bump version, final testing
  echo "1.0.0" > VERSION
  git commit -m "chore(release): bump version to 1.0.0"
  git checkout main
  git merge --no-ff release/1.0.0 -m "merge: release 1.0.0"
  git tag -a v1.0.0 -m "release: v1.0.0"
  git push origin main --tags
  ```

### Hotfix Branch
- **Purpose**: Quick fixes for production bugs
- **Naming**: `hotfix/<version>`
- **Workflow**:
  ```bash
  git checkout -b hotfix/1.0.1 main
  # fix bug
  git commit -m "fix: critical bug"
  echo "1.0.1" > VERSION
  git commit -m "chore(release): bump version to 1.0.1"
  git checkout main
  git merge --no-ff hotfix/1.0.1 -m "merge: hotfix 1.0.1"
  git tag -a v1.0.1 -m "release: v1.0.1"
  git push origin main --tags
  ```

---

## 2. Semantic Versioning (SemVer)

Format: `vMAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes (incompatible API changes)
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

Examples:
- `v1.0.0` → `v2.0.0`: Breaking change
- `v1.0.0` → `v1.1.0`: New feature
- `v1.0.0` → `v1.0.1`: Bug fix

### Tagging
```bash
# Annotated tag (recommended)
git tag -a v1.0.0 -m "release: v1.0.0"

# List tags
git tag -n

# Show tag details
git show v1.0.0

# Push tags
git push origin --tags

# Delete tag
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
```

---

## 3. Rebase vs Merge

### When to use Rebase
- ✅ Feature branches before merging to main
- ✅ Keep history linear and clean
- ✅ Local branches that haven't been pushed
- ❌ **NEVER** rebase shared/public branches

```bash
git checkout feature/xyz
git rebase main  # reapply feature commits on top of main
```

**Pros:**
- Clean, linear history
- Easier to understand commit flow
- No merge commits

**Cons:**
- Rewrites history (dangerous for shared branches)
- Can cause conflicts during rebase

### When to use Merge
- ✅ Release/hotfix branches to main
- ✅ Preserve branch history (audit trail)
- ✅ Shared branches
- ✅ Use `--no-ff` for important merges

```bash
git merge --no-ff release/1.0.0 -m "merge: release 1.0.0"
```

**Pros:**
- Preserves complete history
- Safe for shared branches
- Shows branch structure

**Cons:**
- More merge commits
- History can be complex

---

## 4. Conflict Resolution

### When Conflicts Happen
- Same lines modified in different branches
- File deleted in one branch, modified in another
- Binary files changed in both branches

### Resolution Steps
```bash
# Attempt merge
git merge feature/xyz
# CONFLICT (content): Merge conflict in file.txt

# Check status
git status

# Open conflicted file, look for markers:
<<<<<<< HEAD
Current branch content
=======
Incoming branch content
>>>>>>> feature/xyz

# Edit file, choose correct version, remove markers

# Mark as resolved
git add file.txt

# Complete merge
git commit -m "merge: resolve conflict in file.txt"
```

### Tools
- Command line: manual editing
- GUI: VSCode, GitKraken, SourceTree
- `git mergetool`: configure external tool

---

## 5. Git Bisect (Find Bug)

### Purpose
Binary search to find commit that introduced a bug

### Workflow
```bash
# Start bisect
git bisect start

# Mark current commit as bad
git bisect bad

# Mark known good commit
git bisect good <commit-hash>

# Git checks out middle commit
# Test the commit (run tests, check manually)

# If commit is good
git bisect good

# If commit is bad
git bisect bad

# Repeat until bug commit is found

# End bisect
git bisect reset
```

### Automated Bisect
```bash
git bisect start HEAD <good-commit>
git bisect run ./test.sh  # script that returns 0 for good, 1 for bad
```

---

## 6. Best Practices

### Commit Messages
```bash
# Format: <type>(<scope>): <subject>

feat: add user authentication
fix: resolve login timeout issue
docs: update API documentation
chore: bump version to 1.0.1
test: add unit tests for auth module
refactor: simplify user service
```

### Branch Naming
- `feature/add-login`
- `feature/user-profile`
- `release/1.0.0`
- `hotfix/1.0.1`
- `bugfix/fix-timeout`

### Git Workflow Summary
1. **Feature Development**: feature branch → rebase main → merge to main
2. **Release**: release branch → merge with `--no-ff` → tag
3. **Hotfix**: hotfix branch → merge with `--no-ff` → tag
4. **Always**: pull before push, test before merge

---

## 7. Common Commands

```bash
# Branching
git branch                    # list branches
git branch -a                 # list all (including remote)
git branch -d <branch>        # delete branch
git checkout -b <branch>      # create and switch

# Merging
git merge <branch>            # merge branch
git merge --no-ff <branch>    # merge with merge commit
git merge --abort             # abort merge

# Rebasing
git rebase main               # rebase on main
git rebase --continue         # continue after conflict
git rebase --abort            # abort rebase

# Tagging
git tag -a v1.0.0 -m "msg"    # annotated tag
git tag -d v1.0.0             # delete tag
git push origin --tags        # push all tags

# History
git log --oneline --graph --all --decorate
git log --oneline -- <file>   # history for file
git show <commit>             # show commit details

# Bisect
git bisect start
git bisect bad
git bisect good <hash>
git bisect reset
```

---

## References
- Lab: `labs/03-git/`
- Result: `labs/03-git/RESULT.md`
- Tags: `v1.0.0`, `v1.0.1`
