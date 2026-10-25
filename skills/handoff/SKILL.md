---
name: handoff
description: Save the current Claude Code session as a structured summary into the shared ~/claude-config git repo so it can be resumed on another machine (Linux ↔ macOS), or load such a summary to resume. Use when the user says "/handoff save <topic>", "/handoff load [topic]", "save this session for later", "continue on my Mac", "resume <topic>", or "where were we on <topic>".
---

# Handoff

Sessions and plans in `~/.claude` are local to each machine. Handoffs live in the shared git repo, one file per topic: `~/claude-config/handoffs/<topic>.md`. The user works on both a Linux machine and a Mac.

Arguments: `$ARGUMENTS`.
- `save <topic>`: save the session.
- `load [topic]`: resume a session.
- Anything else, or nothing: infer the intent from the conversation, and ask if it's unclear.

`<topic>` is a short kebab-case name such as `budget-app`. If no topic is given on save, propose one based on the session.

## Never put in a handoff
The handoff file is pushed to GitHub, so:
- No credentials: API keys, tokens, passwords, SSH/private keys, `.env` contents.
- No raw personal financial data: no transaction rows, IBANs, account or card numbers. Describe the data format instead (e.g. "CSV with columns Date;Label;Amount").
- No personal identifiers beyond the user's first name, such as addresses, phone numbers or other people's names.
- No absolute home paths (`/home/...`, `/Users/...`). Use `~`.

## Save
1. Run `uname -s` (Darwin means macOS, Linux means Linux) and `hostname -s`.
2. Run `git -C ~/claude-config pull --rebase --autostash`. On a conflict, stop and show the conflicting files.
3. Write `~/claude-config/handoffs/<topic>.md`, overwriting any existing file. It always holds the latest state, and git keeps the history. Use this structure:
   ```
   # <topic>
   Updated: <YYYY-MM-DD> · from <macOS|Linux> (<hostname>) · project dir: <path with ~, or "none yet">

   ## Goal
   ## Decisions made (and why)
   ## Current plan
   ## Progress / done
   ## Next step
   ## Open questions
   ## User preferences learned
   ```
   - **Current plan**: if the session used a plan file (`~/.claude/plans/*.md`), inline its relevant content in full. The plans folder isn't synced.
   - **Next step**: the exact first action to take on resume.
   - **User preferences learned**: only preferences specific to this topic. Global ones belong in `CLAUDE.md`.
   - Write a summary, not a transcript. Keep it self-contained, so that a fresh session with no other context can continue from it.
4. Check the file against "Never put in a handoff" above. If anything violates a rule, remove it. If you're unsure, ask the user.
5. Commit only this file:
   - `git -C ~/claude-config add handoffs/<topic>.md` (never `-A`, since other uncommitted changes in the repo are not part of the handoff)
   - `git -C ~/claude-config commit -m "Handoff <topic> from <macOS|Linux> (<hostname>)"`
   - The message is one line only: no body and no Co-Authored-By trailer.
   - Running `/handoff save` is the user's explicit request to commit. It is **not** permission to push.
6. **Ask before pushing.** Show the commits about to go out (`git -C ~/claude-config log --oneline @{u}..`), warn that they'll be sent to GitHub, and ask the user to confirm. Wait for an explicit yes, then run `git -C ~/claude-config push` as a separate command.
   - If the user says no, leave the commit local and tell them to run `git -C ~/claude-config push` later.
7. If the push fails, explain why. If it succeeds, report the file path and the resume command for the other machine: `/handoff load <topic>`.

## Load
1. Run `git -C ~/claude-config pull --rebase --autostash`. If it fails (network or conflict), say so and continue with the local copy.
2. If there's no topic, list `~/claude-config/handoffs/*.md` with each file's `Updated:` line, and ask which one to load.
3. Read the file. Give a summary of where things stand in about 5 lines, then propose the **Next step**.
4. If the project dir doesn't exist on this machine, say so. It may need a `git clone`, or it may never have been pushed from the other machine.
5. Follow the file's "User preferences learned" for the rest of the session.
