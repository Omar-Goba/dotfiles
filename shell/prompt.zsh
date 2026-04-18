#!/bin/zsh

# Returns the current battery percentage as an integer followed by a '%'.
# Uses pmset or ioreg (macOS specific). If neither command is available or no valid data is found,
# no output is produced.
function get_battery() {
    local current_bat percentage
    if command -v pmset >/dev/null 2>&1; then
        # Extract battery percentage from pmset output.
        current_bat="$(pmset -g ps | grep -o '[0-9]\+%' | tr -d '%')"
    elif command -v ioreg >/dev/null 2>&1; then
        local _battery_info _max_cap _cur_cap
        _battery_info="$(ioreg -n AppleSmartBattery 2>/dev/null)"
        _max_cap=$(echo "$_battery_info" | awk '/MaxCapacity/ {print $NF}')
        _cur_cap=$(echo "$_battery_info" | awk '/CurrentCapacity/ {print $NF}')
        if [[ -n "$_max_cap" && "$_max_cap" -gt 0 ]]; then
            current_bat=$(awk -v cur="$_cur_cap" -v max="$_max_cap" 'BEGIN { printf "%.2f", (cur/max)*100 }')
        fi
    else
        echo "Error: Neither pmset nor ioreg command is available." >&2
        return 1
    fi
    # Truncate decimal and output percentage if valid.
    percentage="${current_bat%%.*}"
    if [[ -n "$percentage" && "$percentage" =~ ^[0-9]+$ ]]; then
        echo "${percentage}%"
    fi
}

# Returns the current Git branch name in the format " {branch}" if inside a Git repository.
# If not in a Git repository or if git is not installed, the function outputs nothing.
function git_branch() {
    if ! command -v git >/dev/null 2>&1 || ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return
    fi
    local branch
    # Try to get the branch name. If in detached HEAD state, fall back to short commit hash.
    branch=$(git symbolic-ref --quiet HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    [ -n "$branch" ] && echo " {${branch##refs/heads/}}"
}

# Set the prompt to include the current date and time, the current working
# directory (abbreviated to the last segment), and the current Git branch if
# applicable.
export PS1="%B[\$(date +%Y-%m-%dT%H:%M:%S)] %1~\$(git_branch) 
 -> %b"


