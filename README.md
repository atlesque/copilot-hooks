# Copilot Hooks

VS Code Copilot hook scripts that send push notifications via [ntfy.sh](https://ntfy.sh) when the Copilot agent stops or is about to use certain tools.

## Files

| File | Purpose |
|------|---------|
| `copilot-notify.json` | Hook configuration — registers `Stop` and `PreToolUse` events |
| `scripts/copilot-notify.sh` | Shell script that parses the hook payload and sends ntfy notifications |

## Installation

```bash
# Clone into your home directory (or anywhere)
git clone git@github.com:atlesque/copilot-hooks.git ~/.copilot/hooks

# Make the script executable
chmod +x ~/.copilot/hooks/scripts/copilot-notify.sh
```

Then restart VS Code. Copilot will pick up the hook config from `~/.copilot/hooks/copilot-notify.json` automatically.

## Configuration

Edit `scripts/copilot-notify.sh` and set your own ntfy topic:

```bash
NTFY_TOPIC="your-topic-here"
```

The script requires `jq` and `curl` to be installed:

```bash
brew install jq curl   # macOS
```

## Behavior

- **Stop** — Notifies immediately when the Copilot agent finishes its output.
- **PreToolUse** — Notifies when Copilot is about to use a tool that may require approval (`terminal`, `run_in_terminal`, `edit`, `apply_patch`, `create_file`, `delete_file`, `replace_string_in_file`). Has a **120-second cooldown** to avoid notification spam.

### Disabling PreToolUse (autopilot mode)

If you run Copilot in autopilot mode where tool use never requires user feedback, remove the `PreToolUse` block from `copilot-notify.json` to only receive Stop notifications.

## Dependencies

- `bash`
- `jq` — JSON parsing
- `curl` — HTTP requests to ntfy.sh
