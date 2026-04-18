#! /bin/zsh

############################
### ~~~ DEPENDENCIES ~~~ ###
############################

# Check that required commands are installed to avoid runtime errors.
command -v zoxide >/dev/null  || echo "zoxide is not installed! Install with `brew install zoxide`"
command -v eza >/dev/null     || echo "eza is not installed! Install with `brew install eza`"
command -v fzf >/dev/null     || echo "fzf is not installed! Install with `brew install fzf`"
command -v fd >/dev/null      || echo "fd is not installed! Install with `brew install fd`"
command -v pandoc >/dev/null  || echo "pandoc is not installed! Install with `brew install pandoc`"
command -v xelatex >/dev/null || echo "xelatex is not installed! Install with `brew install --cask mactex-no-gui`"

#########################
### ~~~ VARIABLES ~~~ ###
#########################

eval "$(/opt/homebrew/bin/brew shellenv)" # homebrew
export EDITOR="nvim" # neovim
export NVIM_APPNAME="neovim" # neovim
export HOMEBREW_NO_AUTO_UPDATE=1 # homebrew
export YOLO_VERBOSE=False # CV yolo model
export TF_CPP_MIN_LOG_LEVEL='3' # tensorflow
export TERM="tmux-256color" # tmux color support
export PATH="$PATH:$HOME/.local/bin" # pipx
eval "$(zoxide init --cmd cd zsh)" # zoxide

##########################
### ~~~ TOOL SETUP ~~~ ###
##########################

### nvm ###
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

### fzf ###
eval "$(fzf --zsh)"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
function _fzf_compgen_path() {fd --hidden --exclude .git . "$1"}
function _fzf_compgen_dir() {fd --type=d --hidden --exclude .git . "$1"}
source "$HOME/dotfiles/vendors/fzf-git/fzf-git.sh"

### cargo ###
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

### gcp ###
source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"

