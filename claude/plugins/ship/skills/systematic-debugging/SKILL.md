---
name: systematic-debugging
description: >
  Use when something is broken and the cause isn't obvious — failing tests, unexpected output,
  intermittent/flaky behavior, a crash, "it worked yesterday", or a fix that didn't hold.
  Enforces a four-phase root-cause process instead of guess-and-patch. Triggers: "why is this
  failing", "debug", "this isn't working", "flaky", "intermittent", "regression", a stack trace,
  an error message. Use the moment you catch yourself about to change code you don't understand.
---

# Systematic Debugging

Guess-and-patch wastes time and leaves latent bugs — you fix a symptom and the cause resurfaces.
Find the actual cause, then fix once.

## The four phases

1. **Reproduce.** Get a reliable, minimal trigger. If it's intermittent, find what varies between
   pass and fail (data, order, timing, environment). You cannot fix what you can't reproduce —
   make reproduction the first goal, not an afterthought.
2. **Isolate.** Narrow to the smallest failing case. Bisect: by code (git bisect / comment-out),
   by input (shrink the data), by layer (does the unit fail, or only the integration?). Add
   instrumentation — log the actual values at the boundary where expectation diverges from reality.
3. **Hypothesize.** State a specific, falsifiable cause: "X is null here because Y returns early
   when Z." Predict what you'd observe if it's true. Then test that prediction — don't fix yet.
   If the observation contradicts the hypothesis, discard it and form a new one. Don't stack guesses.
4. **Fix + verify.** Fix the confirmed root cause. Prove it: the reproduction now passes, and you
   understand *why* the fix works. Add a regression test (see `test-driven-development`). Check for
   sibling bugs sharing the same cause.

## Rules

- One hypothesis at a time. Changing several things at once destroys the signal.
- Read the actual error and the actual values. Assumptions about what the code does are the bug's
  best hiding place — verify by observation.
- If a "fix" works but you can't explain why, you're not done — you got lucky or moved the symptom.
- Revert experimental instrumentation/changes that weren't the fix before finishing.
