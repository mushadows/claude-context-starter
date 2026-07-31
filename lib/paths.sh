# paths.sh — Helper multi-OS pour skills et scripts Claudia
# À sourcer en tête de tout script qui touche à des chemins utilisateur
# variables selon l'OS.
#
# Usage :
#   source "$CLAUDIA_HOME/lib/paths.sh"
#   ls "$CLAUDIA_HOME/contexts/"
#
# Exporte :
#   OS_KIND        — "linux" ou "windows"
#   CLAUDIA_HOME   — dossier Claudia (contenu perso + fichiers système)
#   CLAUDIA_STATE  — dossier interne (fnm, logs, backups)
#   DOWNLOADS_DIR  — dossier des téléchargements (chemin absolu)
#   VAULT_DIR      — vault Obsidian si utilisé (optionnel, SETUP_REQUIRED sinon)

case "${OSTYPE:-}" in
    msys*|cygwin*|win*) OS_KIND="windows" ;;
    *)                  OS_KIND="linux"   ;;
esac
[ -n "${WINDIR:-}" ] && OS_KIND="windows"

# ── CLAUDIA_HOME ────────────────────────────────────────────────
if [ -z "${CLAUDIA_HOME:-}" ]; then
    # 1) Pointeur écrit par le bootstrap
    if [ "$OS_KIND" = "windows" ] && [ -f "${LOCALAPPDATA:-}/Claudia/root" ]; then
        CLAUDIA_HOME="$(cat "$LOCALAPPDATA/Claudia/root")"
    elif [ -f "$HOME/.claudia/root" ]; then
        CLAUDIA_HOME="$(cat "$HOME/.claudia/root")"
    else
        # 2) Défaut : ~/Documents/Claudia
        CLAUDIA_HOME="$HOME/Documents/Claudia"
    fi
fi

# ── CLAUDIA_STATE ───────────────────────────────────────────────
if [ -z "${CLAUDIA_STATE:-}" ]; then
    if [ "$OS_KIND" = "windows" ] && [ -n "${LOCALAPPDATA:-}" ]; then
        CLAUDIA_STATE="$LOCALAPPDATA/Claudia"
    else
        CLAUDIA_STATE="$HOME/.claudia"
    fi
fi

# ── DOWNLOADS_DIR ───────────────────────────────────────────────
if [ -z "${DOWNLOADS_DIR:-}" ]; then
    if [ -d "$HOME/Téléchargements" ]; then
        DOWNLOADS_DIR="$HOME/Téléchargements"
    else
        DOWNLOADS_DIR="$HOME/Downloads"
    fi
fi

# ── VAULT_DIR (optionnel, seulement si Obsidian configuré) ──────
if [ -z "${VAULT_DIR:-}" ]; then
    # Défaut : vide ; les scripts qui en ont besoin doivent vérifier avant utilisation
    VAULT_DIR=""
fi

export OS_KIND CLAUDIA_HOME CLAUDIA_STATE DOWNLOADS_DIR VAULT_DIR
