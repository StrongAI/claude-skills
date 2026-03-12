---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

Write implementation plans assuming the engineer has zero context for the codebase. Document everything they need: which files to touch, code, testing, how to verify. Bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume a skilled developer who knows almost nothing about the toolset or problem domain and doesn't know good test design very well.

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Plan Document Header

Every plan MUST start with:

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" — step
- "Run it to make sure it fails" — step
- "Implement the minimal code to make the test pass" — step
- "Run the tests and make sure they pass" — step
- "Commit" — step

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

**Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## When NOT to Use

- Single-step task (just do it, don't plan it)
- No spec or requirements yet (use brainstorming first)
- Exploratory/research work (no clear deliverable)
- User gave a complete, unambiguous instruction for one change

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Vague steps ("add validation") | Complete code in every step |
| Missing file paths | Exact paths always, including line ranges for modifications |
| No test commands | Every task needs `Run:` with exact command and `Expected:` output |
| Steps too large (10+ minutes) | Break into 2-5 minute atomic actions |
| No commit steps | Commit after every green test cycle |
| Plan references files it hasn't read | Read all relevant files before writing the plan |

## Remember

- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits

## Execution Handoff

After saving the plan, proceed with **subagent-driven-development** to execute it: dispatch fresh subagent per task with two-stage review (spec compliance, then code quality).
