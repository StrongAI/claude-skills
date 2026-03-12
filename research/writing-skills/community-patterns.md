# Community Patterns for Claude Code Skill Authoring

Research date: 2026-03-11

## 1. Major Skill Collections and Repositories

### everything-claude-code (72k stars)
- **Repo**: https://github.com/affaan-m/everything-claude-code
- The dominant skill collection. 65+ skills covering languages, frameworks, domains, and meta-workflows.
- Installs as a Claude Code plugin via `/plugin marketplace add`.
- Includes agents (12+ subagents), skills, commands (40+ slash commands), rules, hooks, and scripts.
- Skills organized as flat directories under `skills/`, each with a `SKILL.md`. No nesting by category.
- Uses `origin: ECC` in frontmatter as provenance marker.
- Pattern: skills are verbose (1500-3000 words), include code examples, decision matrices, ASCII workflow diagrams.
- Notable skills: `tdd-workflow`, `search-first`, `verification-loop`, `strategic-compact`, `continuous-learning`.
- Chinese translation fork exists (107 stars): https://github.com/xu-xiang/everything-claude-code-zh

### agent-skill-creator (370 stars)
- **Repo**: https://github.com/FrancyJGLisboa/agent-skill-creator
- Generates cross-platform skills from workflow descriptions. One SKILL.md, 14+ platforms.
- Outputs include: SKILL.md, scripts/, references/, assets/, install.sh, README.md.
- The `install.sh` auto-detects installed tools and generates format adapters (.mdc for Cursor, .md rules for Windsurf).
- Creates `~/.agents/skills/` symlink for multi-tool discoverability.
- Key insight: the SKILL.md format is becoming a de facto universal standard across AI coding tools.

### agentsys (552 stars)
- **Repo**: https://github.com/agent-sh/agentsys
- 15 plugins, 35 agents, 32 skills for Claude Code, OpenCode, Codex, Cursor.
- Same team behind `agnix`, a Rust linter/LSP for validating SKILL.md, hooks, and MCP configs.

### awesome-claude-skills / awesome-agent-skills
- Multiple competing curated lists:
  - https://github.com/travisvn/awesome-claude-skills
  - https://github.com/ComposioHQ/awesome-claude-skills
  - https://github.com/VoltAgent/awesome-agent-skills (500+ skills from dev teams)
  - https://github.com/sickn33/antigravity-awesome-skills (1000+ skills)
- Web directory: https://awesome-skills.com/ (1,239+ skills indexed)

### Anthropic Official Skills
- **Repo**: https://github.com/anthropics/skills
  - Includes `skill-creator` (a meta-skill for authoring skills with evals).
  - Official `frontend-design` skill: 277k+ installs as of March 2026.
- **Plugin dev skills**: https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev/skills

### Domain-Specific Collections
- **robotics-agent-skills** (137 stars): ROS1/ROS2, SOLID principles, testing patterns.
- **codealive-skills**: Semantic code search integration.
- **oen-payment-skill**: Payment processing for Taiwan's Oen platform.
- **stream-coding** (70 stars): Methodology-as-skill for specification-driven development.

## 2. How Skill Discovery Works (Technical Architecture)

Source: https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/

The skill system is a **prompt-based meta-tool**, not executable code:

1. **Startup scan**: System scans `~/.config/claude/skills/`, `.claude/skills/`, plugin skills, and built-ins.
2. **Metadata injection**: Skill names and descriptions are formatted into the `Skill` tool's prompt as `<available_skills>`. Token budget: ~15,000 characters for the full skill list.
3. **LLM routing**: Claude's transformer forward pass matches user intent to skill descriptions. No algorithmic routing, embeddings, or pattern matching -- pure language understanding.
4. **Dual-message injection** on invocation:
   - Visible metadata message (user-facing status)
   - Hidden skill prompt message (detailed instructions)
5. **Progressive disclosure**: Only metadata loads at startup. SKILL.md body loads on invocation. Reference files load on demand.

Source: https://mikhail.io/2025/10/claude-code-skills/

Skills are "injected instructions that guide Claude's behavior within the main conversation" -- not separate processes, sub-agents, or external tools. They are "executable knowledge packages that Claude loads only when needed."

## 3. SKILL.md Format Specification

### Required Frontmatter
```yaml
---
name: kebab-case-name     # lowercase, digits, hyphens only
description: "When to use this skill and what it does"
---
```

### Optional Frontmatter Fields
- `allowed-tools`: Restricts tool access during skill execution
- `model`: Override model for this skill
- `version`: Skill version
- `license`: License identifier
- `metadata`: Arbitrary key-value pairs
- `compatibility`: Platform compatibility info
- `disable-model-invocation`: Prevent model override
- `mode`: Execution mode

### Naming Convention
- kebab-case: `pdf-editor`, `brand-guidelines`, `tdd-workflow`
- Some authors prefer gerund form: `debugging`, `planning`, `testing`

### Body Structure Patterns

**Reference-style** (domain knowledge):
```markdown
# Skill Name
## When to Use
## Core Principles
## Patterns / Guidelines
## Examples
## Anti-Patterns
```

**Task-style** (step-by-step workflow):
```markdown
# Skill Name
## Trigger / When to Activate
## Workflow Steps
## Decision Matrix
## Integration Points
## Examples
```

### Directory Structure
```
skill-name/
  SKILL.md           # Required entry point
  scripts/           # Executable code (Python, Bash)
  references/        # Detailed docs, loaded on demand
  templates/         # Output templates
  assets/            # Data files
```

## 4. Effective Patterns Observed

### Description Optimization
- Anthropic data: optimized descriptions improve activation from ~20% to ~50%. Adding examples pushes it to ~90%.
- Write from Claude's perspective: "Use this skill when..." not "This skill is for..."
- Include trigger keywords that match user language.
- Keep under ~200 characters for the token budget.

### Content Organization
- Target 1,500-2,000 words for SKILL.md body.
- Split large skills: SKILL.md stays lean, detailed content in `references/`.
- Use ASCII diagrams for workflows (common in everything-claude-code).
- Include decision matrices (When to X vs Y).
- Include anti-patterns (what NOT to do).

### Skill Composition
- Skills reference other skills and agents (e.g., search-first invokes "researcher agent").
- Integration points documented explicitly ("With planner agent", "With architect agent").
- everything-claude-code treats skills as nodes in a larger agent harness system.

### Visual Output Pattern
- Generate interactive HTML for data viz, reports, dependency graphs.
- Bundled script does computation; Claude handles orchestration.

### Testing Skills
- `skill-creator` (Anthropic) added eval/benchmark support in March 2026.
- Tests verify: activation triggers, output quality, edge cases.
- Pain point: most authors had no way to verify skills worked after model updates until this feature.

## 5. Distribution and Installation Methods

### Current Methods (March 2026)
1. **Claude Code plugin system**: `/plugin marketplace add org/repo` then `/plugin install`
2. **Manual upload**: ZIP and upload via Settings > Customize > Skills
3. **Organization-level skills**: Shipped Dec 2025 with auto-updates and centralized management
4. **Git clone + install script**: Common for everything-claude-code and similar
5. **Symlink to ~/.agents/skills/**: Cross-tool discovery (agent-skill-creator pattern)

### Emerging Tools
- **skilo** (https://github.com/yazcaleb/skilo): Share skills with a link. Publish/install across Claude Code, Codex, Cursor.
- **skillnote** (https://github.com/luna-prompts/skillnote): Self-hosted skill registry (Next.js + FastAPI).
- **vscode-agent-skill-ninja**: VS Code extension for searching/installing skills.
- **obsidian-skills-manager**: Obsidian plugin for browsing/toggling skills.
- **SkillsMP** (https://skillsmp.com): Agent Skills Marketplace.
- **agnix**: Rust linter/LSP that validates SKILL.md files, hooks, and MCP configs.
- **skill-sentinel**: Security scanner for malicious SKILL.md files (prompt injection, data exfiltration).

### No Dominant Standard Yet
- Distribution is fragmented: git repos, ZIP uploads, marketplaces, plugin systems.
- The SKILL.md format itself is converging, but packaging and versioning are not standardized.
- Anthropic has hinted at a marketplace but nothing formal as of March 2026.

## 6. Blog Posts and Deep Dives

| Source                     | URL                                                                                                               | Key Insight                                                                    |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| Anthropic Engineering      | https://claude.com/blog/equipping-agents-for-the-real-world-with-agent-skills                                     | Progressive disclosure architecture; skills as "executable knowledge packages" |
| Lee Han Chung              | https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/                                           | Technical teardown: pure LLM routing, dual-message injection, 15k char budget  |
| Mikhail Shilkov            | https://mikhail.io/2025/10/claude-code-skills/                                                                    | Skills are injected instructions, not processes; on-demand prompt expansion    |
| Sid Saladi (Substack)      | https://sidsaladi.substack.com/p/claude-codes-secret-weapon-the-complete                                          | 60 copy-paste templates for SKILL.md, CLAUDE.md, and config files              |
| Bibek Poudel (Medium)      | https://bibek-poudel.medium.com/the-skill-md-pattern-how-to-write-ai-agent-skills-that-actually-work-72a3169dd7ee | Practical patterns for skills that activate reliably                           |
| Unicodeveloper (Medium)    | https://medium.com/@unicodeveloper/10-must-have-skills-for-claude-and-any-coding-agent-in-2026-b5451b013051       | Top 10 skills for 2026; planning skill most starred in ecosystem               |
| HuggingFace blog           | https://huggingface.co/blog/sionic-ai/claude-code-skills-training                                                 | Using skills to run 1,000+ ML experiments/day                                  |
| Codecademy                 | https://www.codecademy.com/article/how-to-build-claude-skills                                                     | Beginner tutorial: lesson plan generator                                       |
| AI Practitioner (Substack) | https://aipractitioner.substack.com/p/building-claude-skills-a-new-paradigm                                       | Skills as a new paradigm for LLM interaction                                   |
| BSWEN                      | https://docs.bswen.com/blog/2026-03-10-claude-code-skills-when-to-create/                                         | Decision framework: when to use skills vs CLAUDE.md vs hooks                   |

## 7. Common Pain Points

1. **Activation unreliability**: Skills don't trigger when expected. Requires careful description tuning.
2. **No testing framework** (until March 2026 skill-creator update): Authors couldn't verify skills worked after model updates.
3. **Context budget pressure**: 15k char limit for skill list means bloated descriptions crowd out other skills.
4. **Discovery fragmentation**: Solutions scattered across GitHub, Discord, blogs. Duplication is rampant.
5. **No versioning standard**: Skills break across model updates with no way to pin versions.
6. **Security concerns**: Third-party skills can contain prompt injection. skill-sentinel exists but is early.
7. **Cross-platform inconsistency**: SKILL.md format is universal but platform-specific behaviors differ.
8. **Frontmatter documentation gaps**: Anthropic's own docs were initially incomplete about allowed fields (GitHub issue #37 on anthropics/skills, superpowers issue #195).

## 8. What Makes Skills Effective vs. Ineffective

### Effective
- Clear, keyword-rich descriptions matching user language
- Imperative/verb-first instructions in the body
- Decision matrices and concrete examples
- Progressive disclosure (lean SKILL.md, details in references/)
- Explicit trigger conditions ("Use when...")
- Anti-patterns section (what to avoid)
- Integration points with other skills/agents

### Ineffective
- Vague descriptions ("A helpful skill for coding")
- Overly long SKILL.md (3000+ words all in one file)
- No examples or only abstract guidance
- Missing trigger conditions
- Testing implementation details instead of user-visible behavior
- Ignoring the 15k char budget constraint

## Gaps and Further Research

1. **Quantitative activation data**: No public benchmarks on skill activation rates by description style. The 20%->50%->90% numbers are from a single source; would be good to verify independently.
2. **Cross-platform compatibility testing**: How does the same SKILL.md perform across Claude Code vs Cursor vs Codex? No systematic comparison exists.
3. **Skill composition patterns**: How do skills compose in practice? The everything-claude-code approach (skills reference agents) is one model, but formal composition frameworks are absent.
4. **Security analysis**: skill-sentinel is early. No comprehensive analysis of prompt injection vectors in community skills.
5. **Performance impact**: No data on how many skills degrade Claude's performance. What is the practical limit before the 15k budget becomes a bottleneck?
6. **Versioning and breaking changes**: How do model updates affect existing skills? No longitudinal study exists.
7. **Non-English skills**: Almost no research on skill authoring in non-English languages. The Chinese translation of everything-claude-code is a start.
8. **Skill deprecation patterns**: How should skills be retired or superseded? No community convention exists.
9. **Anthropic's skill-creator evals**: The March 2026 update added testing/benchmarking, but detailed methodology is not yet documented publicly.
10. **Organization-level skill management**: Shipped Dec 2025, but case studies on enterprise adoption patterns are sparse.
