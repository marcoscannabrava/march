---
name: vertical-slicing
description: >
  Use when a feature or project is too big to ship in one go and needs to be split into
  independently shippable, demoable increments — to de-risk delivery, get value out sooner, and
  parallelize work. Triggers: "break this into issues", "how do we ship this incrementally",
  "split into tickets", "slice this up", "epic", a large feature after `prd`/`tech-spec`. Emits
  Linear-ready issues and flags risky cross-slice dependencies. For task-level (not slice-level)
  decomposition of a single increment, use `writing-plans`.
---

# Vertical Slicing

Slice a feature so each piece delivers end-to-end user value on its own (UI → logic → data),
rather than horizontal layers ("all the backend", then "all the frontend") that deliver nothing
until the last one lands. Vertical slices ship, demo, and de-risk early.

## How to slice

1. **Find the thinnest end-to-end path** — the simplest case a real user can complete start to
   finish. That's slice 1 (often behind a flag). It proves the whole pipe works.
2. **Add value per slice** — each subsequent slice adds one capability, edge case, or surface,
   and is independently shippable and demoable.
3. **Defer the hard/optional** — push complex edge cases, scale work, and nice-to-haves to later
   slices so the core ships sooner.
4. **Order by value × risk** — do the riskiest assumptions early (fail cheap) and the
   highest-value path first.

## Output: Linear-ready issues

For each slice produce:
- **Title** — outcome-oriented, user-visible where possible.
- **What ships** — the behavior a user/stakeholder can see when this slice is done.
- **Acceptance criteria** — checkable conditions of done.
- **Dependencies** — which slices/issues must land first. **Flag risky cross-slice coupling
  explicitly** — if two slices can't truly ship independently, say so and reconsider the cut.

## Rules

- A slice that delivers no observable value is a horizontal layer in disguise — re-cut it.
- Smaller is better; if a slice can't ship in a few days, split again.
- Offer to create the issues in Linear (via MCP) once the slicing is confirmed — don't auto-create.
- Name what's flagged/hidden until later slices land, so half-built work is never user-visible.
