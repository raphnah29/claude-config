#!/usr/bin/env bash
# Link the shared Claude Code config from this repo into ~/.claude. Safe to re-run.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.claude"
ITEMS=(settings.json CLAUDE.md statusline.sh notify.sh skills)

mkdir -p "$DEST"
chmod +x "$REPO"/*.sh

if ! command -v jq >/dev/null; then
  case "$(uname -s)" in
    Darwin) echo "⚠ jq missing (needed by the status line): brew install jq" ;;
    *)      echo "⚠ jq missing (needed by the status line): sudo apt install jq" ;;
  esac
fi

for f in "${ITEMS[@]}"; do
  src="$REPO/$f"; dst="$DEST/$f"
  [ -e "$src" ] || continue
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    continue
  fi
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
    echo "backed up $dst"
  fi
  ln -sfn "$src" "$dst"
  echo "linked $dst -> $src"
done
