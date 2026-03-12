---
name: writing-skills
description: Use when creating, editing, or improving Claude Code skills (SKILL.md files). Also use when a skill isn't triggering reliably or needs restructuring.
---

# Writing Claude Code Skills

A skill is a SKILL.md file with YAML frontmatter and markdown instructions that teaches Claude a technique, workflow, or domain. Follow these steps to create one.

## Step 1: Name and Structure

```
skill-name/
  SKILL.md              # Required
  references/           # Optional: heavy reference material (>100 lines)
  scripts/              # Optional: executable tools
```

- **Name**: kebab-case only (`condition-based-waiting`, `debugging-with-logs`). Must match directory name.
- Gerunds work well for processes: `creating-skills`, `testing-hooks`
- Avoid vague names: `helper`, `utils`, `tools`

## Step 2: Write the Description

The description is how Claude decides whether to load your skill. This is the highest-leverage part of skill authoring.

**Rules:**
1. **Start with "Use when..."** — triggering conditions only
2. **Write in third person** — it's injected into the system prompt
3. **Include trigger keywords** — words the user would naturally say
4. **Be specific** — "Use when tests have race conditions" not "For async testing"
5. **NEVER summarize the workflow** — Claude will follow the description instead of reading the full skill

**Why rule 5 matters:** A description saying "dispatches subagent per task with code review between tasks" caused Claude to do ONE review, even though the body specified TWO. Changing to just triggering conditions fixed it.

```yaml
# BAD: Summarizes workflow
description: Use for TDD - write test first, watch it fail, write minimal code, refactor

# GOOD: Triggering conditions only
description: Use when implementing any feature or bugfix, before writing implementation code
```

**Make descriptions pushy.** Claude undertriggers skills. Include specific contexts, symptoms, error messages, and phrases. Optimized descriptions improve activation from ~20% to ~90%.

**Debug triggers:** Ask Claude "When would you use the [skill name] skill?" — it quotes the description back. Adjust based on what's missing.

**Limits:** Under 1024 characters. All descriptions share a ~16K char budget (~30-40 skills at 100 words each).

## Step 3: Write the Body

```markdown
# Skill Name

## Overview
Core principle in 1-2 sentences.

## When to Use
- Bullet list of symptoms and use cases
- When NOT to use (scope boundaries)

## Core Pattern / Workflow
Imperative voice, verb-first.
One excellent code example beats many mediocre ones.
Decision matrices for choosing between approaches.

## Common Mistakes
What goes wrong and how to fix it.
```

### Quality Markers

From analysis of 18 production skills:

| Marker                | Excellent                          | Mediocre                      |
| --------------------- | ---------------------------------- | ----------------------------- |
| Agent internal state  | Red-flags map thoughts to actions  | Rules without self-monitoring |
| Empirical grounding   | "24 failures", "6 iterations"      | No evidence of real use       |
| Executable algorithms | Pseudocode, templates, checklists  | Abstract principles only      |
| Good/Bad comparisons  | Side-by-side with explanation      | One example or none           |
| Scope boundaries      | Explicit "when NOT" with reasoning | Missing or vague              |

### Match Structure to Skill Type

| Type       | Examples            | Key Patterns                                         |
| ---------- | ------------------- | ---------------------------------------------------- |
| Discipline | TDD, verification   | Iron Laws, rationalization tables, red-flags lists   |
| Technique  | debugging, research | Templates, reference tables, step-by-step procedures |
| Workflow   | planning, execution | Flowcharts, cross-references, integration sections   |
| Reference  | API docs, tools     | Architecture diagrams, comparison tables             |

**Discipline skills** need anti-rationalization: (1) rationalization table mapping excuses to reality checks, (2) red-flags list of thoughts that mean "stop", (3) explicit loophole closure forbidding specific workarounds, (4) one Iron Law non-negotiable statement.

## Step 4: Size and Organize

- **SKILL.md body**: under 500 lines (~2,000-3,000 words). This is NOT 500 words.
- **Heavy reference** (API docs, lookup tables, exhaustive examples): move to `references/`
- **Code examples**: one excellent example in the most relevant language — not multi-language
- **References**: keep one level deep from SKILL.md
- With 20-50+ skills enabled, monitor `/context` for budget warnings

## Step 5: Test

Three areas (from Anthropic's playbook):

1. **Triggering**: Does the skill activate on relevant queries? NOT on unrelated ones? Target: 90% on 10-20 test queries.
2. **Functional**: Does Claude follow the instructions correctly? Handle edge cases? Use Given/When/Then format.
3. **Performance**: With-skill vs without-skill on the same task. Track messages, tool calls, tokens.

**Practical:** Iterate on one challenging scenario first, then expand. For discipline skills, test under combined pressures (time + sunk cost + authority) and document the exact rationalizations agents use — then add explicit counters.

## Step 6: Deploy

1. **Create as a submodule** under the skills repo (e.g., `~/Dropbox/Projects/claude/skills/`) unless instructed otherwise. If the user's instructions suggest a different location (project-specific, plugin, etc.), ask before proceeding.
2. **Symlink** into `~/.claude/skills/`:
   ```bash
   ln -s /path/to/skills-repo/skill-name ~/.claude/skills/skill-name
   ```
3. **Verify** the skill appears in `/context` on next conversation start.

## Frontmatter Reference

Required fields:
```yaml
---
name: skill-name          # kebab-case, must match directory name
description: Use when ... # Under 1024 chars, triggering conditions only
---
```

Optional Claude Code extensions:

| Field                      | Purpose                                                    |
| -------------------------- | ---------------------------------------------------------- |
| `user-invocable: false`    | Hidden from `/` menu; only Claude can trigger              |
| `disable-model-invocation` | Only user can invoke via `/name`; removed from LLM context |
| `context: fork`            | Runs in isolated subagent context                          |
| `agent`                    | Subagent type when `context: fork` is set                  |
| `model`                    | Override model for this skill                              |
| `allowed-tools`            | Space-delimited pre-approved tools (CLI only, not SDK)     |
| `argument-hint`            | Autocomplete hint, e.g. `[issue-number]`                   |

String substitutions available in skill content:

| Variable               | Description                    |
| ---------------------- | ------------------------------ |
| `$ARGUMENTS`           | All arguments passed on invoke |
| `$ARGUMENTS[N]` / `$N` | Specific argument by 0-index   |
| `${CLAUDE_SESSION_ID}` | Current session ID             |
| `${CLAUDE_SKILL_DIR}`  | Directory containing SKILL.md  |

Dynamic context: `` !`command` `` runs a shell command before skill content is sent. Output replaces the placeholder.

## Progressive Disclosure

Skills load in three stages to minimize token cost:

| Level | What Loads         | When                | Token Impact          |
| ----- | ------------------ | ------------------- | --------------------- |
|     1 | Name + description | Always              | ~100 tokens per skill |
|     2 | SKILL.md body      | When skill triggers | ~1-2% of 200K context |
|     3 | Referenced files   | When Claude reads   | On-demand only        |

`disable-model-invocation: true` removes a skill from the budget entirely (user-only invoke via `/name`).

## Common Mistakes

| Mistake                         | Fix                                                     |
| ------------------------------- | ------------------------------------------------------- |
| Description summarizes workflow | Description = triggering conditions only                |
| Skill too long (500+ lines)     | Move reference material to `references/`                |
| No trigger keywords             | Add error messages, symptoms, tool names to description |
| Vague description               | "Use when tests have race conditions" not "For testing" |
| Multi-language examples         | One excellent example in the most relevant language     |
| No scope boundaries             | Add "When NOT to use" section                           |
| Narrative storytelling          | Convert to patterns, tables, checklists                 |
| Untested skill                  | Test triggering + functional + performance              |
| Deeply nested file references   | Keep references one level deep from SKILL.md            |
