#!/usr/bin/env bash
# skkeleton 用の SKK 辞書 (L 辞書) を取得する。
# 辞書は約 13MB のダウンロード生成物なので dotfiles には含めず、
# XDG の設定ディレクトリへ展開する。
set -euo pipefail

DICT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/skk"
DICT_PATH="$DICT_DIR/SKK-JISYO.L"
DICT_URL="https://skk-dev.github.io/dict/SKK-JISYO.L.gz"

if [ -f "$DICT_PATH" ]; then
  echo "SKK-JISYO.L already exists: $DICT_PATH"
  exit 0
fi

mkdir -p "$DICT_DIR"
echo "Downloading $DICT_URL ..."
curl -fsSL "$DICT_URL" -o "$DICT_PATH.gz"
gunzip -f "$DICT_PATH.gz"
echo "Installed: $DICT_PATH"
