---
name: prd
description: >
  Use when a product feature or initiative needs a written requirements doc before building —
  capturing problem, users, scope, non-goals, and success metrics so engineering and stakeholders
  align. Triggers: "write a PRD", "product requirements", "spec out this feature", "what are we
  building and why", kickoff of a product feature, or turning a brainstorming session into a
  durable artifact. Produces a PRD and offers to file it in Linear/Notion. For the *technical*
  design that follows, use `tech-spec`; to split the work, use `vertical-slicing`.
---

# PRD (Product Requirements Document)

A PRD answers *what we're building, for whom, and why* — and how we'll know it worked. It's the
shared contract before engineering commits. Keep it tight; a PRD nobody reads is waste.

## Structure

1. **Problem & context** — what's broken or missing today, for whom, and the evidence (data,
   support tickets, user quotes). Why now?
2. **Goal** — the outcome we want, in one sentence. The change in user/business behavior.
3. **Target users** — who specifically; their current workaround.
4. **Scope (v1)** — the smallest set of capabilities that delivers the goal. Bullet the user-
   visible behavior, not the implementation.
5. **Non-goals** — what we are deliberately NOT doing. This section prevents the most pain.
6. **Success metrics** — the primary metric that defines success + guardrail metrics that must
   not regress. Make them measurable (see `analytics-instrumentation`).
7. **Risks & open questions** — riskiest assumptions, dependencies, what's still undecided.
8. **Rollout** (brief) — flagged? phased? who gets it first?

## Process

- Pull what you can from the conversation; ask only for the gaps (use `brainstorming` discipline).
- Draft, then read it back as bullets for the user to correct before finalizing.
- Quantify where possible — "reduce time-to-X from N to M", not "make it faster".

## Rules

- Define success *before* scope — metrics keep scope honest.
- Every scope item should trace to the goal; cut the ones that don't.
- Offer to file as a Linear issue or Notion doc (via MCP) once confirmed — don't auto-create.
- Don't design the solution here; capture requirements. Hand off to `tech-spec`.
