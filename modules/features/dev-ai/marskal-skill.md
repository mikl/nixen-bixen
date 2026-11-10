---
name: marskal
description: Manage the user's personal tasks, projects and tags in Marskal through the `marskal` CLI. Use when the user asks to add, capture, list, find, complete, drop, reschedule, flag, tag or move a task or to-do, to create or close a project, or to check their inbox — e.g. "add a task", "remind me to…", "put this on my list", "what's planned today", "mark X done".
---

# Marskal

`marskal` is the user's task manager CLI. It keeps a local database and
syncs with the server on each command.

## Ground rules

- Pass `--json` whenever you need to read the result. The shape is stable;
  the plain-text output is for humans.
- Tasks are referred to by id: the full UUID or the 8-character short id
  that `ls` prints first on each line. Titles do **not** resolve, so look a
  task up with `marskal --json ls …` before changing it.
- Projects (`-p/--project`) resolve by id, id prefix, or title. Run
  `marskal projects` first if unsure of the exact title; never invent one —
  ask, or fall back to the inbox.
- Tags (`-t/--tag`) resolve by name or path. Run `marskal tags` to see
  them. Nested tags are shown as `Parent › Child`.
- Titles take several words without quotes, but quote anything containing
  shell metacharacters (`#`, `&`, `'`, `?`, `*`, …).
- Done and Drop are how work ends. Only use `rm` (deletes the task and all
  its subtasks) when the user explicitly asks to delete; confirm first.
- After writes, if output mentions refused commands, run
  `marskal rejections` and report what the server rejected.

## Dates

`--planned`, `--due` and `--defer` accept `today`, `tomorrow`, weekday names
(`fri`), offsets (`+3d`) or ISO dates (`2026-10-05`), optionally with a
time. Planned = when the user intends to work on it; due = hard deadline;
defer = hidden until then (`--defer-indefinitely` for "someday").

## Commands

```sh
# Capture (inbox unless a place is given)
marskal add Buy milk
marskal add -p "Backups" -t Sysadmin --due fri -f Check restore of NAS
marskal add --parent f9fb5d42 Sub-step title
marskal add -n "longer notes" -u https://example.com/ticket/1 Title

# List
marskal ls                  # open stream
marskal ls --inbox
marskal ls -p "Backups"     # a project's open tasks
marskal ls -t Arbejde       # tag, including tags below it
marskal ls -f               # flagged
marskal ls -a               # include deferred/unavailable
marskal ls --everything     # include Done and Dropped
marskal show <task>

# Change state (several ids at once is fine)
marskal done <task>...
marskal drop <task>...
marskal reopen <task>...

# Edit fields; every setter has a --no-* counterpart that clears it
marskal edit <task> --title "New title" --planned tomorrow --no-due
marskal edit <task> -n "notes" | --no-note | -u URL | --no-url
marskal edit <task> --flag | --no-flag
marskal edit <task> --parent <task> | --no-parent

# Place and tags
marskal move <task> -p "Project" | --inbox | --no-project
marskal tag <task> <tag>
marskal untag <task> <tag>

# Projects and tags
marskal projects                                   # list
marskal projects add --folder Reload -f -u URL Project title
marskal projects flag|unflag|done|drop|reopen <project>
marskal tags
marskal tags add --parent Arbejde NewTag

# Housekeeping
marskal status     # sign-in and sync state
marskal sync
```

Run `marskal <command> --help` for anything not covered here.

## Reporting back

After a change, confirm in one line with the short id, title and where it
landed (project/inbox, dates, tags). Don't dump JSON at the user.

If `marskal status` shows the device is signed out, tell the user to run
`marskal login` themselves (it opens a browser); don't attempt it.
