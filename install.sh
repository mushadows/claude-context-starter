#!/usr/bin/env bash
# install.sh — branche Claude Code sur ce repo de contexte.
# Idempotent et non destructif : tout fichier existant modifié est d'abord sauvegardé (.bak-<horodatage>).
# Usage : bash install.sh [--quiet] [--plugins]
#   --quiet    sortie réduite à une ligne (utilisé par le hook session-start)
#   --plugins  installe aussi quelques plugins Claude Code externes (opt-in)

set -eu

CONTEXT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CLAUDE_DIR="$HOME/.claude"
TS=$(date +%Y%m%d-%H%M%S)
ERRORS=0
QUIET=false
WITH_PLUGINS=false
for a in "$@"; do
    case "$a" in
        --quiet)   QUIET=true ;;
        --plugins) WITH_PLUGINS=true ;;
        *) echo "Option inconnue : $a (attendu : --quiet, --plugins)" >&2; exit 2 ;;
    esac
done
# --quiet : progression coupée, résumé sur fd 3 ; err() reste visible sur stderr
if $QUIET; then exec 3>&1 1>/dev/null; fi

IS_WINDOWS=false
case "${OSTYPE:-}" in msys*|cygwin*|win*) IS_WINDOWS=true ;; esac
[ -n "${WINDIR:-}" ] && IS_WINDOWS=true

ok()   { echo "  ✓ $1"; }
warn() { echo "  ⚠ $1"; }
err()  { echo "  ✗ $1" >&2; ERRORS=$((ERRORS+1)); }

# install_file SRC DST — symlink sur Linux, copie sur Windows.
# Un fichier réel différent à la destination est sauvegardé avant d'être remplacé.
install_file() {
    local src="$1" dst="$2"
    if [ -L "$dst" ]; then
        rm -f "$dst"
    elif [ -f "$dst" ] && ! cmp -s "$src" "$dst"; then
        cp "$dst" "$dst.bak-$TS"
        warn "$(basename "$dst") existant sauvegardé : $dst.bak-$TS"
    fi
    if $IS_WINDOWS; then cp -f "$src" "$dst"; else ln -sf "$src" "$dst"; fi
}

echo ""
echo "══ Claude Code — installation du contexte ($CONTEXT_DIR)"

# ── 1. Dossiers ────────────────────────────────────────────────────────────
mkdir -p "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/commands"
# Les hooks copiés (Windows) retrouvent le repo grâce à ce marqueur
printf '%s\n' "$CONTEXT_DIR" > "$CLAUDE_DIR/context-dir"
mkdir -p "$CONTEXT_DIR/etat"  # états projet (ignoré par git, utilisé par /etat, /bilan, /today)

# ── 2. Hooks ───────────────────────────────────────────────────────────────
echo "[1/5] Hooks..."
n=0
for f in "$CONTEXT_DIR"/hooks/*.sh; do
    [ -f "$f" ] || continue
    chmod +x "$f" 2>/dev/null || true
    install_file "$f" "$CLAUDE_DIR/hooks/$(basename "$f")"
    n=$((n+1))
done
ok "$n hook(s)"

# ── 3. Skills (slash commands) ─────────────────────────────────────────────
echo "[2/5] Skills..."
n=0
for f in "$CONTEXT_DIR"/skills/*.md; do
    [ -f "$f" ] || continue
    install_file "$f" "$CLAUDE_DIR/commands/$(basename "$f")"
    n=$((n+1))
done
ok "$n skill(s)"

# ── 4. ~/CLAUDE.md ─────────────────────────────────────────────────────────
echo "[3/5] ~/CLAUDE.md..."
CLAUDE_MD="$HOME/CLAUDE.md"
case "$CONTEXT_DIR" in "$HOME"/*) CORE_LINE="@${CONTEXT_DIR#"$HOME"/}/core.md" ;; *) CORE_LINE="@$CONTEXT_DIR/core.md" ;; esac
if [ ! -f "$CONTEXT_DIR/core.md" ]; then
    warn "core.md absent du repo — CLAUDE.md non modifié"
elif [ ! -f "$CLAUDE_MD" ]; then
    echo "$CORE_LINE" > "$CLAUDE_MD"
    ok "CLAUDE.md créé ($CORE_LINE)"
elif grep -qF "$CORE_LINE" "$CLAUDE_MD"; then
    ok "CLAUDE.md déjà à jour"
else
    cp "$CLAUDE_MD" "$CLAUDE_MD.bak-$TS"
    # Ajout en fin de fichier (contenu existant conservé) ; saut de ligne si le fichier n'en finit pas par un
    [ -n "$(tail -c1 "$CLAUDE_MD")" ] && echo "" >> "$CLAUDE_MD"
    echo "$CORE_LINE" >> "$CLAUDE_MD"
    ok "ligne $CORE_LINE ajoutée (backup : $CLAUDE_MD.bak-$TS)"
fi

# ── 5. settings.json ───────────────────────────────────────────────────────
echo "[4/5] settings.json..."
TEMPLATE="$CONTEXT_DIR/settings-template.json"
TARGET="$CLAUDE_DIR/settings.json"
if [ ! -f "$TEMPLATE" ]; then
    warn "settings-template.json absent — settings.json non modifié"
elif [ ! -f "$TARGET" ]; then
    cp "$TEMPLATE" "$TARGET"
    ok "settings.json créé depuis le template"
    warn "permissions larges installées (Bash(*), Write(*), WebFetch(*), acceptEdits) : resserre 'permissions' dans $TARGET si besoin (voir README)"
else
    # Fusion minimale : seuls les hooks du template manquants sont ajoutés ;
    # le reste de la config existante (permissions, modèle, plugins...) n'est pas touché.
    MERGED=$(mktemp 2>/dev/null || echo "$CLAUDE_DIR/.settings-merge.$$")
    merged=false
    if command -v python3 >/dev/null 2>&1 && python3 -I -c 'import json' >/dev/null 2>&1; then
        rc=0
        python3 -I - "$TARGET" "$TEMPLATE" "$MERGED" <<'PY' || rc=$?
import json, sys
cur = json.load(open(sys.argv[1], encoding="utf-8"))
tpl = json.load(open(sys.argv[2], encoding="utf-8"))
changed = False
hooks = cur.setdefault("hooks", {})
for event, entries in tpl.get("hooks", {}).items():
    lst = hooks.setdefault(event, [])
    have = {h.get("command") for e in lst for h in e.get("hooks", [])}
    for e in entries:
        if not all(h.get("command") in have for h in e.get("hooks", [])):
            lst.append(e)
            changed = True
if not changed:
    sys.exit(3)  # déjà à jour
with open(sys.argv[3], "w", encoding="utf-8") as f:
    json.dump(cur, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY
        [ $rc -eq 0 ] && merged=true
        [ $rc -eq 3 ] && merged=same
    elif command -v jq >/dev/null 2>&1; then
        jq -s '.[0] as $c | .[1] as $t
          | $c | .hooks = (reduce ($t.hooks | keys[]) as $e (($c.hooks // {});
              .[$e] = ((.[$e] // []) as $cur
                | ($cur | [.[].hooks[]?.command]) as $have
                | $cur + [$t.hooks[$e][] | select([.hooks[]?.command] | all(. as $x | ($have | any(. == $x)) | not))])))' \
          "$TARGET" "$TEMPLATE" > "$MERGED" && merged=true
        # JSON équivalent (clés triées) = rien à faire
        if $merged && [ "$(jq -S . "$MERGED")" = "$(jq -S . "$TARGET")" ]; then merged=same; fi
    fi
    if [ "$merged" != false ]; then
        if [ "$merged" = same ]; then
            ok "settings.json déjà à jour"
        else
            cp "$TARGET" "$TARGET.bak-$TS"
            cp "$MERGED" "$TARGET"
            ok "hooks fusionnés dans settings.json (backup : $TARGET.bak-$TS)"
        fi
    elif command -v python3 >/dev/null 2>&1 || command -v jq >/dev/null 2>&1; then
        err "settings.json illisible (JSON invalide ?) — non modifié, fusionne à la main avec $TEMPLATE"
    else
        cp "$TARGET" "$TARGET.bak-$TS"
        warn "ni python3 ni jq : settings.json NON modifié (backup : $TARGET.bak-$TS)"
        warn "ajoute à la main les hooks de $TEMPLATE, ou installe python3/jq puis relance"
    fi
    rm -f "$MERGED"
fi
# Purge des vieux backups (install.sh tourne à chaque mise à jour du repo)
find "$CLAUDE_DIR" -maxdepth 1 -name "settings.json.bak-*" -mtime +30 -delete 2>/dev/null || true
find "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/commands" -maxdepth 1 -name "*.bak-*" -mtime +30 -delete 2>/dev/null || true
find "$HOME" -maxdepth 1 -name "CLAUDE.md.bak-*" -mtime +30 -delete 2>/dev/null || true

# ── 6. Plugins externes (opt-in) ───────────────────────────────────────────
echo "[5/5] Plugins externes..."
if ! $WITH_PLUGINS; then
    ok "ignorés (relancer avec --plugins pour installer ponytail, playwright, security-guidance, frontend-design)"
elif ! command -v claude >/dev/null 2>&1; then
    warn "CLI claude introuvable dans le PATH — plugins non installés"
else
    for repo in DietrichGebert/ponytail anthropics/claude-plugins-official; do
        claude plugin marketplace add "$repo" >/dev/null 2>&1 || warn "marketplace $repo : échec (réseau ?)"
    done
    fail=0
    for p in ponytail@ponytail playwright@claude-plugins-official security-guidance@claude-plugins-official frontend-design@claude-plugins-official; do
        claude plugin install "$p" >/dev/null 2>&1 || fail=$((fail+1))
        claude plugin enable "$p" >/dev/null 2>&1 || true
    done
    if [ $fail -gt 0 ]; then err "$fail plugin(s) en échec d'installation"; else ok "plugins installés et activés"; fi
fi

# ── Résumé ─────────────────────────────────────────────────────────────────
if $QUIET; then
    if [ $ERRORS -eq 0 ]; then echo "✓ sync OK" >&3; else echo "⚠ sync : $ERRORS erreur(s) (voir stderr)" >&3; fi
else
    echo ""
    [ -f "$CONTEXT_DIR/PROJECTS.md" ] || echo "  Prochaine étape : lance Claude Code dans un terminal et suis INTERVIEW.md pour générer tes fichiers perso."
    if [ $ERRORS -eq 0 ]; then echo "  Installation terminée sans erreur"; else echo "  Installation terminée avec $ERRORS erreur(s)"; fi
fi
[ $ERRORS -eq 0 ]
