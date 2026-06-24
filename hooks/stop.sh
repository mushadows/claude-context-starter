#!/bin/bash
# Hook Stop — déclenché après chaque réponse Claude
# Pushe my-context uniquement si des fichiers ont été modifiés.
# Ajouter d'autres repos si nécessaire (ex: obsidian-vault).

set -euo pipefail

# Lire stdin (JSON fourni par Claude Code — cwd, session_id, etc.)
# On n'en a pas besoin ici, mais on le consomme pour éviter le pipe cassé.
read -r -d '' _stdin < /dev/stdin 2>/dev/null || true

CONTEXT_DIR="$HOME/dev/my-context"

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
    git -C "$repo" commit -m "${label}: session auto ${date_str}" --quiet 2>/dev/null || true
    git -C "$repo" push --quiet 2>/dev/null || \
        echo "[stop.sh] Erreur push $label — vérifier la connexion" >&2
}

push_if_dirty "$CONTEXT_DIR" "context"

# Décommenter pour pusher d'autres repos automatiquement :
# VAULT_DIR="$HOME/dev/obsidian-vault"
# push_if_dirty "$VAULT_DIR" "vault backup"
