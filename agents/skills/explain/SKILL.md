---
name: explain
description: Explain how code, a system, or a concept works. Start with a plain TL;DR for a reader with no background, then go deeper, and end with a glossary. Use when the user asks "how does X work", "explain X", "walk me through X", "what is X", or runs /explain.
---

# Explain

## Goal

Make the reader understand X. Assume the reader is smart but knows nothing about this area.

## 1. Read before you explain

- If the question is not clear, state your best guess and continue. Do not ask.
- Find the entry point. Follow the path from input to output.
- Find the edges: what goes in, what comes out, and which other parts it connects to.
- Read the code. Do not guess from names.
- If there is no code (a general concept), use docs and man pages, or what you know. Say which source you used.
- Stop when you can describe each step without vague words.
- If a part is not clear to you, say so. Do not invent a link between two parts.
- For a large area, you can send 2–3 Explore agents, one for each part. Tell each agent to return file paths, the steps, the edges, surprises, and open questions. If two reports do not agree, read the code yourself. For a small area, do the work yourself.

## 2. Write the explanation

Use this order. Skip a section if it is empty.

### TL;DR

- 2–4 sentences.
- Use simple words. Assume no previous knowledge.
- Say what X does and why it exists. Do not say how yet.
- An everyday comparison is good if it is accurate.

### How it works

- This is the main section. Tell the flow as steps, in the order they occur.
- Name the real parts: "`backup` calls `rclone sync`", not "the script delegates to a tool".
- Add `file:line` references for important steps.
- Add a small ASCII diagram only if it makes the flow clearer.
- Prose is better than code. Show code only if it is the clearest way.
- If a part is complex, say why it is complex.

### Gotchas

- Behavior that surprises people, sharp edges, and history that explains strange code.

### Glossary

- Each domain term from the explanation that a beginner may not know.
- One line per term, two at most: `**term**: meaning.`
- Use the order in which the terms occur in the explanation.

## Style

- Make the length fit the question. A small question gets a short answer, possibly only the TL;DR.
- Short sentences. Active voice. Common words.
- If a part is simple, keep it short. Do not add text to fill space.
- Do not repeat the TL;DR in later sections.
