#!/usr/bin/env bash
# Claudia — bootstrap Linux/Mac
# Usage :
#   curl -fsSL https://raw.githubusercontent.com/mushadows/claudia/main/bootstrap.sh | bash
# Idempotent : peut être relancé pour mettre à jour.

set -euo pipefail

# ────────────────────────────────────────────────────────────────
# Config
# ────────────────────────────────────────────────────────────────
REPO="mushadows/claudia"
BRANCH="main"
CLAUDIA_HOME="${CLAUDIA_HOME:-$HOME/Documents/Claudia}"
CLAUDIA_STATE="${CLAUDIA_STATE:-$HOME/.claudia}"
NODE_MIN_MAJOR=20
LOG_FILE="$CLAUDIA_STATE/logs/install-$(date +%Y%m%d-%H%M%S).log"

# ────────────────────────────────────────────────────────────────
# Sortie visuelle
# ────────────────────────────────────────────────────────────────
BOLD='\033[1m'; DIM='\033[2m'; GREEN='\033[32m'; YEL='\033[33m'; RED='\033[31m'; RST='\033[0m'
step()  { printf "\n${BOLD}➤${RST} %s\n" "$1"; }
ok()    { printf "  ${GREEN}✓${RST} %s\n" "$1"; }
warn()  { printf "  ${YEL}⚠${RST} %s\n" "$1"; }
fail()  { printf "  ${RED}✗${RST} %s\n" "$1" >&2; }
info()  { printf "  ${DIM}·${RST} %s\n" "$1"; }

log() { echo "[$(date +%H:%M:%S)] $*" >> "$LOG_FILE"; }

# ────────────────────────────────────────────────────────────────
# Trap erreurs — message user-friendly
# ────────────────────────────────────────────────────────────────
on_error() {
    local exit_code=$?
    local line=$1
    fail "Quelque chose s'est mal passé (ligne $line, code $exit_code)."
    echo ""
    echo "  Ce qui a été fait est conservé dans : $CLAUDIA_STATE/"
    echo "  Log complet : $LOG_FILE"
    echo ""
    echo "  Tu peux relancer cette commande, elle reprendra où ça s'est arrêté."
    echo "  Si le problème persiste : https://github.com/$REPO/issues"
    exit $exit_code
}
trap 'on_error $LINENO' ERR

# ────────────────────────────────────────────────────────────────
# Bannière
# ────────────────────────────────────────────────────────────────
cat <<'EOF'

   ╭─────────────────────────────────╮
   │                                 │
   │      Bienvenue chez Claudia     │
   │                                 │
   ╰─────────────────────────────────╯

   Une assistante Claude qui te connaît, se souvient de toi,
   et s'adapte à ce que tu fais.

   Cette installation prend environ 3 minutes.
   Aucun mot de passe administrateur ne sera demandé.

EOF

mkdir -p "$CLAUDIA_STATE/logs"
log "bootstrap.sh démarré — user=$USER home=$HOME"

# ────────────────────────────────────────────────────────────────
# 1. Détecter le système
# ────────────────────────────────────────────────────────────────
step "Je regarde ton système"
OS_KIND="$(uname -s)"
ARCH="$(uname -m)"
case "$OS_KIND" in
    Linux)  OS_LABEL="Linux ($ARCH)" ;;
    Darwin) OS_LABEL="macOS ($ARCH)" ;;
    *)      fail "Système non supporté : $OS_KIND"; exit 10 ;;
esac
ok "$OS_LABEL détecté"
log "os=$OS_KIND arch=$ARCH"

# WSL ?
if grep -qi microsoft /proc/version 2>/dev/null; then
    info "Windows Subsystem for Linux détecté — traité comme Linux."
fi

# ────────────────────────────────────────────────────────────────
# 2. Outils de base
# ────────────────────────────────────────────────────────────────
step "Je vérifie les outils de base"
for cmd in curl tar; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        fail "$cmd est nécessaire mais absent."
        echo ""
        case "$OS_KIND" in
            Darwin) echo "  Installe-le avec : xcode-select --install" ;;
            Linux)  echo "  Installe-le avec ton gestionnaire de paquets (apt, dnf, pacman…)" ;;
        esac
        exit 11
    fi
done
ok "curl et tar présents"

# ────────────────────────────────────────────────────────────────
# 3. Créer les dossiers Claudia
# ────────────────────────────────────────────────────────────────
step "Je prépare ton dossier Claudia"
mkdir -p "$CLAUDIA_HOME"
mkdir -p "$CLAUDIA_STATE/backups"
chmod 700 "$CLAUDIA_STATE" 2>/dev/null || true
echo "$CLAUDIA_HOME" > "$CLAUDIA_STATE/root"
ok "Dossier : $CLAUDIA_HOME"
info "État interne : $CLAUDIA_STATE"

# ────────────────────────────────────────────────────────────────
# 4. Node.js via fnm (isolé, pas de sudo)
# ────────────────────────────────────────────────────────────────
step "Je vérifie Node.js"
NEED_FNM=true
if command -v node >/dev/null 2>&1; then
    NODE_MAJOR=$(node -v 2>/dev/null | sed -E 's/^v([0-9]+).*/\1/')
    if [ -n "$NODE_MAJOR" ] && [ "$NODE_MAJOR" -ge "$NODE_MIN_MAJOR" ] 2>/dev/null; then
        ok "Node.js $(node -v) — déjà installé"
        NEED_FNM=false
    else
        info "Node $(node -v) trop ancien (min v${NODE_MIN_MAJOR}), j'installe une version dédiée."
    fi
else
    info "Node.js absent, je l'installe."
fi

if $NEED_FNM; then
    export FNM_DIR="$CLAUDIA_STATE/fnm"
    export PATH="$FNM_DIR:$PATH"
    if [ ! -x "$FNM_DIR/fnm" ]; then
        info "Téléchargement de fnm (gestionnaire Node)…"
        curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$FNM_DIR" --skip-shell >>"$LOG_FILE" 2>&1
    fi
    eval "$("$FNM_DIR/fnm" env --shell bash)"
    "$FNM_DIR/fnm" install --lts >>"$LOG_FILE" 2>&1
    "$FNM_DIR/fnm" use lts-latest >>"$LOG_FILE" 2>&1
    ok "Node.js $(node -v) installé (isolé dans $FNM_DIR)"
fi

# ────────────────────────────────────────────────────────────────
# 5. Claude Code
# ────────────────────────────────────────────────────────────────
step "Je vérifie Claude Code"
if command -v claude >/dev/null 2>&1; then
    ok "Claude Code déjà présent"
else
    info "Installation de Claude Code (peut prendre 30-60 s)…"
    npm install -g @anthropic-ai/claude-code >>"$LOG_FILE" 2>&1
    ok "Claude Code installé"
fi

# ────────────────────────────────────────────────────────────────
# 6. Télécharger le contenu Claudia (tarball, pas besoin de git)
# ────────────────────────────────────────────────────────────────
step "Je télécharge les fichiers Claudia"
TARBALL_URL="https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz"
TMPDIR="$(mktemp -d)"
if [ -f "$CLAUDIA_HOME/.claudia-version" ]; then
    info "Claudia est déjà installée — je mets à jour (tes fichiers persos sont préservés)."
    # Backup des fichiers user avant écrasement
    BACKUP="$CLAUDIA_STATE/backups/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP"
    for f in profil.md memoire.md; do
        [ -f "$CLAUDIA_HOME/$f" ] && cp "$CLAUDIA_HOME/$f" "$BACKUP/" || true
    done
    [ -d "$CLAUDIA_HOME/contexts" ] && cp -R "$CLAUDIA_HOME/contexts" "$BACKUP/" 2>/dev/null || true
    log "backup vers $BACKUP"
fi

curl -fsSL "$TARBALL_URL" | tar -xz -C "$TMPDIR"
SRC="$(find "$TMPDIR" -maxdepth 1 -type d -name 'claudia-*' | head -1)"
if [ -z "$SRC" ]; then
    fail "Impossible d'extraire les fichiers Claudia."
    exit 12
fi

# On copie les fichiers "système" (jamais les fichiers utilisateur existants)
for item in core.md INTERVIEW.md README.md hooks skills lib templates contexts settings-template.json internals; do
    [ -e "$SRC/$item" ] && cp -R "$SRC/$item" "$CLAUDIA_HOME/" || true
done

# Templates user (profil.md, memoire.md) : copier UNIQUEMENT s'ils n'existent pas déjà
for f in profil.md memoire.md; do
    if [ ! -f "$CLAUDIA_HOME/$f" ] && [ -f "$SRC/templates/$f" ]; then
        cp "$SRC/templates/$f" "$CLAUDIA_HOME/$f"
    fi
done

echo "$(date +%Y-%m-%d)" > "$CLAUDIA_HOME/.claudia-version"
rm -rf "$TMPDIR"
ok "Fichiers Claudia à jour"

# ────────────────────────────────────────────────────────────────
# 7. Déployer hooks + skills + settings (via install.sh interne)
# ────────────────────────────────────────────────────────────────
step "Je configure Claude Code"
bash "$CLAUDIA_HOME/install.sh" --yes --claudia-home "$CLAUDIA_HOME" >>"$LOG_FILE" 2>&1
ok "Automatismes et raccourcis en place"

# ────────────────────────────────────────────────────────────────
# 8. ~/CLAUDE.md
# ────────────────────────────────────────────────────────────────
step "Je connecte Claude à ton profil"
CLAUDE_MD="$HOME/CLAUDE.md"
CORE_LINE="@Documents/Claudia/core.md"

if [ ! -f "$CLAUDE_MD" ]; then
    echo "$CORE_LINE" > "$CLAUDE_MD"
    ok "$CLAUDE_MD créé"
elif grep -qF "$CORE_LINE" "$CLAUDE_MD"; then
    ok "$CLAUDE_MD déjà connecté"
else
    cp "$CLAUDE_MD" "${CLAUDE_MD}.bak-$(date +%Y%m%d-%H%M%S)"
    printf "%s\n%s\n" "$CORE_LINE" "$(cat "$CLAUDE_MD")" > "$CLAUDE_MD"
    ok "$CLAUDE_MD mis à jour (ton ancien contenu est conservé)"
fi

# ────────────────────────────────────────────────────────────────
# Terminé
# ────────────────────────────────────────────────────────────────
cat <<EOF

   ╭─────────────────────────────────╮
   │                                 │
   │      C'est prêt !               │
   │                                 │
   ╰─────────────────────────────────╯

   Pour parler à Claudia, tape simplement :

       claude

   La première fois, elle va se présenter et te poser
   quelques questions pour apprendre à te connaître.

   Ton dossier Claudia (tu peux y jeter un œil) :
   $CLAUDIA_HOME

EOF

log "bootstrap terminé avec succès"
