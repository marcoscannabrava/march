---
name: software-design
description: Design and review code to reduce complexity, based on Ousterhout's "A Philosophy of Software Design" and the classic code smells catalog. Use when you design a module, class, or API; write or refactor non-trivial code; review a diff; or choose names, comments, error handling, or where code should live.
---

# Software Design

## Goal

Reduce complexity. Complexity is anything that makes code hard to understand or change.

Every design element (class, method, parameter, layer, setting, exception) adds complexity. Add an element only when it removes more complexity than it adds.

### Symptoms

- **Change amplification**: one simple change needs edits in many places.
- **Cognitive load**: the reader must know a lot to do a task.
- **Unknown unknowns**: the reader cannot tell what to change or what to know. This is the worst symptom.

### Causes

- **Dependencies**: you cannot understand or change code alone. Keep dependencies few. Make each one obvious.
- **Obscurity**: important facts are not clear. Vague names, missing docs, and inconsistency cause it.

## Principles

### 1. Work strategically

- When you change code, do not make the smallest possible change. After the change, the code must look as if the design included it from the start.
- Fix design problems when you find them. If a deadline forces a hack, say so and name the cleanup.
- Solve today's problems. Do not build for "what if" cases (speculative generality).

### 2. Make modules deep

- A deep module has a simple interface and a large implementation. Unix file I/O is the model: five calls hide a huge system.
- Do not split code into many tiny classes or functions ("classitis"). Each new interface costs the reader. Collapse a class that does too little into its user (lazy class, solution sprawl).
- Make the common case simple to use. Do not force callers to learn rare features to use common ones.
- The interface must differ from the implementation. If they match, the module is shallow.

### 3. Hide information

- Keep each design decision inside one module.
- If two modules know the same format, protocol, or step order, that is leakage. Merge them, or move the knowledge into one new module.
- Split code by knowledge, not by the order of steps. "Read, then parse, then write" as three classes often leaks the format into all three (temporal decomposition).
- Minimize the public surface. Every public item needs a reason (indecent exposure).
- Classes must know as little as possible about each other's internals (inappropriate intimacy). Avoid long call chains to reach data: `a.b().c().d()` is a hidden dependency (message chains).
- Do not hide facts that callers need, such as settings that change performance.

### 4. Make modules somewhat general-purpose

- Ask: what is the simplest interface that covers all current needs?
- If several special methods do one job, merge them into one.
- Ask: is this API easy for my current need? If not, it is too general or wrong.
- Push special-case code up (into the app or UI) or down (into drivers). Keep it out of general code.
- Replace near-copies that differ only in small data or behavior with one general function (combinatorial explosion).

### 5. Give each layer a different abstraction

- Remove pass-through methods. A class that only delegates is a middle man. Expose the lower layer, move the duty, or merge the classes.
- Duplicate signatures are OK only when each method adds real function, such as a dispatcher or several implementations of one interface.

### 6. Pull complexity down

- A simple interface matters more than a simple implementation.
- Do not "punt" hard problems to callers through exceptions or settings.
- Before you add a setting, ask: can the caller pick a better value than this module can? If not, compute it here. If you must add one, give it a good default.
- Stop when pulling down adds unrelated logic or leaks information.

### 7. Put code where its knowledge lives

- Move a method to the class whose data it uses most (feature envy).
- Put data and the logic that uses it together. A class that only holds fields, with logic spread among callers, leaks its format (data class).
- Group values that always travel together into one type (data clumps). Give rich domain values their own type instead of loose strings and ints (primitive obsession). This also shortens long parameter lists.
- If one change touches many classes, gather that knowledge in one place (shotgun surgery).
- If one class changes for many unrelated reasons, split it along those reasons (divergent change, large class).
- If a library lacks a method you need, wrap it in one place. Do not scatter it.

### 8. Split methods by depth, not length

- A long method is fine if it has a simple signature and reads top to bottom.
- Split only when a subtask is clean and reusable, or when the method does unrelated things and callers need only one part.
- Do not split a method into pieces a reader must read together (conjoined methods).
- Join shallow methods into deeper ones when it removes interfaces or duplication.

### 9. Define errors out of existence

- Exceptions add much complexity. Each one is part of the interface.
- First, change the API so the error cannot occur. Example: `substring` clamps indices instead of throwing. Example: Unix deletes an open file after the last close.
- Second, mask the error at a low level. Example: TCP resends lost packets.
- Third, aggregate errors. Catch many cases in one top-level handler.
- For rare errors you cannot recover from, such as out of memory, print a diagnostic and crash.
- Expose an error only when callers truly need it.

### 10. Model variation in structure, not conditionals

- Watch large conditional blocks that grow over time. Replace them with polymorphism, a strategy, a state object, or a lookup table when cases keep growing.
- Prefer interface inheritance. Use implementation inheritance with care; it leaks parent state into children. Prefer composition.
- If a subclass ignores most of what it inherits, do not inherit (refused bequest).
- If every subclass in one tree needs a twin in another tree, fold the trees together (parallel hierarchies).
- If two classes do the same job with different interfaces, give them one interface (alternative classes). Solve one problem one way (oddball solution).

### 11. Design it twice

- Sketch two or more very different designs. Focus on the interface.
- List pros and cons. Rank ease of use for callers first.
- Write the interface and its comment before the bodies.

### 12. Choose precise names

- A name must create a clear image of what the thing is and is not. If you read the name to a peer, they must be able to say what it does.
- Avoid vague names: `data`, `result`, `status`, `info`, `x`.
- Avoid names that look alike: `socket` and `sock`.
- Use one name for one concept everywhere. Pair names: `open`/`close`, `start`/`stop`.
- Remove words that add nothing: `object`, `field`, the class name inside the class, the type inside the name (`userList`, `getNameString`).

### 13. Write comments that add facts the code cannot show

- Do not repeat the code. Use different words from the names.
- If a comment explains confusing code, first try to make the code clear. Then comment what is still not obvious.
- **Interface comments** tell callers all they need: behavior, arguments, return value, side effects, errors, preconditions. Keep them apart from implementation comments.
- **Low-level comments** add precision: units, bounds (inclusive or exclusive), null meaning, ownership, invariants.
- **Implementation comments** say what and why, not how. Short simple methods need none.
- Put design decisions that span modules in one central place. Point to it from the code.
- Follow the repository's comment conventions when they are stricter than these rules.

### 14. Be consistent and obvious

- Do not change a convention unless the new one is much better and you update all old uses.
- Do not force consistency onto things that are different.
- Code is obvious when a reader's first guess is correct.
- Avoid generic containers (`Pair`, tuples) for domain data, and hidden control flow, unless you document them.

### 15. Delete dead weight

- Delete unused code, parameters, fields, and branches. Source control keeps the history.
- Remove optional fields that only some code paths set (temporary field). Pass the values the callee needs, not a large object it picks one field from.

### 16. Test and measure

- For bug fixes, write a failing test first, then fix.
- If a speedup complicates an interface, start simple and optimize later.
- Measure before and after each optimization. If it does not help, revert it.

## Red flags

Stop and redesign when you see one of these.

| Red flag | Meaning | Fix |
|---|---|---|
| Shallow module | Interface is almost as complex as its function. | Merge or deepen. |
| Information leakage | One decision appears in more than one module. | Move it into one module. |
| Temporal decomposition | Code is split by step order, not knowledge. | Split by knowledge. |
| Overexposure | Callers must learn rare features for common use. | Simplify the common path. |
| Pass-through / middle man | A method or class only delegates. | Expose, move, or merge. |
| Duplication | Same or near-same code in many places. | Extract one general version. |
| Special-general mixture | General code holds special cases. | Push special code up or down. |
| Conjoined methods | You cannot read one method without another. | Join them. |
| Feature envy | A method mostly uses another class's data. | Move the method. |
| Data clumps / long parameter list | Loose values travel together. | Make a type. |
| Shotgun surgery | One change edits many classes. | Gather the knowledge. |
| Divergent change / large class | One class changes for unrelated reasons. | Split by reason. |
| Message chain | `a.b().c().d()` to reach data. | Hide the path behind one method. |
| Growing conditional | A switch or if-chain gains cases over time. | Use polymorphism or a table. |
| Refused bequest | Subclass ignores what it inherits. | Use composition. |
| Speculative generality | Hooks or parameters with no current user. | Delete them. |
| Dead code / temporary field | Unused code, or fields set on some paths only. | Delete or restructure. |
| Comment repeats code | The comment tells only what the code shows. | Delete or say why. |
| Vague or type-embedded name | The name hides meaning or encodes a type. | Rename precisely. |
| Hard to pick name / hard to describe | You cannot name or briefly explain it. | Redesign. |
| Nonobvious code | A reader cannot quickly predict behavior. | Clarify, then comment. |

## How to apply

When you design or write code:

1. Name the abstraction each new module gives. If you cannot, redesign.
2. For a major decision, sketch a second design before you choose.
3. Write the interface and its comment before the body.
4. Compare interface size with function size. Make modules deeper.
5. List each error and setting. Remove, mask, or default each one you can.

When you review or refactor code:

1. Scan the red flags table. Name each hit with its file and line.
2. Find knowledge shared across modules. Move it into one place.
3. Check names and comments against principles 12 and 13.
4. Rank fixes by how much complexity each removes. Fix the top ones, or state why one stays.
