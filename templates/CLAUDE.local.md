# CLAUDE.local.md — Profil détaillé et habitudes
> Spécifique à l'utilisateur, ignoré par git, importé par `core.md` à chaque session. Rempli par `INTERVIEW.md`.
## Profil
- Nom : SETUP_REQUIRED — GitHub : SETUP_REQUIRED — Email : SETUP_REQUIRED
- OS : SETUP_REQUIRED — Shell : SETUP_REQUIRED — Éditeur : SETUP_REQUIRED
- Dossier des projets : SETUP_REQUIRED (défaut `~/dev/`)
- Langue : SETUP_REQUIRED (défaut : français, accents obligatoires)
- Autonomie : SETUP_REQUIRED (défaut : exécuter sans confirmation, push direct sur les repos perso)
## Conventions de code
- Écarts par rapport à `RULES_GENERIC.md` / `RULES_LANGAGES.md` (ne pas modifier ces fichiers : ils sont versionnés) : SETUP_REQUIRED
## Habitudes
- SETUP_REQUIRED (ex : valide chaque changement individuellement, minimise les dépendances)
## Mise à jour du context (automatique, sans attendre de demande)
| Événement | Fichier |
|---|---|
| Problème système résolu / outil changé | `CONF.md` |
| Projet créé ou archivé | `PROJECTS.md` |
| Règle de code corrigée | `RULES_GENERIC.md` / `RULES_LANGAGES.md` |
| Erreur transversale | section « Erreurs » ci-dessous |
| Erreur propre à un projet | `contexts/ctx-[projet].md` |
## Spécificités OS
Garder uniquement la section de la machine.
### Linux
- Détection : `[[ "${OSTYPE:-}" != msys* && "${OSTYPE:-}" != cygwin* ]]`
- Home `~/`, projets `SETUP_REQUIRED` ; `sudo` / gestionnaire de paquets autorisés selon `CONF.md`
### Windows (Git Bash)
- Détection : `case "${OSTYPE:-}" in msys*|cygwin*|win*)`
- Pas de `/dev/stdin` ; lancer `install.sh` depuis Git Bash ; symlinks : mode développeur ou copie de repli ; `.gitattributes` `*.sh text eol=lf`
## Erreurs à ne pas reproduire
(transversales uniquement — les autres vont dans `ctx-[projet].md`)
