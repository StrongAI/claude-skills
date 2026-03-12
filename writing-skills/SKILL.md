---
name: writing-skills
description: Use when creating, editing, or improving Claude Code skills (SKILL.md files). Covers the Agent Skills open standard, frontmatter fields, description optimization, progressive disclosure, testing, and common mistakes. Also use when a skill isn't triggering reliably or needs restructuring.
---

# Writing Claude Code Skills

A skill is a markdown file (SKILL.md) that teaches Claude a technique, workflow, or domain. Skills follow the [Agent Skills open standard](https://agentskills.io/specification) — a directory with a required SKILL.md containing YAML frontmatter and markdown instructions.

## Skill Anatomy

```
skill-name/
  SKILL.md              # Required: frontmatter + instructions
  references/           # Optional: heavy reference material (>100 lines)
  scripts/              # Optional: executable tools
  assets/               # Optional: templates, data files
```

### Frontmatter (Required)

```yaml
---
name: skill-name
description: Use when [triggering conditions]. [What it does]. [Key capabilities].
---
```

- **`name`**: Lowercase letters, numbers, hyphens only. Must match parent directory name.
- **`description`**: Under 1024 characters. The single most important field — see Description Optimization below.

### Claude Code Extensions (Optional)

| Field                      | Purpose                                                    |
| -------------------------- | ---------------------------------------------------------- |
| `user-invocable: false`    | Hidden from `/` menu; only Claude can trigger              |
| `disable-model-invocation` | Only user can invoke via `/name`; removed from LLM context |
| `context: fork`            | Runs in isolated subagent context                          |
| `agent`                    | Subagent type when `context: fork` is set                  |
| `model`                    | Override model for this skill                              |
| `allowed-tools`            | Space-delimited pre-approved tools (CLI only, not SDK)     |
| `argument-hint`            | Autocomplete hint, e.g. `[issue-number]`                   |

## Description Optimization

The description is how Claude decides whether to load your skill. Get this wrong and the skill never triggers. This is the highest-leverage section of skill authoring.

### Rules

1. **Start with "Use when..."** — focus on triggering conditions
2. **Write in third person** — it's injected into the system prompt
3. **Include trigger keywords** — words the user would naturally say
4. **Be specific** — "Use when tests have race conditions" not "For async testing"
5. **NEVER summarize the workflow** — Claude will follow the description instead of reading the full skill

### Why Rule 5 Matters

Testing revealed that when a description summarizes the skill's workflow, Claude shortcuts it. A description saying "dispatches subagent per task with code review between tasks" caused Claude to do ONE review, even though the skill body specified TWO. When changed to just triggering conditions, Claude read the full skill and followed the two-stage process.

```yaml
# BAD: Summarizes workflow — Claude may follow this instead of reading skill
description: Use for TDD - write test first, watch it fail, write minimal code, refactor

# GOOD: Just triggering conditions
description: Use when implementing any feature or bugfix, before writing implementation code
```

### Make Descriptions Pushy

Claude tends to undertrigger skills. Include not just what the skill does but specific contexts, symptoms, and phrases that should trigger it. Anthropic's own guidance: optimized descriptions improve activation from ~20% to ~90%.

### Debugging Trigger Issues

Ask Claude directly: "When would you use the [skill name] skill?" It will quote the description back. Adjust based on what's missing.

## Progressive Disclosure (Three Levels)

Skills load in stages to minimize token cost:

| Level | What Loads         | When                   | Token Impact          |
| ----- | ------------------ | ---------------------- | --------------------- |
|     1 | Name + description | Always (system prompt) | ~100 tokens per skill |
|     2 | SKILL.md body      | When skill triggers    | ~1-2% of 200K context |
|     3 | Referenced files   | When Claude reads them | On-demand only        |

**Implications:**
- Keep descriptions concise — they compete with other skills for ~16K char budget
- SKILL.md body: under 500 lines (~2,000-3,000 words). This is NOT 500 words.
- Heavy reference material (API docs, lookup tables, exhaustive examples) belongs in `references/`
- With 20-50+ skills enabled, monitor `/context` for budget warnings

## SKILL.md Body Structure

```markdown
# Skill Name

## Overview
Core principle in 1-2 sentences. What is this?

## When to Use
Bullet list of symptoms and use cases.
When NOT to use (scope boundaries).
[Inline flowchart ONLY if decision is non-obvious]

## Core Pattern / Workflow
The actual instructions. Imperative voice, verb-first.
Code examples (one excellent example beats many mediocre ones).
Decision matrices for choosing between approaches.

## Common Mistakes
What goes wrong and how to fix it.

## Anti-Patterns (optional)
What NOT to do, with brief explanations.
```

### What Differentiates Excellent Skills

From analysis of 18 production skills:

| Quality Marker                 | Excellent Skills                         | Mediocre Skills                     |
| ------------------------------ | ---------------------------------------- | ----------------------------------- |
| Addresses agent internal state | Red-flags map thoughts to actions        | Lists rules without self-monitoring |
| Empirical grounding            | "24 failures", "6 iterations"            | No evidence of real use             |
| Executable algorithms          | Pseudocode, prompt templates, checklists | Abstract principles only            |
| Good/Bad comparisons           | Side-by-side with explanation            | One example or none                 |
| Scope boundaries (when NOT)    | Explicit with reasoning                  | Missing or vague                    |

### Skill Types and Their Patterns

**Discipline skills** (TDD, verification): Use Iron Laws, rationalization tables, red-flags lists. Address specific excuses agents make. Average ~1200 words.

**Technique skills** (debugging, research): Use templates, reference tables, step-by-step procedures. Include flowcharts for non-obvious decisions. Average ~1100 words.

**Workflow skills** (planning, execution): Heavy on flowcharts and cross-references. Integration sections show how skills connect. Range 378-1213 words.

**Reference skills** (API docs, tools): Architecture diagrams, comparison tables, wire protocols. Fewest behavioral directives. Average ~850 words.

## Testing Skills

### Three-Area Framework (from Anthropic's playbook)

1. **Triggering**: Does the skill activate on relevant queries? On paraphrased requests? NOT activate on unrelated topics? Target: 90% activation rate on 10-20 test queries.
2. **Functional**: Does Claude follow the instructions correctly? Handle edge cases? Use Given/When/Then format.
3. **Performance**: Compare with-skill vs without-skill on the same task. Track: messages needed, tool calls, token consumption.

### Practical Testing

- **Iterate on one task first**: Get a single challenging scenario working, then expand
- **Test with subagents**: Run pressure scenarios in isolated contexts to check compliance
- **Watch for rationalizations**: When testing discipline skills, document the exact excuses agents use to skip rules — then add explicit counters

## Anti-Rationalization (Discipline Skills Only)

If your skill enforces a rule (like TDD or verification), agents will find loopholes. Close them:

1. **Rationalization table**: Map every excuse to a reality check
2. **Red-flags list**: Thoughts that mean "stop and reconsider"
3. **Explicit loophole closure**: Don't just state the rule — forbid specific workarounds
4. **Iron Law callout**: One non-negotiable statement (e.g., "NO SKILL WITHOUT A FAILING TEST FIRST")

## Common Mistakes

| Mistake                         | Fix                                                         |
| ------------------------------- | ----------------------------------------------------------- |
| Description summarizes workflow | Description = triggering conditions only                    |
| Skill too long (500+ lines)     | Move reference material to `references/`                    |
| No trigger keywords             | Add error messages, symptoms, tool names to description     |
| Vague description               | "Use when tests have race conditions" not "For testing"     |
| Multi-language examples         | One excellent example in the most relevant language         |
| No scope boundaries             | Add "When NOT to use" section                               |
| Narrative storytelling          | Convert to patterns, tables, checklists                     |
| Untested skill                  | Test triggering + functional + performance before deploying |
| Deeply nested file references   | Keep references one level deep from SKILL.md                |

## Quick Reference

### Naming
- kebab-case: `condition-based-waiting`, `writing-skills`
- Gerunds work well for processes: `debugging-with-logs`, `creating-skills`
- Avoid vague names: `helper`, `utils`, `tools`

### File Organization
- Self-contained: everything inline in SKILL.md
- With reference: SKILL.md + `references/` for heavy docs (>100 lines)
- With tools: SKILL.md + `scripts/` for executable code

### Context Budget Math
- Description budget: 2% of context window (~16K chars fallback)
- ~30-40 skills with 100-word descriptions before hitting limit
- SKILL.md body: ~2,000 tokens per invocation for a typical skill
- `disable-model-invocation: true` removes skill from budget entirely

### Validation
- Use `skills-ref validate ./my-skill` (from agentskills repo) to check format
- Ask Claude "When would you use [skill name]?" to test description quality

## Sources

- [Agent Skills open standard](https://agentskills.io/specification)
- [Claude Code skills docs](https://code.claude.com/docs/en/skills)
- [Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Anthropic skills playbook (PDF)](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf)
- See `references/research-summary.md` for the full research corpus
