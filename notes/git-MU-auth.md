# GitHub Multi-Account SSH Setup (Quick Fix)

When git clone or git push fails because the wrong GitHub account is used.

---

## 1. Check which account SSH is using

```bash
ssh -T git@github.com
```

Example output:

```text
Hi Omar-Goba! You've successfully authenticated...
```

If this is not the account that should access the repo, SSH is using the wrong key.

---

## 2. Check SSH config

```bash
cat ~/.ssh/config
```

Example:

```text
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github-stuff/id_ed25519_personal
  IdentitiesOnly yes

Host github-work
  HostName github.com
  User git
  IdentityFile ~/.ssh/github-stuff/id_ed25519_work
  IdentitiesOnly yes
```

Meaning: - github.com -> personal account - github-work -> work account

---

## 3. Clone using the correct host alias

Instead of:

```bash
git clone git@github.com:org/repo.git
```

Use:

```bash
git clone git@github-work:org/repo.git
```

---

## 4. Fix an existing repo

Check remote:

```bash
git remote -v
```

Change it:

```bash
git remote set-url origin git@github-work:org/repo.git
```

---

## 5. Test the alias

```bash
ssh -T git@github-work
```

Expected:

```text
Hi goba-TLM! You've successfully authenticated...
```

---

## 6. List loaded SSH keys

```bash
ssh-add -l
```

Clear and reload if needed:

```bash
ssh-add -D
ssh-add ~/.ssh/github-stuff/id_ed25519_work
```

---

## Mental Model

```text
gh auth login  -> HTTPS auth
ssh config     -> SSH auth
git@github.com -> uses default key
git@github-work -> uses work key
```

If cloning fails but gh auth status looks correct, the issue is almost always SSH key selection, not GitHub login.
