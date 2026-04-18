# dotfiles

Minimal setup. Loud workflow.

Personal shell + editor + terminal configs tuned for speed, sane defaults, and zero clutter.

## stack

- shell: zsh (`shell/`)
- editor: neovim (`config/neovim/`)
- terminal mux: tmux (`config/tmux/`)
- git + gh cli config (`config/git/`, `config/gh/`)
- extras: btop, fastfetch, uv

## layout

```text
.
|- shell/
|- config/
|  |- git/
|  |- neovim/
|  |- tmux/
|  |- gh/
|  |- btop/
|  |- fastfetch/
|  `- uv/
|- vendors/
`- notes/
```

## quick start

Clone where you want it:

```bash
git clone <your-fork-url> ~/dotfiles
```

Then link/copy what you need into `~/.config` and your shell startup files. Keep machine-specific values in local, untracked files.

## design rules

- fast over fancy
- minimal over noisy
- readable over clever
- portable paths over hardcoded machine paths

## safety

This repo is intended to be public-safe. Do not commit secrets or machine-private values.

Suggested ignores to keep local-only:

```gitignore
.env
.env.*
*.pem
*.key
secrets*
```

## license

MIT
