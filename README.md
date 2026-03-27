# Claude Code Skills

A collection of skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that extend its capabilities across programming, research, writing, tooling, and workflow automation.

## Installation

### Clone with all submodules

```bash
git clone --recursive git@github.com:StrongAI/claude-skills.git
```

If you already cloned without `--recursive`:

```bash
git submodule update --init --recursive
```

### Install symlinks

The install script creates symlinks in `~/.claude/skills/` (global) or `.claude/skills/` (local) so Claude Code can discover the skills:

```bash
# Global install (default) — available in all projects
./install_skills.sh

# Local install — available only in the current project
./install_skills.sh --local
```

The script is idempotent. Re-run it after pulling new skills or checking out new submodules.

### Uninstall

```bash
# Remove global symlinks
./uninstall_skills.sh

# Remove local symlinks
./uninstall_skills.sh --local
```

Only removes symlinks that point into this repo — leaves other skills untouched.

## Skills

### Programming

| Skill                   | Path                                   | Description                                                             |
| ----------------------- | -------------------------------------- | ----------------------------------------------------------------------- |
| programming             | `programming/`                         | Top-level router for all programming tasks                              |
| auditing                | `programming/auditing/`                | Audit an implementation against its plan                                |
| concurrency             | `programming/concurrency/`             | Concurrent code on Apple platforms (GCD, actors, async/await, Sendable) |
| cpp                     | `programming/cpp/`                     | C++ with Core Guidelines, smart pointers, GoogleTest/CMake              |
| decompiling             | `programming/decompiling/`             | Reverse-engineer binaries, shared libraries, GPU shaders                |
| dispatch_analyzers      | `programming/dispatch_analyzers/`      | Multi-agent codebase analysis for rewrites                              |
| dispatch_auditors       | `programming/dispatch_auditors/`       | Multi-agent code review and bug finding                                 |
| dispatch_optimizers     | `programming/dispatch_optimizers/`     | Multi-agent performance optimization                                    |
| dispatch_test_designers | `programming/dispatch_test_designers/` | Multi-agent systematic test generation                                  |
| dispatch_programmers    | `programming/dispatch_programmers/`    | Dispatch subagents to execute plan tasks                                |
| implementing            | `programming/implementing/`            | TDD implementation loop (write tests, implement, validate, audit)       |
| postgres                | `programming/postgres/`                | PostgreSQL queries, schemas, indexes, RLS                               |
| solving_bugs            | `programming/solving_bugs/`            | Debugger-first bug investigation                                        |
| swift                   | `programming/swift/`                   | Swift code, protocols, error handling, Swift 6 concurrency              |
| swift_tdd               | `programming/swift_tdd/`               | Swift-specific TDD with Swift Testing framework                         |
| swift_ui                | `programming/swift_ui/`                | SwiftUI views, state management, navigation, performance                |
| typescript              | `programming/typescript/`              | TypeScript, React, Next.js with Zod validation                          |
| wrapping_up             | `programming/wrapping_up/`             | Pre-commit verification before claiming work is done                    |

### Reading & Research

| Skill              | Path                          | Description                                                         |
| ------------------ | ----------------------------- | ------------------------------------------------------------------- |
| analyze_text       | `reading/analyze_text/`       | Deep multi-pass reading of papers, specs, legal docs                |
| forums             | `reading/forums/`             | Scrape and index forum discussions into markdown with vector search |
| research           | `reading/research/`           | Multi-phase deep research on technical domains                      |
| session_annotation | `reading/session_annotation/` | Structured topic extraction from conversation sessions              |

### Writing

| Skill          | Path                      | Description                                       |
| -------------- | ------------------------- | ------------------------------------------------- |
| conceptual     | `writing/conceptual/`     | Transform technical docs into non-technical prose |
| literary_style | `writing/literary_style/` | Style transformation, analysis, and blending      |
| mcp            | `writing/mcp/`            | Build MCP servers with Python FastMCP SDK         |
| plans          | `writing/plans/`          | Plan multi-step tasks before touching code        |
| pull_request   | `writing/pull_request/`   | Create and update PR descriptions                 |
| skills         | `writing/skills/`         | Create and improve Claude Code skills             |

### Tools

| Skill           | Path                         | Description                                       |
| --------------- | ---------------------------- | ------------------------------------------------- |
| ocr_openai      | `tools/ocr_openai/`          | OCR screenshot images to markdown with LaTeX math |
| pdf_to_markdown | `tools/pdf/pdf_to_markdown/` | Convert PDFs to markdown for reading and indexing |

### Workflow

| Skill       | Path                    | Description                                           |
| ----------- | ----------------------- | ----------------------------------------------------- |
| conventions | `workflow/conventions/` | Detect and enforce naming/organization conventions    |
| setup       | `workflow/setup/`       | Bootstrap Claude Code (MCPs, skills, hooks, settings) |
| worktree    | `workflow/worktree/`    | Git worktree creation, isolation, and merge-back      |

### Other

| Skill    | Path                   | Description                                 |
| -------- | ---------------------- | ------------------------------------------- |
| images   | `claude/api/images/`   | Image token optimization for the Claude API |
| thinking | `thinking/`            | Structured thinking before creative work    |
| path     | `repair/session/path/` | Recover orphaned Claude Code sessions       |

## Structure

Skills are organized as nested git submodules. Each category (`programming/`, `reading/`, etc.) is its own repo, and each skill within is a submodule of its category. This allows checking out only the skills you need:

```bash
# Check out just the programming skills
git submodule update --init programming
cd programming && git submodule update --init --recursive
```

## License

MIT
