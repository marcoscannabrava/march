# pstack model configuration

Per-role model overrides for pstack skills. Each pstack SKILL.md names a default model inline; the values here override those defaults. Delete a line to fall back to the skill default. A value of `inherit-parent` or `auto` runs that role on the parent session's model (the `Agent` call omits `model`); an alias entry in a panel list still counts toward that panel's fan-out.

feature, refactoring: claude-opus-5
bug-fix: claude-opus-5
perf-issue: claude-opus-5
hillclimb: claude-opus-5
judgment and prose: claude-opus-5
how explorer: claude-opus-5
how explainer: claude-opus-5
how critics: claude-opus-5, claude-fable-5, claude-sonnet-5, claude-haiku-4-5
why investigators: claude-opus-5
why synthesizer: claude-opus-5
reflect tooling: claude-opus-5
reflect judgment, divergent, synthesizer: claude-opus-5
arena runners: claude-opus-5, claude-fable-5, claude-sonnet-5, claude-haiku-4-5
arena cross-judge pool: claude-opus-5, claude-fable-5, claude-sonnet-5
swarm workers: claude-opus-5
architect runners: claude-opus-5, claude-fable-5, claude-sonnet-5, claude-haiku-4-5
interrogate reviewers: claude-opus-5, claude-fable-5, claude-sonnet-5, claude-haiku-4-5
