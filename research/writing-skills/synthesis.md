# Phase 2 Synthesis: Writing Claude Skills

## Coverage Map

| Sub-topic                          | Coverage       | Sources                    | Notes                                                              |
| ---------------------------------- | -------------- | -------------------------- | ------------------------------------------------------------------ |
| SKILL.md format & frontmatter      | Well Covered   | Official, Community        | Open standard spec + Claude Code extensions well-documented        |
| Description optimization (CSO)     | Well Covered   | All 3                      | Tested insight: descriptions causing shortcutting is key finding   |
| Progressive disclosure / loading   | Well Covered   | Official, Community        | 3-level model clear; 2% context budget documented                  |
| Anti-rationalization design        | Well Covered   | Existing skills            | Superpowers collection pioneered this; 6 skills use it             |
| Testing methodology                | Partial        | Existing skill             | TDD approach documented but no quantitative results published      |
| Token budget constraints           | Partial        | Official, Community        | 15k char budget mentioned; practical limits unexplored             |
| Real skill anatomy (patterns)      | Well Covered   | Existing skills            | 18 skills analyzed; quality spectrum from exemplary to minimal     |
| Distribution / packaging           | Partial        | Community                  | Fragmented; not relevant to authoring skill                        |
| Cross-platform compatibility       | Gap            | —                          | No systematic comparison of SKILL.md across platforms              |
| Skill composition patterns         | Gap            | —                          | Implicit in cross-refs; no formal documentation                    |
| Versioning / deprecation           | Gap            | —                          | No convention exists                                               |
| Official vs practiced word counts  | Tension        | Official vs Existing       | Official says <500 words; best real skills are 668-1500 words      |

## Foundation → Frontier Links

| Foundation (established)                    | Frontier (new solution/insight)                                       |
| ------------------------------------------- | --------------------------------------------------------------------- |
| Skills are prompt injection (not code)      | Progressive disclosure manages token cost (3-level loading)           |
| YAML frontmatter for metadata               | CSO: description must NOT summarize workflow (tested, verified)       |
| TDD cycle (red-green-refactor)              | TDD applied to skill authoring (existing writing-skills skill)        |
| Persuasion research (Cialdini)              | Anti-rationalization tables in discipline skills                      |
| Official spec recommends <500 words         | Real practice shows 668-1500 words for effective skills               |
| LLM routing via description matching        | "Pushy" descriptions improve activation 20% → 90%                    |
| Agent Skills open standard (agentskills.io) | Cross-platform portability (14+ tools consume SKILL.md)               |

## Heat Map

| Topic                              | Temperature | Evidence                                                         |
| ---------------------------------- | ----------- | ---------------------------------------------------------------- |
| Skill ecosystem growth             | Hot         | 72k stars on everything-claude-code; 1200+ skills indexed        |
| Description optimization           | Hot         | Multiple sources confirm this is the #1 lever for skill quality  |
| Testing/eval frameworks            | Warm        | Anthropic added eval to skill-creator March 2026; still early    |
| Anti-rationalization patterns      | Warm        | Proven in superpowers; not widely adopted outside that collection |
| Cross-platform portability         | Warm        | SKILL.md format converging; behavior differences not studied      |
| Skill security                     | Cold        | skill-sentinel exists but early; no systematic analysis           |
| Skill versioning                   | Cold        | No convention; no tooling; no community discussion                |
| Enterprise deployment patterns     | Cold        | Shipped Dec 2025; minimal public case studies                     |

## Gap List for Phase 3

### Priority 1: High value for producing the final skill

1. **Anthropic's 32-page playbook PDF** — May contain guidance not in web docs. URL: `resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf`. Search terms: "complete guide building skills claude pdf"

2. **Word count tension resolution** — Official docs say <500 words; best real skills are 668-1500. Which is right? Need to synthesize the official guidance with empirical evidence from existing skills. This directly affects the authoring guidance in our final skill.

3. **Skill-creator eval methodology** — Anthropic's skill-creator has eval/benchmark modes. What exactly does the eval loop look like? How does it compare to the TDD-with-subagents approach? Search terms: "skill-creator eval benchmark methodology"

### Priority 2: Useful but not blocking

4. **Token budget practical analysis** — How many skills can coexist before context pressure degrades performance? What's the real char count at 2% of various context windows?

5. **Skill composition patterns** — How should skills reference each other? The superpowers collection uses cross-refs but no formal model exists.

### Priority 3: Nice to have

6. **Hooks integration** — The `hooks` frontmatter field is mentioned but not documented.
7. **Cross-platform testing** — How the same SKILL.md behaves across Claude Code, Cursor, Codex.

## Unexpected Connections

1. **CSO parallels SEO** — The description optimization problem is structurally identical to SEO meta-descriptions. Same tradeoff: information density vs. triggering the right behavior. The "pushy description" recommendation maps to SEO's "compelling call-to-action in meta description."

2. **Anti-rationalization ≈ adversarial robustness** — The technique of explicitly listing and countering rationalizations is analogous to adversarial training in ML. You're training the skill against the model's own evasion strategies.

3. **Progressive disclosure ≈ lazy loading** — The 3-level loading model (metadata → SKILL.md → references) mirrors lazy loading in web apps. Same principle: load the minimum needed, defer the rest.

4. **The word count tension reveals a design constraint** — Official guidance optimizes for the SYSTEM (context budget). Real practice optimizes for EFFECTIVENESS (agent compliance). The resolution is progressive disclosure: keep the SKILL.md lean (official guidance) but use references/ for depth (real practice).

## Practical Priorities for This Project

Our goal is to produce a standalone skill for writing Claude skills. Priority ranking:

1. **Description writing guidance** — This is the highest-leverage section. Get this wrong and the skill never triggers.
2. **SKILL.md structure template** — Practical, copy-paste ready.
3. **Word count guidance** — Resolve the tension with clear recommendations.
4. **Quality differentiators** — What separates excellent from mediocre (from existing-skills-analysis).
5. **Testing approach** — Simplified from the existing writing-skills skill (which is very heavy).
6. **Anti-patterns** — What NOT to do.
7. **Progressive disclosure guidance** — When to use references/ vs inline.

## Relationship to Existing `superpowers:writing-skills`

The existing skill is comprehensive (3204 words + 8541 in supporting files) but tightly coupled to the superpowers ecosystem:
- Requires `superpowers:test-driven-development` as prerequisite
- References `superpowers:` specific tools and workflows
- Heavy emphasis on TDD cycle (appropriate for superpowers but may be overkill for standalone use)
- Contains the CSO insight which is universally valuable

Our new skill should:
- Be standalone (no cross-skill prerequisites)
- Incorporate the CSO insight
- Include the quality differentiators from the analysis
- Resolve the word count tension
- Be usable by anyone, not just superpowers users
- Be significantly more concise — aim for ~500-800 words in SKILL.md with a reference file for depth
