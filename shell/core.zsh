#! /bin/zsh

# Shared shell setup. Machine-specific tools belong in shell/local.zsh.
if [[ -z "${DOTFILES_DIR:-}" ]]; then
  export DOTFILES_DIR="${${(%):-%N}:A:h:h}"
fi

export EDITOR="${EDITOR:-nvim}"
export NVIM_APPNAME="neovim"
export YOLO_VERBOSE=False
export TF_CPP_MIN_LOG_LEVEL='3'
export TEXMFHOME="$DOTFILES_DIR/config/templates"
export TAP_LOG="${TAP_LOG:-$HOME/.taplog}"
export PATH="$HOME/.local/bin:$PATH"

# Homebrew uses a different prefix on Apple Silicon, Intel macOS, and Linux.
if command -v brew >/dev/null 2>&1; then
  eval "$(brew shellenv)"
  export HOMEBREW_NO_AUTO_UPDATE=1
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
    function _fzf_compgen_path() { fd --hidden --exclude .git . "$1" }
    function _fzf_compgen_dir() { fd --type=d --hidden --exclude .git . "$1" }
  elif command -v fdfind >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND="fdfind --hidden --strip-cwd-prefix --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fdfind --type=d --hidden --strip-cwd-prefix --exclude .git"
    function _fzf_compgen_path() { fdfind --hidden --exclude .git . "$1" }
    function _fzf_compgen_dir() { fdfind --type=d --hidden --exclude .git . "$1" }
  fi
fi

[[ -r "$DOTFILES_DIR/vendors/fzf-git/fzf-git.sh" ]] && source "$DOTFILES_DIR/vendors/fzf-git/fzf-git.sh"

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
