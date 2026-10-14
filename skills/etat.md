Affiche et gère le fichier d'état (ETAT.md) du projet courant.
## Comportement
Variable : `CTX="$(cat "$HOME/.claude/context-dir" 2>/dev/null || echo "$HOME/dev/claude-context")"`.
**Déterminer le projet actif :** le repo git dans le cwd (`basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"`).
**Vérifier si le projet est en lecture seule** : consulter `$CTX/PROJECTS.md` (et `core.md`, section « Autonomie ») — un projet marqué lecture seule / commit interdit ne doit jamais recevoir de fichier ni de commit.
- Projet en lecture seule → lire `$CTX/etat/[projet].md` et afficher son contenu. Ne jamais créer ni modifier de fichier dans le repo, ne jamais committer. Si le fichier d'état n'existe pas, le créer uniquement dans `$CTX/etat/`.
**Si `ETAT.md` existe dans le cwd (projets modifiables) :**
1. Lire et afficher son contenu complet.
2. Proposer une mise à jour : « Mettre à jour ETAT.md avec la session courante ? (résumé, décisions, prochaine étape) »
3. Si confirmé → mettre à jour les sections pertinentes sans effacer les décisions architecturales existantes.
**Si `ETAT.md` est absent (projets modifiables) :**
1. Lire le template `$CTX/templates/etat-template.md` (s'il manque, utiliser les sections : Dernière session, En cours, Prochaine étape, Décisions architecturales, Déploiement).
2. Explorer le repo pour le remplir : `git log --oneline -10`, `ls`, `README.md`, et le module `$CTX/contexts/ctx-[projet].md` s'il existe.
3. Générer un `ETAT.md` complet et réaliste (pas de placeholders vides) dans le cwd.
4. Committer : `git add ETAT.md && git commit -m "chore: add ETAT.md"`.
**Arguments :** `$ARGUMENTS`
- Sans argument → comportement par défaut ci-dessus
- `update` → forcer la mise à jour même si le fichier est récent
- `create` → forcer la création (écraser si existant, après confirmation)
