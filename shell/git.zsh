#! /bin/zsh

## git [args...] ##
# Git wrapper that supports both standard repositories and a hidden
# repository layout using `._repo` as the git dir.
#
# Behavior:
# - If `--git-dir` or `--work-tree` is passed explicitly, forwards to git unchanged.
# - If the current directory is inside a normal Git repository, forwards to git unchanged.
# - Otherwise, if a parent directory contains `._repo`, uses that as the git dir
#   and the parent as the work tree.
# - Falls back to normal git behavior when no repository is found.
function _find_git_root() {
  local dir="${PWD:A}"
  while [[ "$dir" != "/" ]]; do
    [[ -e "$dir/.git" ]] && return 0
    dir="${dir:h}"
  done
  [[ -e "/.git" ]]
}
function _find_dot_repo_root() {
  local dir="${PWD:A}"
  while [[ "$dir" != "/" ]]; do
    if [[ -e "$dir/._repo" ]]; then
      print -r -- "$dir"
      return 0
    fi
    dir="${dir:h}"
  done
  [[ -e "/._repo" ]] && { print -r -- "/"; return 0; }
  return 1
}
function git() {
  local repo_root

  # respect explicit manual git-dir/work-tree
  case " $* " in
    *" --git-dir "*|*" --work-tree "*|*" --git-dir="*|*" --work-tree="*)
      command git "$@"
      return $?
      ;;
  esac

  # if we're inside a normal repo/worktree, let git handle it
  if _find_git_root; then
    command git "$@"
    return $?
  fi

  # fallback to hidden repo layout
  if repo_root="$(_find_dot_repo_root)"; then
    command git --git-dir="$repo_root/._repo" --work-tree="$repo_root" "$@"
  else
    command git "$@"
  fi
}

# Git completions for the wrappers.
if whence compdef >/dev/null 2>&1; then
  compdef _git git
  compdef _git g
fi


