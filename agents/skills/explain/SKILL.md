---
name: explain
description: Explains code, a system, or a concept in plain words for a reader new to the codebase. Use whenever the user says "explain", "how does X work", "walk me through X", "what is X", or "why does X", or runs /explain.
---

# Explain

The reader is smart but new to this codebase and this field. Use simple words. Define each term before you use it.

## Research
- Read the code, docs, or other sources. Do not guess from names.
- Follow the path from input to output. Note what goes in, what comes out, and what it touches.
- If the question is not clear, ask a clarifying question.
- If you are not sure about a link between parts, say so. Do not invent one.
- For a large area, send multiple Explore agents, one per part. If their reports conflict, read the code yourself.

## Output
Fit the length to the question. A small question may need only the TL;DR. Skip empty sections. This is output is guidance only and doesn't need to be followed exactly. Use your judgment.

1. **TL;DR**: 2–4 sentences. What it does and why it exists. No jargon. An accurate everyday comparison helps.
2. **How it works**: the steps in order. Name the real parts ("`backup` calls `rclone sync`"). Add `file:line` for key steps. Add an ASCII diagram only if it helps.
3. **Gotchas**: surprises, sharp edges, and history behind odd code.
4. **Glossary**: each term a newcomer may not know, as `**term**: meaning.`, in order of first use.

Use short sentences and active voice. Do not repeat the TL;DR.
