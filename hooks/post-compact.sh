#!/usr/bin/env bash
# Hook PostCompact — injecte un rappel après compaction

set -euo pipefail
read -r -d '' _stdin 2>/dev/null || true

MSG="Ma mémoire de la conversation vient d'être condensée. Avant de continuer, je vérifie si j'ai des choses importantes à noter dans mon profil ou ma mémoire. On reprend juste après."

printf '{"systemMessage":"%s"}' "$MSG"
