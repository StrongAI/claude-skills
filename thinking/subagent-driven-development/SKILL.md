---
name: subagent-driven-development
description: Use when you have an implementation plan to execute, dispatching subagents per task - triggers on plan execution, task dispatch, subagent workflow
---

# Subagent-Driven Development

Execute plan by dispatching fresh subagent per task, with two-stage review after each: spec compliance first, then code quality.

**Core principle:** Fresh subagent per task + two-stage review = high quality, fast iteration.

## When to Use

- Have implementation plan with mostly independent tasks
- Want to stay in current session (no context switch)
- Tasks can be understood and implemented by a subagent with provided context

## The Process

```
Read plan → Extract all tasks with full text → Create TodoWrite

For each task:
  1. Dispatch implementer subagent
  2. Answer questions if asked
  3. Implementer implements, tests, commits
  4. Dispatch spec compliance reviewer → pass? If no → implementer fixes → re-review
  5. Dispatch code quality reviewer → pass? If no → implementer fixes → re-review
  6. Mark task complete

After all tasks:
  7. Dispatch final code reviewer across entire implementation
  8. Verify all tests pass
  9. Present branch completion options
```

## Step 1: Load Plan

1. Read plan file once
2. Extract ALL tasks with full text and context
3. Create TodoWrite with all tasks
4. Note any cross-task dependencies

## Step 2: Per-Task Cycle

**Dispatch implementer subagent** with:
- Full task text from plan (don't make subagent read plan file)
- Scene-setting context (where this task fits in the project)
- Clear goal and constraints

```markdown
Implement Task N: [name]

Context: [brief description of where this fits]

[Full task text from plan, verbatim]

Requirements:
- Follow TDD: write failing test first, then implement
- Run tests after each change
- Commit when tests pass
- Return summary of what you built and any decisions made
```

**If implementer asks questions:** Answer clearly and completely. Provide additional context. Don't rush them into implementation.

**After implementation, dispatch spec compliance reviewer:**

```markdown
Review this implementation against its spec.

Spec:
[task text from plan]

Changes: git diff [base_sha]..[head_sha]

Check:
- All requirements implemented? Nothing missing?
- Nothing extra added beyond spec?
- Tests cover the specified behavior?

Reply: Spec compliant, or list specific gaps.
```

**After spec passes, dispatch code quality reviewer:**

```markdown
Review code quality of recent changes.

Changes: git diff [base_sha]..[head_sha]

Check:
- Code quality, patterns, error handling
- Test quality (real code, not mock-heavy)
- Naming, organization, maintainability
- Security considerations

Categorize issues as Critical / Important / Minor.
```

**Fix loop:** Reviewer finds issues → implementer fixes → reviewer re-reviews → repeat until approved.

**Order matters:** Spec compliance MUST pass before starting code quality review.

## Step 3: Branch Completion

After all tasks complete and final reviewer approves:

1. **Verify tests pass** — run full suite, read output, confirm zero failures
2. **If tests fail** — fix before offering options, do not proceed

Present exactly these options:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work
```

**Option 1 — Merge locally:** checkout base, pull latest, merge feature, verify tests on merged result, delete feature branch.

**Option 2 — Create PR:** push branch, `gh pr create` with summary and test plan.

**Option 3 — Keep as-is:** report branch name and path, preserve everything.

**Option 4 — Discard:** require typed "discard" confirmation. Show what will be deleted (branch, commits, worktree). Only then delete.

## Handling Review Feedback

When receiving review feedback from any source:

- **Verify before implementing** — check suggestion against codebase reality
- **Push back if wrong** — technical correctness over social comfort. If suggestion breaks things, lacks context, or violates YAGNI, say so with reasoning.
- **Clarify all items first** — if any feedback is unclear, ask before implementing anything. Partial understanding = wrong implementation.
- **One fix at a time, test each** — don't batch fixes without testing between them
- **No performative agreement** — don't say "Great point!" or "You're absolutely right!" Just fix it or push back.

## Red Flags

**Never:**
- Start implementation on main/master without explicit user consent
- Skip reviews (spec compliance OR code quality)
- Dispatch multiple implementation subagents in parallel (conflicts)
- Make subagent read plan file (provide full text instead)
- Skip re-review after fixes
- Start quality review before spec compliance passes
- Proceed with failing tests
- Trust agent success reports without independent verification
- Force-push without explicit request

**If subagent asks questions:** Answer before letting them proceed.

**If subagent fails:** Dispatch fix subagent with specific instructions. Don't fix manually (context pollution).

**If reviewer finds issues:** Implementer fixes → reviewer re-reviews → repeat. Don't skip re-review.

## When NOT to Use

- Tasks are tightly coupled and can't be understood independently
- No written plan exists (use brainstorming → writing-plans first)
- Single small task (just do it directly)
- Exploratory debugging (use systematic-debugging instead)

## Real-World Impact

From production sessions: 18 tasks across 3 projects (xnn, OnShape, focus_stacking) executed via this workflow. Spec compliance review caught over-building (extra flags not in spec) and under-building (missing progress reporting). Code quality review caught magic numbers and duplicate code. Two-stage review found issues that single-pass review missed — spec compliance ensures correctness, quality review ensures craftsmanship.
