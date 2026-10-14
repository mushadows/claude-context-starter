Clôture de session : résumé, mise à jour de l'état projet, capture des décisions, push des repos modifiés.
## Étapes (dans cet ordre)
Variable utilisée partout : `CTX="$(cat "$HOME/.claude/context-dir" 2>/dev/null || echo "$HOME/dev/claude-context")"`.
### 1. Résumé de session
Produire un résumé en exactement 3 bullets de ce qui a été fait dans cette session.
Format :
```
- [action concrète] — [fichier ou composant concerné]
- ...
- ...
```
Pas de bla-bla, pas de « nous avons » — des faits directs.
### 2. Mise à jour de l'état projet
Déterminer où vit l'état (même règle que `/etat`) :
```bash
CTX="$(cat "$HOME/.claude/context-dir" 2>/dev/null || echo "$HOME/dev/claude-context")"
PROJET=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
ls ETAT.md 2>/dev/null
ls "$CTX/etat/$PROJET.md" 2>/dev/null
```
- Projet marqué `Sensible : oui` (lecture seule) (pas de commit autorisé) dans `PROJECTS.md` → écrire uniquement dans `$CTX/etat/$PROJET.md`, ne rien créer ni modifier dans le repo du projet, ne jamais committer dedans.
- Sinon, si `ETAT.md` existe dans le cwd → le mettre à jour. S'il n'existe pas, utiliser `$CTX/etat/$PROJET.md`.
Dans le fichier d'état :
- Section **Dernière session** : date du jour + résumé ci-dessus
- **En cours** : retirer les tâches terminées, ajouter les nouvelles
- **Prochaine étape** : selon ce qui reste
- **Décisions architecturales** : ajouter les nouvelles décisions
Si c'est `ETAT.md` dans un repo autorisé en écriture : `git add ETAT.md && git commit -m "chore(etat): mise à jour session $(date +%Y-%m-%d)"`.
### 3. Mise à jour du module ctx projet
Identifier le module du projet (`$CTX/contexts/ctx-[projet].md`). Relire la session et extraire ce qui mérite d'être capturé :
- Décisions techniques (choix d'implémentation, pattern retenu, alternative écartée)
- Contraintes découvertes (bug contourné, limite d'une lib, comportement inattendu)
- Nouveaux patterns ou conventions
- Avancement significatif (feature terminée, blocage levé)
Si au moins un item : lire le module, mettre à jour uniquement les sections concernées (deltas, pas de réécriture), puis :
`git -C "$CTX" add contexts/ctx-[projet].md && git -C "$CTX" commit -m "ctx([projet]): mise à jour session $(date +%Y-%m-%d)"`
Si le module n'existe pas et que la session a produit du contenu durable, proposer de le créer. Sinon passer sans commenter.
**Ne pas capturer :** ce qui est déjà dans l'état projet, les détails de debug éphémères, les décisions visibles dans le code.
### 4. Propagation mémoire → context
Relire la session et les fichiers mémoire créés ou modifiés (`memory/`). Pour chaque règle comportementale nouvelle, décider si elle doit entrer dans le context.
**Critères (au moins un) :** règle d'autonomie/permissions · comportement systématique (toujours/jamais) · préférence structurante pour les sessions futures.
**Si propagation :**
- Autonomie / permissions → `core.md`, section « Autonomie »
- Piège technique / erreur à éviter → `CLAUDE.local.md`, section « Erreurs à ne pas reproduire »
- Mettre à jour le fichier puis committer dans `$CTX`.
Sinon passer sans commenter. La mémoire reste un complément ; le context est la source de vérité des règles critiques.
### 5. Push des repos modifiés
```bash
CTX="$(cat "$HOME/.claude/context-dir" 2>/dev/null || echo "$HOME/dev/claude-context")"
git -C "$CTX" status --porcelain
git -C "$CTX" log --oneline '@{u}..' 2>/dev/null
```
- Changements non commités ou commits non poussés dans `$CTX` → committer si besoin puis `git -C "$CTX" push` (selon les règles d'autonomie de `core.md`).
- Ne jamais pousser un repo marqué `Sensible : oui` (lecture seule) dans `PROJECTS.md`.
- Informer en une ligne de ce qui a été poussé (rien si tout était propre).
### 6. Conseil de compaction
Si le contexte de la session est probablement long (beaucoup de fichiers lus, beaucoup d'éditions) → suggérer : « Contexte potentiellement chargé — envisager `/compact` avant la prochaine tâche lourde. » Sinon ne rien dire.
