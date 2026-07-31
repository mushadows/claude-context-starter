# paths.sh — Helper multi-OS pour les skills et scripts my-context
# À sourcer en tête de tout skill/script qui touche à des chemins utilisateur
# variables selon l'OS (vault Obsidian, dossier Téléchargements).
#
# Usage :
#   source ~/dev/my-context/lib/paths.sh
#   ls "$VAULT_DIR/Cours/"
#
# Exporte :
#   OS_KIND       — "linux" ou "windows"
#   VAULT_DIR     — vault Obsidian (chemin absolu, sans trailing slash)
#   DOWNLOADS_DIR — dossier des téléchargements (chemin absolu)
#
# SETUP_REQUIRED : adapter le chemin Windows du vault Obsidian ci-dessous
# à ton nom d'utilisateur (`C:/Users/<toi>/Documents/Obsidian`).
# Ignorer ce fichier si tu n'utilises pas Obsidian.

case "${OSTYPE:-}" in
    msys*|cygwin*|win*) OS_KIND="windows" ;;
    *)                  OS_KIND="linux"   ;;
esac
[ -n "${WINDIR:-}" ] && OS_KIND="windows"

if [ "$OS_KIND" = "windows" ]; then
    VAULT_DIR="${VAULT_DIR:-C:/Users/SETUP_REQUIRED/Documents/Obsidian}"
    if [ -d "$HOME/Téléchargements" ]; then
        DOWNLOADS_DIR="$HOME/Téléchargements"
    else
        DOWNLOADS_DIR="${DOWNLOADS_DIR:-$HOME/Downloads}"
    fi
else
    VAULT_DIR="${VAULT_DIR:-$HOME/dev/obsidian-vault}"
    if [ -d "$HOME/Téléchargements" ]; then
        DOWNLOADS_DIR="$HOME/Téléchargements"
    else
        DOWNLOADS_DIR="${DOWNLOADS_DIR:-$HOME/Downloads}"
    fi
fi

export OS_KIND VAULT_DIR DOWNLOADS_DIR
