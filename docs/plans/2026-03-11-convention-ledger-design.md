# Convention Ledger Skill Design

## Overview

An always-on discipline skill that makes Claude a pattern detector and convention enforcer. It watches everything Claude does — naming files, creating directories, choosing paths, structuring projects, following workflows — and builds up a ledger of recognized conventions that persist across sessions.

## Ledger Files

Two levels:

- **`~/.claude/CONVENTIONS.md`** — global conventions (apply to all projects)
- **`CONVENTIONS.md`** in project root — project-specific conventions

### Format

```markdown
## Naming

### Skill repos use plural names
- Pattern: `claude-skills-*` not `claude-skill-*`
- Examples: claude-skills-code, claude-skills-thinking
- Scope: all skill repos

### Branches use kebab-case with verb prefix
- Pattern: `<verb>-<subject>` (e.g., fix-auth-redirect, add-search-api)
- Examples: fix-auth-redirect, add-search-api, refactor-model-loader

## Organization

### Skills are grouped by topical containers
- Pattern: Related skills go in named subdirectories (thinking/, code/, reading/)
- Examples: thinking/brainstorming, code/swift-patterns

## Process

### Commit after plan execution
- Pattern: When executing an approved plan, commit when done without asking
- Source: CLAUDE.md instruction
```

Each convention has: a short name (heading), pattern description, examples, and optionally source/scope.

## Detection Logic

### Passive Detection

While working, Claude notices repeating patterns:

- 3+ files/directories following the same naming scheme
- Consistent structural choices across the project
- Repeated process decisions (from CLAUDE.md, memory, or observed behavior)

When a pattern is noticed, Claude asks: *"I notice X follows the pattern Y — should I record this as a convention?"*

### Active Detection

When Claude is about to create/name/organize something new, it:

1. Checks both CONVENTIONS.md files (global + project)
2. If a matching convention exists, applies it
3. If no convention exists but the situation feels like it *could* be an instance of a pattern, asks: *"Is this another example of the [convention name] pattern, or is this different?"*

## Discipline Layer

### Red Flags

| Thought                                    | Reality                                                                      |
| ------------------------------------------ | ---------------------------------------------------------------------------- |
| "This is a one-off, no convention applies" | Check the ledger first. One-offs that match a convention aren't one-offs.    |
| "I know what to name this"                 | Your instinct might conflict with a recorded convention. Check.              |
| "The convention doesn't quite fit here"    | Ask the user — don't silently deviate.                                       |
| "I'll record this convention later"        | Record it now or you'll forget across sessions.                              |
| "This project is different"                | Check project-level conventions, then global. Different doesn't mean exempt. |

**Iron Law**: Never name, create, or organize without checking the convention ledger first.

## Lifecycle

- **Recording**: After user confirms a pattern, Claude adds it to the appropriate CONVENTIONS.md (global or project) under the right category heading
- **Updating**: When a convention changes (user corrects a name, adopts a new pattern), Claude proposes updating the existing entry rather than adding a duplicate
- **Retiring**: If Claude notices a convention being consistently violated, it asks: *"It looks like the convention [X] may have changed — should I update or remove it?"*
- **Seeding**: On first use in a project, Claude can do a quick scan of existing files/directories to propose initial conventions from what's already there

## Interaction with Existing Systems

- **CLAUDE.md**: Conventions already explicit in CLAUDE.md don't need duplication. The ledger is for *discovered* patterns, not restated rules.
- **Memory**: Memory handles user preferences, project context, and feedback. Conventions are structural patterns. Existing convention-like memories (e.g., `feedback_repo_naming.md`) would naturally become convention entries instead.
- **Other skills**: Cross-cutting discipline that applies alongside whatever else Claude is doing.

## Scope

Tracks all repeating patterns across:

- **Naming**: file names, directory names, branch names, variable naming, commit messages, skill names
- **Organization**: directory structure, project layout, module/component grouping, where files go
- **Process**: workflow patterns, tool choices, preferred approaches to recurring tasks
