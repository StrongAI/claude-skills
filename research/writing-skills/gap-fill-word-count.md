# Gap Fill: SKILL.md Word Count — "500 Lines" vs Real-World Practice

## The Claimed Tension

Our synthesis identified a tension: Anthropic says keep SKILL.md under 500, but the most effective real skills exceed that. This research resolves it.

## What Anthropic Actually Says

The official guidance is **500 lines**, not 500 words. This distinction matters enormously.

Sources (all say the same thing):

- **Claude Code docs** (code.claude.com/docs/en/skills): "Keep SKILL.md under 500 lines. Move detailed reference material to separate files."
- **Best practices doc** (platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices): "Keep SKILL.md body under 500 lines for optimal performance. Split content into separate files when approaching this limit."
- **skill-creator** (github.com/anthropics/skills): Same 500-line guidance, framed as approximate.

There is **no 500-word limit** anywhere in official docs. The "500 words" figure in our synthesis was a misreading or community telephone-game corruption of "500 lines."

## The Math: 500 Lines vs 500 Words

These are very different limits:

| Metric     | 500 Lines     | 500 Words |
| ---------- | ------------- | --------- |
| Words      | ~2,000-3,000  |       500 |
| Tokens     | ~2,500-4,000  | ~650      |
| Characters | ~15,000-20,00 | ~3,500    |

A 500-line SKILL.md at typical line lengths (40-60 chars average, including blank lines and headings) holds roughly 2,000-3,000 words. This means:

- **test-driven-development at 1,496 words**: Well within the 500-line limit
- **verification-before-completion at 668 words**: Comfortably within it
- **brainstorming at 663 words**: Comfortably within it

**There is no tension.** The effective skills we analyzed all fit within Anthropic's actual recommendation. The perceived conflict was based on confusing "lines" with "words."

## The 2% Context Budget (Description Only)

A separate budget governs **skill descriptions**, not skill bodies:

- Budget: 2% of context window, minimum fallback of 16,000 characters
- At 200K tokens (~150K words): 2% = 4,000 tokens for ALL skill descriptions combined
- Description max: 1,024 characters per skill
- This budget is for the YAML frontmatter (name + description) of all skills, which are pre-loaded so Claude knows what is available

The SKILL.md body is NOT pre-loaded. It loads on-demand when the skill triggers. So the body's size affects per-invocation token cost, not the always-on budget.

**Practical capacity**: With a 4,000-token description budget, you can have roughly 30-40 skills with 100-word descriptions before hitting the limit. The `/context` command warns when skills are excluded.

## How Skill Loading Actually Works

Three-level progressive disclosure:

1. **Always loaded**: Name + description from YAML frontmatter (counts against 2% budget)
2. **Loaded on trigger**: SKILL.md body (counts against conversation context)
3. **Loaded on demand**: Referenced files in skill directory (loaded only when Claude reads them)

This means a 1,500-word SKILL.md costs ~2,000 tokens only when invoked. In a 200K context window, that is 1% of context. Even a maximally large 500-line / ~3,000-word SKILL.md would consume ~4,000 tokens, or 2% of context per invocation.

## Why "Under 500 Lines" Is the Right Guidance

The limit is not about hard enforcement. It is about diminishing returns:

1. **Token competition**: Every token in a loaded skill competes with conversation history, code context, and other skills
2. **Reading overhead**: Claude must read and process the entire SKILL.md when triggered
3. **Progressive disclosure exists**: Anything beyond core instructions belongs in reference files that load only when needed
4. **Practical threshold**: At 500+ lines, the content almost certainly contains reference material that should be split out

Anthropic's best-practices doc frames this explicitly: "Split content into separate files when approaching this limit. Use the progressive disclosure patterns."

## Correcting Our Synthesis

The synthesis table entry should be updated:

| Before (incorrect)                              | After (correct)                                     |
| ----------------------------------------------- | --------------------------------------------------- |
| "Official says <500 words"                      | "Official says <500 lines (~2,000-3,000 words)"     |
| "Best real skills are 668-1500 words (too big)" | "Best real skills are 668-1500 words (well within)" |
| Tension: official vs practice                   | No tension: practice fits within official guidance  |

## Practical Guidelines for Skill Authors

### SKILL.md Body

- **Target**: Under 500 lines (approximately 2,000-3,000 words max)
- **Sweet spot**: 50-200 lines for most skills. Only approach 500 for complex workflow skills.
- **If approaching 500 lines**: Split reference material into separate files, not because of a hard limit, but because progressive disclosure is more token-efficient
- **What belongs in SKILL.md**: Core instructions, decision logic, workflow steps, anti-patterns, key examples
- **What belongs in references/**: API docs, exhaustive examples, lookup tables, domain-specific data, templates

### Description (YAML Frontmatter)

- **Target**: Under 100 words (well within the 1,024-character max)
- **Must include**: What the skill does AND when to trigger it
- **Write in third person**: "Processes PDFs..." not "I help you process PDFs..."
- **Include trigger phrases**: Words the user would naturally say

### Token Budget Awareness

- With 30+ skills installed, check `/context` for description budget warnings
- Each invoked skill costs ~1-2% of a 200K context window
- Skills invoked by subagents (context: fork) get their own context, so size matters less
- `disable-model-invocation: true` removes a skill from the description budget entirely

## Sources

- Anthropic skill docs: https://code.claude.com/docs/en/skills
- Anthropic best practices: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- Anthropic skill-creator: https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md
- Anthropic official skills repo: https://github.com/anthropics/skills
