# paths.sh — helper multi-OS (Linux / Git Bash Windows), à sourcer (jamais exécuter).
#
# Usage : source ~/dev/claude-context/lib/paths.sh
#
# Exporte :
#   OS_KIND       — "linux" ou "windows"
#   CONTEXT_DIR   — racine du repo de contexte (déduite de l'emplacement de ce fichier)
#   DOWNLOADS_DIR — dossier de téléchargements (Téléchargements, sinon Downloads)
#
# Idempotent : peut être sourcé plusieurs fois.

case "${OSTYPE:-}" in
    msys*|cygwin*|win*) OS_KIND="windows" ;;
    *)                  OS_KIND="linux"   ;;
esac
[ -n "${WINDIR:-}" ] && OS_KIND="windows"

# Emplacement réel de ce fichier (suit les symlinks si possible)
_paths_src="${BASH_SOURCE[0]:-}"
if [ -n "$_paths_src" ]; then
    _paths_real=$(readlink -f "$_paths_src" 2>/dev/null) || _paths_real="$_paths_src"
    CONTEXT_DIR=$(cd "$(dirname "$_paths_real")/.." 2>/dev/null && pwd) || CONTEXT_DIR=""
fi
CONTEXT_DIR="${CONTEXT_DIR:-$HOME/dev/claude-context}"
unset _paths_src _paths_real

if [ -d "$HOME/Téléchargements" ]; then
    DOWNLOADS_DIR="$HOME/Téléchargements"
else
    DOWNLOADS_DIR="${DOWNLOADS_DIR:-$HOME/Downloads}"
fi

export OS_KIND CONTEXT_DIR DOWNLOADS_DIR
