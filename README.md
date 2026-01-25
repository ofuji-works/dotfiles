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
  sudo apt-get install -y build-essential procps curl file git
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

7) Launch Neovim to sync plugins

```bash
nvim
```

On first launch, lazy.nvim will bootstrap itself and install plugins.

## Setup Terminal Emulator

**Ghostty**

1) Download Source
https://github.com/ghostty-org/ghostty/tags

2) Install Dependency Packages

```bash
sudo apt update

sudo apt install -y \
    libgtk-4-dev \
    libadwaita-1-dev \
    gettext \
    libxml2-utils
```

The `apt` blueprint-compiler is version 12, but version 16 or higher is required.

```bash
brew install blueprint-compiler
```

2) Build Ghostty  

Because the iTerm2 theme resource paths cannot be resolved automatically, you need to adjust them manually.

```bash
tar -xf ghostty-VERSION.tar.gz
cd ghostty-VERSION/

zig fetch --save=iterm2_themes "https://github.com/mbadolato/iTerm2-Color-Schemes/releases/download/release-20260112-150707-28c8f5b/ghost
ty-themes.tgz"

zig build -Doptimize=ReleaseFast
```

Reference: https://ghostty.org/docs/install/build


For Ubuntu

```bash
zig build -Doptimize=ReleaseFast -fno-sys=gtk4-layer-shell

```

## Fonts (Hack Nerd Font)

The Alacritty config assumes Hack Nerd Font. Install via Homebrew Cask on macOS or from packages/upstream on Linux.

## Common Commands

- `make setup`: one-shot environment bootstrap
- `nvim`: triggers first-time plugin installation

## Notes

- `.zshrc` paths for Homebrew/Terraform are set for macOS (`/opt/homebrew/...`). On Linux, Homebrew lives at `/home/linuxbrew/.linuxbrew/...`; update the paths as needed.
