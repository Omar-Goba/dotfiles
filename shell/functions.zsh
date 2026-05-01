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
# Usage: tx [-v] [-b] [-c] <filename>
# -v: Verbose mode; opens the PDF after successful compilation.
# -b: Run bibtex after the first pdflatex pass.
# -c: Clean auxiliary files recursively (e.g., .aux, .log, .out, .bbl, .blg).
#
# Requires: pdflatex, find, optionally bibtex and open (macOS).
function tx() {
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
      *) echo "Usage: tx [-v] [-b] [-c] <filename>" && return 1 ;;
    esac
  done
  shift $((OPTIND - 1))

  # Check if a filename was provided.
  if [[ -z "$1" ]]; then
    echo "Error: No file specified."
    echo "Usage: tx [-v] [-b] [-c] <filename>"
    return 1
  fi
  tex_file="$1"
  base_name="${tex_file##*/}"
  base_name="${base_name%.tex}"

  # Match mdpdf output behavior.
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
  if ! pdflatex -output-directory="$out_dir" "$tex_file"; then
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
      if ! pdflatex -output-directory="$out_dir" "$tex_file"; then
        echo "Error: Failed to compile '$tex_file' (1st pass after bibtex)."
        return 1
      fi
      echo "Recompiling with pdflatex (2nd pass after bibtex)..."
      if ! pdflatex -output-directory="$out_dir" "$tex_file"; then
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
# Usage: mdpdf [-v] <file.md> [output-name]
# -v: Verbose mode; opens the PDF after successful compilation.
#
function mdpdf() {
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
      *) echo "Usage: mdpdf [-v] <file.md> [output-name]" && return 1 ;;
    esac
  done
  shift $((OPTIND - 1))

  # Check args
  if [[ -z "$1" ]]; then
    echo "Error: No Markdown file specified."
    echo "Usage: mdpdf [-v] <file.md> [output-name]"
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
  if ! pandoc "$md_file" --pdf-engine=xelatex -o "$out_file"; then
    echo "Error: Failed to convert '$md_file' to PDF."
    return 1
  fi

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
