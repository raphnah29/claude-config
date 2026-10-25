#!/usr/bin/env bash
# Claude Code status line: model, dir/branch, context tokens, cost, duration, lines changed.
export LC_ALL=C
input=$(cat)
j() { jq -r "$1 // empty" <<<"$input" 2>/dev/null; }

R=$'\e[0m'; DIM=$'\e[2m'; CY=$'\e[36m'; MG=$'\e[35m'; GR=$'\e[32m'; YL=$'\e[33m'; RD=$'\e[31m'; BL=$'\e[34m'
SEP=" ${DIM}│${R} "
parts=()

human() { awk -v n="$1" 'BEGIN{ if(n>=1000000) printf "%.1fM",n/1e6; else if(n>=1000) printf "%.1fk",n/1e3; else printf "%d",n }'; }

model=$(j '.model.display_name')
[ -n "$model" ] && parts+=("${CY}🤖 ${model}${R}")

dir=$(j '.workspace.current_dir'); [ -z "$dir" ] && dir=$(j '.cwd')
if [ -n "$dir" ]; then
  d="📁 $(basename "$dir")"
  br=$(git -C "$dir" branch --show-current 2>/dev/null)
  [ -n "$br" ] && d+=" ${MG}(${br})${R}"
  parts+=("${BL}${d}${R}")
fi

# Context tokens
used=$(j '(.context_window.current_usage // empty) | ((.input_tokens//0)+(.cache_creation_input_tokens//0)+(.cache_read_input_tokens//0))')
size=$(j '.context_window.context_window_size')
if [ -z "$used" ] || [ "$used" = "0" ]; then
  tp=$(j '.transcript_path')
  if [ -n "$tp" ] && [ -f "$tp" ]; then
    used=$(tail -n 200 "$tp" | jq -r 'select(.message.usage != null) | .message.usage | ((.input_tokens//0)+(.cache_creation_input_tokens//0)+(.cache_read_input_tokens//0))' 2>/dev/null | tail -n 1)
  fi
fi
[ -z "$size" ] && size=200000
if [ -n "$used" ] && [ "$used" -gt 0 ] 2>/dev/null; then
  pct=$(( used * 100 / size ))
  if   [ "$pct" -ge 80 ]; then C=$RD
  elif [ "$pct" -ge 50 ]; then C=$YL
  else C=$GR; fi
  filled=$(( pct / 10 )); [ "$filled" -gt 10 ] && filled=10
  bar=""; for ((i=1;i<=10;i++)); do [ "$i" -le "$filled" ] && bar+="▓" || bar+="░"; done
  parts+=("${C}🧠 $(human "$used")/$(human "$size") (${pct}%) ${bar}${R}")
fi

cost=$(j '.cost.total_cost_usd')
[ -n "$cost" ] && parts+=("${YL}💰 \$$(printf '%.2f' "$cost")${R}")

ms=$(j '.cost.total_duration_ms')
if [ -n "$ms" ]; then
  m=$(( ${ms%.*} / 60000 )); h=$(( m / 60 ))
  [ "$h" -gt 0 ] && t="${h}h$(( m % 60 ))m" || t="${m}m"
  parts+=("${DIM}⏱ ${t}${R}")
fi

add=$(j '.cost.total_lines_added'); rem=$(j '.cost.total_lines_removed')
if [ -n "$add$rem" ]; then
  parts+=("${GR}+${add:-0}${R}/${RD}-${rem:-0}${R}")
fi

out=""
for p in "${parts[@]}"; do [ -n "$out" ] && out+="$SEP"; out+="$p"; done
printf '%s' "$out"
