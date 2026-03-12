---
name: convention-ledger
description: Use when creating, naming, renaming, or organizing any file, directory, branch, variable, module, or project structure. Use when noticing repeated patterns in naming, paths, or organization. Use when the user corrects a name or structure. Always check CONVENTIONS.md before creating anything new. Triggers on words like name, rename, create, organize, structure, convention, pattern.
---

# Convention Ledger

## Overview

You are a convention detector and enforcer. Every time you name, create, or organize something, you check the convention ledger first. Every time you notice a repeating pattern, you propose recording it. Conventions persist across sessions in dedicated files.

**Iron Law**: Never name, create, or organize without checking the convention ledger first.

## The Ledger

Two files, checked in order (project-specific overrides global):

1. **`CONVENTIONS.md`** in the project root — project-specific conventions
2. **`~/.claude/CONVENTIONS.md`** — global conventions (all projects)

If neither file exists yet, that's fine — you'll create one when the first convention is confirmed.

### Ledger Format

```markdown
## Naming

### Skill repos use plural names
- Pattern: `claude-skills-*` not `claude-skill-*`
- Examples: claude-skills-code, claude-skills-thinking

### Branches use kebab-case with verb prefix
- Pattern: `<verb>-<subject>`
- Examples: fix-auth-redirect, add-search-api

## Organization

### Skills are grouped by topical containers
- Pattern: Related skills go in named subdirectories
- Examples: thinking/brainstorming, code/swift-patterns

## Process

### Commit after plan execution
- Pattern: When executing an approved plan, commit when done without asking
- Source: CLAUDE.md
```

Categories: **Naming**, **Organization**, **Process**. Each convention has a descriptive heading, a pattern line, examples, and optionally source/scope.

## When You Act

### Before creating anything new

1. Read both CONVENTIONS.md files (project, then global)
2. Check if any convention applies to what you're about to create
3. If yes — apply it silently
4. If the situation *could* be an instance of a pattern but you're not sure — ask: *"Is this another example of the [convention] pattern, or is this different?"*

### When you notice a repeating pattern

You see 3+ things following the same scheme (file names, directory structure, naming format, workflow choice). Propose it:

> *"I notice [X, Y, Z] all follow the pattern [P]. Should I record this as a convention?"*

If confirmed, add it to the appropriate CONVENTIONS.md under the right category. Create the file if it doesn't exist. Ask whether it's project-specific or global.

### When the user corrects you

A correction to a name, path, or structure is a signal. Ask:

> *"Should I record this as a convention so I get it right next time?"*

### When a convention seems outdated

If the user is consistently doing something differently from a recorded convention, don't silently override. Ask:

> *"It looks like the convention [X] may have changed — should I update or remove it?"*

## What to Track

| Category     | Examples                                                                   |
| ------------ | -------------------------------------------------------------------------- |
| Naming       | File names, directory names, branch names, commit message formats, symbols |
| Organization | Directory structure, project layout, where files of each type go           |
| Process      | Workflow patterns, tool choices, recurring task approaches                 |

## Red Flags

These thoughts mean STOP — you're about to skip the ledger:

| Thought                                    | Reality                                                                      |
| ------------------------------------------ | ---------------------------------------------------------------------------- |
| "This is a one-off, no convention applies" | Check the ledger first. One-offs that match a convention aren't one-offs.    |
| "I know what to name this"                 | Your instinct might conflict with a recorded convention. Check.              |
| "The convention doesn't quite fit here"    | Ask the user — don't silently deviate.                                       |
| "I'll record this convention later"        | Record it now or you'll forget across sessions.                              |
| "This project is different"                | Check project-level conventions, then global. Different doesn't mean exempt. |

## Relationship to Other Systems

- **CLAUDE.md**: Don't duplicate explicit CLAUDE.md instructions into the ledger. The ledger is for *discovered* patterns. If a CLAUDE.md rule implies a convention, reference it with `Source: CLAUDE.md` rather than restating it.
- **Memory**: Memory is for user context, project state, and feedback. Conventions are structural patterns. If a memory file is really a convention (like `feedback_repo_naming.md`), it belongs in the ledger instead.
- **Other skills**: This is a cross-cutting discipline. It runs alongside whatever else you're doing — brainstorming, planning, coding, debugging. Always check conventions regardless of which other skill is active.

## Seeding a New Project

When working in a project for the first time and no CONVENTIONS.md exists, do a quick scan:

1. Look at file and directory naming patterns
2. Check git branch naming history
3. Note any structural regularities

If you spot clear conventions, propose them as a batch: *"I notice several conventions in this project: [list]. Should I record these?"*

Don't be overly aggressive — only propose patterns that are clearly intentional, not coincidental.
