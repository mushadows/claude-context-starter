#!/usr/bin/env bash
# Hook Stop — après chaque réponse de Claude.
# Opt-in : ne fait RIEN sauf si $CONTEXT_DIR/.autosync existe.
#   .autosync vide        -> commit local si des fichiers suivis ont changé
#   .autosync = "push"    -> commit + push
# Attention : si le repo a pour origin le repo template public, ne pas activer "push".

set -euo pipefail
read -r -d '' _stdin 2>/dev/null || true

# Résout le vrai chemin du hook (symlink ~/.claude/hooks/x.sh -> repo) pour retrouver lib/paths.sh.
# Sur Windows le hook est une copie : on se rabat sur ~/.claude/context-dir (écrit par install.sh).
_src="${BASH_SOURCE[0]}"
_real=$(readlink -f "$_src" 2>/dev/null) || _real=""
if [ -z "$_real" ]; then
    while [ -L "$_src" ]; do
        _l=$(readlink "$_src")
        case "$_l" in /*) _src="$_l" ;; *) _src="$(dirname "$_src")/$_l" ;; esac
    done
    _real="$_src"
fi
HOOK_DIR=$(cd "$(dirname "$_real")" && pwd)
_marker=$(cat "$HOME/.claude/context-dir" 2>/dev/null || true)
for _p in "$HOOK_DIR/../lib/paths.sh" "${_marker:+$_marker/lib/paths.sh}" "$HOME/dev/claude-context/lib/paths.sh"; do
    if [ -n "$_p" ] && [ -f "$_p" ]; then
        # shellcheck disable=SC1090
        source "$_p"
        break
    fi
done
CONTEXT_DIR="${CONTEXT_DIR:-$HOME/dev/claude-context}"

AUTOSYNC="$CONTEXT_DIR/.autosync"
[ -f "$AUTOSYNC" ] || exit 0
[ -d "$CONTEXT_DIR/.git" ] || exit 0
[ -n "$(git -C "$CONTEXT_DIR" status --porcelain 2>/dev/null)" ] || exit 0

git -C "$CONTEXT_DIR" add -A 2>/dev/null || true
git -C "$CONTEXT_DIR" commit --quiet -m "context: session auto $(date +%Y-%m-%d)" 2>/dev/null || true

if grep -qx "push" "$AUTOSYNC" 2>/dev/null; then
    git -C "$CONTEXT_DIR" push --quiet 2>/dev/null \
        || echo "[stop.sh] push impossible — vérifier la connexion" >&2
fi
exit 0
