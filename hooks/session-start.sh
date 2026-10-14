#!/usr/bin/env bash
# Hook UserPromptSubmit — init de session, silencieux (aucun stdout).
# Premier prompt d'une session : met à jour le repo de contexte en arrière-plan,
# ré-applique install.sh si le repo a changé, vérifie ~/CLAUDE.md.
# Log lisible : ~/.local/share/claude/last-session.log

set -euo pipefail
read -r -d '' _input 2>/dev/null || true

# Résout le vrai chemin du hook (symlink ~/.claude/hooks/x.sh -> repo) pour retrouver lib/paths.sh.
# Sur Windows le hook est une copie : on se rabat sur ~/.claude/context-dir (écrit par install.sh).
_src="${BASH_SOURCE[0]}"
_real=$(readlink -f "$_src" 2>/dev/null) || _real=""
if [ -z "$_real" ]; then
    while [ -L "$_src" ]; do
        _l=$(readlink "$_src")
        case "$_l" in /*) _src="$_l" ;; *) _src="$(dirname "$_src")/$_l" ;; esac
    done
    _real="$_src"
fi
HOOK_DIR=$(cd "$(dirname "$_real")" && pwd)
_marker=$(cat "$HOME/.claude/context-dir" 2>/dev/null || true)
for _p in "$HOOK_DIR/../lib/paths.sh" "${_marker:+$_marker/lib/paths.sh}" "$HOME/dev/claude-context/lib/paths.sh"; do
    if [ -n "$_p" ] && [ -f "$_p" ]; then
        # shellcheck disable=SC1090
        source "$_p"
        break
    fi
done
CONTEXT_DIR="${CONTEXT_DIR:-$HOME/dev/claude-context}"

LOCK_DIR="$HOME/.local/share/claude"
SESSION_LOCK="$LOCK_DIR/session-${CLAUDE_CODE_SESSION_ID:-$(date +%Y%m%d)}"
LOG_FILE="$LOCK_DIR/last-session.log"
mkdir -p "$LOCK_DIR"

# Réseau non bloquant : jamais de prompt, connexion courte
export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=5"

if [ -z "${CLAUDE_HOOK_BG:-}" ]; then
    [ -f "$SESSION_LOCK" ] && exit 0
    touch "$SESSION_LOCK"
    # Travail réseau relancé en arrière-plan : le hook rend la main tout de suite
    export CLAUDE_HOOK_BG=1
    if command -v setsid >/dev/null 2>&1; then
        setsid nohup bash "${BASH_SOURCE[0]}" </dev/null >/dev/null 2>&1 &
    else
        nohup bash "${BASH_SOURCE[0]}" </dev/null >/dev/null 2>&1 &
    fi
    exit 0
fi

LOG=()

# 1. Repo de contexte : pull + install.sh si changements
BEFORE=$(git -C "$CONTEXT_DIR" rev-parse HEAD 2>/dev/null || echo "")
PULL_OK=true
git -C "$CONTEXT_DIR" pull --ff-only --quiet 2>/dev/null || PULL_OK=false
AFTER=$(git -C "$CONTEXT_DIR" rev-parse HEAD 2>/dev/null || echo "")
if ! $PULL_OK; then
    LOG+=("⚠ pull impossible (modifs locales dans le repo, pas d'origin, ou réseau) : contexte non mis à jour")
elif [ -n "$BEFORE" ] && [ "$BEFORE" != "$AFTER" ]; then
    bash "$CONTEXT_DIR/install.sh" --quiet >/dev/null 2>&1 || true
    LOG+=("✓ contexte mis à jour (hooks/skills/settings ré-appliqués)")
else
    LOG+=("· contexte à jour")
fi

# 1bis. Première session : CLAUDE.local.md absent ou non rempli -> core.md déclenche INTERVIEW.md
if [ ! -f "$CONTEXT_DIR/CLAUDE.local.md" ] || grep -q "SETUP_REQUIRED" "$CONTEXT_DIR/CLAUDE.local.md" 2>/dev/null; then
    LOG+=("· première session : configuration à faire (INTERVIEW.md)")
fi

# 2. ~/CLAUDE.md doit référencer core.md
CORE_LINE="@${CONTEXT_DIR#"$HOME"/}/core.md"
if [ ! -f "$HOME/CLAUDE.md" ] || ! grep -qF "$CORE_LINE" "$HOME/CLAUDE.md"; then
    LOG+=("⚠ ~/CLAUDE.md ne contient pas $CORE_LINE — relancer install.sh")
else
    LOG+=("· CLAUDE.md OK")
fi

# 3. Opt-in (.autosync) : pull ff-only des autres repos de ~/dev
if [ -f "$CONTEXT_DIR/.autosync" ]; then
    updated=()
    for dir in "$HOME"/dev/*/; do
        [ -d "$dir/.git" ] || continue
        [ "$(cd "$dir" && pwd)" = "$CONTEXT_DIR" ] && continue
        result=$(git -C "$dir" pull --ff-only 2>&1) || continue
        case "$result" in *"Already up to date"*|*"Déjà à jour"*) ;; *) updated+=("$(basename "$dir")") ;; esac
    done
    if [ ${#updated[@]} -gt 0 ]; then LOG+=("✓ projets mis à jour : ${updated[*]}"); else LOG+=("· projets à jour"); fi
fi

{
    echo "[$(date '+%Y-%m-%d %H:%M')] Nouvelle session"
    for l in "${LOG[@]}"; do echo "  $l"; done
} > "$LOG_FILE"
find "$LOCK_DIR" -maxdepth 1 -name "session-*" -mtime +7 -delete 2>/dev/null || true
exit 0
