---
name: update-claude-config
description: Sync and update the shared Claude Code config (settings, permissions, hooks, CLAUDE.md, status line, skills) kept in the ~/claude-config git repo, on Linux or macOS. Use when the user says "update/sync my claude config", "pull my claude settings", "add a permission/hook/instruction everywhere", or wants a Claude Code setting changed on all their machines.
---

# Update Claude config

The shared Claude Code config lives in the git repo `~/claude-config`. Each file is symlinked into `~/.claude` by `install.sh`. The repo is the source of truth, so always edit files there and never in `~/.claude` directly. The user works on both a Linux machine and a Mac.

Arguments: `$ARGUMENTS`. When this is empty, just sync (steps 1–4, then 6–7). Otherwise it describes a change to make.

## 1. Detect the machine
Run `uname -s` and `hostname -s`. Darwin means macOS and Linux means Linux. Tell the user in one line, e.g. "Running on macOS (macbook)". Remember the OS for the later steps.

## 2. Get the latest config
- If `~/claude-config` doesn't exist, clone it: `git clone git@github.com:raphnah29/claude-config.git ~/claude-config`.
- Otherwise:
  - If `git -C ~/claude-config status --porcelain` shows uncommitted local changes, mention them. They'll be committed in step 6.
  - Run `git -C ~/claude-config pull --rebase --autostash`.
  - If the pull fails because there's no remote yet, the remote repo doesn't exist, or the network is down, say so and continue locally.
  - On a conflict, stop and show the conflicting files. Don't resolve them silently.

## 3. Check dependencies for this OS
`jq` is required by the status line and is used to validate settings.
- If it's missing, propose `brew install jq` on macOS or `sudo apt install jq` on Linux.
- Run the install command only after the user approves.

## 4. Link files on this machine
Run `~/claude-config/install.sh`. It's idempotent: it backs up any real file it replaces and creates the missing symlinks. When a new top-level file or folder is added to the repo, also add it to `ITEMS` in `install.sh`.

## 5. Apply the requested change (only if `$ARGUMENTS` asks for one)
- Edit files inside `~/claude-config`.
  - `settings.json` holds permissions, hooks, the status line and env vars.
  - `CLAUDE.md` holds global instructions.
  - `skills/<name>/SKILL.md` holds skills.
- Keep everything portable across Linux and macOS:
  - Never hardcode an OS-only command in `settings.json`, such as `notify-send`, `osascript`, `pbcopy`, `xdg-open` or `apt`/`brew`.
  - Put that kind of command in a script in the repo that branches on `uname -s` (see `notify.sh`). Call the script as `~/.claude/<script>.sh` and link it through `install.sh`.
  - Use `~` or `$HOME`, never `/home/raphael` or `/Users/raphael`.
  - Write scripts for bash 3.2, the macOS default: no `declare -A`, no `mapfile`, no `${var,,}`. Avoid GNU-only flags such as `sed -i` without a suffix argument.
- After you edit `settings.json`, run `jq . ~/claude-config/settings.json >/dev/null`. If it fails, fix the file.
- Run `bash -n` on any script you edited.

## 6. Commit and push
- Run `git -C ~/claude-config status --porcelain`. If it's empty, report "already up to date" and skip the rest of this step.
- Show a short `git diff --stat`.
- Before committing, scan the diff for secrets, such as API keys, tokens, `.credentials.json` or private keys. If you find one, stop and warn the user.
- Commit everything with this message format:
  `Update Claude config from <macOS|Linux> (<hostname>): <short summary>`
  The message is one line only: no body and no Co-Authored-By trailer.
- **Ask before pushing.** Show the commits about to go out (`git log --oneline @{u}..`) and ask the user to confirm. Wait for an explicit yes, then run `git push` as a separate command.
- If there's no remote or the push is rejected, explain why and how to fix it. For example: create the private repo `claude-config` on GitHub, then run `git push -u origin main`.

## 7. Report
Briefly tell the user:
- what was pulled
- what changed
- what was pushed

If `settings.json` or a hook changed, say that Claude Code needs a restart, or `/hooks` reviewing, before the change takes effect.
