---
name: karpathy-guidelines
description: Applies Andrej Karpathy's four coding discipline principles to every task. Use this skill for all software engineering, coding, debugging, refactoring, and technical implementation work. Enforces: (1) think before coding — surface assumptions and tradeoffs before writing a line, (2) simplicity first — minimum code that solves the problem, nothing speculative, (3) surgical changes — touch only what you must, never refactor adjacent code unless asked, (4) goal-driven execution — define verifiable success criteria and loop until met. Triggers on any coding request, implementation task, bug fix, refactor, architecture decision, or technical review. Derived from Andrej Karpathy's observations on LLM coding pitfalls (forrestchang/andrej-karpathy-skills).
---

# Karpathy Coding Guidelines

Behavioral guidelines to reduce common LLM coding mistakes. These bias toward **caution over speed** — for trivial one-liners, use judgment; for anything non-trivial, apply all four principles.

---

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

---

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask: *"Would a senior engineer say this is overcomplicated?"* If yes, simplify.

---

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that **your** changes made unused.
- Don't remove pre-existing dead code unless explicitly asked.

The test: **Every changed line should trace directly to the user's request.**

---

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan upfront:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

## Self-Check Before Responding

Before delivering any code output, verify:
- [ ] Did I state my assumptions?
- [ ] Is this the simplest solution?
- [ ] Did I only touch what was asked?
- [ ] Do I have a verifiable success criterion?

**These guidelines are working if:** diffs are smaller, rewrites drop, and clarifying questions come before implementation rather than after mistakes.

---

*Source: Andrej Karpathy's observations on LLM coding pitfalls, encoded by Forrest Chang — github.com/forrestchang/andrej-karpathy-skills. MIT License.*
