#!/usr/bin/env bash
# install.sh — Claude Context Starter
# Configure Claude Code depuis ~/dev/my-context/
# Idempotent et non-destructif : ne détruit jamais de données existantes
# Usage : bash ~/dev/my-context/install.sh [--yes]

set -e

CONTEXT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
AUTO_YES="${1:-}"
ERRORS=0

green() { echo "  ✓ $1"; }
warn()  { echo "  ⚠ $1"; }
err()   { echo "  ✗ $1"; ERRORS=$((ERRORS+1)); }

echo ""
echo "==================================================="
echo "  Claude Context Starter — Installation"
echo "==================================================="
echo ""

# Vérifier que le dossier est bien dans ~/dev/my-context/
EXPECTED_PATH="$HOME/dev/my-context"
if [ "$CONTEXT_DIR" != "$EXPECTED_PATH" ]; then
    echo "⚠️  Ce repo n'est pas dans le bon dossier."
    echo "   Chemin actuel : $CONTEXT_DIR"
    echo "   Chemin attendu : $EXPECTED_PATH"
    echo ""
    echo "   Pour corriger :"
    echo "   mv \"$CONTEXT_DIR\" \"$EXPECTED_PATH\""
    echo "   cd \"$EXPECTED_PATH\""
    echo "   bash install.sh"
    echo ""
    exit 1
fi

green "Dossier détecté : $CONTEXT_DIR"
echo ""

# ── 1. Sync context depuis git ──────────────────────────────────────────────
echo "[1/6] Sync context depuis git..."
if git -C "$CONTEXT_DIR" pull --ff-only 2>/dev/null; then
    green "context à jour"
else
    warn "git pull impossible (pas de réseau ou conflits) — on continue avec l'état local"
fi

# ── 2. Créer les dossiers ~/.claude/ nécessaires ───────────────────────────
echo "[2/6] Dossiers ~/.claude/..."
mkdir -p "$CLAUDE_DIR/hooks"
mkdir -p "$CLAUDE_DIR/commands"
green "~/.claude/hooks/ et ~/.claude/commands/ prêts"

# ── 3. Symlinks hooks (.sh) ────────────────────────────────────────────────
echo "[3/6] Hooks..."
HOOK_COUNT=0
for hook in "$CONTEXT_DIR/hooks/"*.sh; do
    [ -f "$hook" ] || continue
    name=$(basename "$hook")
    target="$CLAUDE_DIR/hooks/$name"
    chmod +x "$hook"
    [ -L "$target" ] && rm "$target"
    if [ -f "$target" ] && [ ! -L "$target" ]; then
        warn "hooks/$name existe (non-symlink) — non écrasé, backup manuel requis"
        continue
    fi
    ln -sf "$hook" "$target"
    green "hooks/$name"
    HOOK_COUNT=$((HOOK_COUNT+1))
done
[ $HOOK_COUNT -eq 0 ] && warn "Aucun hook .sh trouvé dans hooks/"

# ── 4. Symlinks skills (.md) ───────────────────────────────────────────────
echo "[4/6] Skills..."
SKILL_COUNT=0
for skill in "$CONTEXT_DIR/skills/"*.md; do
    [ -f "$skill" ] || continue
    name=$(basename "$skill")
    target="$CLAUDE_DIR/commands/$name"
    [ -L "$target" ] && rm "$target"
    if [ -f "$target" ] && [ ! -L "$target" ]; then
        warn "commands/$name existe (non-symlink) — non écrasé"
        continue
    fi
    ln -sf "$skill" "$target"
    green "commands/$name"
    SKILL_COUNT=$((SKILL_COUNT+1))
done
[ $SKILL_COUNT -eq 0 ] && warn "Aucun skill .md trouvé dans skills/"

# ── 5. ~/CLAUDE.md ─────────────────────────────────────────────────────────
echo "[5/6] ~/CLAUDE.md..."
CLAUDE_MD="$HOME/CLAUDE.md"
CORE_LINE="@dev/my-context/core.md"

if [ ! -f "$CONTEXT_DIR/core.md" ]; then
    warn "core.md absent — CLAUDE.md non modifié"
elif [ ! -f "$CLAUDE_MD" ]; then
    echo "$CORE_LINE" > "$CLAUDE_MD"
    green "CLAUDE.md créé"
elif grep -qF "$CORE_LINE" "$CLAUDE_MD"; then
    green "CLAUDE.md déjà à jour"
else
    # CLAUDE.md existe avec un autre contenu → backup + remplacement
    BACKUP="${CLAUDE_MD}.bak-$(date +%Y%m%d-%H%M%S)"
    if [ "$AUTO_YES" = "--yes" ]; then
        cp "$CLAUDE_MD" "$BACKUP"
        echo "$CORE_LINE" > "$CLAUDE_MD"
        green "CLAUDE.md migré (backup : $BACKUP)"
    else
        echo ""
        echo "  Un fichier ~/CLAUDE.md existe déjà avec un contenu différent :"
        echo "  ---"
        cat "$CLAUDE_MD"
        echo "  ---"
        echo ""
        read -p "  Remplacer par @dev/my-context/core.md ? (o/N) : " confirm
        if [[ "$confirm" == "o" || "$confirm" == "O" ]]; then
            cp "$CLAUDE_MD" "$BACKUP"
            echo "$CORE_LINE" > "$CLAUDE_MD"
            green "CLAUDE.md migré (backup : $BACKUP)"
        else
            warn "CLAUDE.md non modifié — à corriger manuellement si besoin"
        fi
    fi
fi

# ── 6. settings.json ───────────────────────────────────────────────────────
echo "[6/6] settings.json..."
SETTINGS_TEMPLATE="$CONTEXT_DIR/settings-template.json"
SETTINGS_TARGET="$CLAUDE_DIR/settings.json"

if [ ! -f "$SETTINGS_TEMPLATE" ]; then
    warn "settings-template.json absent — settings.json non modifié"
else
    if [ -f "$SETTINGS_TARGET" ]; then
        cp "$SETTINGS_TARGET" "${SETTINGS_TARGET}.bak-$(date +%Y%m%d-%H%M%S)"
        green "backup settings.json créé"
    fi
    cp "$SETTINGS_TEMPLATE" "$SETTINGS_TARGET"
    green "settings.json mis à jour"
fi

# ── Résumé ─────────────────────────────────────────────────────────────────
echo ""
echo "==================================================="
if [ $ERRORS -eq 0 ]; then
    echo "  Installation terminée !"
else
    echo "  Installation terminée avec $ERRORS erreur(s)"
fi
echo "==================================================="
echo ""
echo "  Composants installés :"
[ -f "$CONTEXT_DIR/core.md" ]                && echo "    ✓ core.md — context modulaire" || echo "    · core.md — absent"
[ $HOOK_COUNT -gt 0 ]                        && echo "    ✓ $HOOK_COUNT hook(s) — ~/.claude/hooks/" || echo "    · hooks — aucun"
[ $SKILL_COUNT -gt 0 ]                       && echo "    ✓ $SKILL_COUNT skill(s) — ~/.claude/commands/" || echo "    · skills — aucun"
[ -f "$SETTINGS_TARGET" ]                    && echo "    ✓ settings.json — hooks activés" || echo "    · settings.json — absent"
echo ""
echo "  Prochaine étape :"
echo ""
echo "  1. Lance Claude depuis ton dossier home :"
echo "     cd ~ && claude"
echo ""
echo "  2. Si c'est la première installation :"
echo "     Claude va démarrer l'interview de configuration automatiquement."
echo ""
echo "  3. Si tu migres depuis l'ancienne architecture :"
echo "     Claude détectera le SETUP_REQUIRED dans core.md et proposera"
echo "     de mettre à jour les fichiers."
echo ""
