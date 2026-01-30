# /cross-project

**Template Category**: Action

Reuse an existing implementation from a sibling project and adapt it.

## Input

- `$1` (task_id): task tracking ID
- `$2` (task_description): detailed task description
- `$3` (source_project_path): relative or absolute path to source project

## Instructions

1. Search the source project for the feature or pattern.
2. Identify the minimal set of files to copy or mirror.
3. Adapt to the current project conventions (paths, config, types).
4. Update any changelog or docs as needed.
5. Verify the behavior in the current project.

## Report

Return a concise reuse summary:
- source files used
- target files changed
- adaptation notes
- verification performed

**Example output:**
```
- Source: ../vibetunnel/src/changelog.ts
- Target: src/changelog.ts
- Adaptation: path aliases updated; config keys renamed
- Verification: local build ok
```
