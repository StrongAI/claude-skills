# Anger Log Skill Design

## Overview

A passive frustration detection skill that logs incidents to a persistent ledger. The negative counterpart in a trio with idiocy-check and conventions:

```
anger-log           →  idiocy-check        →  conventions
"this made me angry"   "don't do this"        "do this instead"
(raw negative data)    (positive avoidance)   (positive patterns)
```

Anger is the raw input. Idiocy and conventions are the processed outputs.

## Location

`thinking/anger/SKILL.md` — alongside `thinking/idiocy/` and `thinking/conventions/`.

## Trigger: Frustration Detection

Runs passively during all conversations. Watches for signals:

**Strong signals** (propose logging immediately):
- Explicit anger/frustration ("that's wrong", "no!", "I already told you", profanity)
- Repeated corrections of the same mistake within a session
- User undoing Claude's work ("revert that", "put it back")
- User invoking problem-fixing language after Claude's action ("you broke", "that ruined")

**Not signals** (do not propose):
- Normal corrections ("actually, use X instead")
- Disagreements without frustration
- Brief replies (brevity alone isn't anger)

## The Ledger

Two files, checked in order (project-specific then global):

1. **`ANGER.md`** in the project root — project-specific anger
2. **`~/.claude/ANGER.md`** — global anger (Claude behavior patterns)

### Entry Format

```markdown
## YYYY-MM-DD: Short description of what happened

**What I did:** [The action that caused anger]
**Why it was wrong:** [The user's perspective on why this was bad]
**Category:** [naming | scope-creep | ignoring-instructions | breaking-things | wrong-tool | other]
**Graduated:** [not yet | idiocy-check | conventions | both]
```

## Workflow

1. Detect frustration signal during normal work
2. Propose: "It seems like [X] frustrated you. Should I log this?"
3. If yes: Write entry to appropriate ANGER.md (ask project vs global if unclear)
4. Propose graduation: "Should this become an idiocy-check example, a convention, or both?"
5. If graduation accepted: Update the target skill and mark entry as graduated

## What It Does NOT Do

- Does not block work (unlike idiocy-check's gate)
- Does not lecture the user about anger
- Does not log without asking
- Does not auto-graduate — always proposes, user decides

## Relationship to Other Skills

- **idiocy-check**: Anger entries graduate into idiocy-check examples (the "Examples of Idiot Moves" table)
- **conventions**: Anger entries graduate into conventions when the fix is a repeatable pattern
- **Both**: Some anger entries produce both an idiocy example AND a convention

## Categories

| Category               | Meaning                                              |
| ---------------------- | ---------------------------------------------------- |
| naming                 | Named something wrong, ignored naming conventions    |
| scope-creep            | Did more than asked, added unrequested features      |
| ignoring-instructions  | Didn't follow CLAUDE.md, memories, or direct orders  |
| breaking-things        | Broke working code, removed features, lost work      |
| wrong-tool             | Used inferior tool when better one was available      |
| other                  | Anything not covered above                           |
