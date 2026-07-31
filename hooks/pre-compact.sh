#!/bin/bash
# Hook PreCompact — sauvegarde le transcript avant compaction

set -euo pipefail

# Charger CLAUDIA_STATE via lib/paths.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../lib/paths.sh" ]; then
    source "$SCRIPT_DIR/../lib/paths.sh"
else
    CLAUDIA_STATE="${CLAUDIA_STATE:-$HOME/.claudia}"
fi

STATE_DIR="$CLAUDIA_STATE/session-state"
mkdir -p "$STATE_DIR"

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
