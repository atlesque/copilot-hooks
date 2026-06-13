#!/usr/bin/env bash
set -euo pipefail

NTFY_TOPIC="alexander-copilot-vscode-7f3d9c2a91b84e6aa1"
NTFY_URL="https://ntfy.sh/$NTFY_TOPIC"

# Cooldown in seconds for noisy PreToolUse notifications.
PRE_TOOL_USE_COOLDOWN=120

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/copilot-hooks"
PRE_TOOL_USE_STATE_FILE="$STATE_DIR/last-pretooluse-notification"

mkdir -p "$STATE_DIR"

payload="$(cat)"

event="$(echo "$payload" | jq -r '.hook_event_name // empty')"
tool_name="$(echo "$payload" | jq -r '.tool_name // empty')"

now="$(date +%s)"

send_notification() {
  local title="$1"
  local message="$2"

  curl -s \
    -H "Title: $title" \
    -H "Priority: default" \
    -d "$message" \
    "$NTFY_URL" >/dev/null
}

cooldown_allows_pretooluse() {
  local last_sent=0

  if [[ -f "$PRE_TOOL_USE_STATE_FILE" ]]; then
    last_sent="$(cat "$PRE_TOOL_USE_STATE_FILE" 2>/dev/null || echo 0)"
  fi

  local elapsed=$((now - last_sent))

  if (( elapsed >= PRE_TOOL_USE_COOLDOWN )); then
    echo "$now" > "$PRE_TOOL_USE_STATE_FILE"
    return 0
  fi

  return 1
}

case "$event" in
  Stop)
    send_notification \
      "Copilot agent stopped" \
      "The VS Code Copilot agent has finished output."
    ;;

  PreToolUse)
    case "$tool_name" in
      terminal|run_in_terminal|edit|apply_patch|create_file|delete_file|replace_string_in_file)
        if cooldown_allows_pretooluse; then
          send_notification \
            "Copilot needs attention" \
            "Copilot is about to use tool: $tool_name. It may need approval or feedback."
        fi
        ;;
    esac
    ;;
esac
