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

## Install Haskell

1. install ghcup

```bash
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
```

2. install haskell environment

```bash
ghcup tui
```

3. set default ghc

```bash
ghcup set ghc xx.x.x
```

## Install Docker

https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository のページを参照してください。

## Run Docker without sudo (Rootless mode)

`sudo` を付けずに Docker を実行する方法。詳細は https://docs.docker.com/engine/security/rootless/ を参照。

1. 前提パッケージのインストール

```bash
sudo apt-get install -y uidmap dbus-user-session
```

2. システム全体の Docker デーモンが動いている場合は停止

```bash
sudo systemctl disable --now docker.service docker.socket
sudo rm /var/run/docker.sock
```

3. rootless 用セットアップツールを実行

```bash
dockerd-rootless-setuptool.sh install
```

ツールが見つからない場合は `docker-ce-rootless-extras` をインストールする。

```bash
sudo apt-get install -y docker-ce-rootless-extras
```

4. 環境変数を設定（`~/.zshrc` などに追記）

```bash
export PATH=/usr/bin:$PATH
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock
```

5. デーモンの起動と自動起動の設定

```bash
systemctl --user start docker
systemctl --user enable docker
sudo loginctl enable-linger $(whoami)
```

6. 動作確認

```bash
docker info
```

`Security Options` に `rootless` が表示されていれば成功。

## Fonts (Hack Nerd Font)

The Alacritty config assumes Hack Nerd Font. Install via Homebrew Cask on macOS or from packages/upstream on Linux.

Download Page https://www.nerdfonts.com/font-downloads

## SKK (skkeleton)

Neovim の日本語入力は [skkeleton](https://github.com/vim-skk/skkeleton) を使う。
denops.vim 経由で Deno 上に動くため、mise の `deno` が入っていれば追加の導入は不要。

変換には SKK 辞書が必要。`makers setup` に含まれているが、単体で入れる場合は:

```bash
makers set-skk-dict
```

L 辞書が `~/.config/skk/SKK-JISYO.L` に展開される（約 4.5MB のため dotfiles には含めない）。
ユーザー辞書は skkeleton の既定どおり `~/.skkeleton` に作られる。

初回起動時は denops が Deno の依存を取得するため少し時間がかかる。
また skkeleton は denops.vim の import map 対応（2025 年後半以降）を要求するので、
`Failed to load plugin 'skkeleton': ... not in import map` が出る場合は
`:Lazy update denops.vim` で denops.vim を更新する。

### Usage

- `<C-j>`: 日本語入力のトグル（insert / cmdline）
- 大文字始まりで変換ポイント、`<Space>` で変換、`<C-g>` でキャンセル
- statusline に現在のモード（`[あ]` / `[ア]` など）が出る

## Ubuntu Mozc settings

### input mode default hiragana 

```bash
vi .config/mozc/ibus_config.textproto
```
```shell
active_on_launch: True

```

## terminal-browser settings

1. install 

```bash
curl -fsSl https://terminal-browser.sh/install | bash
```

2. エラーが出るため、~/.local/share/terminal-browser/scripts/apparmor.shを書き換える

Ubuntu 24の場合App Armorが4.0になっており、terminal-browserでは5.0が要求される。
apparmor.sh内でabi5.0でハードコーディングされているため、4.0に書き換える。

3. apparmor.shを実行する

```bash
sudo ~/.local/share/terminal-browser/app/scripts/apparmor.sh
```
sudoをつけて実行をする必要がある。

4. .bashrcにupgrade時にapparmor.shの内容が更新されないように対応
以下を.bashrcに追加

```shell
export TERMINAL_BROWSER_SKIP_APPARMOR=1
```

## Common Commands

- `make setup`: one-shot environment bootstrap
- `nvim`: triggers first-time plugin installation

## Notes

- `.zshrc` paths for Homebrew/Terraform are set for macOS (`/opt/homebrew/...`). On Linux, Homebrew lives at `/home/linuxbrew/.linuxbrew/...`; update the paths as needed.
