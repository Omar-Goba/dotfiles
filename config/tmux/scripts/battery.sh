#!/bin/zsh

pmset -g ps | grep -o '[0-9]\+%' | tr -d '%'
