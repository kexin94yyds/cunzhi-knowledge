# /model-routing

**Template Category**: Action

Route tasks to the right model based on scope and risk.

## Input

- `$1` (task_id): task tracking ID
- `$2` (task_description): detailed task description

## Instructions

1. Classify task size:
   - small edit (single file, <=50 lines)
   - medium feature (2-5 files)
   - large refactor (multi-module or cross-cutting)
2. Route by size:
   - small: Opus
   - medium: codex high
   - large: codex high
3. Avoid ultra-high modes unless explicitly required.
4. If unsure, pick codex high and note why.

## Report

Return routing decision:
- task size
- chosen model + mode
- reason

**Example output:**
```
- Size: large refactor
- Model: codex (reasoning=high)
- Reason: multi-file changes; higher read-coverage needed
```
