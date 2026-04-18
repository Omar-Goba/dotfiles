# New Tool Playbook

A quick, repeatable process for adding a new tool to my dotfiles without turning the repo back into a mess.

---

## Core rule

Every new tool must be classified before I add anything.

A tool belongs to one or more of these buckets:

- **Shell core**: portable shell setup I want on every machine
- **Shell local**: machine-specific, private, or path-sensitive setup
- **Repo config**: real config files I want versioned
- **Ignore**: cache, runtime state, logs, plugins, auth, generated files

Never skip classification.

---

## Step-by-step workflow

## 1. Install the tool normally

Install it using the normal method first.

Examples:

- `brew install ...`
- language package manager
- manual install

Do **not** touch dotfiles yet.

---

## 2. Run the tool once

Launch it once so it creates its default files and folders.

This reveals:

- config
- runtime state
- cache
- auth files
- plugin directories

Do not guess before seeing what it actually creates.

---

## 3. Discover what it created

Check common places:

- `~/.config/<tool>`
- `~/.<tool>`
- `~/.local/share/...`
- `~/.cache/...`

Inspect what is:

- real config
- machine state
- session state
- logs
- credentials
- plugin installs

---

## 4. Classify the tool

### Put it in `shell/core.zsh` if:

it adds portable shell setup I want everywhere.

Examples:

- `PATH` additions
- shell completions
- `eval "$(tool init zsh)"`
- shared environment variables

### Put it in `shell/local.zsh` if:

it is machine-specific, private, or path-sensitive.

Examples:

- absolute paths
- work-only setup
- host-specific SDK locations
- local aliases
- credentials or secret-adjacent values

### Put it in `config/<tool>/` if:

it creates meaningful config under `~/.config/<tool>` that I want versioned.

### Do **not** put it in git if it is:

- auth
- tokens
- secrets
- logs
- caches
- plugin install directories
- runtime state
- generated files
- session dumps

---

## 5. Copy config into the repo

If the tool has real config, copy it first.

For a whole config directory:

```bash
mkdir -p ~/dotfiles/config
cp -R ~/.config/<tool> ~/dotfiles/config/
```

For a single file:

```bash
mkdir -p ~/dotfiles/config/<tool>
cp ~/.config/<tool>/<file> ~/dotfiles/config/<tool>/
```

> Copy first. Do not move yet.

---

## 6. Back up the live config

Before linking anything:

```bash
mv ~/.config/<tool> ~/.config/<tool>.bak
```

For a single file:

```bash
mv ~/.config/<tool>/<file> ~/.config/<tool>/<file>.bak
```

---

## 7. Symlink the repo-owned config back

For a directory:

```bash
ln -sfn ~/dotfiles/config/<tool> ~/.config/<tool>
```

For a file:

```bash
ln -sfn ~/dotfiles/config/<tool>/<file> ~/.config/<tool>/<file>
```

---

## 8. Test immediately

Open the tool and verify:

- it launches
- config loads
- no missing file warnings
- no broken plugin references
- no auth breakage
- no weird path assumptions

If it breaks, roll back immediately:

```bash
rm ~/.config/<tool>
mv ~/.config/<tool>.bak ~/.config/<tool>
```

---

## 9. Add shell integration only after config works

If the tool needs shell init, add it to the correct place.

Example for shell/core.zsh

```bash
command -v <tool> >/dev/null 2>&1 && eval "$(<tool> init zsh)"
```

Example for shell/local.zsh

```bash
export <TOOL>\_HOME="$HOME/some/local/path"
```

Rule:

- portable -> core.zsh
- machine-specific -> local.zsh

---

## 10. Update .gitignore if needed

If the tool creates runtime junk inside a repo-owned path, ignore it.

Examples:

```bash
config/<tool>/logs/
config/<tool>/cache/
config/<tool>/state/
config/<tool>/plugins/
```

Also keep secrets ignored.

---

## 11. Commit only when stable

Once:

- config works
- symlink works
- shell init works
- no secrets are tracked
- repo tree still makes sense

Commit it:

```bash
cd ~/dotfiles
git add config/<tool> shell .gitignore
git commit -m "Add <tool> configuration"
```

---

## Decision cheat sheet

If the tool adds shell init

- shell/core.zsh if portable
- shell/local.zsh if machine-specific

If the tool creates ~/.config/<tool>

- copy into config/<tool>/

If it only creates state/auth/cache

- do not version it

If it uses plugins:

- usually version the config
- do not version installed plugins unless intentional
- let plugin managers own plugin directories
- ignore plugin/runtime dirs if necessary

---

## Safe default policy

When unsure:

1. copy config
2. back up live config
3. symlink repo config
4. test
5. commit only after stability

Never track:

- secrets
- tokens
- auth files
- local runtime junk

---

## Minimal reusable checklist

1. Install tool
2. Run tool once
3. Find config path
4. Classify: core / local / repo / ignore
5. Copy config into `~/dotfiles/config/<tool>`
6. Back up live config
7. Symlink repo config back
8. Test tool
9. Add shell init if needed
10. Update .gitignore
11. Commit

---

## Final sanity question

Before I add any new tool, ask:

> Am I trying to version actual configuration, or am I accidentally versioning runtime garbage?

If the answer is unclear, inspect first and only then integrate.
