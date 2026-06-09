# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal dotfiles repo for macOS (also targets Linux). There is no build, test, or
lint step — it is shell scripts and tool config files sourced/symlinked into a live
environment. "Running" a change means sourcing it into a shell and observing behavior.

## Layout

- `shell/` — zsh runtime, sourced at startup. This is the part with real logic.
- `config/<tool>/` — versioned config for individual tools (neovim, tmux, git, gh,
  btop, fastfetch, uv), symlinked into `~/.config/<tool>`.
- `vendors/` — third-party helper scripts vendored in (e.g. `fzf-git`). Don't rewrite these.
- `notes/` — personal ops notes and playbooks (not loaded by anything).

## Shell startup flow

`shell/core.zsh` is the entry point (`source ~/dotfiles/shell/core.zsh` from `~/.zshrc`).
It checks dependencies, sets env vars, and initializes tools (homebrew, zoxide, fzf, nvm,
cargo, gcloud). The other `shell/*.zsh` files (`aliases`, `functions`, `git`,
`completions`, `prompt`) are the rest of the runtime. After editing any of them, reload
with `rst` (`source ~/.zshrc`) or `exec zsh`.

Machine-specific or secret config goes in `shell/local.zsh` and `shell/secrets.env` —
both gitignored and never committed. Don't put absolute paths, host-specific SDK
locations, or credentials in the tracked `shell/*.zsh` files; that's what `local.zsh` is for.

## Key custom behavior to know before editing

- **`git` is a shell function** (`shell/git.zsh`), not the binary. It transparently
  supports a "hidden repo" layout: when you're not inside a normal git repo but a parent
  directory contains a `._repo` dir, it runs git with `--git-dir=<root>/._repo
  --work-tree=<root>`. Explicit `--git-dir`/`--work-tree` flags and normal repos bypass
  this. The bare `git ls-files`/`git` commands fail outside a shell that has sourced this
  function — that's expected, not a bug.
- **Worktree helpers** (`gwl`, `gwcd` in `shell/functions.zsh`) are the project's most
  involved code. `gwl` pretty-prints `git worktree list --porcelain` with optional
  `--disk` and `--pr` (GitHub PR lookup via `gh`) columns; `gwcd` is an fzf-driven
  worktree switcher. They parse porcelain output and assume the custom `git` function.
- **Custom commands with completions**: `tx` (LaTeX → PDF via pdflatex) and `mdpdf`
  (Markdown → PDF via pandoc/xelatex) have zsh completion functions in
  `shell/completions.zsh` wired with `compdef`. If you change a command's flags, update
  its `_<cmd>` completion in lockstep.
- Functions follow a consistent style: a header comment with Usage/Requires, `getopts`
  flag parsing, dependency checks via `command -v`, and `return 1` on error.

## Adding a new tool

Follow `notes/new-tool-playbook.md` — the canonical checklist. The core decision is
classifying every addition as: portable shell init (`shell/core.zsh`), machine-specific
(`shell/local.zsh`), versioned config (`config/<tool>/`), or ignore (auth/cache/state/
plugins — never tracked). Copy config into the repo and symlink back; never commit
secrets, tokens, logs, or runtime state.

## neovim

`config/neovim/` is a LazyVim-based config (`init.lua` bootstraps lazy.nvim, then loads
`core/` and `plugins/`). Note `NVIM_APPNAME="neovim"` is set in `core.zsh`, so it lives at
`~/.config/neovim`, not the default `~/.config/nvim`. Plugin specs are one file per plugin
under `lua/plugins/`.
