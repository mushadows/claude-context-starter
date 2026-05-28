#!/usr/bin/env bash
# install.sh — Claude Context Starter
# Configure le fichier ~/CLAUDE.md pour activer le context

set -e

CONTEXT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_CLAUDE_MD="$HOME/CLAUDE.md"

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

echo "✅ Dossier détecté : $CONTEXT_DIR"
echo ""

# Vérifier si ~/CLAUDE.md existe déjà
if [ -f "$HOME_CLAUDE_MD" ]; then
    echo "ℹ️  Un fichier ~/CLAUDE.md existe déjà :"
    echo "---"
    cat "$HOME_CLAUDE_MD"
    echo "---"
    echo ""
    read -p "Remplacer par la configuration Claude Context Starter ? (o/N) : " confirm
    if [[ "$confirm" != "o" && "$confirm" != "O" ]]; then
        echo "Installation annulée."
        exit 0
    fi
    echo ""
fi

# Créer ~/CLAUDE.md
cat > "$HOME_CLAUDE_MD" << 'EOF'
@dev/my-context/CLAUDE.md
EOF

echo "✅ ~/CLAUDE.md créé"
echo ""

# Configurer git si nécessaire
if ! git -C "$CONTEXT_DIR" remote -v 2>/dev/null | grep -q "origin"; then
    echo "ℹ️  Aucun remote Git configuré pour ce repo."
    echo "   Tu pourras le configurer depuis Claude Code lors de l'interview."
    echo ""
fi

# Résumé
echo "==================================================="
echo "  Installation terminée !"
echo "==================================================="
echo ""
echo "  Prochaine étape :"
echo ""
echo "  1. Ouvre un terminal dans ton dossier home"
echo "     → Sur Mac/Linux : cd ~"
echo "     → Sur Windows   : cd C:\\Users\\ton-nom\\"
echo ""
echo "  2. Lance Claude Code :"
echo "     → claude"
echo ""
echo "  3. Claude va démarrer l'interview de configuration"
echo "     automatiquement. Réponds aux questions et ton"
echo "     context sera prêt en 5-10 minutes !"
echo ""
