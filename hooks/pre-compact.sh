#!/bin/bash
# Hook PreCompact — déclenché avant la compaction automatique du contexte.
# NOTE : "PreCompact" n'est pas un hook natif confirmé dans Claude Code (certifiés : Stop,
# PreToolUse, PostToolUse, Notification). Ce script est prêt — il s'activera automatiquement
# si/quand Claude Code implémente cet événement officiellement.
#
# Objectif : sauvegarder le transcript de session avant que la compaction ne l'écrase,
# pour ne pas perdre les décisions architecturales prises en cours de session.

set -euo pipefail

STATE_DIR="$HOME/.claude/session-state"
mkdir -p "$STATE_DIR"

# Lire le JSON stdin (format attendu : {"session_id":"...","transcript_path":"...","cwd":"..."})
stdin_data=$(cat)

session_id=$(echo "$stdin_data" | grep -o '"session_id":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "unknown")
transcript_path=$(echo "$stdin_data" | grep -o '"transcript_path":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "")

date_str=$(date +%Y-%m-%d-%H%M)
output_file="$STATE_DIR/${date_str}-${session_id}.md"

{
    echo "# Session compactée — ${date_str}"
    echo "session_id: ${session_id}"
    echo ""
    if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
        echo "## Transcript (extrait — 200 dernières lignes)"
        tail -200 "$transcript_path"
    else
        echo "(transcript non disponible)"
    fi
} > "$output_file"

# Nettoyer les sauvegardes de plus de 30 jours
find "$STATE_DIR" -name "*.md" -mtime +30 -delete 2>/dev/null || true
