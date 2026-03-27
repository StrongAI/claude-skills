#!/usr/bin/env bash
set -euo pipefail

# Install skill symlinks into ~/.claude/skills (global) or .claude/skills (local).
# Finds every SKILL.md under this repo and creates a symlink named after
# the containing directory. Missing submodules are silently skipped.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCOPE="global"

usage() {
    echo "Usage: $(basename "$0") [--global | --local]"
    echo "  --global  Install to ~/.claude/skills (default)"
    echo "  --local   Install to \$PWD/.claude/skills"
    exit 1
}

for arg in "$@"; do
    case "$arg" in
        --global) SCOPE="global" ;;
        --local)  SCOPE="local" ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $arg"; usage ;;
    esac
done

if [[ "$SCOPE" == "global" ]]; then
    TARGET="$HOME/.claude/skills"
else
    TARGET="$PWD/.claude/skills"
fi

mkdir -p "$TARGET"

# Directories to scan for SKILL.md files.
SCAN_DIRS=("$REPO_ROOT/skills" "$REPO_ROOT/brain/skills")

installed=0
skipped=0

for scan_dir in "${SCAN_DIRS[@]}"; do
    [[ -d "$scan_dir" ]] || continue

    while IFS= read -r skill_md; do
        skill_dir="$(dirname "$skill_md")"
        skill_name="$(basename "$skill_dir")"
        link="$TARGET/$skill_name"

        # Already correct — nothing to do.
        if [[ -L "$link" && "$(readlink "$link")" == "$skill_dir" ]]; then
            ((skipped++)) || true
            continue
        fi

        # Remove stale symlink or plain directory we're replacing.
        if [[ -L "$link" ]]; then
            rm "$link"
        elif [[ -d "$link" ]]; then
            rm -rf "$link"
        fi

        ln -s "$skill_dir" "$link"
        echo "  $skill_name -> $skill_dir"
        ((installed++)) || true

    done < <(find "$scan_dir" -name SKILL.md -not -path '*/.*' 2>/dev/null | sort)
done

echo ""
echo "Installed $installed, skipped $skipped (already linked)."
