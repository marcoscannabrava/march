# ship — Claude Code skills for shipping product features

[Claude Code](https://claude.com/claude-code) skills for a product engineer: pin down
requirements, plan, build, debug, and ship measurable features — plus artifact tooling
(docs/decks/sheets/PDFs, browser automation, art, theming).

Lives in the [march](https://github.com/marcoscannabrava/march) dotfiles repo. Packaged as a
plugin marketplace (`mc-skills` → plugin `ship`). Invoke as `/ship:<name>` or let descriptions
auto-trigger them.

## Install

```bash
cd ~/code/march && ./install.sh -s   # symlinks these skills into ~/.claude/skills (idempotent)
```

Restart Claude Code afterward. To drop one skill: `rm ~/.claude/skills/<name>`.

Plugin-marketplace alternative (versioned): inside Claude Code run
`/plugin marketplace add ~/code/march/claude` then `/plugin install ship@mc-skills`.

## Skills

### Workflow — original

| Skill | Fires when |
|---|---|
| `brainstorming` | A request is ambiguous or buildable several ways — interrogates requirements, surfaces design in chunks. |
| `grill-me` | Stress-test a plan/design — relentless one-at-a-time interview down the decision tree, each with a recommendation. |
| `writing-plans` | Approach is clear — decomposes into small, ordered, individually-verifiable tasks with file paths. |
| `tech-spec` | Requirements settled — architecture, data model, interfaces, rollout, test plan, alternatives. |
| `prd` | A feature needs a requirements doc — problem, users, scope, non-goals, metrics; offers to file in Linear/Notion. |
| `vertical-slicing` | A feature is too big — splits into independently shippable increments; emits Linear-ready issues. |
| `test-driven-development` | Implementing logic / fixing a bug — enforces RED → GREEN → REFACTOR, refuses anti-patterns. |
| `systematic-debugging` | Cause isn't obvious — four-phase root-cause: reproduce → isolate → hypothesize → fix+verify. |
| `analytics-instrumentation` | A feature must be measurable — Amplitude event model, success/guardrail metrics, experiments; validates in BigQuery. |

Typical loop: `brainstorming → prd → tech-spec → vertical-slicing → (per slice) writing-plans →
test-driven-development → systematic-debugging when stuck → ship`.

### Artifacts & tooling — vendored

| Skill | Fires when | Source · setup |
|---|---|---|
| `docx` | Create/read/edit Word `.docx` — reports, memos, letters, templates, tracked changes. | Anthropic · Python |
| `pdf` | Anything with PDFs — extract, merge/split, fill forms, watermark, OCR, create. | Anthropic · Python |
| `pptx` | Any `.pptx` — build decks, parse/extract slides, edit templates, speaker notes. | Anthropic · Python |
| `xlsx` | Spreadsheets as input/output — `.xlsx/.csv`, formulas, charts, cleaning messy data. | Anthropic · Python |
| `algorithmic-art` | Generative art with p5.js — flow fields, particle systems, seeded randomness. | Anthropic |
| `theme-factory` | Style artifacts (slides/docs/HTML) with one of 10 preset themes or a generated one. | Anthropic |
| `skill-creator` | Create, edit, optimize, and eval skills; tune descriptions for trigger accuracy. | Anthropic |
| `playwright-skill` | Browser automation — test pages, forms, screenshots, responsive/UX, login flows. | [lackeyjb](https://github.com/lackeyjb/playwright-skill) (MIT) · `npm run setup` in its dir |

**Dependencies (installed on first use / manually):** Python skills need libs like `python-docx`,
`openpyxl`, `pypdf`; `playwright-skill` needs `npm run setup` (installs Playwright + Chromium).

These intentionally don't duplicate Claude Code built-ins — use `/code-review`, `/security-review`,
`verify`, `run`, `simplify`, and the native `Workflow`/worktree tools for review, verification, and
multi-agent fan-out.


## Layout & extending

```
claude/.claude-plugin/marketplace.json   # catalog (marketplace "mc-skills", strict:false → auto-discovers skills)
claude/plugins/ship/.claude-plugin/plugin.json
claude/plugins/ship/skills/<name>/SKILL.md
```

Add a skill: create `claude/plugins/ship/skills/<name>/SKILL.md` with YAML frontmatter (`name` +
`description` written as a precise *when to use this* trigger), then re-run `./install.sh -s` from
the repo root.
