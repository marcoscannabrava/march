---
name: test-driven-development
description: >
  Use when implementing logic where correctness matters and behavior is specifiable up front —
  new functions, bug fixes (write the failing test that reproduces the bug first), API/handler
  logic, data transforms, anything with clear inputs and outputs. Enforces the RED → GREEN →
  REFACTOR loop and guards against common anti-patterns. Triggers: "write tests", "TDD", "fix
  this bug", "implement <function/endpoint>", "add a test". Skip for throwaway prototypes (see
  `vertical-slicing`/prototype thinking) and pure UI styling with no testable behavior.
---

# Test-Driven Development

Write the test first so the spec is concrete and you get an honest signal that your code does
what you claimed. For bugs, the failing test *is* the reproduction.

## The loop

1. **RED** — write the smallest test that expresses the next behavior. Run it. **Watch it fail**,
   and confirm it fails for the right reason (asserting the thing you mean, not a typo/import error).
2. **GREEN** — write the least code that makes it pass. No extra features, no speculative
   abstraction. Run the test; see it pass.
3. **REFACTOR** — clean up names, dedupe, simplify — with the test as your safety net. Re-run.
4. Repeat for the next behavior.

## Anti-patterns to refuse

- **Writing code first, tests after** to rubber-stamp it — you lose the design feedback and tend
  to test what you wrote, not what was required.
- **Tests that can't fail** — assert real outputs/side effects, not `expect(true).toBe(true)` or
  over-mocked stubs that just echo the mock.
- **Skipping the failing run** — if you never saw RED, you don't know the test tests anything.
- **Giant tests** — one behavior per test; a failure should point at one cause.
- **Testing implementation details** — assert observable behavior so refactors don't break tests.

## Rules

- Match the project's existing test framework, layout, and naming — explore first.
- For a bug: reproduce with a failing test, fix, watch it go green, then check for siblings.
- Keep tests fast and deterministic; isolate I/O and time/randomness.
- When done, hand off to `verify` / `/code-review` (built-ins) for end-to-end confirmation.
