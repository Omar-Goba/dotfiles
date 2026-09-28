#!/usr/bin/env bash
# Bootstrap this repository on macOS and Debian-family Linux distributions.
set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly MARKER_START='# >>> dotfiles bootstrap >>>'
readonly MARKER_END='# <<< dotfiles bootstrap <<<'

DRY_RUN=0
ASSUME_YES=0
NO_PACKAGES=0
NO_TUI=0
DOCTOR=0
RESTORE_DIR=''
PROFILE_CSV=''
OS=''
PACKAGE_MANAGER=''
BACKUP_ROOT="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backups}"
BACKUP_DIR=''
declare -a PROFILES=()
declare -a PACKAGES=()
declare -a CASKS=()

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Install this dotfiles repository into the current user's home directory.

Options:
  --profile NAME[,NAME]  Select core, editor, terminal, writing, or all
  --dry-run              Show packages, links, and backups without changing anything
  --no-packages          Link configuration only
  --no-tui               Use defaults/flags without the interactive chooser
  --yes                  Do not ask for confirmation
  --doctor               Report configuration and dependency health
  --restore DIRECTORY    Restore a backup created by this installer
  -h, --help             Show this help
EOF
}

say() { printf '%s\n' "$*"; }
info() { printf '\033[38;5;141m›\033[0m %s\n' "$*"; }
ok() { printf '\033[38;5;78m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[38;5;214m!\033[0m %s\n' "$*" >&2; }
die() { printf '\033[38;5;203m✗ %s\033[0m\n' "$*" >&2; exit 1; }

run() {
  if (( DRY_RUN )); then
    printf '  [dry-run]'; printf ' %q' "$@"; printf '\n'
  else
    "$@"
  fi
}

detect_platform() {
  case "$(uname -s)" in
    Darwin) OS='macos'; PACKAGE_MANAGER='brew' ;;
    Linux)
      [[ -r /etc/debian_version ]] || die 'Only Debian-family Linux distributions are supported.'
      OS='debian'; PACKAGE_MANAGER='apt'
      ;;
    *) die "Unsupported operating system: $(uname -s)" ;;
  esac
}

has_profile() {
  local wanted=$1 profile
  for profile in "${PROFILES[@]:-}"; do [[ $profile == "$wanted" ]] && return 0; done
  return 1
}

add_profile() {
  local profile=$1
  case "$profile" in
    all) PROFILES=(core editor terminal writing) ;;
    core|editor|terminal|writing)
      has_profile "$profile" || PROFILES+=("$profile")
      ;;
    *) die "Unknown profile: $profile" ;;
  esac
}

parse_profiles() {
  local profile
  [[ -n $PROFILE_CSV ]] || return 0
  local old_ifs=$IFS
  IFS=',' read -r -a requested <<< "$PROFILE_CSV"
  IFS=$old_ifs
  for profile in "${requested[@]}"; do add_profile "$profile"; done
}

render_header() {
  printf '\n\033[1;38;5;141m'
  cat <<'EOF'
       _       _    __ _ _
    __| | ___ | |_ / _(_) | ___  ___
   / _` |/ _ \| __| |_| | |/ _ \/ __|
  | (_| | (_) | |_|  _| | |  __/\__ \
   \__,_|\___/ \__|_| |_|_|\___||___/
EOF
  printf '\033[0m  %s · %s\n\n' "$OS" "${PACKAGE_MANAGER}"
}

choose_profiles() {
  (( NO_TUI )) && return 0
  [[ -n $PROFILE_CSV ]] && return 0
  if command -v gum >/dev/null 2>&1 && [[ -t 0 ]]; then
    mapfile -t PROFILES < <(printf '%s\n' core editor terminal writing | gum choose --no-limit --header 'Select profiles (space toggles, enter confirms)')
  elif [[ -t 0 ]]; then
    PROFILES=(core editor terminal)
    local choice profile
    while true; do
      printf '\n\033[1;38;5;141m  Configure your setup\033[0m\n'
      for profile in core editor terminal writing; do
        if has_profile "$profile"; then
          printf '  \033[38;5;78m[x]\033[0m %-8s' "$profile"
        else
          printf '  \033[38;5;245m[ ]\033[0m %-8s' "$profile"
        fi
        case "$profile" in
          core) say ' shell, Git, fuzzy search, navigation' ;;
          editor) say ' Neovim' ;;
          terminal) say ' tmux and terminal tools' ;;
          writing) say ' Pandoc and XeLaTeX' ;;
        esac
      done
      read -r -p 'Toggle [c/e/t/w], [a]ll, or [enter] to continue: ' choice
      case "$choice" in
        '') break ;;
        a|A) PROFILES=(core editor terminal writing) ;;
        c|C) profile=core ;;
        e|E) profile=editor ;;
        t|T) profile=terminal ;;
        w|W) profile=writing ;;
        *) warn 'Choose c, e, t, w, a, or Enter.'; continue ;;
      esac
      [[ $choice == a || $choice == A ]] && continue
      if has_profile "$profile"; then
        local -a kept=()
        local selected
        for selected in "${PROFILES[@]}"; do [[ $selected != "$profile" ]] && kept+=("$selected"); done
        PROFILES=("${kept[@]}")
      else
        PROFILES+=("$profile")
      fi
    done
  else
    PROFILES=(core editor terminal)
  fi
  ((${#PROFILES[@]})) || die 'Choose at least one profile.'
}

collect_packages() {
  PACKAGES=()
  CASKS=()
  if [[ $OS == macos ]]; then
    if has_profile core; then PACKAGES+=(git zsh fzf fd ripgrep zoxide eza); fi
    if has_profile editor; then PACKAGES+=(neovim); fi
    if has_profile terminal; then PACKAGES+=(tmux gh btop fastfetch uv); fi
    if has_profile writing; then PACKAGES+=(pandoc); CASKS+=(mactex-no-gui); fi
  else
    if has_profile core; then PACKAGES+=(git zsh curl ca-certificates fzf fd-find ripgrep); fi
    if has_profile editor; then PACKAGES+=(neovim); fi
    if has_profile terminal; then PACKAGES+=(tmux btop); fi
    if has_profile writing; then PACKAGES+=(pandoc texlive-xetex); fi
  fi
}

ensure_brew() {
  command -v brew >/dev/null 2>&1 && return
  if (( DRY_RUN )); then
    info 'Would install Homebrew from https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'
    return
  fi
  command -v curl >/dev/null 2>&1 || die 'curl is required to bootstrap Homebrew.'
  info 'Installing Homebrew from its official installer'
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    die 'Homebrew installed but was not found in a supported prefix. Open a new shell and rerun the installer.'
  fi
}

install_packages() {
  (( NO_PACKAGES )) && return
  ((${#PACKAGES[@]})) || return
  if [[ $PACKAGE_MANAGER == brew ]]; then
    ensure_brew
    info "Installing ${#PACKAGES[@]} Homebrew formula(s)"
    run brew install "${PACKAGES[@]}"
    if ((${#CASKS[@]})); then
      info "Installing ${#CASKS[@]} Homebrew cask(s)"
      run brew install --cask "${CASKS[@]}"
    fi
  else
    command -v apt-get >/dev/null 2>&1 || die 'apt-get is required on this system.'
    info "Installing ${#PACKAGES[@]} apt package(s)"
    run sudo apt-get update
    run sudo apt-get install -y "${PACKAGES[@]}"
  fi
}

relative_home_path() {
  local path=$1
  printf '%s' "${path#"$HOME"/}"
}

backup_target() {
  local target=$1 relative
  [[ -e $target || -L $target ]] || return 0
  relative=$(relative_home_path "$target")
  if [[ -z $BACKUP_DIR ]]; then
    BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%dT%H%M%S)"
    local suffix=1
    while [[ -e $BACKUP_DIR ]]; do
      BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%dT%H%M%S)-$suffix"
      ((suffix++))
    done
  fi
  info "Backing up $target"
  run mkdir -p "$BACKUP_DIR/$(dirname "$relative")"
  run mv "$target" "$BACKUP_DIR/$relative"
}

link_target() {
  local source=$1 target=$2
  [[ -e $source || -L $source ]] || die "Repository source is missing: $source"
  if [[ -L $target && $(readlink "$target") == "$source" ]]; then
    ok "Linked: $target"
    return
  fi
  backup_target "$target"
  info "Linking $target → $source"
  run mkdir -p "$(dirname "$target")"
  run ln -s "$source" "$target"
}

write_zshrc() {
  local zshrc="$HOME/.zshrc" temporary
  local block
  block=$(cat <<EOF
$MARKER_START
export DOTFILES_DIR="$SCRIPT_DIR"
source "\$DOTFILES_DIR/shell/core.zsh"
source "\$DOTFILES_DIR/shell/git.zsh"
source "\$DOTFILES_DIR/shell/functions.zsh"
source "\$DOTFILES_DIR/shell/hoists.zsh"
source "\$DOTFILES_DIR/shell/completions.zsh"
source "\$DOTFILES_DIR/shell/aliases.zsh"
source "\$DOTFILES_DIR/shell/prompt.zsh"
[[ -r "\$DOTFILES_DIR/shell/local.zsh" ]] && source "\$DOTFILES_DIR/shell/local.zsh"
[[ -r "\$DOTFILES_DIR/shell/secrets.env" ]] && source "\$DOTFILES_DIR/shell/secrets.env"
$MARKER_END
EOF
)
  if [[ -f $zshrc ]] && grep -Fqx "$MARKER_START" "$zshrc"; then
    temporary=$(mktemp)
    awk -v start="$MARKER_START" -v end="$MARKER_END" '
      $0 == start { skip=1; next }
      $0 == end { skip=0; next }
      !skip { print }
    ' "$zshrc" > "$temporary"
    if (( DRY_RUN )); then
      info "Updating managed block in $zshrc"
      rm -f "$temporary"
    else
      printf '\n%s\n' "$block" >> "$temporary"
      mv "$temporary" "$zshrc"
    fi
  else
    info "Adding managed shell block to $zshrc"
    if (( ! DRY_RUN )); then printf '\n%s\n' "$block" >> "$zshrc"; fi
  fi
}

activate_configs() {
  link_target "$SCRIPT_DIR/config/btop" "$HOME/.config/btop"
  link_target "$SCRIPT_DIR/config/fastfetch" "$HOME/.config/fastfetch"
  link_target "$SCRIPT_DIR/config/gh" "$HOME/.config/gh"
  link_target "$SCRIPT_DIR/config/git" "$HOME/.config/git"
  link_target "$SCRIPT_DIR/config/neovim" "$HOME/.config/neovim"
  link_target "$SCRIPT_DIR/config/tmux" "$HOME/.config/tmux"
  write_zshrc
}

show_link_plan() {
  local target
  local -a targets=(
    "$HOME/.config/btop"
    "$HOME/.config/fastfetch"
    "$HOME/.config/gh"
    "$HOME/.config/git"
    "$HOME/.config/neovim"
    "$HOME/.config/tmux"
  )
  for target in "${targets[@]}"; do
    if [[ -L $target && $(readlink "$target") == "$SCRIPT_DIR/config/${target##*/}" ]]; then
      say "  keep link: $target"
    elif [[ -e $target || -L $target ]]; then
      say "  backup then link: $target"
    else
      say "  link: $target"
    fi
  done
  if [[ -f $HOME/.zshrc ]] && grep -Fqx "$MARKER_START" "$HOME/.zshrc"; then
    say '  update managed block: ~/.zshrc'
  else
    say '  append managed block: ~/.zshrc'
  fi
}

show_package_plan() {
  (( NO_PACKAGES )) && { say 'Packages: skipped'; return; }
  if [[ $OS == macos ]] && ! command -v brew >/dev/null 2>&1; then
    say 'Package manager: bootstrap Homebrew from its official installer'
  else
    say "Package manager: $PACKAGE_MANAGER"
  fi
  say "Formulae/packages: ${PACKAGES[*]}"
  if ((${#CASKS[@]})); then say "Casks: ${CASKS[*]}"; fi
}

doctor() {
  local failed=0 command
  say 'dotfiles doctor'
  for command in zsh git fzf rg; do
    if command -v "$command" >/dev/null 2>&1; then ok "$command: $(command -v "$command")"; else warn "$command is missing"; failed=1; fi
  done
  if command -v nvim >/dev/null 2>&1; then
    ok "nvim: $(nvim --version | head -n 1)"
  else
    warn 'nvim is missing; choose the editor profile to install it'
  fi
  if [[ $OS == debian ]] && ! command -v fd >/dev/null 2>&1 && ! command -v fdfind >/dev/null 2>&1; then
    warn 'fd/fdfind is missing'; failed=1
  fi
  for config in btop fastfetch gh git neovim tmux; do
    if [[ -L "$HOME/.config/$config" ]]; then ok "config/$config linked"; else warn "config/$config is not linked"; failed=1; fi
  done
  [[ -f $HOME/.zshrc ]] && grep -Fqx "$MARKER_START" "$HOME/.zshrc" && ok '.zshrc managed block present' || { warn '.zshrc managed block missing'; failed=1; }
  return "$failed"
}

restore() {
  local source=$1 relative target
  local -a managed_paths=(.zshrc .config/btop .config/fastfetch .config/gh .config/git .config/neovim .config/tmux)
  [[ -d $source ]] || die "Backup directory does not exist: $source"
  info "Restoring backup from $source"
  for relative in "${managed_paths[@]}"; do
    local item="$source/$relative"
    [[ -e $item || -L $item ]] || continue
    target="$HOME/$relative"
    [[ -e $target || -L $target ]] && backup_target "$target"
    info "Restoring $target"
    run mkdir -p "$(dirname "$target")"
    run mv "$item" "$target"
  done
}

show_restore_plan() {
  local source=$1 relative
  local -a managed_paths=(.zshrc .config/btop .config/fastfetch .config/gh .config/git .config/neovim .config/tmux)
  [[ -d $source ]] || die "Backup directory does not exist: $source"
  say "Restore from: $source"
  for relative in "${managed_paths[@]}"; do
    [[ -e $source/$relative || -L $source/$relative ]] && say "  restore: ~/$relative"
  done
}

confirm() {
  (( ASSUME_YES || DRY_RUN )) && return
  if command -v gum >/dev/null 2>&1 && [[ -t 0 ]]; then
    gum confirm 'Apply this plan?' || exit 0
  elif [[ -t 0 ]]; then
    read -r -p 'Apply this plan? [y/N] ' answer
    [[ $answer =~ ^[Yy]([Ee][Ss])?$ ]] || exit 0
  else
    die 'Non-interactive execution requires --yes.'
  fi
}

parse_args() {
  while (($#)); do
    case "$1" in
      --profile) PROFILE_CSV=${2:?--profile needs a value}; shift 2 ;;
      --dry-run) DRY_RUN=1; shift ;;
      --no-packages) NO_PACKAGES=1; shift ;;
      --no-tui) NO_TUI=1; shift ;;
      --yes) ASSUME_YES=1; shift ;;
      --doctor) DOCTOR=1; shift ;;
      --restore) RESTORE_DIR=${2:?--restore needs a directory}; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "Unknown option: $1" ;;
    esac
  done
}

main() {
  parse_args "$@"
  detect_platform
  if (( DOCTOR )); then doctor; return; fi
  if [[ -n $RESTORE_DIR ]]; then show_restore_plan "$RESTORE_DIR"; confirm; restore "$RESTORE_DIR"; return; fi
  parse_profiles
  render_header
  choose_profiles
  collect_packages
  say "Profiles: ${PROFILES[*]}"
  show_package_plan
  say 'Configuration plan:'
  show_link_plan
  (( DRY_RUN )) && say 'Mode: dry run'
  confirm
  install_packages
  activate_configs
  if (( ! DRY_RUN )); then
    say
    ok 'Installed. Start a new shell with: exec zsh'
    [[ -n $BACKUP_DIR ]] && info "Backups: $BACKUP_DIR"
    doctor || true
  fi
}

main "$@"
