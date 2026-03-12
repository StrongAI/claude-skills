# Official Anthropic Documentation on Writing Claude Code Skills

Research date: 2026-03-11

## Sources

| Source                           | URL                                                                                       |
| -------------------------------- | ----------------------------------------------------------------------------------------- |
| Claude Code Skills docs          | https://code.claude.com/docs/en/skills                                                    |
| Agent Skills overview (API docs) | https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview                |
| Skill authoring best practices   | https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices          |
| Agent Skills in the SDK          | https://platform.claude.com/docs/en/agent-sdk/skills                                      |
| Agent Skills open standard spec  | https://agentskills.io/specification                                                      |
| Engineering blog post            | https://claude.com/blog/equipping-agents-for-the-real-world-with-agent-skills             |
| anthropics/skills repo           | https://github.com/anthropics/skills                                                      |
| skill-creator SKILL.md           | https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md              |
| 32-page playbook PDF             | https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf |
| agentskills spec repo            | https://github.com/agentskills/agentskills                                                |
| skills-ref validation library    | https://github.com/agentskills/agentskills/tree/main/skills-ref                           |
| Skills for enterprise            | https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise              |
| Skills API quickstart            | https://platform.claude.com/docs/en/agents-and-tools/agent-skills/quickstart              |
| Skills cookbook                  | https://platform.claude.com/cookbook/skills-notebooks-01-skills-introduction              |

## Open Standard: Agent Skills (agentskills.io)

Claude Code skills follow the Agent Skills open standard. Claude Code extends it with additional fields.

### Required Frontmatter Fields

- **`name`**: 1-64 chars. Lowercase letters, numbers, hyphens only. No leading/trailing/consecutive hyphens. Must match parent directory name.
- **`description`**: 1-1024 chars. Non-empty. Should describe what + when to use.

### Optional Frontmatter Fields (Open Standard)

- **`license`**: License name or bundled file reference.
- **`compatibility`**: Max 500 chars. Environment requirements (products, packages, network).
- **`metadata`**: Arbitrary key-value map (string to string). For custom properties.
- **`allowed-tools`**: Space-delimited list of pre-approved tools. Experimental.

### Directory Structure (Open Standard)

```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
├── assets/           # Optional: templates, resources
└── ...               # Any additional files
```

## Claude Code Extensions to the Standard

Claude Code adds these frontmatter fields beyond the open standard:

| Field                      | Description                                                              |
| -------------------------- | ------------------------------------------------------------------------ |
| `argument-hint`            | Hint for autocomplete, e.g. `[issue-number]`                             |
| `disable-model-invocation` | `true` = only user can invoke via `/name`. Default: `false`.             |
| `user-invocable`           | `false` = hidden from `/` menu, only Claude can invoke. Default: `true`. |
| `model`                    | Model to use when skill is active.                                       |
| `context`                  | Set to `fork` to run in a forked subagent context.                       |
| `agent`                    | Subagent type when `context: fork` is set (e.g., `Explore`, `Plan`).     |
| `hooks`                    | Hooks scoped to this skill's lifecycle.                                  |

### Invocation Control Matrix

| Frontmatter                      | User can invoke | Claude can invoke | Context loading                                     |
| -------------------------------- | --------------- | ----------------- | --------------------------------------------------- |
| (default)                        | Yes             | Yes               | Description always loaded; full skill on invocation |
| `disable-model-invocation: true` | Yes             | No                | Description NOT in context; loads when user invokes |
| `user-invocable: false`          | No              | Yes               | Description always loaded; full skill on invocation |

### String Substitutions

| Variable               | Description                                    |
| ---------------------- | ---------------------------------------------- |
| `$ARGUMENTS`           | All arguments passed when invoking             |
| `$ARGUMENTS[N]` / `$N` | Specific argument by 0-based index             |
| `${CLAUDE_SESSION_ID}` | Current session ID                             |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's SKILL.md file |

### Dynamic Context Injection

The `` !`command` `` syntax runs shell commands before skill content is sent to Claude. Output replaces the placeholder. This is preprocessing, not something Claude executes.

### Subagent Execution

`context: fork` runs the skill in an isolated subagent. The skill content becomes the subagent's prompt. The `agent` field picks the agent type (`Explore`, `Plan`, `general-purpose`, or custom from `.claude/agents/`).

## Skill Discovery and Loading

### Three-Level Progressive Disclosure

1. **Level 1 (Metadata)**: Name + description loaded into system prompt at startup. ~100 tokens per skill.
2. **Level 2 (Instructions)**: Full SKILL.md body loaded when skill is triggered. Target < 5000 tokens / < 500 lines.
3. **Level 3+ (Resources)**: Referenced files loaded as needed. Scripts executed without loading code into context. Effectively unlimited.

### Context Budget

Skill descriptions are loaded into context so Claude knows what is available. Budget scales dynamically at 2% of context window, fallback of 16,000 characters. Check with `/context` for warnings about excluded skills. Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var.

### Where Skills Live

| Location   | Path                                     | Scope                     |
| ---------- | ---------------------------------------- | ------------------------- |
| Enterprise | Managed settings                         | All users in organization |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects         |
| Project    | `.claude/skills/<skill-name>/SKILL.md`   | This project only         |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`  | Where plugin is enabled   |

Priority: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace.

### Auto-Discovery

- Nested `.claude/skills/` directories are discovered when working in subdirectories (monorepo support).
- Skills from `--add-dir` directories are loaded and support live change detection.
- Legacy `.claude/commands/` files still work with same frontmatter support. Skills take precedence when names conflict.

## Agent SDK Integration

Skills in the SDK require:
1. `setting_sources=["user", "project"]` (Python) or `settingSources: ["user", "project"]` (TypeScript) -- the SDK does NOT load filesystem settings by default.
2. `"Skill"` in `allowed_tools`.

Skills must be filesystem artifacts. No programmatic API for registering skills exists.

Note: The `allowed-tools` frontmatter field in SKILL.md does NOT apply in the SDK -- control tools via `allowedTools` in query config.

## The `anthropic-skills:skill-creator` Skill

Located at `github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md`. This is Anthropic's own skill for creating and iterating on skills. Key features:

### Modes
- **Create**: Interview user, capture intent, write SKILL.md, create test cases
- **Eval**: Run test prompts with and without skill, compare results
- **Improve**: Rewrite skill based on evaluation feedback
- **Benchmark**: Run at scale with variance analysis

### Process It Prescribes
1. Decide what skill should do
2. Write draft SKILL.md
3. Create 2-3 realistic test prompts
4. Run claude-with-skill on them + baseline (no skill or old skill)
5. Evaluate qualitatively and quantitatively
6. Rewrite based on feedback
7. Repeat until satisfied
8. Expand test set for larger scale validation

### Key Guidance from skill-creator

**On descriptions**: Claude tends to "undertrigger" skills. Make descriptions "a little bit pushy" -- include not just what the skill does but specific contexts and phrases that should trigger it.

**On writing style**: Explain WHY things are important rather than heavy-handed MUSTs. Use theory of mind. Make skills general, not narrow to specific examples.

**On communication**: Adapt language to user's technical level. Terms like "evaluation" and "benchmark" are borderline OK; "JSON" and "assertion" need context cues before using without explanation.

**On skill anatomy**: Same structure as the open standard -- SKILL.md + optional scripts/, references/, assets/.

## Best Practices (from official docs)

### Conciseness
- Context window is a shared resource. Challenge every piece of information.
- Only add context Claude doesn't already have.
- Keep SKILL.md body under 500 lines.

### Description Writing
- Always write in third person. Description is injected into system prompt.
- Include both what the skill does AND when to use it.
- Include specific keywords for discovery.
- Be specific, not vague.

### Naming Conventions
- Gerund form recommended: `processing-pdfs`, `analyzing-spreadsheets`
- Noun phrases acceptable: `pdf-processing`
- Action-oriented acceptable: `process-pdfs`
- Avoid vague names: `helper`, `utils`, `tools`

### Degrees of Freedom
- **High freedom** (text instructions): when multiple approaches are valid.
- **Medium freedom** (pseudocode/parameterized scripts): when a preferred pattern exists.
- **Low freedom** (specific scripts): when operations are fragile or sequence-critical.

### File Organization
- Keep references one level deep from SKILL.md. Avoid nested reference chains.
- For files > 100 lines, include table of contents.
- Use forward slashes in paths (never backslashes).
- Name files descriptively: `form_validation_rules.md` not `doc2.md`.

### Scripts
- Handle errors explicitly, don't punt to Claude.
- Document magic numbers (no "voodoo constants").
- Make execution intent clear: "Run X" vs "See X for reference".
- Pre-made scripts are more reliable, save tokens, and ensure consistency.

### Feedback Loops
- Use plan-validate-execute pattern for complex tasks.
- Include checklists for multi-step workflows.
- Make validation scripts verbose with specific error messages.

### Testing
- Build evaluations BEFORE extensive documentation.
- Test with all models you plan to use (Haiku, Sonnet, Opus).
- Use iterative development: Claude A creates skill, Claude B tests it.

### Anti-Patterns
- Avoid time-sensitive information.
- Avoid offering too many options (provide a default with escape hatch).
- Avoid deeply nested file references.
- Avoid Windows-style paths.
- Avoid inconsistent terminology.

## Permission and Security

### Restricting Skill Access
- Deny the Skill tool entirely in `/permissions`.
- Allow/deny specific skills: `Skill(name)` exact, `Skill(name *)` prefix.
- `disable-model-invocation: true` removes skill from Claude's context entirely.

### Security Considerations
- Use skills only from trusted sources.
- Audit all bundled files before using third-party skills.
- Skills with external URL fetches are particularly risky.
- Treat installing a skill like installing software.

## Bundled Skills (shipped with Claude Code)

- `/simplify`: Reviews recent changes for code reuse, quality, efficiency. Spawns 3 parallel agents.
- `/batch <instruction>`: Orchestrates large-scale parallel changes via worktrees. 5-30 units.
- `/debug [description]`: Reads session debug log for troubleshooting.
- `/loop [interval] <prompt>`: Runs prompt repeatedly on schedule.
- `/claude-api`: Loads Claude API reference for project's language. Auto-activates on anthropic imports.

## Extended Thinking in Skills

Include the word "ultrathink" anywhere in skill content to enable extended thinking.

## anthropics/skills Repository

- Contains pre-built skills: document skills (docx, pdf, pptx, xlsx), creative/design, development, enterprise
- Template directory for creating new skills
- Spec directory with the open standard
- Plugin config for Claude Code: `/plugin marketplace add anthropics/skills`
- Document skills are source-available (not open source); others are Apache 2.0

## Validation Tool

The `skills-ref` library validates skills: `skills-ref validate ./my-skill`. Checks frontmatter validity and naming conventions. Located at `github.com/agentskills/agentskills/tree/main/skills-ref`.

## Cross-Platform Availability

| Surface     | Custom Skills    | Pre-built Skills | Sharing Scope             |
| ----------- | ---------------- | ---------------- | ------------------------- |
| Claude.ai   | Yes (upload)     | Yes              | Individual user only      |
| Claude API  | Yes (upload)     | Yes              | Workspace-wide            |
| Claude Code | Yes (filesystem) | No               | Personal or project-based |
| Agent SDK   | Yes (filesystem) | No               | Per-application           |

Custom skills do NOT sync across surfaces.

## Gaps & Further Research

1. **32-page playbook PDF**: Fully extracted. See `gap-fill-playbook.md` for novel guidance not in web docs.
2. **Enterprise skills docs**: The `platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise` page was not fetched. May contain admin deployment details.
3. **Skills API endpoints**: The `/v1/skills` API for uploading custom skills to the API surface was referenced but not documented in detail here.
4. **Eval framework details**: The skill-creator references `eval-viewer/generate_review.py` and `references/schemas.md` for eval schemas -- these bundled files were not fetched.
5. **Hooks in skills**: The `hooks` frontmatter field is mentioned but details are in the hooks documentation, not fetched here.
6. **Plugin packaging**: How to package skills as plugins for distribution was referenced but not deeply explored.
7. **`compatibility` field behavior**: The open standard defines it, but how Claude Code actually uses it at runtime (if at all) is unclear.
8. **`metadata` field usage**: No examples of Claude Code consuming custom metadata fields. May be purely for external tooling.
9. **Model field behavior**: The `model` frontmatter field is listed but no documentation on which models are valid values or how it interacts with the session's default model.
10. **Skill description character budget details**: The 2% of context window scaling formula is mentioned but not elaborated on (e.g., how many skills this supports in practice).
