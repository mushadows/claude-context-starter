#!/usr/bin/env bash
# Hook PostCompact — rappel injecté après la compaction du contexte.

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

# Pas de guillemet ni de backslash dans MSG (JSON écrit à la main) ; "\\n" = saut de ligne JSON
MSG="Contexte compacté. Avant de continuer :\\n1. Mettre à jour etat/[projet].md dans ${CONTEXT_DIR} (sections En cours + Dernière session) pour le projet courant\\n2. Noter dans le module contexts/ctx-[projet].md les décisions et contraintes de cette session si elles manquent\\nPuis reprendre le travail normalement."
printf '{"systemMessage":"%s"}' "$MSG"
