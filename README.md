<!-- ░▒▓█ BANNER █▓▒░ -->
<p align="center">
  <a href="https://github.com/Omar-Goba/dotfiles">
    <img src="https://capsule-render.vercel.app/api?type=waving&color=0:0f0c29,50:302b63,100:24243e&height=220&section=header&text=dotfiles&fontSize=90&fontColor=ffffff&fontAlignY=38&desc=minimal%20config%20•%20maximum%20velocity&descSize=18&descAlignY=62&animation=fadeIn" alt="banner"/>
  </a>
</p>

<!-- ░▒▓█ TYPING HERO █▓▒░ -->
<p align="center">
  <a href="https://git.io/typing-svg">
    <img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=700&size=22&duration=2800&pause=700&color=8B5CF6&center=true&vCenter=true&multiline=true&width=720&height=80&lines=%3E+cd+~%2Fdotfiles+%26%26+source+shell%2Fcore.zsh;%3E+startup+0.08s+%E2%80%A2+zero+ceremony+%E2%80%A2+pure+muscle+memory" alt="typing" />
  </a>
</p>

<!-- ░▒▓█ BADGE WALL █▓▒░ -->
<p align="center">
  <img src="https://img.shields.io/badge/shell-zsh-0b0f14?style=for-the-badge&logo=gnu-bash&logoColor=F7DF1E" />
  <img src="https://img.shields.io/badge/editor-neovim-0b0f14?style=for-the-badge&logo=neovim&logoColor=57A143" />
  <img src="https://img.shields.io/badge/multiplexer-tmux-0b0f14?style=for-the-badge&logo=tmux&logoColor=1BB91F" />
  <img src="https://img.shields.io/badge/vcs-git-0b0f14?style=for-the-badge&logo=git&logoColor=F05032" />
  <img src="https://img.shields.io/badge/cli-gh-0b0f14?style=for-the-badge&logo=github&logoColor=ffffff" />
  <img src="https://img.shields.io/badge/python-uv-0b0f14?style=for-the-badge&logo=python&logoColor=3776AB" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS-0b0f14?style=flat-square&logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/platform-Linux-0b0f14?style=flat-square&logo=linux&logoColor=FCC624" />
  <img src="https://img.shields.io/badge/license-MIT-8B5CF6?style=flat-square" />
  <img src="https://img.shields.io/badge/startup-0.08s-22c55e?style=flat-square" />
  <img src="https://img.shields.io/badge/public--safe-yes-22c55e?style=flat-square" />
  <img src="https://img.shields.io/github/last-commit/Omar-Goba/dotfiles?style=flat-square&color=8B5CF6" />
  <img src="https://img.shields.io/github/stars/Omar-Goba/dotfiles?style=flat-square&color=f5a623" />
</p>

<p align="center">
  <sub><em>terminals are a feeling. this repo is the feeling.</em></sub>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="520" alt="palette"/>
</p>

---

## ◆ the arsenal

<table align="center">
  <tr>
    <td align="center" width="110"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/bash/bash-original.svg" width="46"/><br/><sub><b>zsh</b></sub></td>
    <td align="center" width="110"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/neovim/neovim-original.svg" width="46"/><br/><sub><b>neovim</b></sub></td>
    <td align="center" width="110"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/tmux/tmux-original.svg" width="46"/><br/><sub><b>tmux</b></sub></td>
    <td align="center" width="110"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/git/git-original.svg" width="46"/><br/><sub><b>git</b></sub></td>
    <td align="center" width="110"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/github/github-original.svg" width="46"/><br/><sub><b>gh</b></sub></td>
    <td align="center" width="110"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg" width="46"/><br/><sub><b>uv</b></sub></td>
    <td align="center" width="110"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/linux/linux-original.svg" width="46"/><br/><sub><b>btop</b></sub></td>
    <td align="center" width="110"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/apple/apple-original.svg" width="46"/><br/><sub><b>fastfetch</b></sub></td>
  </tr>
</table>

---

## ◆ neon map

```text
┌─ shell/   ── aliases · functions · prompt · startup flow
├─ config/  ── neovim · tmux · git · gh · btop · fastfetch · uv
├─ vendors/ ── external helper scripts (fzf-git, …)
└─ notes/   ── personal ops notes & playbooks
```

<details>
<summary><b>◇ full tree</b></summary>

```text
.
├─ shell/
│  ├─ aliases.zsh
│  ├─ core.zsh
│  ├─ functions.zsh
│  ├─ git.zsh
│  ├─ prompt.zsh
│  └─ local.zsh        # untracked, machine-local
├─ config/
│  ├─ git/
│  ├─ gh/
│  ├─ neovim/
│  ├─ tmux/
│  ├─ btop/
│  ├─ fastfetch/
│  └─ uv/
├─ vendors/
│  └─ fzf-git/
└─ notes/
   ├─ new-tool-playbook.md
   ├─ git-MU-auth.md
   └─ …
```
</details>

---

## ◆ launch sequence

<table>
<tr><td>

```bash
# 1 ─ clone into place
git clone https://github.com/Omar-Goba/dotfiles ~/dotfiles

# 2 ─ wire it up
ln -sf ~/dotfiles/config/nvim ~/.config/nvim
ln -sf ~/dotfiles/config/tmux ~/.config/tmux
echo 'source ~/dotfiles/shell/core.zsh' >> ~/.zshrc

# 3 ─ take off
exec zsh
```

</td></tr>
</table>

> <sub>keep machine-specific bits in `shell/local.zsh` — already ignored, stays off the public record.</sub>

---

## ◆ design contract

<table align="center">
  <tr>
    <td align="center" width="180">
      <h3>⚡</h3>
      <b>speed</b><br/>
      <sub>over ceremony</sub>
    </td>
    <td align="center" width="180">
      <h3>◻</h3>
      <b>minimal</b><br/>
      <sub>over noisy</sub>
    </td>
    <td align="center" width="180">
      <h3>◎</h3>
      <b>legible</b><br/>
      <sub>over clever</sub>
    </td>
    <td align="center" width="180">
      <h3>✦</h3>
      <b>portable</b><br/>
      <sub>over host-locked</sub>
    </td>
  </tr>
</table>

---

## ◆ public-push safety

This repo is intended for public hosting. Secrets, keys, tokens and machine-private values never get committed.

```gitignore
.env
.env.*
*.pem
*.key
secrets*
shell/local.zsh
shell/secrets.env
```

<details>
<summary><b>◇ adding a new tool? follow the playbook</b></summary>

<br/>

See [`notes/new-tool-playbook.md`](notes/new-tool-playbook.md) — the canonical checklist for landing a new config into this repo cleanly (naming, placement, gitignore, wiring).
</details>

---

<p align="center">
  <img src="https://raw.githubusercontent.com/platane/snk/output/github-contribution-grid-snake-dark.svg" alt="snake" />
</p>

<p align="center">
  <sub>crafted with too much coffee ☕ &nbsp;·&nbsp; <b>MIT</b> licensed &nbsp;·&nbsp; © Omar Goba</sub>
</p>

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:24243e,50:302b63,100:0f0c29&height=100&section=footer&animation=fadeIn" alt="footer"/>
</p>
