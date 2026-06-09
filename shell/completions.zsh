#! /bin/zsh

[[ -n "$ZSH_VERSION" ]] || return
autoload -Uz compdef 2>/dev/null || return

function _tx() {
  _arguments \
    '-v[open generated PDF]' \
    '-b[run bibtex]' \
    '-c[clean auxiliary files recursively]' \
    '1:TeX file:_files -g "*.tex"'
}

function _mdpdf() {
  _arguments \
    '-v[open generated PDF]' \
    '1:Markdown file:_files -g "*.(md|markdown)"' \
    '2:output PDF name: '
}

compdef _tx tx
compdef _mdpdf mdpdf
