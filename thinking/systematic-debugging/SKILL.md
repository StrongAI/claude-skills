---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---

# Systematic Debugging

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

**Use this ESPECIALLY when:** under time pressure, "just one quick fix" seems obvious, you've already tried multiple fixes, or you don't fully understand the issue. These are exactly when systematic process prevents thrashing.

## The Four Phases

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Read error messages carefully** — don't skip past errors or warnings. Read stack traces completely. Note line numbers, file paths, error codes. They often contain the exact solution.

2. **Reproduce consistently** — can you trigger it reliably? What are the exact steps? If not reproducible, gather more data — don't guess.

3. **Check recent changes** — git diff, recent commits, new dependencies, config changes, environmental differences.

4. **Gather evidence in multi-component systems** — before proposing fixes, add diagnostic logging at each component boundary. Run once to see WHERE it breaks. Then investigate that specific component.

5. **Trace data flow** — where does the bad value originate? What called this with bad data? Keep tracing up until you find the source. Fix at source, not at symptom.

### Phase 2: Pattern Analysis

1. **Find working examples** — similar working code in same codebase
2. **Compare against references** — read reference implementations COMPLETELY, not skimming
3. **Identify differences** — every difference, however small. Don't assume "that can't matter"
4. **Understand dependencies** — settings, config, environment, assumptions

### Phase 3: Hypothesis and Testing

1. **Form single hypothesis** — "I think X is the root cause because Y." Be specific.
2. **Test minimally** — smallest possible change, one variable at a time
3. **Verify** — worked? Phase 4. Didn't? NEW hypothesis. Don't stack fixes.
4. **When you don't know** — say so. Don't pretend. Research more.

### Phase 4: Implementation

1. **Create failing test case** — use test-driven-development skill
2. **Implement single fix** — ONE change, no "while I'm here" improvements
3. **Verify fix** — test passes, no regressions
4. **If 3+ fixes failed** — STOP. Question the architecture. See below.

## When 3+ Fixes Fail

**Pattern:** each fix reveals new shared state/coupling/problem in a different place. Fixes require "massive refactoring." Each fix creates new symptoms elsewhere.

**This is NOT a failed hypothesis — this is a wrong architecture.**

STOP and question fundamentals:
- Is this pattern fundamentally sound?
- Should we refactor architecture vs. continue fixing symptoms?
- Discuss before attempting more fixes.

## Red Flags — STOP and Return to Phase 1

- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "It's probably X, let me fix that"
- Proposing solutions before tracing data flow
- "One more fix attempt" (when already tried 2+)
- Each fix reveals new problem in different place

## Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple" | Simple issues have root causes. Process is fast for simple bugs. |
| "Emergency, no time" | Systematic is FASTER than guess-and-check thrashing. |
| "Just try this first" | First fix sets the pattern. Do it right. |
| "Reference too long" | Partial understanding guarantees bugs. Read completely. |
| "I see the problem" | Seeing symptoms ≠ understanding root cause. |
| "One more fix attempt" (after 2+) | 3+ failures = architectural problem. Question the pattern. |

## Quick Reference

| Phase | Key Activities | Done When |
|-------|---------------|-----------|
| 1. Root Cause | Read errors, reproduce, check changes, gather evidence | Understand WHAT and WHY |
| 2. Pattern | Find working examples, compare | Identified differences |
| 3. Hypothesis | Form theory, test minimally | Confirmed or new hypothesis |
| 4. Implementation | Create test, fix, verify | Bug resolved, tests pass |
