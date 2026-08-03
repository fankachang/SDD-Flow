---
name: karpathy-guidelines
description: >
  Based on Andrej Karpathy's observations about LLM coding defects, providing behavioral guidelines to reduce common LLM coding errors. Use when writing, reviewing, or refactoring code to avoid overdesign, make precise changes, state assumptions explicitly, and define verifiable success criteria.
  Trigger scenarios: when tasks involve unclear requirements, are prone to overengineering, or have unclear scope of changes.
license: MIT
---

# Karpathy Guidelines

Derived from Andrej Karpathy's observations about LLM coding defects, four principles directly address common problems.

**Tradeoff note:** These guidelines lean toward caution over speed. Use your judgment for trivial tasks.

---

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Make tradeoffs.**

Before implementation:
- State your assumptions explicitly. If unsure, ask.
- If multiple interpretations exist, present them—don't silently pick one.
- If there's a simpler way, say so. Object when appropriate.
- If something is unclear, stop. Explain the confusion, ask.

---

## 2. Simplicity First

**Solve the problem with the least code. Don't do speculative implementation.**

- Don't add features users didn't request.
- Don't create abstractions for one-off code.
- Don't add "flexibility" or "configurability" that wasn't requested.
- Don't add error handling for scenarios that can't happen.
- If you wrote 200 lines when 50 would do, rewrite it.

Self-test: "Would a senior engineer call this overcomplicated?" If yes, simplify.

---

## 3. Precise Changes

**Only touch what must be touched. Only clean up your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor something that isn't broken.
- Follow existing style, even if you'd write it differently.
- If you find unrelated dead code, mention it—don't delete it.

When your changes create orphans:
- Remove unused imports/variables/functions that "your changes" created.
- Don't remove pre-existing dead code unless requested.

Self-test: Every line of change should trace directly to user's request.

---

## 4. Goal-Driven Execution

**Define success criteria. Loop until verification passes.**

Turn tasks into verifiable goals:
- "Add validation" → "Write tests for invalid input, then make tests pass"
- "Fix bug" → "Write tests that reproduce the bug, then make tests pass"
- "Refactor X" → "Ensure tests pass before and after refactoring"

For multi-step tasks, state a short plan first:
```
1. [step] → Verification: [check item]
2. [step] → Verification: [check item]
3. [step] → Verification: [check item]
```

Clear success criteria let LLMs loop independently. Vague criteria ("make it work") require constant clarification.

---

**Signs these guidelines are working:**
- Fewer unnecessary changes in the diff
- Fewer rewrites due to overcomplication
- Clarifying questions happen before implementation, not after errors
