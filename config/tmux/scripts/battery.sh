#!/bin/sh

if command -v pmset >/dev/null 2>&1; then
  pmset -g ps | grep -o '[0-9]\+%' | tr -d '%'
elif command -v upower >/dev/null 2>&1; then
  upower -e | grep -m1 battery | xargs -r upower -i 2>/dev/null | awk '/percentage:/ {gsub(/%/, "", $2); print $2; exit}'
fi
