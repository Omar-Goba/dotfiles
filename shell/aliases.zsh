#! /bin/zsh

### listing aliases ###
alias ls="/bin/ls" # old ls command remains
alias l="advanced_ls" # use advanced_ls for listing directories
alias ll="eza -l -T --level=2 --no-user --time-style=iso --no-filesize -s type" # skip advanced_ls but keeps same style
alias ld="eza -lD" # list directories only
alias lf="eza -lf" # list files only
alias la="eza -la" # list all files including hidden ones

### Miscellaneous aliases ###
alias rst="source ~/.zshrc"
alias clr="clear && l"
alias Pwd="pwd | pbcopy"
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -I"
alias src="source"

### Navigation shortcuts ###
alias /="cd / && l"
alias ..="cd .. && l"
alias ...="cd ../.. && l"

### Git shortcuts ###
alias g="git"
alias gs="git status --short"
alias gd="git diff --output-indicator-new=' ' --output-indicator-old=' '"
alias ga="git add -A"
alias gc="git commit"
alias gl="git log --all --graph --pretty=format:'%C(magenta)%h %C(white) %an %ar%C(auto) %D%n%s%n'"
alias gb="git branch"
alias gco="git checkout"
alias gP="git push"
alias gp="git pull"
alias gi="git init"
alias gcl="git clone"
alias gw="git worktree"
alias lg="lazygit" # Use lazygit for a more interactive git experience

### Github shortcuts ###
alias ghp="gh pr"
alias ghls="gh pr list"
alias ghpv="gh pr view"

# Docker shortcuts
alias d='docker'
alias dps='docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | GREP_COLORS="ms=01;34" grep -E --color=always "^|CONTAINER ID|NAMES|IMAGE|STATUS|PORTS" | less -R'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs'
alias drm='docker rm -f'
alias drmi='docker rmi'

# Docker compose shortcuts
alias dc='docker compose'
alias dcup='docker compose up -d'
alias dcdown='docker compose down'
alias dcl='docker compose logs -f'

# Vim and editor shortcuts
alias n="nvim"

# Other aliases (python, aux commands, etc.)
alias py="python3 -q"
alias fast="speedtest-cli --secure"
alias shit="cmatrix -u 9"

