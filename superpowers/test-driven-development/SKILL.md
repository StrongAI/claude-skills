---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code
---

# Test-Driven Development

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Wrote code before the test? Delete it. Start over. No exceptions.

- Don't keep it as "reference"
- Don't "adapt" it while writing tests
- Delete means delete

## Red-Green-Refactor

### RED — Write Failing Test

One minimal test showing what should happen. Clear name, tests real behavior, one thing.

```typescript
test('rejects empty email', async () => {
  const result = await submitForm({ email: '' });
  expect(result.error).toBe('Email required');
});
```

**Requirements:** One behavior. Clear name. Real code (no mocks unless unavoidable).

### Verify RED — Watch It Fail

**MANDATORY. Never skip.**

```bash
npm test path/to/test.test.ts
```

Confirm: test fails (not errors), failure is expected, fails because feature missing.

**Test passes?** You're testing existing behavior. Fix test.

### GREEN — Minimal Code

Simplest code to pass the test. Don't add features, refactor, or "improve" beyond the test.

```typescript
function submitForm(data: FormData) {
  if (!data.email?.trim()) {
    return { error: 'Email required' };
  }
  // ...
}
```

### Verify GREEN — Watch It Pass

**MANDATORY.**

Confirm: test passes, other tests still pass, output pristine.

**Test fails?** Fix code, not test.

### REFACTOR — Clean Up

After green only. Remove duplication, improve names, extract helpers. Keep tests green. Don't add behavior.

### Repeat

Next failing test for next behavior.

## Good Tests

| Quality | Good | Bad |
|---------|------|-----|
| **Minimal** | One behavior. "and" in name? Split it | `test('validates email and domain')` |
| **Clear** | Name describes behavior | `test('test1')` |
| **Real** | Real code, no mocks unless unavoidable | Mock-heavy, testing framework behavior |

## Why Order Matters

**"I'll write tests after"** — tests passing immediately prove nothing. You never saw them catch the bug. Test-first forces you to see the test fail, proving it actually tests something.

**"Already manually tested"** — ad-hoc, no record, can't re-run. Automated tests are systematic and repeatable.

**"Deleting X hours is wasteful"** — sunk cost fallacy. Working code without real tests is technical debt.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests-after = "what does this do?" Tests-first = "what should this do?" |
| "TDD will slow me down" | TDD faster than debugging. |
| "Need to explore first" | Fine. Throw away exploration, start with TDD. |
| "Keep as reference" | You'll adapt it. That's testing after. Delete means delete. |
| "It's about spirit not ritual" | Spirit IS the ritual. Tests-after are biased by implementation. |

## Red Flags — Delete and Start Over

- Code before test
- Test passes immediately
- Can't explain why test failed
- "Just this once"
- "Keep as reference"
- "This is different because..."

## Verification Checklist

- [ ] Every new function has a test
- [ ] Watched each test fail before implementing
- [ ] Each test failed for expected reason
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass, output pristine
- [ ] Tests use real code (mocks only if unavoidable)
- [ ] Edge cases covered

Can't check all boxes? You skipped TDD. Start over.
