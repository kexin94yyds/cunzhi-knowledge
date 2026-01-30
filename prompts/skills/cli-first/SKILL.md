---
name: cli-first
description: CLI-first build workflow. Use when building a tool/app/automation or extension; start with a CLI, validate outputs, then layer UI/extension. Triggers: cli first, command line first, terminal first, CLI-first.
---

# CLI-First Skill

Build the core as a CLI so agents can run, verify, and close the loop before any UI work.

## Core principles

1. CLI is the source of truth. UI/extension wraps the CLI, not the other way around.
2. Make I/O explicit and machine-checkable (exit codes, JSON, files).
3. Keep the CLI stable after v1; add flags, do not break outputs.
4. Only add UI when the CLI path is correct and repeatable.

## Workflow

1. Define the CLI contract
   - Command name, flags, input source, output destination
   - Error behavior and exit codes
2. Build the minimal happy path
   - One narrow use case that works end-to-end
3. Add verification hooks
   - `--dry-run`, `--json`, or deterministic file output
   - Golden output files or snapshot tests
4. Run and validate
   - Use the CLI to verify outputs locally
5. Wrap with UI/extension
   - UI calls the CLI or shares the same core module
   - Keep a CLI path for regression checks

## I/O contract checklist

- Inputs: file path, stdin, or URL (one primary path)
- Outputs: stdout (text or JSON) and/or output file
- Errors: non-zero exit + concise message
- Deterministic output option for tests

## When to skip CLI-first

- Purely UI-driven prototypes where no reusable core exists
- One-off visual prototypes with no automation value

## Example prompt

"Start with a CLI that takes <input> and produces <output>. Add --json and a deterministic output mode. Once that works, build the UI on top of the same core."
