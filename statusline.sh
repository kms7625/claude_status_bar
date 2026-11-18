#!/usr/bin/env bash
# Claude Code Status Line Script
# Displays: Model | Directory | Git Branch | Context %
input=$(cat)
# 1. 모델명
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
# 2. 현재 디렉토리명
workspace_dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')
if [ -z "$workspace_dir" ]; then
  workspace_dir=$(echo "$input" | jq -r '.cwd // "~"')
fi
workspace_name=$(basename "$workspace_dir")
# 3. Git branch
git_branch=""
if [ -n "$workspace_dir" ] && [ -d "$workspace_dir" ]; then
  git_branch=$(git -C "$workspace_dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi
# epoch 초 → 시각 문자열 (GNU date: Windows Git Bash·Linux / BSD date: macOS)
fmt_ts() {
  if date --version >/dev/null 2>&1; then
    date -d "@$1" "+$2" 2>/dev/null
  else
    date -r "$1" "+$2" 2>/dev/null
  fi
}
# 4. 사용량 퍼센트 (5시간 현재 / 7일 주간)
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
five_hour_reset_ts=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
if [ -n "$five_hour_reset_ts" ]; then
  five_hour_reset_time=$(fmt_ts "$five_hour_reset_ts" "%H:%M")
fi
seven_day_reset_ts=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
if [ -n "$seven_day_reset_ts" ]; then
  seven_day_reset_time=$(fmt_ts "$seven_day_reset_ts" "%m/%d %H:%M")
fi
if [ -n "$five_hour_pct" ]; then
  five_hour_display=$(awk -v p="$five_hour_pct" 'BEGIN{printf "%.0f%%", p}')
  if [ -n "$five_hour_reset_time" ]; then
    five_hour_display="${five_hour_display} (~${five_hour_reset_time})"
  fi
else
  five_hour_display="--"
fi
if [ -n "$seven_day_pct" ]; then
  seven_day_display=$(awk -v p="$seven_day_pct" 'BEGIN{printf "%.0f%%", p}')
  if [ -n "$seven_day_reset_time" ]; then
    seven_day_display="${seven_day_display} (~${seven_day_reset_time})"
  fi
else
  seven_day_display="--"
fi
# 5. 컨텍스트 퍼센티지
context_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$context_pct" ]; then
  context_display="${context_pct}%"
else
  context_pct="--"
  context_display="--"
fi
# Color codes
RESET=$'\033[0m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
BLUE=$'\033[34m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
RED=$'\033[31m'
# Context color
if [ "$context_pct" != "--" ]; then
  if [ "$context_pct" -ge 80 ] 2>/dev/null; then
    CTX_COLOR=$RED
  elif [ "$context_pct" -ge 60 ] 2>/dev/null; then
    CTX_COLOR=$YELLOW
  else
    CTX_COLOR=$GREEN
  fi
else
  CTX_COLOR=$DIM
fi
# Build status line
line="${BLUE}${BOLD}🤖 ${model}${RESET}"
line+=" ${DIM}${CYAN}|${RESET} "
line+="${MAGENTA}📂 ${workspace_name}${RESET}"
if [ -n "$git_branch" ]; then
  line+=" ${DIM}${CYAN}|${RESET} "
  line+="${YELLOW}🔀 ${git_branch}${RESET}"
fi
line+=" ${DIM}${CYAN}|${RESET} "
line+="${CTX_COLOR}${BOLD}🧠 ${context_display}${RESET}"
line+=" ${DIM}${CYAN}|${RESET} "
line+="${GREEN}⏱ ${five_hour_display}${RESET}"
line+=" ${DIM}${CYAN}|${RESET} "
line+="${GREEN}📅 ${seven_day_display}${RESET}"
echo -e "$line"
