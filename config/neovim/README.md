# NeoVim Config

This repository contains my NeoVim configuration files.

* To find the keybindings, see the [mapping.lua](lua/plugins/mappings.lua) file, or run `:Telescope keymaps` in NeoVim.

## Setup

1. Run `./install.sh --profile editor` from the dotfiles repository.
2. Start `nvim`. Lazy.nvim installs the pinned plugins on first launch.

The shell bootstrap sets `NVIM_APPNAME=neovim`, so this configuration is linked
at `~/.config/neovim` rather than Neovim's default `~/.config/nvim` path.
