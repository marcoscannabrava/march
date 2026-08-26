---
name: analytics-instrumentation
description: >
  Use when a feature needs to be measurable — defining what events/metrics to track, naming and
  structuring them, tying the feature to success + guardrail metrics, and (optionally) designing
  an experiment to evaluate it. Triggers: "what should we track", "instrumentation", "analytics
  events", "Amplitude", "how do we measure success", "A/B test", "experiment", success metrics
  from a `prd`. Defines an Amplitude-style event model and points validation queries at BigQuery.
---

# Analytics Instrumentation

A feature you can't measure is a feature you can't evaluate, iterate, or defend. Define the
measurement *with* the feature, not after launch when the data's already missing.

## Process

1. **Start from the success metric.** Take the PRD's primary metric and work backward: what user
   actions must be recorded to compute it? Add guardrail metrics that must not regress.
2. **Design the event model** (Amplitude-style):
   - **Event names** — consistent convention (e.g. `Object Action`, past tense / `noun_verb`),
     matching the existing taxonomy. Don't invent a new convention per feature.
   - **Properties** — the dimensions you'll slice by (surface, variant, entity id, source, result).
     Capture them at fire time; you can't backfill what you didn't send.
   - **Identity** — who/what is acted on; ensure user/session is attached.
   - Avoid: high-cardinality junk properties, PII in event payloads, redundant events.
3. **Map metrics to events** — write, in plain terms, how each success/guardrail metric is
   computed from the events (numerator/denominator, window, dedup rule).
4. **Experiment design (if A/B testing)** — hypothesis, unit of randomization, primary metric,
   minimum detectable effect, guardrails, and the stop/decision rule. Name what would make you
   ship, iterate, or kill it.
5. **Validation** — after instrumenting, verify events arrive with correct properties; sketch the
   BigQuery query that confirms volume and powers the metric (via MCP) before trusting a dashboard.

## Rules

- Define events before coding so they land in the same PR as the feature.
- One source of truth per metric — don't compute the same KPI two ways.
- Guardrails matter as much as the win metric; name what you're protecting.
- Privacy first: no PII / secrets in event properties; respect consent.
