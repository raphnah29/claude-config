#!/usr/bin/env bash
# Cross-platform desktop notification: notify.sh "message" ["title"]
msg="${1:-Claude Code}"; title="${2:-Claude Code}"
case "$(uname -s)" in
  Darwin) osascript -e "display notification \"${msg//\"/\\\"}\" with title \"${title//\"/\\\"}\"" >/dev/null 2>&1 ;;
  Linux)  command -v notify-send >/dev/null && notify-send -a "$title" "$title" "$msg" ;;
esac
exit 0
