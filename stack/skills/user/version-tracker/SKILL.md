---
name: version-tracker
description: Automatically tracks and saves versioned snapshots of work. Use this skill proactively whenever the user wants to save a version, track an iteration, checkpoint progress, bump a version number, or preserve the current state. Triggers on phrases like "save version", "track this", "checkpoint", "v2", "next version", "bump version", "save a copy", "track iteration", "preserve this", "new version", "archive this", or whenever a significant piece of work completes and should be archived. Never deletes old versions — always accumulates.
---

# version-tracker skill

## Purpose

Every time an iteration completes, automatically increment the version counter and save a full snapshot of the current workspace state. **Versions are never deleted — they accumulate forever.**

## Storage Layout

```
~/Documents/version-tracker/
├── .version_state.json          ← version counter + full history index
└── versions/
    ├── v0001_20260609_143022/   ← snapshot at version 1
    ├── v0002_20260609_150511/   ← snapshot at version 2
    └── ...                      ← accumulates indefinitely
```

## How to Invoke

Run the bundled script via bash:

```bash
python3 ~/ai-stack-template/stack/skills/user/version-tracker/scripts/save_version.py \
  --message "describe what changed in this version"
```

To snapshot only specific files:

```bash
python3 ~/ai-stack-template/stack/skills/user/version-tracker/scripts/save_version.py \
  --message "checkpoint after refactor" \
  --files file1.py file2.md
```

## What the Script Does

1. Reads `.version_state.json` to get the current version number (starts at 0)
2. Increments to `next_version = current + 1`
3. Creates `versions/v{NNNN}_{YYYYMMDD_HHMMSS}/` directory
4. Copies all non-excluded workspace files into that directory
5. Appends a version entry to `.version_state.json` with timestamp, message, and file list
6. Prints a confirmation summary

## Invariant Rules

- **Never delete any version directory** — all versions persist forever
- **Always increment** — never reuse a version number
- **Always copy** — snapshots are full copies, not diffs
- `.version_state.json` is the source of truth for the counter; never manually edit it

## What to Report Back to User

After running the script, parse its stdout and report:

```
✓ Saved version v{N} → {version_dir_name}
  Files: {comma-separated list}
  Note: {message if provided}
  Total versions stored: {count}
```

If the script errors, show the stderr output and do not claim success.

## Triggering Examples

| User says | Action |
|-----------|--------|
| "save version" | Run script with a short auto-generated message |
| "checkpoint before refactor" | Run script with `--message "before refactor"` |
| "bump to v3" | Run script; the counter auto-increments regardless of label |
| "archive this" | Run script with `--message "archive"` |
| "track this iteration" | Run script with descriptive message about what just happened |
