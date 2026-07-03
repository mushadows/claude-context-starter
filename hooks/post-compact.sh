#!/usr/bin/env bash
# Hook PostCompact — injecte un rappel après compaction auto ou manuelle

set -euo pipefail
read -r -d '' _stdin < /dev/stdin 2>/dev/null || true

CWD=$(pwd)
PROJECT=""
case "$CWD" in
    # Ajouter ici les projets actifs — adapter selon PROJECTS.md
    # Exemple :
    # */dev/mon-projet*) PROJECT="mon-projet" ;;
    # */dev/autre*)      PROJECT="autre" ;;
    *) PROJECT="" ;;
esac

if [ -n "$PROJECT" ]; then
    MSG="Contexte compacté. Avant de continuer :\\n1. Mettre à jour ETAT.md dans le cwd si présent\\n2. Mettre à jour ~/dev/my-context/contexts/ctx-${PROJECT}.md (décisions, contraintes, patterns de cette session)\\n3. git -C ~/dev/my-context add contexts/ctx-${PROJECT}.md && git commit -m 'ctx(${PROJECT}): checkpoint post-compact' && git push\\nPuis reprendre le travail normalement."
else
    MSG="Contexte compacté. Avant de continuer : mettre à jour ETAT.md dans le cwd si présent, puis pusher my-context. Puis reprendre le travail normalement."
fi

printf '{"hookSpecificOutput":{"hookEventName":"PostCompact","additionalContext":"%s"}}' "$MSG"
