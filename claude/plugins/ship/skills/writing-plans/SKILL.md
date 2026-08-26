---
name: writing-plans
description: >
  Use when the approach is understood and it's time to turn it into an executable plan — before
  starting a multi-step implementation, a refactor, or any change spanning more than a couple of
  files. Decomposes work into small, ordered, individually-verifiable tasks with exact file paths
  and a check for each. Triggers: "write a plan", "break this down", "what are the steps", "plan
  out", starting a feature with a clear approach. Pairs with `brainstorming` (before) and
  `vertical-slicing` (when the unit is a shippable increment, not a code task).
---

# Writing Plans

A good plan is executable by someone with no extra context. Each step is small enough to verify
on its own, so a wrong turn is caught immediately instead of three steps later.

## What a plan task looks like

Each task has:
- **Action** — one concrete change, ~2–5 minutes of work. If it's bigger, split it.
- **Files** — exact paths to create/edit (and the function/section within them).
- **Reuse** — existing utilities/patterns to use instead of writing new code (name them).
- **Verification** — the command or observation that proves this step worked (test, build, run,
  curl, screenshot). A step with no check isn't done.

## Process

1. State the goal and the end-state in 1–2 sentences.
2. List the tasks in dependency order. Number them. Keep each independently verifiable.
3. For risky/uncertain tasks, add the fallback or the thing to confirm first.
4. Call out a **verification section** at the end: how to prove the whole thing works end-to-end.
5. Note anything intentionally deferred or out of scope.

## Rules

- Reference real files and real existing helpers — explore first, don't invent paths.
- No mega-steps. "Implement the feature" is not a task; the five edits that compose it are.
- Prefer editing existing code over adding parallel new code; say which.
- Every task ends in a checkable state. If you can't name the check, the task is underspecified.
- Keep the plan scannable — a reader should grasp the shape in 30 seconds.
