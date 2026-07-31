#!/usr/bin/env bash
# Hook SessionStart / UserPromptSubmit — init silencieux de la session Claudia
# Zéro stdout par défaut. Utilise le log pour tracer.

set -euo pipefail
read -r -d '' _input 2>/dev/null || true

# Charger les chemins Claudia (CLAUDIA_HOME, CLAUDIA_STATE, OS_KIND…)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../lib/paths.sh" ]; then
    source "$SCRIPT_DIR/../lib/paths.sh"
elif [ -f "$HOME/Documents/Claudia/lib/paths.sh" ]; then
    source "$HOME/Documents/Claudia/lib/paths.sh"
else
    # Défauts si paths.sh introuvable
    CLAUDIA_HOME="${CLAUDIA_HOME:-$HOME/Documents/Claudia}"
    CLAUDIA_STATE="${CLAUDIA_STATE:-$HOME/.claudia}"
fi

LOG_DIR="$CLAUDIA_STATE/logs"
SESSION_LOCK="$LOG_DIR/session-${CLAUDE_CODE_SESSION_ID:-unknown}"
LOG_FILE="$LOG_DIR/last-session.log"

mkdir -p "$LOG_DIR"

# Déjà initialisé pour cette session → silence
[ -f "$SESSION_LOCK" ] && exit 0
touch "$SESSION_LOCK"

LOG=()
log_() { LOG+=("$1"); }

# ── 1. Vérifier que Claudia est installée ──────────────────────
if [ -f "$CLAUDIA_HOME/core.md" ]; then
    log_ "· Claudia OK ($CLAUDIA_HOME)"
else
    log_ "⚠ Claudia introuvable dans $CLAUDIA_HOME"
fi

# ── 2. Vérifier CLAUDE.md ──────────────────────────────────────
if [ -f "$HOME/CLAUDE.md" ] && grep -q "Documents/Claudia/core.md" "$HOME/CLAUDE.md"; then
    log_ "· ~/CLAUDE.md connecté"
else
    echo "@Documents/Claudia/core.md" > "$HOME/CLAUDE.md"
    log_ "✓ ~/CLAUDE.md créé/corrigé"
fi

# ── 3. Détecter si c'est la 1ère session (SETUP_REQUIRED dans core.md) ─
# Le hook UserPromptSubmit peut injecter un additionalContext pour orienter
# Claude vers l'interview au 1er lancement.
FIRST_RUN_MSG=""
if [ -f "$CLAUDIA_HOME/core.md" ] && grep -q "SETUP_REQUIRED" "$CLAUDIA_HOME/core.md" 2>/dev/null; then
    FIRST_RUN_MSG="C'est la toute première session avec cet utilisateur — le fichier $CLAUDIA_HOME/core.md contient encore des SETUP_REQUIRED. Lire $CLAUDIA_HOME/INTERVIEW.md et suivre son déroulé pour se présenter et accueillir la personne. Ne pas exécuter la checklist normale."
fi

# ── 4. Écrire le log ───────────────────────────────────────────
{
    echo "[$(date '+%Y-%m-%d %H:%M')] Session Claudia démarrée"
    for l in "${LOG[@]}"; do echo "  $l"; done
} > "$LOG_FILE"

# ── 5. Émettre additionalContext si 1ère session ───────────────
if [ -n "$FIRST_RUN_MSG" ]; then
    # Échapper les quotes et retours à la ligne pour JSON
    ESCAPED=$(printf '%s' "$FIRST_RUN_MSG" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n' | sed 's/\\n$//')
    printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}' "$ESCAPED"
fi

exit 0
