#!/usr/bin/env bash
# Hook UserPromptSubmit — init session Claude (silencieux à 100%)
#
# Niveaux : boot (tmpfs) → session → message
# Aucun output stdout → aucune hallucination possible
# Log écrit dans ~/.local/share/claude/last-session.log → lisible via /today

set -euo pipefail
read -r -d '' _input < /dev/stdin 2>/dev/null || true

LOCK_DIR="$HOME/.local/share/claude"
BOOT_LOCK="/tmp/claude-boot-$(hostname -s)"
SESSION_LOCK="$LOCK_DIR/session-${CLAUDE_CODE_SESSION_ID}"
LOG_FILE="$LOCK_DIR/last-session.log"

mkdir -p "$LOCK_DIR"

# Niveau message : déjà initialisé, silence
[ -f "$SESSION_LOCK" ] && exit 0
touch "$SESSION_LOCK"

LOG=()
log_() { LOG+=("$1"); }

# ── 1. my-context : pull + install.sh si changements ───────────────────────
BEFORE=$(git -C ~/dev/my-context rev-parse HEAD 2>/dev/null || echo "")
git -C ~/dev/my-context pull --ff-only --quiet 2>/dev/null || true
AFTER=$(git -C ~/dev/my-context rev-parse HEAD 2>/dev/null || echo "")
if [ "$BEFORE" != "$AFTER" ] && [ -n "$BEFORE" ]; then
    bash ~/dev/my-context/install.sh >/dev/null 2>&1 || true
    log_ "✓ my-context mis à jour (hooks/skills/settings re-appliqués)"
else
    log_ "· my-context à jour"
fi

# ── 2. obsidian-vault ───────────────────────────────────────────────────────
OBS_BEFORE=$(git -C ~/dev/obsidian-vault rev-parse HEAD 2>/dev/null || echo "")
git -C ~/dev/obsidian-vault pull --ff-only --quiet 2>/dev/null || true
OBS_AFTER=$(git -C ~/dev/obsidian-vault rev-parse HEAD 2>/dev/null || echo "")
if [ "$OBS_BEFORE" != "$OBS_AFTER" ] && [ -n "$OBS_BEFORE" ]; then
    log_ "✓ obsidian-vault mis à jour"
else
    log_ "· obsidian-vault à jour"
fi

# ── Niveau session (boot déjà fait) ────────────────────────────────────────
if [ -f "$BOOT_LOCK" ]; then
    updated=()
    for dir in ~/dev/*/; do
        name=$(basename "$dir")
        [[ "$name" == "my-context" || "$name" == "obsidian-vault" ]] && continue
        [ -d "$dir/.git" ] || continue
        result=$(git -C "$dir" pull --ff-only 2>&1) || continue
        [[ "$result" != *"Already up to date"* && "$result" != *"Déjà à jour"* ]] && updated+=("$name")
    done
    [ ${#updated[@]} -gt 0 ] && log_ "✓ Projets mis à jour : ${updated[*]}" || log_ "· Projets à jour"

    {
        echo "[$(date '+%Y-%m-%d %H:%M')] Nouvelle session (boot déjà fait)"
        for l in "${LOG[@]}"; do echo "  $l"; done
    } > "$LOG_FILE"
    exit 0
fi

# ── Niveau boot (première session depuis le démarrage) ─────────────────────
touch "$BOOT_LOCK"

# 3. Pull tous les projets
updated=()
for dir in ~/dev/*/; do
    name=$(basename "$dir")
    [[ "$name" == "my-context" || "$name" == "obsidian-vault" ]] && continue
    [ -d "$dir/.git" ] || continue
    result=$(git -C "$dir" pull --ff-only 2>&1) || continue
    [[ "$result" != *"Already up to date"* && "$result" != *"Déjà à jour"* ]] && updated+=("$name")
done
[ ${#updated[@]} -gt 0 ] && log_ "✓ Projets mis à jour : ${updated[*]}" || log_ "· Projets à jour"

# 4. Vérifier CLAUDE.md
if [ ! -f ~/CLAUDE.md ] || ! grep -q "@dev/my-context/core.md" ~/CLAUDE.md; then
    echo "@dev/my-context/core.md" > ~/CLAUDE.md
    log_ "✓ ~/CLAUDE.md corrigé"
else
    log_ "· CLAUDE.md OK"
fi

# 5. Scanner ~/Téléchargements/ (adapter le chemin si nécessaire)
DL_COUNT=$(ls ~/Téléchargements/ 2>/dev/null | grep -cv "^a-trier$" || echo 0)
[ "$DL_COUNT" -gt 0 ] \
    && log_ "⚠ ${DL_COUNT} fichier(s) dans ~/Téléchargements/ à traiter" \
    || log_ "· Téléchargements vide"

# 6. Vérifier la racine ~/
# SETUP_REQUIRED : adapter la liste selon votre structure home
ALLOWED=(dev Documents Téléchargements VM wallpaper)
INTRUS=()
for item in ~/*/; do
    [ -e "$item" ] || continue
    name=$(basename "$item")
    skip=false
    for a in "${ALLOWED[@]}"; do [[ "$name" == "$a" ]] && skip=true && break; done
    $skip || INTRUS+=("$name/")
done
for f in ~/*; do
    [ -e "$f" ] || continue
    [ -d "$f" ] && continue
    name=$(basename "$f")
    [[ "$name" == "CLAUDE.md" || "$name" == .* ]] && continue
    INTRUS+=("$name")
done
if [ ${#INTRUS[@]} -gt 0 ]; then
    for item in "${INTRUS[@]}"; do
        mv ~/"$item" ~/Documents/ 2>/dev/null || true
    done
    log_ "✓ Déplacé dans Documents/ : ${INTRUS[*]}"
else
    log_ "· Racine ~/ propre"
fi

# 7. Revue mensuelle (SETUP_REQUIRED : adapter ou supprimer selon votre contexte)
# Exemple : vérifier si une note financière a été mise à jour ce mois-ci
# DAY=$(date +%d)
# if [ "$DAY" -ge 25 ]; then
#     YEAR=$(date +%Y); MONTH=$(date +%m)
#     REVUE=$(git -C ~/dev/obsidian-vault log \
#         --after="${YEAR}-${MONTH}-24" \
#         --pretty=format:"%s" \
#         -- "votre/fichier/revue.md" 2>/dev/null \
#         | grep -v "^vault backup:" | head -1 || true)
#     [ -z "$REVUE" ] \
#         && log_ "⚠ REVUE MENSUELLE MANQUANTE" \
#         || log_ "· Revue mensuelle OK"
# fi

{
    echo "[$(date '+%Y-%m-%d %H:%M')] Init boot (première session depuis démarrage)"
    for l in "${LOG[@]}"; do echo "  $l"; done
} > "$LOG_FILE"

exit 0
