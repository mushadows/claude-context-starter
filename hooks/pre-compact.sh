#!/usr/bin/env bash
# Hook PreCompact — sauvegarde locale de la fin du transcript avant compaction,
# pour ne pas perdre les décisions prises en cours de session.
# Fichiers dans ~/.claude/session-state/ (purgés après 30 jours, jamais versionnés).

set -euo pipefail

umask 077  # le transcript peut contenir des secrets
STATE_DIR="$HOME/.claude/session-state"
mkdir -p "$STATE_DIR"

# JSON stdin : {"session_id":"...","transcript_path":"...","cwd":"..."}
stdin_data=$(cat)

if command -v jq >/dev/null 2>&1; then
    session_id=$(printf '%s' "$stdin_data" | jq -r '.session_id // "unknown"')
    transcript_path=$(printf '%s' "$stdin_data" | jq -r '.transcript_path // ""')
else
    session_id=$(printf '%s' "$stdin_data" | sed -n 's/.*"session_id" *: *"\([^"]*\)".*/\1/p' | head -1)
    transcript_path=$(printf '%s' "$stdin_data" | sed -n 's/.*"transcript_path" *: *"\([^"]*\)".*/\1/p' | head -1)
fi
# Nom de fichier sûr (la valeur vient de stdin)
session_id=$(printf '%s' "${session_id:-unknown}" | tr -cd 'A-Za-z0-9_-')
session_id="${session_id:-unknown}"

date_str=$(date +%Y-%m-%d-%H%M)
output_file="$STATE_DIR/${date_str}-${session_id}.md"

{
    echo "# Session compactée — ${date_str}"
    echo "session_id: ${session_id}"
    echo ""
    if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
        echo "## Transcript (200 dernières lignes)"
        tail -n 200 "$transcript_path"
    else
        echo "(transcript non disponible)"
    fi
} > "$output_file"

find "$STATE_DIR" -name "*.md" -mtime +30 -delete 2>/dev/null || true
