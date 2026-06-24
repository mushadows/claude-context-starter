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

### 3. Push des repos modifiés
```bash
git -C ~/dev/my-context status --porcelain
```
- Si `my-context` a des changements non pushés → `git -C ~/dev/my-context push`
- Pour tout autre repo modifié pendant la session → informer et demander confirmation avant push
- Informer en une ligne de ce qui a été pushé (ou rien si tout était propre)

### 4. Conseil de compaction
Estimer si le contexte de la session est long (nombreux fichiers lus, beaucoup d'éditions).
Si oui → suggérer : "Contexte potentiellement chargé — envisager `/compact` avant la prochaine tâche lourde."
Sinon → ne rien dire sur ce point.
