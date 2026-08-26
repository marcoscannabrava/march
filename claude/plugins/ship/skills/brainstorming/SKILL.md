---
name: brainstorming
description: >
  Use BEFORE writing any code or plan when a task is non-trivial, ambiguous, or could be built
  several ways — feature requests, new systems, vague asks ("add X", "we should support Y"),
  or anything where requirements aren't pinned down. Interrogates the request, surfaces hidden
  assumptions and constraints, and presents the design in small reviewable chunks before
  implementation. Triggers: "let's design", "how should we build", "I want to add", new feature,
  unclear scope, greenfield work. Do NOT use for mechanical edits with an obvious single answer.
---

# Brainstorming

Lock down *what* and *why* before *how*. Jumping to code on an underspecified request is the
most expensive mistake — you build the wrong thing confidently. This skill front-loads the cheap
questions.

## Process

1. **Restate the request** in one sentence and name the underlying goal. Confirm you've got it
   right before going further.
2. **Interrogate — one cluster of questions at a time, not a wall of 20.** Cover:
   - Who is this for, and what do they do today instead?
   - What's explicitly *out* of scope? (Non-goals prevent scope creep.)
   - What's the smallest version that delivers value?
   - Hard constraints: deadlines, systems it must integrate with, data/privacy, scale.
   - How will we know it worked? (Ties into `analytics-instrumentation`.)
   - What could go wrong / what's the riskiest assumption?
3. **Reflect back** what you heard as a short bulleted understanding. Let the user correct it.
4. **Surface the design in digestible sections** — one decision area at a time (data model, then
   interface, then rollout…). After each, pause for agreement. Don't dump a full spec at once.
5. **Name the open questions** that still block a confident plan. Resolve or explicitly defer each.

## Rules

- Ask, don't assume. If you're filling a gap with a guess, say so and flag it for confirmation.
- Prefer the smallest scope that ships value; suggest cutting before adding.
- One reversible decision shouldn't block the others — separate "must decide now" from "decide later".
- End by recommending the next skill: usually `writing-plans` (if approach is clear) or `prd`
  (if this is a product feature needing a written artifact) or `vertical-slicing` (if it's large).
