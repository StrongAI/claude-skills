# Gap-Fill: Anthropic Skills Playbook PDF

Source: "The Complete Guide to Building Skills for Claude" (32-page PDF)
URL: https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf
Research date: 2026-03-11

This document captures guidance from the playbook PDF that is NOT already
covered in the web documentation or official-docs.md. Organized by topic.

---

## 1. Quantitative Benchmarks and Limits

### SKILL.md Word Count

The PDF explicitly states: keep SKILL.md under **5,000 words**. This is the
first concrete word-count recommendation from Anthropic (the web docs only
say "under 500 lines").

### Simultaneous Skills Cap

Evaluate if you have more than **20-50 skills** enabled simultaneously. At
that range, performance degrades. Consider "skill packs" to group related
capabilities and selective enablement.

### Description Length

Under **1024 characters**. Must include BOTH what the skill does and when to
use it. The PDF gives a formula: `[What it does] + [When to use it] + [Key capabilities]`.

### Compatibility Field

1-500 characters. Environment requirements (intended product, required
system packages, network access needs).

### Build Time Estimate

Expect about **15-30 minutes** to build and test a first working skill
using the skill-creator.

---

## 2. Success Criteria Framework

The PDF defines concrete metrics. The web docs mention testing but never
specify what to measure.

### Quantitative Metrics

| Metric                             | Target       | How to Measure                                                                |
| ---------------------------------- | ------------ | ----------------------------------------------------------------------------- |
| Skill triggers on relevant queries |          90% | Run 10-20 test queries. Track auto-load vs explicit invocation.               |
| Completes workflow in X tool calls | Compare w/wo | Same task with and without skill. Count tool calls and total tokens consumed. |
| Failed API calls per workflow      |            0 | Monitor MCP server logs during test runs. Track retry rates and error codes.  |

### Qualitative Metrics

| Metric                             | How to Assess                                                          |
| ---------------------------------- | ---------------------------------------------------------------------- |
| No user prompting needed           | During testing, note how often you redirect or clarify. Ask beta.      |
| Workflows complete without fixes   | Run same request 3-5 times. Compare structural consistency.            |
| Consistent results across sessions | Can a new user accomplish the task on first try with minimal guidance? |

The PDF explicitly acknowledges these are aspirational, not precise --
there is "an element of vibes-based assessment."

---

## 3. Three Use Case Categories

The PDF identifies three common skill categories. The web docs list
examples but never categorize them this way.

1. **Document and Asset Creation**: Consistent output (docs, presentations,
   apps, code). Techniques: embedded style guides, template structures,
   quality checklists, uses built-in capabilities only.
2. **Workflow Automation**: Multi-step processes across multiple MCP
   servers. Techniques: validation gates, templates, iterative refinement.
3. **MCP Enhancement**: Workflow guidance on top of MCP tool access.
   Techniques: sequenced MCP calls, embedded domain expertise, error
   handling for common MCP issues.

---

## 4. Five Architecture Patterns

The PDF documents five patterns from early adopters and internal teams.
The web docs mention patterns but not with this taxonomy or level of detail.

1. **Sequential Workflow Orchestration**: Multi-step processes in specific
   order. Each step names MCP tool, parameters, wait conditions. Includes
   rollback instructions for failures.
2. **Multi-MCP Coordination**: Workflows spanning services (e.g., Figma ->
   Drive -> Linear -> Slack). Clear phase separation, data passing between
   MCPs, validation before next phase.
3. **Iterative Refinement**: Quality improves with loops. Initial draft,
   quality check via validation script, refinement loop, finalization.
   Key: knowing when to stop iterating.
4. **Context-Aware Tool Selection**: Same outcome, different tools based on
   context (e.g., route files to different storage MCPs by type/size).
   Explain to user why a particular tool was chosen.
5. **Domain-Specific Intelligence**: Specialized knowledge beyond tool
   access (e.g., compliance checks before payment processing). Domain
   expertise embedded in skill logic, not just tool orchestration.

---

## 5. Problem-First vs Tool-First Framing

A design decision framework not found in the web docs.

- **Problem-first**: User describes outcomes ("I need to set up a project
  workspace"). The skill orchestrates the right MCP calls in the right
  sequence. User doesn't need to know which tools exist.
- **Tool-first**: User already has tools connected ("I have Notion MCP
  connected"). The skill teaches optimal workflows and best practices.
  User has access; the skill provides expertise.

Most skills lean one direction. Knowing which framing fits helps choose the
right architecture pattern.

---

## 6. Testing Methodology

### Three-Area Test Framework

The PDF prescribes testing in three areas, with specific test case designs:

1. **Triggering tests**: Should trigger on obvious tasks, paraphrased
   requests, and NOT trigger on unrelated topics. Include both positive
   and negative examples.

2. **Functional tests**: Valid outputs generated, API calls succeed, error
   handling works, edge cases covered. Use Given/When/Then format.

3. **Performance comparison**: Baseline comparison showing with-skill vs
   without-skill metrics (messages needed, failed API calls, tokens consumed).

### Iterate on a Single Task First

The most effective skill creators iterate on a single challenging task
until Claude succeeds, then extract the winning approach into a skill.
This leverages in-context learning and provides faster signal than broad
testing. Expand to multiple test cases only after the foundation works.

### Debugging Trigger Issues

Ask Claude directly: "When would you use the [skill name] skill?" Claude
will quote the description back. Adjust based on what's missing from the
description.

---

## 7. Instruction Writing -- Advanced Techniques

### Combating Model "Laziness"

Add explicit encouragement in a Performance Notes section:
"Take your time to do this thoroughly. Quality is more important than
speed. Do not skip validation steps."

The PDF notes: adding this to the user prompt is more effective than
putting it in SKILL.md.

### Programmatic Validation Over Language Instructions

For critical validations, bundle a script that performs the checks
programmatically rather than relying on language instructions. Code is
deterministic; language interpretation is not.

### Instruction Hierarchy in SKILL.md

When instructions are not followed, common causes are:
- Instructions too verbose (use bullet points, not prose)
- Critical instructions buried (put them at the top, use ## Important headers)
- Ambiguous language ("validate things properly" vs specific checklist)

---

## 8. Distribution Surface Guidance

The PDF provides a decision matrix for API vs interactive use: use
Claude.ai/Claude Code for end-user interaction, manual testing, and ad-hoc
workflows. Use the API for programmatic applications, production
deployments at scale, and automated pipelines/agent systems.

Organization-level skills (shipped December 2025) allow workspace-wide
deployment with automatic updates and centralized management.

---

## 9. Positioning and Marketing Skills

The PDF includes guidance on describing skills to potential users -- not
found in web docs.

- Focus on **outcomes, not features**. Describe what users accomplish, not
  what the YAML contains.
- Highlight the **MCP + skills story** together: "Our MCP server gives
  Claude access. Our skills teach Claude your workflow. Together, they
  enable AI-powered [domain]."
- For GitHub repos: clear README with installation instructions, example
  usage with screenshots, link to MCP documentation explaining the
  combined value.

---

## 10. Additional Frontmatter Fields

The PDF's Reference B reveals metadata subfields not in the web docs:
`mcp-server`, `category`, `tags` (list), `documentation` (URL), `support`
(email). These are all under the `metadata:` key and appear to be for
external tooling/discovery rather than consumed by Claude at runtime.

---

## Gaps (Still Not Addressed)

1. **No quantitative effectiveness data**: Metrics to track are defined but
   no aggregate results. The 12K vs 6K tokens example (p.16) is illustrative.
2. **No enterprise deployment patterns**: Org-level skills get three bullet
   points. No rollout strategy, governance, or versioning guidance.
3. **No model-specific guidance**: Nothing on Haiku/Sonnet/Opus behavioral
   differences despite web docs recommending cross-model testing.
4. **No skill-to-skill interaction patterns**: Composability mentioned but
   no patterns for skills that reference or depend on other skills.
5. **No token budget analysis**: How many skills can coexist before budget
   pressure degrades triggering accuracy is never quantified.
6. **No `context: fork`, subagent, or hooks patterns**: The PDF predates
   or ignores these Claude Code-specific execution models.
7. **No long-form SKILL.md examples**: All "real examples" are links to
   external repos. No complete SKILL.md over a few lines in the PDF itself.
