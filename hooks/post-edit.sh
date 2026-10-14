#!/usr/bin/env bash
# Hook PostToolUse (Edit|Write) — lint léger du fichier édité selon l'extension.
# Les erreurs sont écrites sur stderr avec exit 2 : Claude les voit et corrige.
# Outils absents ou projet non configuré -> silence (jamais bloquant).

set -euo pipefail
TO=""; command -v timeout >/dev/null 2>&1 && TO="timeout 30"  # évite un hook bloqué sur un gros projet

stdin_data=$(cat)

if command -v jq >/dev/null 2>&1; then
    file_path=$(printf '%s' "$stdin_data" | jq -r '.tool_input.file_path // ""')
else
    file_path=$(printf '%s' "$stdin_data" | sed -n 's/.*"file_path" *: *"\([^"]*\)".*/\1/p' | head -1)
fi

[ -n "$file_path" ] && [ -f "$file_path" ] || exit 0

fail() { printf '[post-edit] %s\n%s\n' "$1" "$2" >&2; exit 2; }

case "${file_path##*.}" in
    ts|tsx)
        # Remonter jusqu'à un tsconfig.json
        dir=$(dirname "$file_path")
        while [ ! -f "$dir/tsconfig.json" ]; do
            parent=$(dirname "$dir")
            [ "$parent" = "$dir" ] && exit 0
            dir="$parent"
        done
        tsc_bin="$dir/node_modules/.bin/tsc"
        [ -x "$tsc_bin" ] || exit 0
        result=$(cd "$dir" && ${TO:+$TO }"$tsc_bin" --noEmit 2>&1) || fail "erreurs TypeScript ($file_path)" "$result"
        ;;
    go)
        command -v go >/dev/null 2>&1 || exit 0
        result=$(cd "$(dirname "$file_path")" && ${TO:+$TO }go vet ./... 2>&1) || fail "go vet ($file_path)" "$result"
        ;;
    sh)
        command -v shellcheck >/dev/null 2>&1 || exit 0
        result=$(shellcheck "$file_path" 2>&1) || fail "shellcheck ($file_path)" "$result"
        ;;
esac
exit 0
