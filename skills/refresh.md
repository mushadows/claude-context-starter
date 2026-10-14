# /refresh — Pull + sync + détection environnement
Met à jour le repo context, redéploie skills/hooks/settings, et détecte l'OS. À lancer en début de session ou avant `/today`. Pur sync, aucun jugement de qualité (`/check`) ni liste de tâches (`/today`).
À la demande uniquement — ne jamais lancer automatiquement.
## Comportement
**Arguments :** `$ARGUMENTS` (ignorés)
### Étape 1 — Pull + sync skills
```bash
CTX="$(cat "$HOME/.claude/context-dir" 2>/dev/null || echo "$HOME/dev/claude-context")"
[ -d "$CTX/.git" ] || { echo "Repo context introuvable : $CTX"; exit 1; }
result=$(git -C "$CTX" pull --ff-only 2>&1)
# install.sh : (re)crée les liens hooks/skills, nettoie les cassés
install_result=$(bash "$CTX/install.sh" --quiet 2>&1) || echo "$install_result"
# Liens cassés résiduels dans ~/.claude/commands/
for link in "$HOME"/.claude/commands/*.md; do
  [ -L "$link" ] && [ ! -e "$link" ] && rm -f "$link" && echo "cassé supprimé : $(basename "$link")"
done
case "$result" in *"Already up to date"*|*"Déjà à jour"*) echo "Repo à jour.";; *) echo "$result";; esac
```
Afficher en une ligne : `🔄 Repo à jour` ou `🔄 Mis à jour : [ce qui a changé]`. Si des liens cassés ont été nettoyés → ajouter `🔧 [N] skill(s) cassé(s) supprimé(s)`.
### Étape 2 — Détection de l'OS
```bash
case "${OSTYPE:-}" in
  msys*|cygwin*|win*) echo "OS: windows (Git Bash)";;
  darwin*) echo "OS: macos";;
  *) echo "OS: linux";;
esac
```
Retenir le résultat pour la session (chemins, commandes). Ne l'afficher que si inattendu.
### Sortie
Deux lignes maximum : résumé du sync, puis l'OS seulement s'il est inattendu.
