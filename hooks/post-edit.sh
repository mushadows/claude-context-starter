#!/usr/bin/env bash
# Hook PostToolUse — déclenché après chaque Edit ou Write.
# Lit le fichier édité depuis stdin JSON et lance le linter approprié selon l'extension.

set -euo pipefail

stdin_data=$(cat)

# Extraire file_path depuis tool_input
file_path=$(echo "$stdin_data" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null || echo "")

[ -z "$file_path" ] && exit 0
[ -f "$file_path" ] || exit 0

ext="${file_path##*.}"

case "$ext" in
    ts|tsx)
        # Remonter depuis le fichier jusqu'à trouver un tsconfig.json
        dir=$(dirname "$file_path")
        tsconfig=""
        while [ "$dir" != "/" ]; do
            if [ -f "$dir/tsconfig.json" ]; then
                tsconfig="$dir/tsconfig.json"
                break
            fi
            dir=$(dirname "$dir")
        done

        if [ -n "$tsconfig" ]; then
            project_root=$(dirname "$tsconfig")
            command -v npx &>/dev/null || exit 0
            result=$(cd "$project_root" && npx --no tsc --noEmit 2>&1) || \
                echo "[post-edit] TypeScript errors in $file_path:
$result"
        fi
        ;;

    go)
        command -v go &>/dev/null || exit 0
        dir=$(dirname "$file_path")
        result=$(cd "$dir" && go vet ./... 2>&1) || \
            echo "[post-edit] go vet errors in $file_path:
$result"
        ;;

    sh)
        if command -v shellcheck &>/dev/null; then
            result=$(shellcheck "$file_path" 2>&1) || \
                echo "[post-edit] shellcheck warnings in $file_path:
$result"
        fi
        ;;
esac
