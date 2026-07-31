---
description: Charge un contexte particulier (un projet, un domaine) dans la conversation.
---

# /ctx — Charger un contexte

Sert à dire à Claudia « on va parler de X, prépare-toi ». Elle va lire le fichier de contexte correspondant pour être au point.

## Préparation

Toujours en tête de skill :

```bash
source "$CLAUDIA_HOME/lib/paths.sh"
```

Les contextes vivent dans `$CLAUDIA_HOME/contexts/` — un fichier `ctx-[nom].md` par projet ou domaine.

## Comportement

**Sans argument :**

Lister les contextes disponibles :

```bash
ls "$CLAUDIA_HOME/contexts/"ctx-*.md 2>/dev/null
```

Afficher chaque contexte avec une ligne de description (prise du fichier). Si le dossier où on est correspond à un projet connu, le signaler :

> « Tu veux qu'on parle de quoi ? Voilà ce que je connais : *[liste]*. »

**Avec argument (ex: `/ctx cuisine`) :**

1. Trouver le fichier correspondant (tolérer fautes et variantes)
2. Le lire depuis `$CLAUDIA_HOME/contexts/ctx-[nom].md`
3. Confirmer en une ligne : *« C'est bon, je suis dans le contexte [nom]. »*

**Si le contexte demandé n'existe pas :**

> « Je n'ai rien sur *[nom]*. J'ai ça : *[liste courte]*. Tu veux que je crée un contexte pour *[nom]* ? »

Si oui → créer un fichier de base `$CLAUDIA_HOME/contexts/ctx-[nom].md` avec une trame courte (nom, description, notes) et le confirmer.
