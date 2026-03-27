#!/usr/bin/env bash
set -euo pipefail

# Remove skill symlinks that point into this repo from ~/.claude/skills (global)
# or .claude/skills (local). Only removes symlinks targeting this repo's skills
# or brain/skills trees — leaves everything else untouched.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCOPE="global"

usage() {
    echo "Usage: $(basename "$0") [--global | --local]"
    echo "  --global  Uninstall from ~/.claude/skills (default)"
    echo "  --local   Uninstall from \$PWD/.claude/skills"
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

[[ -d "$TARGET" ]] || { echo "Nothing to uninstall — $TARGET does not exist."; exit 0; }

removed=0
skipped=0

for link in "$TARGET"/*; do
    [[ -L "$link" ]] || continue

    dest="$(readlink "$link")"

    # Only remove symlinks that point into this repo's skill trees.
    if [[ "$dest" == "$REPO_ROOT/skills/"* || "$dest" == "$REPO_ROOT/brain/skills/"* ]]; then
        rm "$link"
        echo "  removed $(basename "$link")"
        ((removed++)) || true
    else
        ((skipped++)) || true
    fi
done

echo ""
echo "Removed $removed, skipped $skipped (not from this repo)."
