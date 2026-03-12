---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs
---

# Verification Before Completion

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate

Before claiming any status:

1. **IDENTIFY** — what command proves this claim?
2. **RUN** — execute it fresh and complete
3. **READ** — full output, check exit code, count failures
4. **VERIFY** — does output confirm the claim?
5. **CLAIM** — only now state the result

Skip any step = lying, not verifying.

## What Requires What

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test output: 0 failures | Previous run, "should pass" |
| Build succeeds | Build output: exit 0 | Linter passing |
| Bug fixed | Symptom test: passes | Code changed, assumed fixed |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags — STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Done!")
- About to commit/push/PR without verification
- Trusting agent success reports
- Thinking "just this once"
- **ANY wording implying success without having run verification**

## Rationalizations

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter ≠ compiler |
| "Agent said success" | Verify independently |
| "Partial check is enough" | Partial proves nothing |

## Key Patterns

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Build:**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**Requirements:**
```
✅ Re-read plan → checklist → verify each → report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → check VCS diff → verify changes → report actual state
❌ Trust agent report
```

## The Bottom Line

Run the command. Read the output. THEN claim the result. Non-negotiable.
