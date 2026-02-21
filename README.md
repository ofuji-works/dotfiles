# Dotfiles

Personal development environment setup (zsh / Neovim / Alacritty / mise / Homebrew, etc.).

## What’s Included

- zsh: completion, prompt, and aliases (`.zshrc`)
- Neovim: lazy.nvim-based plugin stack with LSP/fern/telescope (`.config/nvim`)
- Alacritty: theme and font configuration (`.config/alacritty`)
- mise: language/CLI tool version management (`.config/mise/config.toml`)
- Makefile: bootstrap automation via `make setup`

## Prerequisites

- OS: macOS or Linux (Ubuntu/Debian based)
- Git and curl available

Example: install base packages on Ubuntu

```bash
sudo apt-get update && \
  sudo apt-get install -y build-essential procps curl file git pkg-config libssl-dev
```

## Setup

1) Install Homebrew (Linux; on macOS follow the website)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Reference: https://brew.sh/

2) Clone this repository

```bash
git clone https://github.com/ofuji-works/dotfiles.git
cd dotfiles
```

3) Install Mise

```bash
brew install mise
```

4) Install Languages

```bash
mise install
```

5) Install Cargo Make

```bash
mise use -g rust@xx
cargo install cargo-make
```

6) Run bootstrap

```bash
makers setup
```

7) Setup Neovim

Launch Neovim to sync plugins
On first launch, lazy.nvim will bootstrap itself and install plugins.

```bash
nvim
```
For ubuntu, be able to delete file on fern.

```bash
sudo apt update
sudo apt install trash-cli
```

8) Install Other Tools

```bash
brew install anomalyco/tap/opencode
```

## Fonts (Hack Nerd Font)

The Alacritty config assumes Hack Nerd Font. Install via Homebrew Cask on macOS or from packages/upstream on Linux.

Download Page https://www.nerdfonts.com/font-downloads

## Ubuntu Mozc settings

### input mode default hiragana 

```bash
vi .config/mozc/ibus_config.textproto
```
```shell
active_on_launch: True

```

## Common Commands

- `make setup`: one-shot environment bootstrap
- `nvim`: triggers first-time plugin installation

## Notes

- `.zshrc` paths for Homebrew/Terraform are set for macOS (`/opt/homebrew/...`). On Linux, Homebrew lives at `/home/linuxbrew/.linuxbrew/...`; update the paths as needed.
