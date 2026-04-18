# dotfiles

<p align="center">
  <img alt="zsh" src="https://img.shields.io/badge/shell-zsh-0b0f14?style=for-the-badge&logo=gnu-bash&logoColor=F7DF1E">
  <img alt="neovim" src="https://img.shields.io/badge/editor-neovim-0b0f14?style=for-the-badge&logo=neovim&logoColor=57A143">
  <img alt="tmux" src="https://img.shields.io/badge/terminal-tmux-0b0f14?style=for-the-badge&logo=tmux&logoColor=1BB91F">
  <img alt="git" src="https://img.shields.io/badge/versioned-git-0b0f14?style=for-the-badge&logo=git&logoColor=F05032">
</p>

<p align="center"><strong>Minimal config. Maximum velocity.</strong></p>
<p align="center">Fast startup, clean output, muscle-memory-first workflows.</p>

---

## neon map

```text
shell/   -> aliases, functions, startup flow
config/  -> neovim, tmux, git, gh, btop, fastfetch, uv
vendors/ -> external helper scripts
notes/   -> personal ops notes and references
```

## structure

```text
.
|- shell/
|- config/
|  |- git/
|  |- gh/
|  |- neovim/
|  |- tmux/
|  |- btop/
|  |- fastfetch/
|  `- uv/
|- vendors/
`- notes/
```

## launch sequence

```bash
git clone <your-fork-url> ~/dotfiles
```

Then link what you want into `~/.config` and your shell startup files.
Keep machine-specific values in local, untracked files.

## design contract

- speed over ceremony
- minimal over noisy
- legible over clever
- portable over host-locked

## public push safety

This repo is intended for public hosting.
Do not commit secrets, private keys, tokens, or machine-private values.

Recommended local-only ignore patterns:

```gitignore
.env
.env.*
*.pem
*.key
secrets*
```

---

## license

MIT
