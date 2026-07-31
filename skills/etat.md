---
description: Regarde où on en est sur le projet en cours et met à jour la note d'avancement.
---

# /etat — Où on en est

Sert à retrouver le fil d'un projet : ce qui a été fait, ce qui reste, la prochaine étape. Le fichier s'appelle `ETAT.md` par convention — Claudia le pose dans le dossier du projet.

## Préparation

```bash
source "$CLAUDIA_HOME/lib/paths.sh"
```

## Comportement

**Repérer le projet actif :**

```bash
pwd
```

Le dossier où on est = le projet actif.

**Vérifier si le projet est marqué « sensible » :**

Regarder dans `$CLAUDIA_HOME/profil.md` ou `$CLAUDIA_HOME/core.md` si des projets sont marqués comme sensibles (interdiction de sauvegarder à la place de la personne).

- Si oui → lire le fichier d'avancement mais ne rien modifier ni sauvegarder. Se contenter d'afficher.

**Si `ETAT.md` existe dans le dossier :**

1. Lire et afficher son contenu.
2. Proposer : *« Tu veux que je le mette à jour avec ce qu'on vient de faire ? »*
3. Si oui → mettre à jour les sections concernées sans effacer les décisions déjà notées.

**Si `ETAT.md` est absent :**

1. Lire le modèle si présent : `$CLAUDIA_HOME/templates/etat-template.md`
2. Explorer le dossier pour remplir (lecture du README si présent, listing des fichiers, contexte du projet dans `$CLAUDIA_HOME/contexts/ctx-[projet].md`)
3. Écrire `ETAT.md` dans le dossier avec du concret, pas des trous à remplir
4. Le signaler : *« J'ai posé un fichier `ETAT.md` dans le dossier — c'est notre mémoire du projet. »*

Ne rien sauvegarder à distance sans demander, sauf si la personne a activé les sauvegardes automatiques pour ce projet.

## Arguments

- Sans argument → comportement par défaut
- `update` → forcer la mise à jour même si récent
- `create` → forcer la création (écrase l'existant, demander confirmation avant)
