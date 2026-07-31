---
description: Clôture propre d'une session : résumé, mise à jour du fichier d'avancement, sauvegarde si prévue.
---

# /bilan — On arrête là

Sert à ranger avant de fermer : Claudia résume ce qu'on a fait, met à jour la mémoire du projet, et sauvegarde si la personne l'a demandé.

## Préparation

```bash
source "$CLAUDIA_HOME/lib/paths.sh"
```

## Étapes (dans cet ordre)

### 1. Résumé de session

3 bullets, faits directs, pas de « nous avons » :

```
- [action concrète] — [fichier ou sujet]
- ...
- ...
```

### 2. Mise à jour du fichier d'avancement

```bash
pwd
ls ETAT.md 2>/dev/null
```

Si `ETAT.md` existe dans le dossier où on est :
- **Dernière session** → date du jour + résumé ci-dessus
- **En cours** → retirer ce qui est terminé, ajouter le nouveau
- **Prochaine étape** → selon ce qui reste
- **Décisions** → ajouter les nouvelles décisions prises

Ne rien sauvegarder à distance à moins que la personne l'ait activé pour ce projet (voir profil).

### 3. Mise à jour du contexte projet

Identifier le contexte projet actif (dossier courant → `ctx-[projet].md`).

Repérer dans la session ce qui mérite d'être capturé :
- Décisions prises (choix, alternatives écartées)
- Contraintes découvertes (problème contourné, comportement inattendu)
- Nouvelles conventions établies
- Étapes importantes franchies

Si au moins un item est identifié et que `$CLAUDIA_HOME/contexts/ctx-[projet].md` existe :
- Le lire
- Mettre à jour les sections concernées (viser les vrais changements, pas tout réécrire)

Si rien de neuf, ou si le contexte n'existe pas encore → passer sans commenter.

**Ne pas capturer :** ce qui est déjà dans `ETAT.md`, les détails de débogage jetables, les décisions déjà visibles dans les fichiers.

### 4. Remontée mémoire → contexte général

Relire la session. Pour chaque règle de comportement nouvelle, décider si elle doit remonter dans le contexte général :

**Critères (au moins un) :**
- Règle sur l'autonomie ou les permissions (sauvegarder, demander avant, etc.)
- Règle systématique (toujours faire X, ne jamais faire Y)
- Préférence structurante qui vaut pour toutes les sessions

**Si oui :**
- Règle d'autonomie / permissions → `$CLAUDIA_HOME/core.md` section « Autonomie »
- Erreur à éviter → `$CLAUDIA_HOME/profil.md` ou `$CLAUDIA_HOME/memoire.md`
- Signaler ce qui est ajouté en une ligne (règle Claudia : jamais silencieusement)

**Si rien à remonter** → passer.

### 5. Sauvegarde (si prévue)

Vérifier si la personne a activé la sauvegarde automatique pour Claudia elle-même :

```bash
git -C "$CLAUDIA_HOME" status --porcelain 2>/dev/null
```

- Si `$CLAUDIA_HOME` est suivi par une sauvegarde (git présent) et qu'il y a des changements → sauvegarder et informer en une ligne.
- Pour tout autre dossier modifié pendant la session → demander avant de sauvegarder.

Si rien n'est configuré → ne rien faire, ne pas insister.

### 6. Conseil de compaction

Si la session a été longue (beaucoup de fichiers lus, beaucoup d'éditions) → suggérer :

> « La conversation commence à être longue. Si tu veux, on peut nettoyer avec `/compact` avant la prochaine grosse tâche. »

Sinon → rien dire.
