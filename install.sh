#!/usr/bin/env bash
# install.sh — Configure Claude Code depuis le dossier Claudia
# Appelé par bootstrap.sh / bootstrap.ps1. Peut aussi être lancé manuellement.
# Idempotent et non-destructif.
#
# Usage :
#   bash install.sh [--yes] [--claudia-home <path>]

set -e

# ────────────────────────────────────────────────────────────────
# Détection OS
# ────────────────────────────────────────────────────────────────
IS_WINDOWS=false
case "${OSTYPE:-}" in
    msys*|cygwin*|win*) IS_WINDOWS=true ;;
esac
[ -n "${WINDIR:-}" ] && IS_WINDOWS=true

# ────────────────────────────────────────────────────────────────
# Args
# ────────────────────────────────────────────────────────────────
AUTO_YES=false
CLAUDIA_HOME=""
while [ $# -gt 0 ]; do
    case "$1" in
        --yes) AUTO_YES=true; shift ;;
        --claudia-home) CLAUDIA_HOME="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Chemin par défaut si non fourni
if [ -z "$CLAUDIA_HOME" ]; then
    # Windows Git Bash : Documents peut être redirigé (OneDrive)
    if $IS_WINDOWS && [ -f "$LOCALAPPDATA/Claudia/root" ]; then
        CLAUDIA_HOME="$(cat "$LOCALAPPDATA/Claudia/root")"
    elif [ -f "$HOME/.claudia/root" ]; then
        CLAUDIA_HOME="$(cat "$HOME/.claudia/root")"
    else
        # Auto-détection : le dossier où se trouve ce script
        CLAUDIA_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    fi
fi

CLAUDE_DIR="$HOME/.claude"
ERRORS=0

green() { echo "  ✓ $1"; }
warn()  { echo "  ⚠ $1"; }
err()   { echo "  ✗ $1"; ERRORS=$((ERRORS+1)); }

echo ""
echo "Configuration de Claude Code…"
echo "  Source  : $CLAUDIA_HOME"
echo "  Cible   : $CLAUDE_DIR"
echo ""

# ────────────────────────────────────────────────────────────────
# Helper : lien symbolique OU copie (Windows sans Dev Mode)
# ────────────────────────────────────────────────────────────────
link_or_copy() {
    local src="$1" dst="$2"
    if [ -e "$dst" ] || [ -L "$dst" ]; then rm -f "$dst"; fi
    if $IS_WINDOWS; then
        # Copie systématique sur Windows (symlinks demandent Dev Mode ou admin)
        cp "$src" "$dst"
    else
        ln -sf "$src" "$dst"
    fi
}

# ────────────────────────────────────────────────────────────────
# 1. Dossiers ~/.claude/
# ────────────────────────────────────────────────────────────────
mkdir -p "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/commands"
green "Dossiers Claude Code prêts"

# ────────────────────────────────────────────────────────────────
# 2. Hooks (.sh)
# ────────────────────────────────────────────────────────────────
HOOK_COUNT=0
for hook in "$CLAUDIA_HOME/hooks/"*.sh; do
    [ -f "$hook" ] || continue
    name=$(basename "$hook")
    chmod +x "$hook" 2>/dev/null || true
    link_or_copy "$hook" "$CLAUDE_DIR/hooks/$name"
    HOOK_COUNT=$((HOOK_COUNT+1))
done
green "$HOOK_COUNT automatismes installés"

# ────────────────────────────────────────────────────────────────
# 3. Skills (.md)
# ────────────────────────────────────────────────────────────────
SKILL_COUNT=0
for skill in "$CLAUDIA_HOME/skills/"*.md; do
    [ -f "$skill" ] || continue
    name=$(basename "$skill")
    link_or_copy "$skill" "$CLAUDE_DIR/commands/$name"
    SKILL_COUNT=$((SKILL_COUNT+1))
done
green "$SKILL_COUNT raccourcis installés"

# ────────────────────────────────────────────────────────────────
# 4. settings.json
# ────────────────────────────────────────────────────────────────
SETTINGS_TEMPLATE="$CLAUDIA_HOME/settings-template.json"
SETTINGS_TARGET="$CLAUDE_DIR/settings.json"
if [ -f "$SETTINGS_TEMPLATE" ]; then
    if [ -f "$SETTINGS_TARGET" ] && ! cmp -s "$SETTINGS_TEMPLATE" "$SETTINGS_TARGET"; then
        cp "$SETTINGS_TARGET" "${SETTINGS_TARGET}.bak-$(date +%Y%m%d-%H%M%S)"
    fi
    cp "$SETTINGS_TEMPLATE" "$SETTINGS_TARGET"
    green "Réglages Claude Code à jour"
else
    warn "settings-template.json absent — réglages non modifiés"
fi

# ────────────────────────────────────────────────────────────────
# 5. Résumé
# ────────────────────────────────────────────────────────────────
if [ $ERRORS -eq 0 ]; then
    echo ""
    green "Installation terminée sans erreur"
else
    echo ""
    warn "Terminé avec $ERRORS avertissement(s)"
fi
