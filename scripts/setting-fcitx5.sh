#!/usr/bin/env bash
# Ubuntu (GNOME) の日本語入力を ibus から fcitx5 + SKK へ移行する。
#
# 前提: Ubuntu 24.04 / GNOME 46 / Wayland で検証。
# 冪等に書いてあるので再実行してよい。既存の設定ファイルが差分を持つ場合は
# .bak.<timestamp> を残してから上書きする。
#
# 反映には再ログインが必要 (environment.d は systemd ユーザーセッション起動時に読まれるため)。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# fcitx5 本体 + 各ツールキット向け frontend + SKK/Mozc エンジン + SKK 辞書
PACKAGES=(
  fcitx5
  fcitx5-config-qt
  fcitx5-frontend-all
  fcitx5-mozc
  fcitx5-skk
  skkdic
  skkdic-extra
  im-config
)

log() { printf '\n==> %s\n' "$1"; }

install_packages() {
  log "Installing packages"
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "  apt-get not found; this script targets Debian/Ubuntu" >&2
    exit 1
  fi

  local missing=()
  local pkg
  for pkg in "${PACKAGES[@]}"; do
    if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'ok installed'; then
      missing+=("$pkg")
    fi
  done

  if [ "${#missing[@]}" -eq 0 ]; then
    echo "  all packages already installed"
    return
  fi

  echo "  missing: ${missing[*]}"
  sudo apt-get update
  sudo apt-get install -y "${missing[@]}"
}

# 差分があればバックアップしてから配置する。
# fcitx5 は profile / config を実行中に書き戻すため、symlink ではなく copy で運用する。
install_file() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && cmp -s "$src" "$dst"; then
    echo "  unchanged: $dst"
    return
  fi
  if [ -e "$dst" ]; then
    local backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
    cp -a "$dst" "$backup"
    echo "  backed up: $backup"
  fi
  cp -f "$src" "$dst"
  echo "  installed: $dst"
}

install_configs() {
  log "Installing config files"
  # 実行中の fcitx5 が profile を書き戻して上書きを打ち消すのを防ぐ
  pkill -x fcitx5 2>/dev/null || true

  install_file "$REPO_ROOT/.config/fcitx5/config"              "$CONFIG_HOME/fcitx5/config"
  install_file "$REPO_ROOT/.config/fcitx5/profile"             "$CONFIG_HOME/fcitx5/profile"
  install_file "$REPO_ROOT/.config/fcitx5/skk/dictionary_list" "$CONFIG_HOME/fcitx5/skk/dictionary_list"
  install_file "$REPO_ROOT/.config/environment.d/im.conf"      "$CONFIG_HOME/environment.d/im.conf"
  install_file "$REPO_ROOT/.config/autostart/fcitx5.desktop"   "$CONFIG_HOME/autostart/fcitx5.desktop"
}

# X / XWayland セッション向け。Wayland ネイティブでは参照されないが揃えておく。
configure_im_config() {
  log "Pointing im-config at fcitx5"
  if command -v im-config >/dev/null 2>&1; then
    im-config -n fcitx5
    echo "  $(grep -v '^\s*#' "$HOME/.xinputrc" 2>/dev/null | grep -v '^$' || echo 'no ~/.xinputrc')"
  else
    echo "  skipped: im-config not found"
  fi
}

# GNOME は入力ソースに ibus エンジンが残っていると ibus 側を起動してしまうので、
# xkb のレイアウトだけ残して ibus エントリを落とす。
configure_gnome_input_sources() {
  log "Removing ibus engines from GNOME input sources"
  if ! command -v gsettings >/dev/null 2>&1 || [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    echo "  skipped: no GNOME session bus available"
    return
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    echo "  skipped: python3 not found (remove ibus entries via Settings > Keyboard)"
    return
  fi

  local current filtered
  current="$(gsettings get org.gnome.desktop.input-sources sources)"
  filtered="$(python3 - "$current" <<'PY'
import ast
import sys

try:
    items = ast.literal_eval(sys.argv[1])
except (ValueError, SyntaxError):
    items = []
kept = [i for i in items if i[0] != "ibus"] or [("xkb", "us")]
print("[" + ", ".join("('%s', '%s')" % i for i in kept) + "]")
PY
)"

  gsettings set org.gnome.desktop.input-sources sources "$filtered"
  gsettings set org.gnome.desktop.input-sources mru-sources "$filtered"
  echo "  sources: $filtered"
}

main() {
  install_packages
  install_configs
  configure_im_config
  configure_gnome_input_sources

  log "Done"
  cat <<'EOS'
  Log out and log back in to apply ~/.config/environment.d/im.conf.
  After re-login, verify with:

    fcitx5-diagnose | less
    fcitx5-config-qt   # GUI

  Ctrl+Space (or Zenkaku_Hankaku) toggles SKK; Ctrl+Shift+Space cycles skk <-> mozc.
EOS
}

main "$@"
