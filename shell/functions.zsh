#! /bin/zsh

## Listing Functions ##
# Lists directory contents using eza.
# Optionally prints debugging information when the -d flag is used.
# Usage: advanced_ls [-d] [directory]
# If a directory is not specified, the current directory is used.
# Requires: eza, tput
# Debug Mode:
#   - Enabled with the -d flag.
#   - In debug mode, more ignored patterns are used, and additional
#     diagnostic output is printed.
function advanced_ls() {
    local debug=0
    local OPTIND
    
    # Parse options
    while getopts "d" opt; do
        case "$opt" in
            d) debug=1 ;;
            *) echo "Usage: advanced_ls [-d] [directory]" && return 1 ;;
        esac
    done
    shift $((OPTIND - 1))
    
    local c_dir ignored n_dirs n_lines prompt_lines
    
    # Use provided directory or default to current working directory.
    c_dir="${1:-$(pwd)}"
    
    # Validate that c_dir is a directory.
    if [[ ! -d "$c_dir" ]]; then
        echo "Error: '$c_dir' is not a valid directory."
        return 1
    fi
    
    # Check for required commands.
    if ! command -v eza >/dev/null 2>&1; then
        echo "Error: eza is not installed."
        return 1
    fi
    if ! command -v tput >/dev/null 2>&1; then
        echo "Error: tput command is required."
        return 1
    fi
    
    # Set ignored patterns; include extra patterns in debug mode.
    if [[ "$debug" -eq 1 ]]; then
        ignored="__pycache__|bin|lib|share|pyvenv.cfg"
    else
        ignored="__pycache__|share|pyvenv.cfg"
    fi
    
    # Count entries using eza.
    n_dirs=$(eza -l -T --level=2 --no-user --time-style=iso --no-filesize -s type -I="$ignored" "$c_dir" | wc -l)
    
    # Get terminal height and subtract estimated prompt lines.
    n_lines=$(tput lines)
    prompt_lines=$(echo "${PS1:-1}" | wc -l)
    (( n_lines = n_lines - prompt_lines ))
    
    # Choose tree view if there is enough room, otherwise use standard view.
    if [ "$n_dirs" -lt "$n_lines" ]; then
        eza -l -T --level=2 --no-user --time-style=iso --no-filesize -s type -I="$ignored" "$c_dir"
    else
        eza -l --no-user --time-style=iso --no-filesize -s type -I="$ignored" "$c_dir"
    fi
    
    # If in debug mode, output additional diagnostic information.
    if [ "$debug" -eq 1 ]; then
        echo "n_dirs: $n_dirs, available lines (after prompt): $n_lines, prompt lines: $prompt_lines, directory: $c_dir"
    fi
}

## File Management Functions ##

# dp: Create a backup copy of a file or directory as `<path>.bak`.
# Usage: dp <path>
function dp() {
  local src dest cp_args

  if [[ "$#" -ne 1 ]]; then
    echo "Usage: dp <path>"
    return 1
  fi

  src="$1"
  dest="${src}.bak"

  if [[ -f "$src" ]]; then
    cp_args=()
  elif [[ -d "$src" ]]; then
    cp_args=(-r)
  else
    echo "Error: '$src' is not a valid file or directory."
    return 1
  fi

  if cp "${cp_args[@]}" -- "$src" "$dest"; then
    echo "Backup created: '$dest'"
  else
    echo "Error: Failed to create backup for '$src'."
    return 1
  fi
}

# swp: Swap the contents (or filenames) of two files.
# Usage: swp <file1> <file2>
function swp() {
  if [ "$#" -ne 2 ]; then
      echo "Usage: swp <file1> <file2>"
      return 1
  fi
  if [ ! -e "$1" ]; then
      echo "Error: '$1' does not exist."
      return 1
  fi
  if [ ! -e "$2" ]; then
      echo "Error: '$2' does not exist."
      return 1
  fi
  local temp="${1}~~~"
  if mv "$1" "$temp" && mv "$2" "$1" && mv "$temp" "$2"; then
      echo "Swapped '$1' and '$2'."
  else
      echo "Error: Swap operation failed."
      return 1
  fi
}

# Copies the contents of a specified file to the clipboard using pbcopy.
# Usage: copy2cb <filename>
# Note: This function requires pbcopy, which is available on macOS.
function copy2cb() {
    local file="$1"
    # Check if pbcopy is available
    if ! command -v pbcopy >/dev/null; then
        echo "Error: pbcopy command not found. This function is intended for macOS."
        return 1
    fi
    # Check if a filename was provided
    if [[ -z "$file" ]]; then
        echo "Usage: copy2cb <filename>"
        return 1
    fi
    # Check if the file exists and is a regular file
    if [[ ! -f "$file" ]]; then
        echo "Error: '$file' is not a valid file."
        return 1
    fi
    # Check if the file is readable
    if [[ ! -r "$file" ]]; then
        echo "Error: '$file' is not readable."
        return 1
    fi
    # Copy the file contents to the clipboard and check for success
    if pbcopy < "$file"; then
        echo "Copied contents of '$file' to clipboard."
    else
        echo "Error: Failed to copy contents of '$file' to clipboard."
        return 1
    fi
}

## navigation functions ##
# c: Change directory and list its contents using advanced_ls.
# Usage: c <directory>
function c() {
    if cd "$@"; then
        advanced_ls
    else
        echo "Error: Failed to change directory to '$@'."
        return 1
    fi
}

## Additional Functions (latex, etc.)

# Requires: pdflatex, optionally bibtex and open (macOS).
# Compile a LaTeX file using pdflatex and optionally open the resulting PDF.
# If a ./pdfs directory exists, output goes there; otherwise it stays in the current directory.
# Usage: txp [-v] [-b] [-c] <filename>
# -v: Verbose mode; opens the PDF after successful compilation.
# -b: Run bibtex after the first pdflatex pass.
# -c: Clean auxiliary files recursively (e.g., .aux, .log, .out, .bbl, .blg).
#
# Requires: pdflatex, find, optionally bibtex and open (macOS).
function txp() {
  local verbose=0
  local run_bibtex=0
  local recursive_clean=0
  local tex_file
  local pdf_file
  local out_dir="."
  local base_name

  # Parse options.
  while getopts "vbc" opt; do
    case "$opt" in
      v) verbose=1 ;;
      b) run_bibtex=1 ;;
      c) recursive_clean=1 ;; # Handle the new -c flag
      *) echo "Usage: txp [-v] [-b] [-c] <filename>" && return 1 ;;
    esac
  done
  shift $((OPTIND - 1))

  # Check if a filename was provided.
  if [[ -z "$1" ]]; then
    echo "Error: No file specified."
    echo "Usage: txp [-v] [-b] [-c] <filename>"
    return 1
  fi
  tex_file="$1"
  base_name="${tex_file##*/}"
  base_name="${base_name%.tex}"

  # Match mdp output behavior.
  [[ -d "pdfs" ]] && out_dir="pdfs"
  pdf_file="${out_dir}/${base_name}.pdf"

  # Check if the file exists and is readable.
  if [[ ! -f "$tex_file" || ! -r "$tex_file" ]]; then
    echo "Error: '$tex_file' is not a valid or readable file."
    return 1
  fi

  # Check if pdflatex is installed.
  if ! command -v pdflatex >/dev/null 2>&1; then
    echo "Error: pdflatex is not installed."
    return 1
  fi

  # First pdflatex pass.
  if ! pdflatex -interaction=nonstopmode -output-directory="$out_dir" "$tex_file"; then
    echo "Error: Failed to compile '$tex_file' with pdflatex."
    return 1
  fi

  # Run bibtex if requested.
  if [[ $run_bibtex -eq 1 ]]; then
    local aux_file="${out_dir}/${base_name}.aux"
    if [[ ! -f "$aux_file" ]]; then
      echo "Error: AUX file ('$aux_file') not found; cannot run bibtex."
      # Optionally, you might want to proceed without bibtex or make this a softer warning.
      # For now, maintaining original strictness.
      # return 1 # Or just warn and continue
    else
      if ! command -v bibtex >/dev/null 2>&1; then
        echo "Error: bibtex is not installed."
        return 1 # Bibtex requested but not found
      fi
      echo "Running bibtex on ${out_dir}/${base_name}..."
      if ! bibtex "${out_dir}/${base_name}"; then
        echo "Error: bibtex command failed."
        # Decide if this is a fatal error for the script
        # return 1
      fi
      # Recompile twice after bibtex to resolve references.
      echo "Recompiling with pdflatex (1st pass after bibtex)..."
      if ! pdflatex -interaction=nonstopmode -output-directory="$out_dir" "$tex_file"; then
        echo "Error: Failed to compile '$tex_file' (1st pass after bibtex)."
        return 1
      fi
      echo "Recompiling with pdflatex (2nd pass after bibtex)..."
      if ! pdflatex -interaction=nonstopmode -output-directory="$out_dir" "$tex_file"; then
        echo "Error: Failed to compile '$tex_file' (2nd pass after bibtex)."
        return 1
      fi
    fi
  fi

  # Clean up auxiliary files.
  if [[ $recursive_clean -eq 1 ]]; then
    # Use find to delete specific file types recursively from the current directory.
    find . -type f \( \
      -name "*.aux" -o \
      -name "*.log" -o \
      -name "*.out" -o \
      -name "*.bbl" -o \
      -name "*.blg" -o \
      -name "*.toc" -o \
      -name "*.lof" -o \
      -name "*.lot" -o \
      -name "*.fls" -o \
      -name "*.fdb_latexmk" -o \
      -name "*.synctex.gz" -o \
      -name "*.nav" -o \
      -name "*.snm" \
    \) -delete
  else
    setopt localoptions nullglob # Make nullglob local to the function call if in zsh
    \rm -f *.{aux,log,out,bbl,blg,toc,lof,lot,fls,fdb_latexmk,synctex.gz,nav,snm}
    \rm -f "${out_dir}"/*.{aux,log,out,bbl,blg,toc,lof,lot,fls,fdb_latexmk,synctex.gz,nav,snm}
    unsetopt nullglob
  fi

  # Open the PDF if verbose mode is enabled and the PDF exists.
  if [[ $verbose -eq 1 ]]; then
    if [[ -f "$pdf_file" ]]; then
      if command -v open >/dev/null 2>&1; then # macOS 'open'
        open "$pdf_file"
      elif command -v xdg-open >/dev/null 2>&1; then # Linux 'xdg-open'
        xdg-open "$pdf_file"
      elif command -v evince >/dev/null 2>&1; then # Common PDF viewer on Linux
        evince "$pdf_file" &
      else
        echo "Warning: 'open' or 'xdg-open' command not found; cannot open PDF automatically."
        echo "You can find the PDF at: $pdf_file"
      fi
    else
      echo "Warning: PDF file '$pdf_file' not found. Cannot open."
    fi
  elif [[ -f "$pdf_file" ]]; then
    echo "Successfully compiled. PDF is at: $pdf_file"
  else
    echo "Compilation finished, but PDF file '$pdf_file' was not created."
  fi
}

# Requires: pandoc and xelatex, optionally open/xdg-open.
# Convert a Markdown file to PDF using pandoc.
# If a ./pdfs directory exists, output goes there; otherwise it stays in the current directory.
# If an output name is provided, it is used; otherwise the PDF uses the Markdown filename.
#
# Usage: mdp [-v] <file.md> [output-name]
# -v: Verbose mode; opens the PDF after successful compilation.
#
function mdp() {
  local verbose=0
  local md_file
  local out_name
  local out_dir="."
  local out_file
  local base_name

  # Parse options
  while getopts "v" opt; do
    case "$opt" in
      v) verbose=1 ;;
      *) echo "Usage: mdp [-v] <file.md> [output-name]" && return 1 ;;
    esac
  done
  shift $((OPTIND - 1))

  # Check args
  if [[ -z "$1" ]]; then
    echo "Error: No Markdown file specified."
    echo "Usage: mdp [-v] <file.md> [output-name]"
    return 1
  fi

  md_file="$1"
  out_name="$2"

  # Validate input file
  if [[ ! -f "$md_file" || ! -r "$md_file" ]]; then
    echo "Error: '$md_file' is not a valid or readable file."
    return 1
  fi

  # Check dependencies
  if ! command -v pandoc >/dev/null 2>&1; then
    echo "Error: pandoc is not installed."
    return 1
  fi

  if ! command -v xelatex >/dev/null 2>&1; then
    echo "Error: xelatex is not installed."
    return 1
  fi

  # Determine output directory
  [[ -d "pdfs" ]] && out_dir="pdfs"

  # Determine output filename
  if [[ -n "$out_name" ]]; then
    out_name="${out_name%.pdf}.pdf"
  else
    base_name="${md_file##*/}"
    out_name="${base_name%.md}.pdf"
  fi

  out_file="${out_dir}/${out_name}"

  # Run pandoc
  if ! pandoc "$md_file" --filter mermaid-filter --pdf-engine=xelatex -o "$out_file"; then
    echo "Error: Failed to convert '$md_file' to PDF."
    return 1
  fi

  # mermaid-filter always creates this file; remove it if empty
  [[ -f "mermaid-filter.err" && ! -s "mermaid-filter.err" ]] && rm "mermaid-filter.err"

  echo "Successfully created: $out_file"

  # Open PDF if -v
  if [[ $verbose -eq 1 ]]; then
    if command -v open >/dev/null 2>&1; then
      open "$out_file"
    elif command -v xdg-open >/dev/null 2>&1; then
      xdg-open "$out_file"
    else
      echo "Warning: No PDF opener found."
    fi
  fi
}

# Function: txn
# Description:
#   Bootstrap a new LaTeX note from the default template. Copies the template
#   and its companion sty file into the current directory, then opens it.
#
# Usage:
#   txn [filename]
#
# Requires: cp, $EDITOR
function txn() {
  local templates_dir="$HOME/dotfiles/config/templates/latex"
  local filename="${${1:-tmp}%.tex}.tex"

  if [[ ! -d "$templates_dir" ]]; then
    echo "Error: Templates directory '$templates_dir' not found." >&2
    return 1
  fi
  if [[ -f "$filename" ]]; then
    echo "Error: '$filename' already exists." >&2
    return 1
  fi

  cp "$templates_dir/default.tex" "$filename" || return 1
  echo "Created: $filename"
  "${EDITOR:-nvim}" "$filename"
}

# Function: mdn
# Description:
#   Bootstrap a new Markdown note from the default template. Uses a timestamp
#   as the filename if no name is given.
#
# Usage:
#   mdn [filename]
#
# Requires: cp, $EDITOR
function mdn() {
  local templates_dir="$HOME/dotfiles/config/templates/markdown"
  local filename="${${1:-$(date '+%Y%m%dT%H%M')}%.md}.md"

  if [[ ! -d "$templates_dir" ]]; then
    echo "Error: Templates directory '$templates_dir' not found." >&2
    return 1
  fi
  if [[ -f "$filename" ]]; then
    echo "Error: '$filename' already exists." >&2
    return 1
  fi

  cp "$templates_dir/default.md" "$filename" || return 1
  echo "Created: $filename"
  "${EDITOR:-nvim}" "$filename"
}

# Recursively add `.gitkeep` files to all empty folders from the current directory.
# Useful for preserving empty directories in Git repositories.
#
# Usage: gitkeep
#
# Requires: find, test, touch
function gitkeep() {
  # List of directories to exclude by name
  local exclude_dirs=("venv" "node_modules" ".venv" ".git")

  # Ensure required commands are available
  for cmd in find test touch; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "Error: Required command '$cmd' not found"
      return 1
    fi
  done

  count=0

  while IFS= read -r dir; do
    # Check if directory name is in the exclude list
    for excluded in "${exclude_dirs[@]}"; do
      if [[ "$dir" == *"/$excluded"* ]]; then
        continue 2
      fi
    done
    if touch "$dir/.gitkeep"; then
      echo "Added .gitkeep to $dir"
      ((count++))
    fi
  done < <(find . -type d)

  echo "Added .gitkeep to $count directories."
}

## Docker Functions ##
function dx() {
    docker start "$1" && docker exec -it "$1" /bin/bash
}

# Python environment activation
activ() {
    if [[ -n "$1" ]]; then
        conda activate "$1"
    else
        source env/bin/activate
    fi
}

unalias gl 2>/dev/null
function gl() {
    git log --all --graph --color=always --pretty=format:'%C(magenta)%h %C(white) %an %ar%C(auto) %D%n%s%n' | less -R +/HEAD
}

# Function: tap
# Description:
#   Records a quick terminal thought marker with tactile feedback.
#   Logs timestamp, directory, and current git branch as TSV.
#
# Usage:
#   tap
function tap() {
  local file="${TAP_LOG:-$HOME/.taplog}"
  local now dir branch count log_dir

  if [[ $# -ne 0 ]]; then
    echo "Usage: tap" >&2
    return 1
  fi

  now="$(date '+%Y-%m-%d %H:%M:%S')"
  dir="$PWD"
  branch="$(git branch --show-current 2>/dev/null)"
  log_dir="${file:h}"

  if [[ -n "$log_dir" && ! -d "$log_dir" ]]; then
    mkdir -p "$log_dir" || return 1
  fi

  if [[ -f "$file" ]]; then
    count=$(($(wc -l < "$file" | tr -d ' ') + 1))
  else
    count=1
  fi

  local label="tap #$count  $(date '+%H:%M:%S')"
  local border="${(l:$(( ${#label} + 4 ))::─:)}"

  printf '\a\n'
  printf '╭─ %s ─╮\n' "$label"
  printf '╰%s╯\n\n' "$border"

  if (( count % 10 == 0 )); then
    printf '✨ milestone tap: %s ✨\n\n' "$count"
  fi

  printf '%s\t%s\t%s\n' "$now" "$dir" "$branch" >> "$file"
}

# Function: tapstats
# Description:
#   Shows aggregate stats for taps recorded by `tap`.
#
# Usage:
#   tapstats
function tapstats() {
  local file="${TAP_LOG:-$HOME/.taplog}"

  if [[ $# -ne 0 ]]; then
    echo "Usage: tapstats" >&2
    return 1
  fi

  if [[ ! -f "$file" ]]; then
    echo "No taps yet."
    return 1
  fi

  echo
  echo "╭─ tap stats ────────────────────────╮"
  printf '│ total taps: %s\n' "$(wc -l < "$file" | tr -d ' ')"
  printf '│ first tap : %s\n' "$(awk -F'\t' 'NR == 1 { print $1; exit }' "$file")"
  printf '│ latest tap: %s\n' "$(awk -F'\t' 'END { print $1 }' "$file")"
  echo "╰────────────────────────────────────╯"

  echo
  echo "Taps by day:"
  awk -F'\t' '{ day=substr($1,1,10); count[day]++ } END { for (d in count) print d, count[d] }' "$file" |
    sort |
    while read -r day n; do
      printf '%s  %3d  %s\n' "$day" "$n" "$(printf '%*s' "$n" '' | tr ' ' '█')"
    done

  echo
  echo "Taps by hour:"
  awk -F'\t' '{ hour=substr($1,12,2); count[hour]++ } END { for (h=0; h<24; h++) { hh=sprintf("%02d", h); print hh, count[hh]+0 } }' "$file" |
    while read -r hour n; do
      printf '%s:00  %3d  %s\n' "$hour" "$n" "$(printf '%*s' "$n" '' | tr ' ' '▇')"
    done

  echo
  echo "Top directories:"
  awk -F'\t' '{ count[$2]++ } END { for (d in count) print count[d] "\t" d }' "$file" |
    sort -nr |
    head -10 |
    while IFS=$'\t' read -r n d; do
      printf '%3d  %s\n' "$n" "$d"
    done
}

function tapstat() {
  tapstats "$@"
}

function tapline() {
  tap "$@" || return 1
  printf '        thought checkpoint reached\n'
}

# Function: gwl
# Description:
#   Pretty prints `git worktree list` by parsing porcelain output.
#   Shows current marker, shortened path, branch, short HEAD, state, and
#   disk usage for each worktree.
#   Long path/branch values are truncated to keep rows on one line.
#
# Usage:
#   gwl [--plain] [--disk] [--pr]
#   --plain: disable color output for scripting/piping.
#   --disk: show per-worktree disk usage column.
#   --pr: show open GitHub PR number for each branch.
function gwl() {
  local plain=0
  local show_disk=0
  local show_pr=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --plain) plain=1 ;;
      --disk) show_disk=1 ;;
      --pr|--prs) show_pr=1 ;;
      *)
        echo "Usage: gwl [--plain] [--disk] [--pr]" >&2
        return 1
        ;;
    esac
    shift
  done

  local wt_path=""
  local wt_head=""
  local wt_branch=""
  local wt_locked=""
  local wt_prunable=""
  local current_root
  local worktree_list
  local path_w=52
  local branch_w=30
  local head_w=7
  local state_w=16
  local disk_w=8
  local pr_w=8

  if (( COLUMNS > 0 && COLUMNS < 120 )); then
    path_w=34
    branch_w=20
  fi

  current_root="$(git rev-parse --show-toplevel 2>/dev/null)" || current_root=""

  if ! worktree_list="$(git worktree list --porcelain 2>/dev/null)"; then
    echo "Error: Not inside a git repository/worktree." >&2
    return 1
  fi

  typeset -A gwl_prs

  _gwl_remote_slug() {
    local remote_url="$1"
    local remote_host=""
    local slug=""

    case "$remote_url" in
      git@github.com:*) slug="${remote_url#git@github.com:}" ;;
      https://github.com/*) slug="${remote_url#https://github.com/}" ;;
      http://github.com/*) slug="${remote_url#http://github.com/}" ;;
      git@*:*)
        remote_host="${remote_url#git@}"
        remote_host="${remote_host%%:*}"
        if [[ "$(ssh -G "$remote_host" 2>/dev/null | awk '/^hostname / { print $2; exit }')" == "github.com" ]]; then
          slug="${remote_url#git@*:}"
        fi
        ;;
    esac

    slug="${slug%.git}"
    print -r -- "$slug"
  }

  _gwl_load_prs() {
    [[ $show_pr -eq 1 ]] || return 0

    if ! command -v gh >/dev/null 2>&1; then
      echo "Error: gh is required for --pr." >&2
      return 1
    fi

    local first_path=""
    local remote_url
    local repo_slug
    local pr_rows
    local pr_line
    local pr_branch
    local pr_number

    for pr_line in ${(f)worktree_list}; do
      [[ "$pr_line" == worktree\ * ]] || continue
      first_path="${pr_line#worktree }"
      [[ "$first_path" == */._repo ]] && continue
      break
    done

    if [[ -z "$first_path" ]]; then
      echo "Error: Could not find a worktree for --pr." >&2
      return 1
    fi

    if ! remote_url="$(git --git-dir="$first_path/.git" --work-tree="$first_path" remote get-url origin 2>/dev/null)"; then
      echo "Error: Could not read origin remote for --pr." >&2
      return 1
    fi

    repo_slug="$(_gwl_remote_slug "$remote_url")"
    if [[ -z "$repo_slug" || "$repo_slug" == "$remote_url" ]]; then
      echo "Error: --pr only supports GitHub origin remotes." >&2
      return 1
    fi

    if ! pr_rows="$(gh pr list --repo "$repo_slug" --state open --limit 200 --json headRefName,number --template '{{range .}}{{.headRefName}}{{"\t"}}{{.number}}{{"\n"}}{{end}}' 2>/dev/null)"; then
      echo "Error: Could not fetch open PRs with gh." >&2
      return 1
    fi

    while IFS=$'\t' read -r pr_branch pr_number; do
      [[ -n "$pr_branch" && -n "$pr_number" ]] || continue
      gwl_prs[$pr_branch]="#$pr_number"
    done <<< "$pr_rows"
  }

  _gwl_load_prs || return 1

  local c_reset="" c_dim="" c_green="" c_red="" c_yellow="" c_blue="" c_magenta="" c_cyan=""
  if [[ $plain -eq 0 ]]; then
    c_reset=$'\033[0m'
    c_dim=$'\033[2m'
    c_green=$'\033[1;32m'
    c_red=$'\033[1;31m'
    c_yellow=$'\033[1;33m'
    c_blue=$'\033[1;36m'
    c_magenta=$'\033[1;35m'
    c_cyan=$'\033[1;96m'
  fi

  _gwl_trunc_end() {
    local text="$1"
    local width="$2"
    if (( ${#text} <= width )); then
      print -r -- "$text"
      return
    fi
    if (( width <= 3 )); then
      print -r -- "${text[1,$width]}"
      return
    fi
    print -r -- "${text[1,$((width-3))]}..."
  }

  _gwl_trunc_mid() {
    local text="$1"
    local width="$2"
    local len=${#text}

    if (( len <= width )); then
      print -r -- "$text"
      return
    fi
    if (( width <= 5 )); then
      print -r -- "${text[1,$width]}"
      return
    fi

    local left=$(( (width - 3) / 2 ))
    local right=$(( width - 3 - left ))
    print -r -- "${text[1,$left]}...${text[$((len-right+1)),$len]}"
  }

  _gwl_trunc_path_keep_leaf() {
    local path_text="$1"
    local width="$2"
    local len=${#path_text}

    if (( len <= width )); then
      print -r -- "$path_text"
      return
    fi

    local leaf="${path_text##*/}"
    local leaf_len=${#leaf}

    if (( leaf_len + 4 >= width )); then
      print -r -- "$(_gwl_trunc_end "$path_text" "$width")"
      return
    fi

    local keep_prefix=$(( width - leaf_len - 4 ))
    local prefix="${path_text[1,$keep_prefix]}"
    print -r -- "${prefix}.../${leaf}"
  }

  _gwl_print_row() {
    local row_path="$1"
    local row_head="$2"
    local row_branch_ref="$3"
    local row_locked="$4"
    local row_prunable="$5"

    # Ignore hidden git-dir pseudo entry used by the `._repo` layout.
    [[ "$row_path" == */._repo ]] && return 0

    local marker=" "
    [[ "$row_path" == "$current_root" ]] && marker="*"

    local branch_display="detached"
    [[ -n "$row_branch_ref" ]] && branch_display="${row_branch_ref#refs/heads/}"
    local pr_display="-"
    [[ $show_pr -eq 1 && -n "$row_branch_ref" && -n "${gwl_prs[$branch_display]}" ]] && pr_display="${gwl_prs[$branch_display]}"

    local head_short="${row_head[1,7]}"
    local state_text="clean"
    if [[ -n "$(git --git-dir="$row_path/.git" --work-tree="$row_path" status --porcelain 2>/dev/null)" ]]; then
      state_text="dirty"
    fi
    [[ -n "$row_locked" ]] && state_text+=" locked"
    [[ -n "$row_prunable" ]] && state_text+=" prunable"

    local path_display="${row_path/#$HOME/~}"
    path_display="$(_gwl_trunc_path_keep_leaf "$path_display" "$path_w")"
    branch_display="$(_gwl_trunc_end "$branch_display" "$branch_w")"
    state_text="$(_gwl_trunc_end "$state_text" "$state_w")"
    pr_display="$(_gwl_trunc_end "$pr_display" "$pr_w")"

    local disk_display=""
    if [[ $show_disk -eq 1 ]]; then
      disk_display="-"
      if command -v du >/dev/null 2>&1; then
        disk_display="$(du -sh "$row_path" 2>/dev/null | awk '{print $1}')"
        [[ -z "$disk_display" ]] && disk_display="-"
      fi
      disk_display="$(_gwl_trunc_end "$disk_display" "$disk_w")"
    fi

    local state_color="$c_green"
    [[ "$state_text" == *dirty* ]] && state_color="$c_red"
    [[ "$state_text" == *prunable* ]] && state_color="$c_yellow"

    if [[ $show_disk -eq 1 && $show_pr -eq 1 ]]; then
      printf "%b%-2s %-${path_w}s %b%-${branch_w}s%b %b%-${head_w}s%b %b%-${state_w}s%b %b%-${pr_w}s%b %b%-${disk_w}s%b\n" \
        "$c_dim" "$marker" "$path_display" \
        "$c_blue" "$branch_display" "$c_reset" \
        "$c_magenta" "$head_short" "$c_reset" \
        "$state_color" "$state_text" "$c_reset" \
        "$c_yellow" "$pr_display" "$c_reset" \
        "$c_cyan" "$disk_display" "$c_reset"
    elif [[ $show_disk -eq 1 ]]; then
      printf "%b%-2s %-${path_w}s %b%-${branch_w}s%b %b%-${head_w}s%b %b%-${state_w}s%b %b%-${disk_w}s%b\n" \
        "$c_dim" "$marker" "$path_display" \
        "$c_blue" "$branch_display" "$c_reset" \
        "$c_magenta" "$head_short" "$c_reset" \
        "$state_color" "$state_text" "$c_reset" \
        "$c_cyan" "$disk_display" "$c_reset"
    elif [[ $show_pr -eq 1 ]]; then
      printf "%b%-2s %-${path_w}s %b%-${branch_w}s%b %b%-${head_w}s%b %b%-${state_w}s%b %b%-${pr_w}s%b\n" \
        "$c_dim" "$marker" "$path_display" \
        "$c_blue" "$branch_display" "$c_reset" \
        "$c_magenta" "$head_short" "$c_reset" \
        "$state_color" "$state_text" "$c_reset" \
        "$c_yellow" "$pr_display" "$c_reset"
    else
      printf "%b%-2s %-${path_w}s %b%-${branch_w}s%b %b%-${head_w}s%b %b%-${state_w}s%b\n" \
        "$c_dim" "$marker" "$path_display" \
        "$c_blue" "$branch_display" "$c_reset" \
        "$c_magenta" "$head_short" "$c_reset" \
        "$state_color" "$state_text" "$c_reset"
    fi
  }

  if [[ $show_disk -eq 1 && $show_pr -eq 1 ]]; then
    printf "%b%-2s %-${path_w}s %-${branch_w}s %-${head_w}s %-${state_w}s %-${pr_w}s %-${disk_w}s%b\n" \
      "$c_dim" "" "PATH" "BRANCH" "HEAD" "STATE" "PR" "DISK" "$c_reset"
  elif [[ $show_disk -eq 1 ]]; then
    printf "%b%-2s %-${path_w}s %-${branch_w}s %-${head_w}s %-${state_w}s %-${disk_w}s%b\n" \
      "$c_dim" "" "PATH" "BRANCH" "HEAD" "STATE" "DISK" "$c_reset"
  elif [[ $show_pr -eq 1 ]]; then
    printf "%b%-2s %-${path_w}s %-${branch_w}s %-${head_w}s %-${state_w}s %-${pr_w}s%b\n" \
      "$c_dim" "" "PATH" "BRANCH" "HEAD" "STATE" "PR" "$c_reset"
  else
    printf "%b%-2s %-${path_w}s %-${branch_w}s %-${head_w}s %-${state_w}s%b\n" \
      "$c_dim" "" "PATH" "BRANCH" "HEAD" "STATE" "$c_reset"
  fi

  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == worktree\ * ]]; then
      if [[ -n "$wt_path" ]]; then
        _gwl_print_row "$wt_path" "$wt_head" "$wt_branch" "$wt_locked" "$wt_prunable"
      fi

      wt_path="${line#worktree }"
      wt_head=""
      wt_branch=""
      wt_locked=""
      wt_prunable=""
    elif [[ "$line" == HEAD\ * ]]; then
      wt_head="${line#HEAD }"
    elif [[ "$line" == branch\ * ]]; then
      wt_branch="${line#branch }"
    elif [[ "$line" == locked* ]]; then
      wt_locked=1
    elif [[ "$line" == prunable* ]]; then
      wt_prunable=1
    fi
  done <<< "$worktree_list"

  if [[ -n "$wt_path" ]]; then
    _gwl_print_row "$wt_path" "$wt_head" "$wt_branch" "$wt_locked" "$wt_prunable"
  fi
}

# Function: gwcd
# Description:
#   Interactive worktree switcher using fzf. Select a worktree and change
#   directory into it.
#
# Usage:
#   gwcd
#
# Requires:
#   - fzf
function gwcd() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is not installed." >&2
    return 1
  fi

  local current_root
  local worktree_list
  current_root="$(git rev-parse --show-toplevel 2>/dev/null)" || current_root=""

  if ! worktree_list="$(git worktree list --porcelain 2>/dev/null)"; then
    echo "Error: Not inside a git repository/worktree." >&2
    return 1
  fi

  local rows=""
  local wt_path=""
  local wt_head=""
  local wt_branch=""
  local wt_locked=""
  local wt_prunable=""
  local line

  _gwcd_trunc_end() {
    local text="$1"
    local width="$2"
    if (( ${#text} <= width )); then
      print -r -- "$text"
      return
    fi
    if (( width <= 3 )); then
      print -r -- "${text[1,$width]}"
      return
    fi
    print -r -- "${text[1,$((width-3))]}..."
  }

  _gwcd_append_row() {
    local row_path="$1"
    local row_head="$2"
    local row_branch_ref="$3"
    local row_locked="$4"
    local row_prunable="$5"

    [[ "$row_path" == */._repo ]] && return 0

    local marker=" "
    [[ "$row_path" == "$current_root" ]] && marker="*"

    local branch_display="detached"
    [[ -n "$row_branch_ref" ]] && branch_display="${row_branch_ref#refs/heads/}"

    local head_short="${row_head[1,7]}"
    local state_text="clean"
    if [[ -n "$(git --git-dir="$row_path/.git" --work-tree="$row_path" status --porcelain 2>/dev/null)" ]]; then
      state_text="dirty"
    fi
    [[ -n "$row_locked" ]] && state_text+=" locked"
    [[ -n "$row_prunable" ]] && state_text+=" prunable"

    local path_display="${row_path/#$HOME/~}"
    local dir_display="${row_path##*/}"
    local branch_short
    local path_short

    branch_short="$(_gwcd_trunc_end "$branch_display" 56)"
    path_short="$(_gwcd_trunc_end "$path_display" 64)"

    rows+="$row_path"$'\t'"$branch_short"$'\t'"$dir_display"$'\t'"$path_short"$'\t'"$state_text"$'\t'"$head_short"$'\n'
  }

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == worktree\ * ]]; then
      if [[ -n "$wt_path" ]]; then
        _gwcd_append_row "$wt_path" "$wt_head" "$wt_branch" "$wt_locked" "$wt_prunable"
      fi
      wt_path="${line#worktree }"
      wt_head=""
      wt_branch=""
      wt_locked=""
      wt_prunable=""
    elif [[ "$line" == HEAD\ * ]]; then
      wt_head="${line#HEAD }"
    elif [[ "$line" == branch\ * ]]; then
      wt_branch="${line#branch }"
    elif [[ "$line" == locked* ]]; then
      wt_locked=1
    elif [[ "$line" == prunable* ]]; then
      wt_prunable=1
    fi
  done <<< "$worktree_list"

  if [[ -n "$wt_path" ]]; then
    _gwcd_append_row "$wt_path" "$wt_head" "$wt_branch" "$wt_locked" "$wt_prunable"
  fi

  local selected
  selected="$(print -r -- "$rows" | fzf --height=45% --reverse --prompt='worktree> ' --delimiter=$'\t' --with-nth=2,3,5,6,4 --nth=2,3,4 --header=$'  BRANCH\tDIR\tSTATE\tHEAD\tPATH')"
  [[ -z "$selected" ]] && return 0

  local target
  target="$(print -r -- "$selected" | cut -f1)"

  if [[ -d "$target" ]]; then
    cd "$target" || return 1
    if whence advanced_ls >/dev/null 2>&1; then
      advanced_ls
    fi
  else
    echo "Error: selected path does not exist: $target" >&2
    return 1
  fi
}

## Worktree Management ##

# Function: gwn
# Description:
#   Create a new git worktree at a sibling path, optionally checking out an
#   existing branch or creating a new one. Changes into the new worktree.
#
# Usage:
#   gwn <branch> [path]
#
# Requires: git
function gwn() {
  if [[ -z "$1" ]]; then
    echo "Usage: gwn <branch> [path]" >&2
    return 1
  fi

  local branch="$1"
  local repo_root
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "Error: Not inside a git repository." >&2
    return 1
  }

  local wt_path="${2:-${repo_root%/*}/${branch}}"

  if git rev-parse --verify "$branch" >/dev/null 2>&1; then
    git worktree add "$wt_path" "$branch" || return 1
  else
    git worktree add -b "$branch" "$wt_path" || return 1
  fi

  echo "Created worktree: $wt_path ($branch)"
  cd "$wt_path" || return 1
  if whence advanced_ls >/dev/null 2>&1; then
    advanced_ls
  fi
}

# Function: gwa
# Description:
#   Create a new git worktree and launch an AI coding agent in a new tmux
#   window (or session) named after the branch.
#
# Usage:
#   gwa <branch> [cl|cx|oc] [path]
#
# Requires: git, tmux
function gwa() {
  if [[ -z "$1" ]]; then
    echo "Usage: gwa <branch> [cl|cx|oc] [path]" >&2
    return 1
  fi

  local branch="$1"
  local agent="${2:-cl}"
  local override_path="$3"

  case "$agent" in
    cl|cx|oc) ;;
    *)
      echo "Error: Unknown agent '$agent'. Choose: cl, cx, oc." >&2
      return 1
      ;;
  esac

  if ! command -v tmux >/dev/null 2>&1; then
    echo "Error: tmux is not installed." >&2
    return 1
  fi

  local repo_root
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "Error: Not inside a git repository." >&2
    return 1
  }

  local wt_path="${override_path:-${repo_root%/*}/${branch}}"

  if git rev-parse --verify "$branch" >/dev/null 2>&1; then
    git worktree add "$wt_path" "$branch" || return 1
  else
    git worktree add -b "$branch" "$wt_path" || return 1
  fi

  echo "Created worktree: $wt_path ($branch)"

  local session_name="${branch//\//-}"

  if [[ -n "$TMUX" ]]; then
    tmux new-window -n "$session_name" -c "$wt_path"
    tmux send-keys -t "$session_name" "$agent" Enter
    echo "Opened tmux window '$session_name' with '$agent'."
  else
    tmux new-session -d -s "$session_name" -c "$wt_path"
    tmux send-keys -t "$session_name" "$agent" Enter
    tmux attach-session -t "=$session_name"
  fi
}

# Function: gwrm
# Description:
#   Interactively select a non-main worktree with fzf and remove it.
#   Optionally deletes the branch too.
#
# Usage:
#   gwrm [--force] [--branch]
#
# Requires: git, fzf
function gwrm() {
  local force=0
  local delete_branch=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --force|-f) force=1 ;;
      --branch|-b) delete_branch=1 ;;
      *)
        echo "Usage: gwrm [--force] [--branch]" >&2
        return 1
        ;;
    esac
    shift
  done

  if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is not installed." >&2
    return 1
  fi

  local worktree_list
  if ! worktree_list="$(git worktree list --porcelain 2>/dev/null)"; then
    echo "Error: Not inside a git repository/worktree." >&2
    return 1
  fi

  local main_path
  main_path="$(awk '/^worktree /{print substr($0,10); exit}' <<< "$worktree_list")"

  local rows="" wt_path="" wt_head="" wt_branch="" line

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == worktree\ * ]]; then
      if [[ -n "$wt_path" && "$wt_path" != */._repo && "$wt_path" != "$main_path" ]]; then
        local bd="${wt_branch#refs/heads/}"
        [[ -z "$bd" ]] && bd="detached"
        rows+="$wt_path"$'\t'"$bd"$'\t'"${wt_head[1,7]}"$'\t'"${wt_path/#$HOME/~}"$'\n'
      fi
      wt_path="${line#worktree }"
      wt_head="" wt_branch=""
    elif [[ "$line" == HEAD\ * ]];   then wt_head="${line#HEAD }"
    elif [[ "$line" == branch\ * ]]; then wt_branch="${line#branch }"
    fi
  done <<< "$worktree_list"

  if [[ -n "$wt_path" && "$wt_path" != */._repo && "$wt_path" != "$main_path" ]]; then
    local bd="${wt_branch#refs/heads/}"
    [[ -z "$bd" ]] && bd="detached"
    rows+="$wt_path"$'\t'"$bd"$'\t'"${wt_head[1,7]}"$'\t'"${wt_path/#$HOME/~}"$'\n'
  fi

  if [[ -z "$rows" ]]; then
    echo "No removable worktrees found." >&2
    return 0
  fi

  local selected
  selected="$(print -r -- "${rows%$'\n'}" | fzf --height=45% --reverse \
    --prompt='remove worktree> ' \
    --delimiter=$'\t' --with-nth=2,4,3 \
    --header=$'  BRANCH\tPATH\tHEAD')"
  [[ -z "$selected" ]] && return 0

  local target_path target_branch
  target_path="$(cut -f1 <<< "$selected")"
  target_branch="$(cut -f2 <<< "$selected")"

  if (( !force )); then
    echo -n "Remove worktree '$target_path' ($target_branch)? [y/N] "
    read -rk1 reply; echo
    [[ "$reply" != [yY] ]] && { echo "Aborted."; return 0; }
  fi

  local rm_args=()
  (( force )) && rm_args+=(--force)

  if ! git worktree remove "${rm_args[@]}" "$target_path"; then
    echo "Error: Remove failed. Use --force if the worktree has uncommitted changes." >&2
    return 1
  fi

  git worktree prune 2>/dev/null

  if (( delete_branch )) && [[ "$target_branch" != "detached" ]]; then
    if ! git branch -d "$target_branch" 2>/dev/null; then
      if (( force )); then
        git branch -D "$target_branch" && echo "Force-deleted branch: $target_branch"
      else
        echo "Note: Branch '$target_branch' not deleted (unmerged). Use --force to force-delete."
      fi
    else
      echo "Deleted branch: $target_branch"
    fi
  fi
}

## tmux Sessionizer ##

# Function: mux
# Description:
#   fzf over zoxide history and common project dirs. Attach-or-create a tmux
#   session named after the selected directory.
#
# Usage:
#   mux [query]
#
# Requires: tmux, fzf. Optional: zoxide (for ranked results).
function mux() {
  if ! command -v tmux >/dev/null 2>&1; then
    echo "Error: tmux is not installed." >&2
    return 1
  fi
  if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is not installed." >&2
    return 1
  fi

  local candidates=""

  if command -v zoxide >/dev/null 2>&1; then
    candidates="$(zoxide query -l 2>/dev/null)"
  fi

  for base in "$HOME" "$HOME/dev" "$HOME/projects" "$HOME/work" "$HOME/code"; do
    [[ -d "$base" ]] && candidates+=$'\n'"$(find "$base" -maxdepth 1 -mindepth 1 -type d 2>/dev/null)"
  done

  local selected
  selected="$(print -r -- "$candidates" | sort -u | grep -v '^$' | sed "s|$HOME|~|g" | \
    fzf --height=45% --reverse --prompt='session> ' --query="${1:-}" \
        --preview="ls \"\$(echo {} | sed 's|~|$HOME|g')\" 2>/dev/null | head -20")"

  [[ -z "$selected" ]] && return 0
  selected="${selected/#\~/$HOME}"

  local session_name
  session_name="$(basename "$selected" | tr '.:/ ' '____')"

  if [[ -z "$TMUX" ]]; then
    tmux new-session -A -s "$session_name" -c "$selected"
  else
    if tmux has-session -t "=$session_name" 2>/dev/null; then
      tmux switch-client -t "=$session_name"
    else
      tmux new-session -d -s "$session_name" -c "$selected"
      tmux switch-client -t "=$session_name"
    fi
  fi
}

## Docker fzf Pickers ##

# _dpick: Internal fzf picker for Docker containers.
# Returns the selected container name on stdout.
function _dpick() {
  local prompt="${1:-container> }"
  if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is not installed." >&2
    return 1
  fi
  docker ps -a --format '{{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null | \
    fzf --height=45% --reverse --prompt="$prompt" \
        --delimiter=$'\t' --with-nth=1,2,3 \
        --header=$'  NAME\tIMAGE\tSTATUS' | \
    cut -f1
}

# dex: docker exec -it, with fzf picker when called with no arguments.
# Usage: dex [container] [command]
unalias dex 2>/dev/null
function dex() {
  if [[ $# -eq 0 ]]; then
    local cid="$(_dpick 'exec> ')"
    [[ -z "$cid" ]] && return 0
    docker exec -it "$cid" /bin/bash
  else
    docker exec -it "$@"
  fi
}

# dlog: docker logs -f, with fzf picker when called with no arguments.
# Usage: dlog [container] [docker-logs-flags...]
unalias dlog 2>/dev/null
function dlog() {
  if [[ $# -eq 0 ]]; then
    local cid="$(_dpick 'logs> ')"
    [[ -z "$cid" ]] && return 0
    docker logs -f "$cid"
  else
    docker logs "$@"
  fi
}

# drm: docker rm -f, with fzf picker (multi-select) when called with no arguments.
# Usage: drm [container...]
unalias drm 2>/dev/null
function drm() {
  if [[ $# -eq 0 ]]; then
    local cids
    cids="$(docker ps -a --format '{{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null | \
      fzf --height=45% --reverse --prompt='remove> ' --multi \
          --delimiter=$'\t' --with-nth=1,2,3 \
          --header=$'  NAME\tIMAGE\tSTATUS' | cut -f1)"
    [[ -z "$cids" ]] && return 0
    print -r -- "$cids" | xargs docker rm -f
  else
    docker rm -f "$@"
  fi
}

## Process Killer ##

# fkill: Interactively select one or more processes with fzf and kill them.
# Usage: fkill [-9]
# -9: send SIGKILL instead of SIGTERM
function fkill() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is not installed." >&2
    return 1
  fi

  local signal="15"
  [[ "$1" == "-9" ]] && signal="9"

  local selected
  selected="$(ps -eo pid,user,pcpu,pmem,comm --sort=-pcpu 2>/dev/null | tail -n +2 | \
    fzf --height=50% --reverse --prompt='kill> ' --multi \
        --header='  PID   USER  %CPU %MEM  COMMAND')"

  [[ -z "$selected" ]] && return 0

  print -r -- "$selected" | awk '{print $1}' | while read -r pid; do
    if kill "-$signal" "$pid" 2>/dev/null; then
      echo "Killed PID $pid (SIG${signal})"
    else
      echo "Error: Failed to kill PID $pid" >&2
    fi
  done
}

## Small QoL ##

# extract: Decompress an archive file, auto-detecting format.
# Usage: extract <file>
function extract() {
  if [[ -z "$1" ]]; then
    echo "Usage: extract <file>" >&2
    return 1
  fi
  if [[ ! -f "$1" ]]; then
    echo "Error: '$1' is not a file." >&2
    return 1
  fi

  case "$1" in
    *.tar.gz|*.tgz)    tar -xzf "$1"            ;;
    *.tar.bz2|*.tbz2)  tar -xjf "$1"            ;;
    *.tar.xz|*.txz)    tar -xJf "$1"            ;;
    *.tar.zst)         tar --zstd -xf "$1"      ;;
    *.tar)             tar -xf "$1"              ;;
    *.gz)              gunzip "$1"               ;;
    *.bz2)             bunzip2 "$1"              ;;
    *.xz)              unxz "$1"                 ;;
    *.zip)             unzip "$1"                ;;
    *.7z)              7z x "$1"                 ;;
    *.rar)             unrar x "$1"              ;;
    *.zst)             zstd -d "$1"              ;;
    *)
      echo "Error: Unsupported format '${1##*.}'." >&2
      return 1
      ;;
  esac
}

# mkcd: Create a directory (including parents) and change into it.
# Usage: mkcd <dir>
function mkcd() {
  if [[ -z "$1" ]]; then
    echo "Usage: mkcd <dir>" >&2
    return 1
  fi
  mkdir -p "$1" && cd "$1" || return 1
}

## Discoverability ##

# funcs: List all custom shell functions with their Usage lines.
# Usage: funcs [pattern]
function funcs() {
  local pattern="${1:-}"
  local shell_dir="$HOME/dotfiles/shell"

  if [[ ! -d "$shell_dir" ]]; then
    echo "Error: '$shell_dir' not found." >&2
    return 1
  fi

  awk '
    /^function [a-zA-Z_][a-zA-Z0-9_-]*\(\)/ {
      split($2, a, "("); fname = a[1]; usage = ""
    }
    fname && /# Usage:/ {
      sub(/.*# Usage:[[:space:]]*/, "")
      if (length($0) > 0) {
        printf "  %-22s %s\n", fname, $0
        fname = ""
      } else {
        getline; sub(/^#[[:space:]]*/, "")
        printf "  %-22s %s\n", fname, $0
        fname = ""
      }
    }
    fname && /^[^#[:space:]]/ { fname = "" }
  ' "$shell_dir"/*.zsh 2>/dev/null | \
    { [[ -n "$pattern" ]] && grep -i "$pattern" || cat; } | \
    sort
}
