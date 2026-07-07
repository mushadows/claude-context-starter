Clôture de session : résumé, mise à jour ETAT.md, push des repos modifiés.

## Étapes (dans cet ordre)

### 1. Résumé de session
Produire un résumé en exactement 3 bullets de ce qui a été fait dans cette session.
Format :
```
- [action concrète] — [fichier ou composant concerné]
- ...
- ...
```
Pas de bla-bla, pas de verbe "nous avons" — des faits directs.

### 2. Mise à jour ETAT.md
```bash
pwd
ls ETAT.md 2>/dev/null
```
Si `ETAT.md` existe dans le cwd courant :
- Mettre à jour la section **Dernière session** avec la date du jour et le résumé ci-dessus
- Mettre à jour **En cours** : retirer les tâches terminées, ajouter les nouvelles
- Mettre à jour **Prochaine étape** selon ce qui reste
- Mettre à jour **Décisions architecturales** si de nouvelles décisions ont été prises
- Commiter : `git add ETAT.md && git commit -m "chore(etat): mise à jour session $(date +%Y-%m-%d)"`

### 3. Mise à jour du ctx projet

Identifier le projet actif depuis le cwd (ex: `~/dev/[projet]/` → `ctx-[projet].md`).

Relire mentalement la session et extraire ce qui mérite d'être capturé dans le ctx :
- Décisions techniques prises (choix d'implémentation, pattern retenu, alternative écartée)
- Contraintes découvertes (bug contourné, limite d'une lib, comportement inattendu)
- Nouveaux patterns ou conventions établis
- État d'avancement significatif (feature terminée, module intégré, blocage levé)

Si au moins un item est identifié et que le module `ctx-[projet].md` existe :
- Lire `~/dev/my-context/contexts/ctx-[projet].md`
- Mettre à jour les sections concernées (ne pas tout réécrire — cibler les deltas)
- `git -C ~/dev/my-context add contexts/ctx-[projet].md && git commit -m "ctx([projet]): mise à jour session $(date +%Y-%m-%d)"`

Si rien de nouveau à capturer, ou si le module ctx n'existe pas encore → passer sans commenter.

**Ne pas capturer :** ce qui est déjà dans ETAT.md, les détails de debug éphémères, les décisions qui seront visibles dans le code.

### 4. Propagation mémoire → context

Relire la session et les fichiers mémoire créés ou modifiés (`memory/`). Pour chaque règle comportementale nouvelle ou mise à jour, décider si elle doit être propagée dans le context :

**Critères de propagation (au moins un) :**
- Règle sur l'autonomie ou les permissions (push, commit, confirmation)
- Règle sur le comportement systématique (toujours faire X, ne jamais faire Y)
- Préférence structurante qui s'applique à toutes les sessions futures

**Si propagation nécessaire :**
- Règle d'autonomie / permissions → `core.md` section "Autonomie"
- Comportement technique ou erreur à éviter → `CLAUDE.local.md` section "Erreurs à ne pas reproduire"
- Mettre à jour le fichier, commiter dans `my-context`

**Si rien à propager** → passer sans commenter.

La mémoire (`memory/`) reste un complément — le context (`core.md`, `CLAUDE.local.md`) est la source de vérité pour les règles critiques.

### 5. Push des repos modifiés
```bash
git -C ~/dev/my-context status --porcelain
```
- Si `my-context` a des changements non pushés → `git -C ~/dev/my-context push`
- Pour tout autre repo modifié pendant la session (ex: `obsidian-vault` si configuré) → informer et demander confirmation avant push
- Informer en une ligne de ce qui a été pushé (ou rien si tout était propre)

### 6. Conseil de compaction
Estimer si le contexte de la session est long (nombreux fichiers lus, beaucoup d'éditions).
Si oui → suggérer : "Contexte potentiellement chargé — envisager `/compact` avant la prochaine tâche lourde."
Sinon → ne rien dire sur ce point.
