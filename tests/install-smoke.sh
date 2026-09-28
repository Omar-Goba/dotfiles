#!/usr/bin/env bash
# Run installer behavior checks without touching the caller's home directory.
set -Eeuo pipefail

readonly ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly TEST_HOME="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-smoke.XXXXXX")"
trap '/bin/rm -rf "$TEST_HOME"' EXIT

mkdir -p "$TEST_HOME/.config/git"
printf 'preexisting git config\n' > "$TEST_HOME/.config/git/config"
printf 'export PRESERVE_ME=1\n' > "$TEST_HOME/.zshrc"

HOME="$TEST_HOME" DOTFILES_BACKUP_DIR="$TEST_HOME/backups" "$ROOT/install.sh" --no-packages --no-tui --yes --profile core,editor >/dev/null

[[ -L "$TEST_HOME/.config/git" ]]
grep -Fqx 'export PRESERVE_ME=1' "$TEST_HOME/.zshrc"
[[ $(grep -Fxc '# >>> dotfiles bootstrap >>>' "$TEST_HOME/.zshrc") == 1 ]]

HOME="$TEST_HOME" DOTFILES_BACKUP_DIR="$TEST_HOME/backups" "$ROOT/install.sh" --no-packages --no-tui --yes --profile core,editor >/dev/null
[[ $(grep -Fxc '# >>> dotfiles bootstrap >>>' "$TEST_HOME/.zshrc") == 1 ]]

backup=$(find "$TEST_HOME/backups" -mindepth 1 -maxdepth 1 -type d -print -quit)
HOME="$TEST_HOME" DOTFILES_BACKUP_DIR="$TEST_HOME/backups" "$ROOT/install.sh" --restore "$backup" --yes --no-tui >/dev/null
grep -Fqx 'preexisting git config' "$TEST_HOME/.config/git/config"

printf 'installer smoke test passed\n'
