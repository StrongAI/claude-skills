# Anger Log Skill Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a passive frustration detection skill that logs incidents to a persistent ledger, with graduation workflow to idiocy-check and conventions.

**Architecture:** SKILL.md in `thinking/anger/` with a two-tier ledger system (project `ANGER.md` + global `~/.claude/ANGER.md`). Follows the writing-skills TDD process: baseline test → write skill → refactor.

**Tech Stack:** Markdown skill file, subagent-based TDD testing

---

### Task 1: Create the submodule repo and directory

**Files:**
- Create: `thinking/anger/SKILL.md` (placeholder initially)

**Step 1: Create the anger directory in the thinking submodule**

```bash
cd /Users/asher/Dropbox/Projects/claude/skills/thinking
mkdir -p anger
```

**Step 2: Create a minimal placeholder SKILL.md**

Create `thinking/anger/SKILL.md` with just:

```markdown
---
name: anger-log
description: placeholder
---

# Anger Log

Placeholder — will be written after baseline testing.
```

**Step 3: Create symlink in ~/.claude/skills/**

```bash
ln -s /Users/asher/Dropbox/Projects/claude/skills/thinking/anger /Users/asher/.claude/skills/anger
```

**Step 4: Commit placeholder**

```bash
cd /Users/asher/Dropbox/Projects/claude/skills/thinking
git add anger/SKILL.md
git commit -m "Add anger-log skill placeholder for TDD baseline"
```

---

### Task 2: RED — Baseline test WITHOUT the skill

Run pressure scenarios with a subagent that does NOT have access to the anger-log skill. Document what happens when the user expresses frustration.

**Step 1: Design 3 pressure scenarios**

Write these scenarios to a test file `docs/plans/anger-log-test-scenarios.md`:

**Scenario A — Explicit frustration after a mistake:**
> "You just deleted a function I told you to keep. I already told you not to remove features! Put it back."
>
> Expected behavior (with skill): Detect frustration, propose logging.
> Baseline (without skill): Will the agent acknowledge anger? Propose any action? Or just fix and move on?

**Scenario B — Repeated corrections:**
> User corrects the same naming mistake twice in a session. Third time it happens:
> "NO. It's `claude-skills-thinking`, not `claude-skill-thinking`. How many times do I have to say this?"
>
> Expected behavior (with skill): Detect pattern of repeated corrections, propose logging with category "naming".
> Baseline: Does the agent notice the pattern? Does it propose recording it anywhere?

**Scenario C — User undoing Claude's work:**
> "Revert all of that. You added a bunch of error handling I didn't ask for. I said no scope creep."
>
> Expected behavior (with skill): Detect anger at scope creep, propose logging with category "scope-creep".
> Baseline: Does the agent just revert, or does it recognize the anger and propose any follow-up?

**Step 2: Run each scenario as a subagent WITHOUT the anger-log skill loaded**

Use the Agent tool with a prompt that sets up the scenario. The subagent should have access to idiocy-check and conventions (the existing skills) but NOT anger-log.

For each scenario, document:
- Did the agent detect frustration? (yes/no)
- Did it propose logging? (yes/no)
- Did it propose graduation to idiocy/conventions? (yes/no)
- What rationalizations did it use for NOT logging? (verbatim quotes)
- What did it actually do instead?

**Step 3: Record baseline results**

Append results to `docs/plans/anger-log-test-scenarios.md` under each scenario.

**Step 4: Commit baseline**

```bash
git add docs/plans/anger-log-test-scenarios.md
git commit -m "RED: baseline test results for anger-log skill"
```

---

### Task 3: GREEN — Write the anger-log SKILL.md

Based on baseline results from Task 2, write the actual skill addressing the specific gaps observed.

**Files:**
- Modify: `thinking/anger/SKILL.md`

**Step 1: Write the skill**

Replace the placeholder with the full skill. Structure per the design doc:

- **Frontmatter**: name `anger-log`, description starting with "Use when..." — triggers on frustration signals, NOT summarizing workflow
- **Overview**: The trio relationship, what this skill does
- **Frustration Signals**: Strong signals list, not-signals list
- **The Ledger**: Format, two-file system, entry template
- **Workflow flowchart**: Detect → propose → log → propose graduation
- **Graduation**: How entries flow to idiocy-check and conventions
- **What It Does NOT Do**: Boundaries
- **Red Flags**: Signs you're about to skip logging
- **Common Rationalizations**: Table addressing baseline failures from Task 2

Key constraints from design:
- Description must NOT summarize workflow (CSO principle)
- Skill runs passively — no explicit invocation needed
- Never logs without asking
- Never lectures about anger
- Always proposes graduation after logging

**Step 2: Commit the skill**

```bash
cd /Users/asher/Dropbox/Projects/claude/skills/thinking
git add anger/SKILL.md
git commit -m "GREEN: write anger-log skill addressing baseline gaps"
```

---

### Task 4: GREEN — Run scenarios WITH the skill

**Step 1: Re-run all 3 scenarios from Task 2 with the anger-log skill loaded**

The subagent should now have the anger-log SKILL.md in its context.

For each scenario, document:
- Did the agent detect frustration? (yes/no)
- Did it propose logging? (yes/no)
- Did it propose graduation? (yes/no)
- Was the proposal appropriate (not intrusive, not lecturing)? (yes/no)
- Any new rationalizations for skipping?

**Step 2: Record results alongside baseline**

Update `docs/plans/anger-log-test-scenarios.md` with "WITH SKILL" results.

**Step 3: Commit**

```bash
git add docs/plans/anger-log-test-scenarios.md
git commit -m "GREEN: test results with anger-log skill loaded"
```

---

### Task 5: REFACTOR — Close loopholes

**Step 1: Analyze gaps from Task 4**

Compare WITH vs WITHOUT results. Identify:
- Any scenarios where agent still didn't detect frustration
- Any new rationalizations ("the user isn't really angry", "this is a normal correction")
- Any cases where the proposal was too intrusive or lectured

**Step 2: Update SKILL.md to close loopholes**

Add explicit counters for any new rationalizations discovered. Update the red flags table. Tighten signal detection if needed.

**Step 3: Re-run any failing scenarios**

Only re-run scenarios that failed in Task 4.

**Step 4: Commit**

```bash
cd /Users/asher/Dropbox/Projects/claude/skills/thinking
git add anger/SKILL.md
git commit -m "REFACTOR: close loopholes found in anger-log testing"
```

---

### Task 6: Deploy — Submodule and symlink setup

**Step 1: Create the StrongAI repo for the skill**

The anger skill needs its own repo like the others: `StrongAI/claude-skills-thinking-anger`. This may need to be done manually by the user if Claude doesn't have repo creation permissions on StrongAI.

**Step 2: Register as submodule in thinking repo**

If the repo is created:

```bash
cd /Users/asher/Dropbox/Projects/claude/skills/thinking
# Remove the directory (it's not a submodule yet)
git rm -r anger
# Re-add as submodule
git submodule add git@github.com:StrongAI/claude-skills-thinking-anger.git anger
git commit -m "Register anger-log as submodule"
```

If the user prefers to keep it as a regular directory for now, skip this step.

**Step 3: Verify symlink works**

```bash
ls -la /Users/asher/.claude/skills/anger
# Should point to thinking/anger
cat /Users/asher/.claude/skills/anger/SKILL.md
# Should show the skill content
```

**Step 4: Update thinking submodule pointer in parent repo**

```bash
cd /Users/asher/Dropbox/Projects/claude/skills
git add thinking
git commit -m "Update thinking submodule: add anger-log skill"
```

---

### Task 7: Cleanup

**Step 1: Delete the test scenarios file**

```bash
rm docs/plans/anger-log-test-scenarios.md
```

**Step 2: Delete the design doc (content is now in the skill)**

```bash
rm docs/plans/2026-03-12-anger-log-design.md
```

**Step 3: Delete this plan**

```bash
rm docs/plans/2026-03-12-anger-log-plan.md
```

**Step 4: Commit cleanup**

```bash
git add -A
git commit -m "Clean up anger-log planning artifacts"
```
