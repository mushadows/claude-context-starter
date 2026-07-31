---
description: Mode professeur — génère ou met à jour des fiches de cours à partir de tes notes brutes (nécessite un vault Obsidian configuré).
---

# /prof — Mode cours

Sert à transformer des notes brutes de cours en fiches propres (cours, exercices, fiche rapide, quiz, schémas).

## Préparation

```bash
source "$CLAUDIA_HOME/lib/paths.sh"
```

**Vérification vault Obsidian :**

```bash
if [ -z "${VAULT_DIR:-}" ] || [ ! -d "$VAULT_DIR" ]; then
    echo "not_configured"
fi
```

Si pas de vault configuré → dire à la personne :

> « Pour ce mode, j'ai besoin de savoir où sont tes notes de cours (un dossier Obsidian par exemple). Dis-moi le chemin et je le note. »

Attendre le chemin, puis proposer de l'enregistrer dans `$CLAUDIA_HOME/profil.md` (à la ligne outil « Prise de notes » ou zone dédiée) pour que ce soit permanent. Ne pas planter, ne pas continuer tant que ce n'est pas défini.

## Arguments : `$ARGUMENTS`

- Sans argument → lister les matières trouvées et demander laquelle traiter
- Avec argument → traiter la matière nommée (ex: `/prof algo`)

## Étapes

### 1. Charger les règles du mode prof

Lire `$CLAUDIA_HOME/contexts/ctx-professor.md` si présent — il contient les règles de génération, le format, les conventions.
Si absent, utiliser les règles de base ci-dessous.

### 2. Trouver la matière

```bash
ls "$VAULT_DIR/Cours/" 2>/dev/null
```

Repérer le dossier qui correspond (tolérer casse et variantes).

Si la matière n'existe pas encore, la créer :

```bash
mkdir -p "$VAULT_DIR/Cours/[Matière]/notes"
```

### 3. Lire les notes brutes

```bash
ls "$VAULT_DIR/Cours/[Matière]/notes/"
```

Lire tous les fichiers `.md` et `.pdf` présents dans `notes/`.
**Ne jamais modifier les fichiers de `notes/` — c'est de la lecture seule, ce sont tes notes originales.**

### 4. Regarder ce qui est déjà généré

```bash
ls "$VAULT_DIR/Cours/[Matière]/"
```

Chercher : `[préfixe]-cours.md`, `[préfixe]-exercices.md`, `[préfixe]-express.md`, `[préfixe]-quiz.md`, `[préfixe]-schemas.md`

- **Aucun fichier généré** → générer les 5 fichiers depuis les notes
- **Fichiers existants + nouvelles notes** → mettre à jour
- **Fichiers complets + rien de neuf** → informer que tout est à jour, ne rien faire

### 5. Générer les 5 fichiers

Toujours en minuscules, un seul jeu par dossier :
- `[préfixe]-cours.md` — cours structuré avec exemples concrets
- `[préfixe]-exercices.md` — exercices progressifs avec corrections repliées
- `[préfixe]-express.md` — fiche révision rapide (< 1 page)
- `[préfixe]-quiz.md` — QCM + questions ouvertes avec réponses repliées
- `[préfixe]-schemas.md` — schémas Mermaid des concepts clés

Créer `Main_[Matière].md` avec liens vers les 5 fichiers si absent.

### 6. Sauvegarder

Si le vault a une sauvegarde configurée (dossier suivi) → sauvegarder les nouveaux fichiers et informer en une ligne.
Sinon → ne rien faire, dire simplement : *« C'est prêt dans tes cours. »*

Ne jamais forcer une sauvegarde à distance sans que la personne l'ait activée.

<!-- TODO: décision à valider — où stocker VAULT_DIR de façon permanente une fois donné par la personne (profil.md, variable env, ou paths.sh) -->
