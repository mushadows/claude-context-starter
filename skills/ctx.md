Charge manuellement un module de context dans la session courante.
## Source des modules
Dossier : `le dossier `contexts/` du repo de contexte`, fichiers `ctx-[nom].md`.
La liste des modules disponibles et leur routage par cwd sont dans le tableau « Modules context » de `core.md` — c'est la source de vérité. Ne pas dupliquer de liste figée ici.
## Comportement
**Arguments :** `$ARGUMENTS`
**Sans argument :**
1. Lister les fichiers `contexts/ctx-*.md` (nom + première ligne de description de chacun).
```bash
CTX="$(cat "$HOME/.claude/context-dir" 2>/dev/null || echo "$HOME/dev/claude-context")"
for f in "$CTX"/contexts/ctx-*.md; do [ -e "$f" ] && echo "$(basename "$f" .md | sed 's/^ctx-//') — $(grep -m1 -v '^#\|^$\|^>' "$f")"; done
```
2. Indiquer le module détecté automatiquement selon le cwd (via le tableau de `core.md`), si applicable.
**Avec argument :**
1. Identifier le module demandé (tolérer les fautes de frappe : choisir le nom le plus proche parmi les fichiers existants).
2. Lire `ctx-[nom].md`, ainsi que les modules associés indiqués pour ce nom dans le tableau de `core.md` (ex. un module projet + `ctx-dev`).
3. Confirmer en une ligne : « Contexte [module] chargé. »
**Module inexistant :** lister les modules disponibles et suggérer le plus proche. Si aucun module ne convient, proposer d'en créer un à partir de `templates/`.
