#!/usr/bin/env bash
# Hook Stop — déclenché après chaque réponse de Claude
# Par défaut : ne fait rien.
# Si l'utilisateur a activé la sauvegarde en ligne (git dans ~/Documents/Claudia),
# pousse automatiquement les modifications.

set -euo pipefail
read -r -d '' _stdin 2>/dev/null || true

# Charger CLAUDIA_HOME
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../lib/paths.sh" ]; then
    source "$SCRIPT_DIR/../lib/paths.sh"
else
    CLAUDIA_HOME="${CLAUDIA_HOME:-$HOME/Documents/Claudia}"
fi

push_if_dirty() {
    local repo="$1"
    local label="$2"

    [ -d "$repo/.git" ] || return 0

    local status
    status=$(git -C "$repo" status --porcelain 2>/dev/null)
    [ -z "$status" ] && return 0

    local date_str
    date_str=$(date +%Y-%m-%d)

    git -C "$repo" add -A 2>/dev/null
    git -C "$repo" commit -m "${label}: sauvegarde auto ${date_str}" --quiet 2>/dev/null || true
    git -C "$repo" push --quiet 2>/dev/null || true
}

# Sauvegarde auto : uniquement si l'user l'a activée explicitement
# (crée $CLAUDIA_HOME/.autosync pour activer)
if [ -f "$CLAUDIA_HOME/.autosync" ]; then
    push_if_dirty "$CLAUDIA_HOME" "claudia"
fi

exit 0
