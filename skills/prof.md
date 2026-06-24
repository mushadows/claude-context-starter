Active le mode professeur pour générer ou mettre à jour les cours Obsidian.

## Arguments : `$ARGUMENTS`

Sans argument → lister les matières disponibles et demander laquelle traiter.
Avec argument → traiter la matière nommée (ex: `/prof algo`, `/prof réseau`).

## Prérequis

Ce skill suppose qu'Obsidian est configuré avec un vault dans `~/dev/obsidian-vault/` (Linux/Mac)
ou `C:/Users/[user]/Documents/Obsidian/` (Windows).
Adapter le chemin si différent (voir CLAUDE.local.md ou CONF.md).

## Étapes

### 1. Charger le contexte professeur
Lire `~/dev/my-context/contexts/ctx-professor.md` si présent — contient les règles de génération, le format des 5 fichiers, les conventions.
Si absent, utiliser les règles de base ci-dessous.

### 2. Localiser la matière
```bash
ls ~/dev/obsidian-vault/Cours/
```
Trouver le dossier correspondant à la matière demandée (tolérer la casse et les variantes).

Si la matière n'existe pas → la créer :
```bash
mkdir -p ~/dev/obsidian-vault/Cours/[Matière]/notes
```

### 3. Lire les notes brutes
```bash
ls ~/dev/obsidian-vault/Cours/[Matière]/notes/
```
Lire tous les fichiers `.md` et `.pdf` présents dans `notes/`.
**Ne jamais modifier les fichiers dans `notes/` — lecture seule.**

### 4. Vérifier l'état des fichiers générés
```bash
ls ~/dev/obsidian-vault/Cours/[Matière]/
```
Chercher : `[préfixe]-cours.md`, `[préfixe]-exercices.md`, `[préfixe]-express.md`, `[préfixe]-quiz.md`, `[préfixe]-schemas.md`

- **Aucun fichier généré** → générer les 5 fichiers depuis les notes
- **Fichiers existants + nouvelles notes** → mettre à jour les fichiers existants
- **Fichiers complets + aucune note nouvelle** → informer que tout est à jour, rien à faire

### 5. Générer les 5 fichiers

**Format des 5 fichiers** (toujours lowercase, un seul jeu par dossier) :
- `[préfixe]-cours.md` — cours structuré avec exemples concrets
- `[préfixe]-exercices.md` — exercices progressifs avec corrections repliées
- `[préfixe]-express.md` — fiche révision rapide (< 1 page)
- `[préfixe]-quiz.md` — QCM + questions ouvertes avec réponses repliées
- `[préfixe]-schemas.md` — schémas Mermaid des concepts clés

Créer `Main_[Matière].md` avec liens vers les 5 fichiers si absent.

### 6. Commiter et pusher
```bash
git -C ~/dev/obsidian-vault add Cours/[Matière]/
git -C ~/dev/obsidian-vault commit -m "prof: génération cours [Matière] $(date +%Y-%m-%d)"
git -C ~/dev/obsidian-vault push
```
