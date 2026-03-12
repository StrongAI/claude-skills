# Writing Skills — Research Summary

Compiled from deep research (March 2026) across official docs, community patterns, 18 existing skill analyses, and Anthropic's 32-page playbook PDF.

## Architecture Patterns (from Anthropic's Playbook)

Five patterns for structuring skills:

1. **Sequential Workflow Orchestration**: Steps in specific order. Each step names the tool, parameters, and wait conditions. Include rollback instructions.
2. **Multi-MCP Coordination**: Workflows spanning services (e.g., Figma → Drive → Linear → Slack). Phase separation with validation gates.
3. **Iterative Refinement**: Quality improves with loops. Draft → validate → refine → finalize. Key: define when to stop iterating.
4. **Context-Aware Tool Selection**: Same outcome, different tools based on context. Explain to user why a particular tool was chosen.
5. **Domain-Specific Intelligence**: Specialized knowledge beyond tool access. Compliance, regulations, or domain expertise embedded in skill logic.

## Design Framing

- **Problem-first**: User describes outcomes; skill orchestrates tools. User doesn't need to know which tools exist.
- **Tool-first**: User has tools connected; skill teaches optimal workflows and best practices.

## Quantitative Benchmarks

| Metric              | Limit/Target                          |
| ------------------- | ------------------------------------- |
| SKILL.md body       | Under 500 lines (~2,000-3,000 words)  |
| SKILL.md words      | Under 5,000 (Anthropic playbook)      |
| Description         | Under 1,024 characters                |
| Compatibility field | 1-500 characters                      |
| Simultaneous skills | 20-50 before performance degrades     |
| Description budget  | 2% of context window (min 16K chars)  |
| Skills in budget    | ~30-40 with 100-word descriptions     |
| Trigger target      | 90% on 10-20 test queries             |
| Build time          | 15-30 minutes for first working skill |

## String Substitutions Available

| Variable               | Description                    |
| ---------------------- | ------------------------------ |
| `$ARGUMENTS`           | All arguments passed on invoke |
| `$ARGUMENTS[N]` / `$N` | Specific argument by 0-index   |
| `${CLAUDE_SESSION_ID}` | Current session ID             |
| `${CLAUDE_SKILL_DIR}`  | Directory containing SKILL.md  |

Dynamic context: `` !`command` `` runs shell commands before skill content is sent. Output replaces the placeholder.

## Invocation Control Matrix

| Frontmatter                      | User invoke | Claude invoke | Context loading                     |
| -------------------------------- | ----------- | ------------- | ----------------------------------- |
| (default)                        | Yes         | Yes           | Description always; body on trigger |
| `disable-model-invocation: true` | Yes         | No            | Removed from LLM context            |
| `user-invocable: false`          | No          | Yes           | Description always; body on trigger |

## Skill Locations

| Location   | Path                               | Scope         |
| ---------- | ---------------------------------- | ------------- |
| Enterprise | Managed settings                   | All org users |
| Personal   | `~/.claude/skills/<name>/SKILL.md` | All projects  |
| Project    | `.claude/skills/<name>/SKILL.md`   | This project  |
| Plugin     | `<plugin>/skills/<name>/SKILL.md`  | Where enabled |

Priority: enterprise > personal > project.

## Community Ecosystem (March 2026)

- **everything-claude-code**: 72K stars, 65+ skills, dominant collection
- **awesome-skills.com**: 1,239+ skills indexed
- **Agent Skills standard**: Consumed by 14+ tools beyond Claude Code
- **Distribution**: Fragmented — plugins, ZIP upload, git clone, symlinks, emerging marketplaces
- No dominant packaging or versioning standard yet

## Instruction Writing Tips (from Playbook)

- **Bullet points over prose**: Instructions are followed more reliably
- **Critical instructions at top**: Don't bury important rules
- **Specific over ambiguous**: "Run validation script X" not "validate things properly"
- **Programmatic validation**: Bundle scripts for critical checks; code is deterministic, language is not
- **Combating laziness**: "Take your time. Quality over speed. Do not skip steps." — more effective in user prompt than SKILL.md
- **Extended thinking**: Include "ultrathink" anywhere in skill content to enable

## Quality Spectrum (from 18-Skill Analysis)

### Tier 1 (Exemplary)
- test-driven-development: Anti-rationalization design, Good/Bad comparisons, 6-iteration bulletproofing
- verification-before-completion: Gate-function pseudocode, empirically grounded (24 failures)
- systematic-debugging: 4-phase structure, multi-component diagnostic examples

### What Makes the Difference
- Addresses agent's internal state (red-flags map thoughts to actions)
- Empirical grounding (evidence from real sessions)
- Anti-rationalization (explicit counters for specific excuses)
- Executable algorithms (pseudocode, templates, checklists — not just principles)
- Honest cost accounting (benefits AND tradeoffs)

## Testing Methodology

### Anthropic's Three-Area Framework
1. **Triggering**: 10-20 queries, positive + negative. Target 90% activation.
2. **Functional**: Given/When/Then format. Edge cases.
3. **Performance**: With-skill vs without-skill comparison.

### TDD Approach (from superpowers collection)
- RED: Run scenario without skill. Document baseline behavior and rationalizations.
- GREEN: Write minimal skill addressing those specific failures.
- REFACTOR: Find new rationalizations, add counters, re-test.

### Practical Tips
- Iterate on one task first, then expand
- Ask Claude "When would you use [skill]?" to debug descriptions
- For discipline skills, pressure-test with combined pressures (time + sunk cost + authority)

## Research Files

Full research available in `../../research/writing-skills/`:
- `official-docs.md` — Anthropic documentation analysis (14 sources)
- `community-patterns.md` — Community skills ecosystem
- `existing-skills-analysis.md` — 18-skill quality analysis
- `synthesis.md` — Cross-source synthesis and gap analysis
- `gap-fill-playbook.md` — Anthropic's 32-page playbook PDF insights
- `gap-fill-word-count.md` — Resolution of the "500 lines vs 500 words" confusion
