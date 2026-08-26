---
name: tech-spec
description: >
  Use when a feature's requirements are settled and you need a technical design before
  implementation — for anything non-trivial, cross-service, schema-touching, or with meaningful
  architectural choices. Triggers: "tech spec", "design doc", "how should we architect this",
  "technical design", "RFC", after a `prd` is agreed. Produces architecture, data model,
  interfaces, rollout, and a test plan, with alternatives and open questions. Pairs with
  `vertical-slicing` to turn the design into shippable increments.
---

# Tech Spec (Technical Design Doc)

Turn agreed requirements into a design the team can review and build against. The point is to
make the hard decisions — and their trade-offs — explicit *before* code, where they're cheap to change.

## Structure

1. **Summary & link to PRD** — what we're building, one paragraph; link the requirements.
2. **Approach** — the chosen design end-to-end. Diagram the components and the data flow.
3. **Data model** — new/changed tables, fields, types, migrations. Backward compatibility.
4. **Interfaces** — API endpoints / function signatures / events; request/response shapes; error
   cases. How callers and consumers integrate.
5. **Alternatives considered** — the 1–2 other approaches and why you rejected them. (Reviewers'
   first question; answer it up front.)
6. **Rollout & migration** — flags, phasing, backfill, reversibility. How to ship safely.
7. **Test plan** — what proves it correct (unit/integration/e2e), and what you'll monitor in prod.
8. **Risks & open questions** — performance, scale, failure modes, security/privacy, dependencies.

## Process

- Explore the existing codebase first — reuse current patterns, models, and utilities; name them.
- Prefer the smallest design that meets the requirements and is reversible.
- Flag the decisions that need sign-off vs. the ones you'll make as you go.

## Rules

- Make trade-offs explicit; "X over Y because Z". A spec with no rejected alternatives is suspect.
- Design for safe rollout and rollback, not just the happy path.
- Touching a shared schema/CMS? Trace downstream consumers before committing to the change.
- Keep it reviewable — diagrams and tables over prose. Hand off to `writing-plans` / `vertical-slicing`.
