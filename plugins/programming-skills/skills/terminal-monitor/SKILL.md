---
name: terminal-monitor
description: >
  Utility skill for opening a named terminal pane (tmux or iTerm2) to monitor
  a subagent or team member's output in real time. Supports both Agent tool
  (subagents) and TeamCreate tool (Claude teams). Call this skill before
  launching any Agent or team member, passing mode, label, pane-name, and the
  relevant output target as context. Detects terminal type once per session and
  reuses it across calls.
license: MIT
metadata:
  author: Wesley Egberto
  version: "1.0.0"
  domain: developer-experience
  scope: utility
  role: helper
  triggers: open pane, monitor agent, terminal pane, tmux pane, iterm pane, monitor team, team pane, subagent pane
  related-skills: java-feature-development, react-feature-development, node-feature-development
---

# Terminal Monitor — Utility Skill

Opens a dedicated terminal pane (tmux or iTerm2) to let the user follow a
subagent's or team member's output in real time.

---

## Parameters (passed by the calling skill via context)

| Parameter | Required | Description |
|-----------|----------|-------------|
| `mode` | yes | `subagent` or `team` |
| `label` | yes | Header text displayed in the pane |
| `pane-name` | yes | Short name for the tab/window |
| `output-file` | if `mode: subagent` | File to tail (written by the agent) |
| `team-name` | if `mode: team` | Team name (used to locate `.team/<team-name>/`) |
| `team-member` | optional | Specific team member to monitor; omit to show full team activity |

---

## Protocol

Execute the steps below every time this skill is called.

### Step 1 — Detect terminal type (once per session)

If the terminal type has NOT been detected yet in this session, run:

```bash
if [ -n "$TMUX" ]; then
  echo "tmux"
elif [ -n "$ITERM_SESSION_ID" ] || [ "$TERM_PROGRAM" = "iTerm.app" ]; then
  echo "iterm2"
else
  echo "none"
fi
```

Store the result as `TERMINAL_TYPE`. On subsequent calls reuse the stored value
— do NOT re-detect.

If `TERMINAL_TYPE` is `none`, print **once** (not on every call):

```
Terminal multiplexer not detected (no tmux session, ITERM_SESSION_ID not set).
Agents will run without dedicated panes.
To enable live monitoring: run Claude inside a tmux session or use iTerm2.
```

Then return immediately — skip Steps 2 and 3.

---

### Step 2 — Build the monitoring command

**`mode: subagent`** — tail the output file as soon as it appears:

```bash
echo '=== <label> ==='; \
until [ -f <output-file> ]; do sleep 1; done; \
tail -f <output-file>
```

**`mode: team`, with `team-member`** — tail that member's output file:

```bash
echo '=== <label> ==='; \
until [ -f .team/<team-name>/<team-member>.md ]; do sleep 1; done; \
tail -f .team/<team-name>/<team-member>.md
```

**`mode: team`, without `team-member`** — watch the team directory for activity:

```bash
echo '=== <label> ==='; \
watch -n 2 "ls -lt .team/<team-name>/ 2>/dev/null | head -20"
```

---

### Step 3 — Open the pane

**tmux:**

```bash
# Ensure the monitoring session exists (only first call creates it)
tmux has-session -t agent-monitor 2>/dev/null || \
  tmux new-session -d -s agent-monitor -n "orchestrator"

# Open a named window running the monitoring command
tmux new-window -t agent-monitor -n "<pane-name>" \
  "MONITORING_CMD; exec bash"
```

Replace `MONITORING_CMD` with the command built in Step 2.

**iTerm2** (via AppleScript):

```applescript
tell application "iTerm2"
  tell current window
    create tab with default profile
    tell current session
      set name to "<pane-name>"
      write text "MONITORING_CMD"
    end tell
  end tell
end tell
```

Replace `MONITORING_CMD` with the command built in Step 2.

---

### Step 4 — Return to caller

After opening the pane, return control to the calling skill immediately. The
pane runs independently; the calling skill proceeds to launch the agent or team
member without waiting.
