# /iterate-loop

**Template Category**: Action

Iterative build loop: build a small slice, run it, feel the result, then refine.

## Input

- `$1` (task_id): task tracking ID
- `$2` (task_description): detailed task description

## Instructions

1. Define the smallest runnable slice (one thin vertical path).
2. Implement the minimal change to make it run end-to-end.
3. Run or preview the slice.
4. Capture observations (what feels wrong or missing).
5. Apply one focused tweak per iteration.
6. Repeat until the user accepts the behavior.
7. When stable, write docs to `docs/*.md` for new behavior.

## Report

Return a concise loop summary:
- iterations run
- key adjustments made
- current state and next suggested tweak (if any)

**Do not include:**
- Markdown headings
- verbose explanations

**Example output:**
```
- Iterations: 3
- Adjustments: input parsing tightened; output format stabilized; error message simplified
- State: matches expected behavior; ready for docs update
- Next: optional UI wrapper
```
