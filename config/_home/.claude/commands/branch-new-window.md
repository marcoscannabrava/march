---
description: Fork this session into a new terminal window
allowed-tools: Bash(setsid:*), Bash(ls:*)
argument-hint: "[optional first prompt for the fork]"
---

Open a new terminal window running a forked copy of this session.

1. Get the current session id: it is the last path segment of the scratchpad
   directory named in your environment block (a UUID). If no scratchpad
   directory is named, fall back to the newest transcript:

   ```
   ls -t ~/.claude/projects/$(pwd | sed 's|/|-|g')/*.jsonl | head -1
   ```

   and take its basename without `.jsonl`.

2. Launch the window from the current working directory:

   ```
   setsid uwsm-app -- xdg-terminal-exec --dir="$PWD" -- \
     claude --resume <session-id> --fork-session
   ```

   If `$ARGUMENTS` is not empty, append it as a quoted final argument so the
   fork starts on that prompt.

3. Report the session id you forked and nothing else. Do not wait on the
   command — it detaches.
