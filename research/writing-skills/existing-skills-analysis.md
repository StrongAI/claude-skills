# Existing Skills Analysis

Analysis of 18 real skills: 4 local (deep-research, forum-extraction, claude-code-loopback, context-first-lookup) and 14 superpowers (brainstorming, test-driven-development, systematic-debugging, executing-plans, dispatching-parallel-agents, verification-before-completion, writing-plans, subagent-driven-development, writing-skills, using-superpowers, using-git-worktrees, finishing-a-development-branch, receiving-code-review, requesting-code-review). Also analyzed 4 supporting files (anthropic-best-practices.md, testing-skills-with-subagents.md, persuasion-principles.md, graphviz-conventions.dot).

## Individual Skill Analyses

### Local Skills

#### deep-research (1406 words)
- **Structure:** Frontmatter, overview, graphviz flowchart, 5 phases with detail, prompt templates, adapting-scope table, common-mistakes table. Longest local skill.
- **Frontmatter:** Long description with many trigger phrases. Effective at discovery.
- **Strengths:** Prompt templates are extremely practical -- copy-paste ready. Adapting-scope table gives clear guidance for different project sizes. Common-mistakes table is actionable.
- **Weaknesses:** Prompt templates are verbose (4 multi-line templates). Could compress by extracting shared structure.
- **Cross-references:** None. Self-contained.
- **Testing:** No evidence of subagent testing.

#### forum-extraction (1229 words)
- **Structure:** Frontmatter, overview, ASCII architecture diagram, output-format spec with code blocks, file-organization tree, rate-limiting table, platform-specific fetcher sections, incremental-sync pattern, CLI pattern, reference-implementation pointer, checklist, common-mistakes table.
- **Frontmatter:** Good trigger list (scrape, sync, index, extract).
- **Strengths:** Extremely practical reference skill. Platform-specific API details (Discourse JSON API, phpBB selectors) give concrete starting points. Rate-limiting table is non-negotiable rules with rationale. Checklist for adding a new forum is step-by-step.
- **Weaknesses:** Project-specific details (Onshape, McNeel Forum) reduce reusability. User-Agent string is hardcoded to a specific project. Straddles reference and technique skill types.
- **Cross-references:** References statement-mcp ingest_collection.
- **Testing:** No evidence.

#### claude-code-loopback (845 words)
- **Structure:** Frontmatter, overview, ASCII architecture diagram, key-properties bullets, setup steps, wire-protocol spec, client-integration code, MCP-tools table, what-it-doesn't-do list, why-not-other-approaches comparison table, provenance note.
- **Frontmatter:** Highly specific trigger with clear scope.
- **Strengths:** Why-not-other-approaches table is excellent -- preempts wrong paths. Wire protocol is concrete and implementable. Architecture diagram clearly shows data flow.
- **Weaknesses:** Somewhat niche -- only useful during MCP server development. Code examples are Python-only.
- **Cross-references:** None.
- **Testing:** No evidence.

#### context-first-lookup (1019 words)
- **Structure:** Frontmatter, overview with bold core principle, graphviz flowchart, 5-level hierarchy with details, red-flags table, common-mistakes table, bottom-line summary.
- **Frontmatter:** Description lists trigger symptoms ("I don't know where this is", "let me search for"). Good discovery optimization.
- **Strengths:** Red-flags table maps internal thoughts to corrective actions -- addresses the agent's internal state directly. Bottom-line summary crystallizes the point memorably. Flowchart correctly shows hierarchy.
- **Weaknesses:** Somewhat repetitive between hierarchy detail and red-flags table. Level 3 (indexed collections) overlaps with Level 2 (semantic tools).
- **Cross-references:** References statement-mcp tools.
- **Testing:** No evidence.

### Superpowers Skills

#### test-driven-development (1496 words)
- **Structure:** Frontmatter, overview, "Iron Law" callout, when-to-use, graphviz flowchart (red-green-refactor), Good/Bad code examples in custom tags, verification checklist, common-rationalizations table, red-flags list, bug-fix walkthrough, when-stuck table.
- **Frontmatter:** Short, clean: "Use when implementing any feature or bugfix, before writing implementation code."
- **Strengths:** Best example of anti-rationalization design. Good/Bad code comparisons are immediately clear. "Why Order Matters" section preemptively addresses every common objection with devastating logic. Red-flags list is comprehensive. Cross-references testing-anti-patterns.md.
- **Weaknesses:** At 1496 words, pushes the boundary for a frequently-loaded skill. Some redundancy between rationalizations table and red-flags list.
- **Cross-references:** References @testing-anti-patterns.md supporting file.
- **Testing:** Heavily tested -- writing-skills documents the TDD skill's own 6-iteration bulletproofing process.

#### systematic-debugging (1504 words)
- **Structure:** Frontmatter, overview, Iron Law, when-to-use (including "especially when"), 4 phases with detail, diagnostic instrumentation examples, red-flags list, "human partner's signals" section, rationalizations table, quick-reference table, supporting-techniques section.
- **Frontmatter:** Short trigger. Effective.
- **Strengths:** 4-phase structure is clear and memorable. Multi-component diagnostic instrumentation example is gold -- shows exactly what logging to add. "Your human partner's signals" section is unique -- teaches the agent to recognize meta-feedback. The 3-fix escalation rule (question architecture after 3 failed fixes) is practical wisdom.
- **Weaknesses:** "your human partner" phrasing is project-specific. Some bash examples are macOS-specific (security/keychain).
- **Cross-references:** References root-cause-tracing.md, defense-in-depth.md, condition-based-waiting.md, and other superpowers skills.
- **Testing:** Evidence of real-session origin ("From debugging sessions").

#### brainstorming (663 words)
- **Structure:** Frontmatter, overview, HARD-GATE tag, anti-pattern warning, checklist, graphviz flowchart, process detail, after-design section, key-principles list.
- **Frontmatter:** Uses MUST language ("You MUST use this before any creative work"). Aggressive trigger -- tries to match any creative/feature work.
- **Strengths:** HARD-GATE tag is effective framing for absolute requirements. Anti-pattern section preempts "too simple" rationalization. Terminal state is explicit (invoke writing-plans only). Compact for a workflow skill.
- **Weaknesses:** Description says what skill does (violates CSO advice in writing-skills). "MUST use before ANY creative work" is very broad -- could trigger on simple questions.
- **Cross-references:** References writing-plans, elements-of-style.
- **Testing:** No direct evidence.

#### executing-plans (378 words)
- **Structure:** Frontmatter, overview, 5-step process, when-to-stop section, when-to-revisit section, remember bullets, integration section.
- **Frontmatter:** Clean trigger.
- **Strengths:** Extremely concise. Does one thing well. Integration section shows workflow connections. "When to stop and ask for help" is crucial guidance.
- **Weaknesses:** Almost too minimal -- relies heavily on cross-references for substance.
- **Cross-references:** Three required skills referenced.
- **Testing:** No evidence.

#### dispatching-parallel-agents (872 words)
- **Structure:** Frontmatter, overview, when-to-use flowchart, pattern (4 steps), agent-prompt-structure section with good/bad examples, when-NOT-to-use section, real-example section, key-benefits list, verification section, real-world-impact.
- **Frontmatter:** Clean trigger with numeric threshold ("2+ independent tasks").
- **Strengths:** Good/bad agent prompt examples are immediately practical. Real example with concrete results (3 agents, 3 files, all fixed independently) proves the pattern. When-NOT-to-use is well-considered.
- **Weaknesses:** Uses emoji in good/bad markers. Real-world impact section could be more concise.
- **Cross-references:** None explicit.
- **Testing:** Session-dated evidence (2025-10-03).

#### verification-before-completion (668 words)
- **Structure:** Frontmatter, overview, Iron Law, gate-function pseudocode, common-failures table, red-flags list, rationalization-prevention table, key-patterns with good/bad examples, why-this-matters section, when-to-apply scope, bottom-line.
- **Frontmatter:** Long but specific -- includes "evidence before assertions."
- **Strengths:** Gate-function pseudocode is brilliant -- turns abstract principle into executable algorithm. "24 failure memories" gives empirical weight. Common-failures table maps claim-type to required evidence. Scope section ("ANY variation of success claims") closes loopholes.
- **Weaknesses:** Somewhat repetitive between red-flags and rationalization tables.
- **Cross-references:** None.
- **Testing:** Implicitly tested (references 24 failure memories from real sessions).

#### writing-plans (458 words)
- **Structure:** Frontmatter, overview with audience assumptions, bite-sized-task granularity section, plan-document-header template, task-structure template, remember bullets, execution-handoff section.
- **Frontmatter:** Clean trigger.
- **Strengths:** Templates are copy-paste ready. Bite-sized granularity section is crucial ("each step is one action, 2-5 minutes"). Execution handoff gives two clear options. Compact.
- **Weaknesses:** Templates take up most of the word count. Could be compressed.
- **Cross-references:** References executing-plans, subagent-driven-development.
- **Testing:** No evidence.

#### subagent-driven-development (1213 words)
- **Structure:** Frontmatter, overview, when-to-use flowchart, process flowchart (detailed), prompt-template references, example workflow, advantages/costs section, red-flags list, integration section.
- **Frontmatter:** Clean trigger, no workflow summary (follows CSO advice).
- **Strengths:** Process flowchart is the most complex in the collection -- it accurately encodes a two-stage review loop. Example workflow is realistic and shows the full cycle. Advantages section has honest cost accounting.
- **Weaknesses:** Flowchart may be too complex for quick comprehension. Red-flags list is long (14 items).
- **Cross-references:** References prompt templates in directory, 4 other skills.
- **Testing:** Writing-skills documents how workflow summary in description caused agents to skip the two-stage review.

#### writing-skills (3204 words)
- **Structure:** Frontmatter, overview (TDD mapping), when-to-create, skill-types taxonomy, directory-structure, SKILL.md structure template, CSO section (description optimization), flowchart-usage guide, code-examples guidance, file-organization patterns, Iron Law, testing-all-skill-types section, rationalizations table, bulletproofing section, RED-GREEN-REFACTOR for skills, anti-patterns, STOP gate, deployment checklist, discovery workflow, bottom-line.
- **Frontmatter:** Simple trigger.
- **Strengths:** Most comprehensive skill in collection. CSO section is unique and crucial (tested insight about descriptions causing shortcutting). TDD mapping table is elegant. Anti-patterns section with explanations. Supporting files handle heavy reference.
- **Weaknesses:** At 3204 words, very large. Some sections repeat TDD principles already in TDD skill. Supporting files add 8541 more words.
- **Cross-references:** References TDD skill, 4 supporting files.
- **Testing:** Extensive -- documents its own testing methodology.

#### using-superpowers (621 words)
- **Structure:** EXTREMELY-IMPORTANT tag, how-to-access, the-rule section, flowchart, red-flags table, skill-priority, skill-types, user-instructions.
- **Frontmatter:** Session-start trigger.
- **Strengths:** EXTREMELY-IMPORTANT tag is aggressive but appropriate for bootstrapping skill. Red-flags table maps 12 internal thoughts to corrective actions. Skill-priority section (process before implementation) prevents wrong ordering.
- **Weaknesses:** Tone is very forceful. Could alienate rather than persuade.
- **Cross-references:** References brainstorming skill.
- **Testing:** No direct evidence.

#### Remaining skills (using-git-worktrees, finishing-a-development-branch, receiving-code-review, requesting-code-review)
- **Structure:** All follow standard pattern: frontmatter, overview, step-by-step process, common-mistakes, red-flags, integration.
- **Strengths:** Consistent structure. Integration sections show workflow connections. finishing-a-development-branch's "exactly 4 options" framing removes ambiguity.
- **Weaknesses:** receiving-code-review has project-specific language ("your human partner", Circle K reference). requesting-code-review is very thin (366 words).

## Cross-Skill Synthesis

### Common Structural Patterns

| Pattern                       | Prevalence | Purpose                                 |
| ----------------------------- | ---------- | --------------------------------------- |
| YAML frontmatter              | 18/18      | Discovery (name + description)          |
| Overview with core principle  | 16/18      | Immediate context and philosophy        |
| Common-mistakes table         | 12/18      | Error prevention                        |
| Red-flags list                | 10/18      | Self-monitoring triggers                |
| Rationalization table         | 6/18       | Anti-bypass for discipline skills       |
| Graphviz flowchart            | 10/18      | Decision and process visualization      |
| Integration/cross-ref section | 8/14       | Workflow connections (superpowers only) |
| Iron Law callout              | 4/18       | Non-negotiable rule statement           |
| Good/Bad code comparison      | 4/18       | Pattern teaching                        |
| When-to-use / When-NOT-to     | 12/18      | Scope definition                        |
| Real-world impact             | 4/18       | Empirical credibility                   |
| Bottom-line summary           | 6/18       | Memorable takeaway                      |

### Quality Spectrum (Best to Worst)

**Tier 1 -- Exemplary:**
1. **test-driven-development** -- Best anti-rationalization design. Good/Bad examples. Proven through 6-iteration bulletproofing. High density.
2. **verification-before-completion** -- Gate-function pseudocode turns principle into algorithm. Empirically grounded (24 failures).
3. **systematic-debugging** -- 4-phase structure is memorable. Multi-component diagnostic example. "Partner signals" section is unique.
4. **writing-skills** -- Most comprehensive meta-skill. CSO insight is tested and valuable.

**Tier 2 -- Strong:**
5. **deep-research** -- Copy-paste prompt templates. Adapting-scope table. Self-contained methodology.
6. **context-first-lookup** -- Red-flags table addresses internal state. Memorable bottom line.
7. **subagent-driven-development** -- Complex process encoded accurately in flowchart. Honest cost accounting.
8. **brainstorming** -- HARD-GATE is effective. Compact for its scope.
9. **forum-extraction** -- Excellent reference skill. Platform-specific details are immediately useful.

**Tier 3 -- Adequate:**
10. **dispatching-parallel-agents** -- Good real example. Slightly verbose.
11. **claude-code-loopback** -- Clean architecture. Niche scope.
12. **receiving-code-review** -- Good pushback guidance. Too project-specific in places.
13. **using-git-worktrees** -- Solid operational skill. Procedural.
14. **finishing-a-development-branch** -- Clear 4-option structure.

**Tier 4 -- Minimal:**
15. **writing-plans** -- Templates useful but thin on guidance.
16. **executing-plans** -- Too minimal, relies on cross-references.
17. **requesting-code-review** -- Bare-bones, mostly a pointer to template.
18. **using-superpowers** -- Aggressive tone, more enforcement than teaching.

### What Differentiates Excellent from Mediocre

| Quality marker                     | Excellent skills                             | Mediocre skills                     |
| ---------------------------------- | -------------------------------------------- | ----------------------------------- |
| Addresses agent's internal state   | Red-flags map thoughts to actions            | Lists rules without self-monitoring |
| Empirical grounding                | "24 failures", "6 iterations"                | No evidence of real use             |
| Anti-rationalization design        | Explicit counters for specific excuses       | Rules without loophole closure      |
| Executable algorithms              | Gate-function pseudocode, prompt templates   | Abstract principles only            |
| Good/Bad comparisons               | Side-by-side with explanation                | One example or none                 |
| Honest cost accounting             | "More invocations, but catches issues early" | Only benefits listed                |
| Bottom-line summary                | Memorable one-liner                          | Ends with checklist                 |
| Scope boundaries (when NOT to use) | Explicit with reasoning                      | Missing or vague                    |

### Patterns by Skill Type

**Discipline skills** (TDD, verification, debugging): Heaviest use of Iron Laws, rationalization tables, red-flags lists, pressure-tested. Authority + commitment persuasion. Average ~1200 words.

**Technique skills** (deep-research, forum-extraction, context-first-lookup): Heavier on templates, reference tables, step-by-step procedures. Moderate use of flowcharts. Average ~1100 words.

**Workflow/orchestration skills** (executing-plans, subagent-driven, brainstorming, writing-plans): Heaviest use of flowcharts and cross-references. Integration sections are critical. Wide word-count range (378--1213).

**Reference skills** (claude-code-loopback): Architecture diagrams, wire protocols, comparison tables. Fewest behavioral directives. Average ~850 words.

### Local vs. Superpowers Comparison

| Dimension                | Local skills            | Superpowers                  |
| ------------------------ | ----------------------- | ---------------------------- |
| Average words            |                    1125 |                          952 |
| Frontmatter quality      | Good triggers, longer   | Shorter, cleaner             |
| Anti-rationalization     | Absent                  | Strong in discipline skills  |
| Cross-references         | Minimal                 | Extensive workflow web       |
| Testing evidence         | None                    | Present in 4+ skills         |
| Flowchart usage          | 2/4 skills              | 8/14 skills                  |
| Project-specific content | Some (forum-extraction) | Some (receiving-code-review) |
| Integration sections     | Absent                  | 8/14 skills                  |

Local skills are strong as standalone references but lack the workflow integration and testing discipline of the superpowers collection. Superpowers skills form an interconnected workflow graph (brainstorming -> writing-plans -> executing-plans/subagent-driven -> finishing-a-development-branch), while local skills are islands.

### Token Efficiency Observations

- writing-skills at 3204 words + 8541 words in supporting files is the outlier. It uses supporting files correctly (heavy reference offloaded).
- The most effective skills per word: verification-before-completion (668 words, maximum impact), executing-plans (378 words, clear delegation), brainstorming (663 words, effective gating).
- Least efficient: deep-research prompt templates (4 templates with substantial overlap could share structure), TDD's redundant rationalization/red-flags sections.
- Anthropic's official guidance recommends <500 words for SKILL.md. Only 5/18 skills meet this. The disconnect suggests real skills need more space than official guidance implies, or that many skills are bloated.

## Gaps & Further Research

1. **No quantitative testing data.** Writing-skills describes a testing methodology but no skill publishes test results (pass rates, iteration counts, failure modes) as structured data.

2. **Description optimization is under-explored.** The CSO insight (descriptions causing shortcutting) is documented for one case. Systematic testing of description variants across multiple skills would be valuable.

3. **No token-budget analysis.** How many skills can be loaded simultaneously before context pressure degrades performance? No skill addresses this.

4. **Discipline skills lack graduated responses.** They're binary (follow rule or violate). No skill models "partial compliance" or "degraded-mode" operation for genuinely constrained situations.

5. **No versioning or deprecation pattern.** Skills evolve (writing-skills references iteration history) but no skill documents how to version or deprecate.

6. **Reference skills lack freshness signals.** forum-extraction has hardcoded API details that may go stale. No pattern for marking "verify this is current."

7. **Missing: skill composition patterns.** The superpowers workflow graph is implicit in cross-references. No skill explicitly documents the full workflow DAG or how skills compose.

8. **Missing: failure-mode documentation.** What happens when a skill is loaded but the agent ignores it? Only writing-skills addresses this (through testing methodology). Other skills have no fallback.

9. **Local skills could benefit from the superpowers integration pattern.** deep-research and context-first-lookup have natural connections that are not documented.

10. **Anthropic best practices vs. superpowers practice gap.** Official docs recommend <500 words and high-freedom text instructions. Superpowers discipline skills use 668--1504 words with low-freedom imperative language. Which approach produces better outcomes is not empirically settled.
