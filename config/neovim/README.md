# NeoVim Config

This repository contains my NeoVim configuration files.

* To find the keybindings, see the [mapping.lua](lua/plugins/mappings.lua) file, or run `:Telescope keymaps` in NeoVim.

## Setup

1. Install [NeoVim](https://neovim.io/):

   ```shell
   sudo apt install neovim
   ```

2. Clone this repository at `~/.config/`:

   ```shell
   git clone https://github.com/Hamada-Gado/neovim.git
   ```

3. Run neovim:
   * Set the `NVIM_APPNAME` environment variable to the name of the directory if it's not `nvim`:

      ```shell
      export NVIM_APPNAME="neovim"
      ```
