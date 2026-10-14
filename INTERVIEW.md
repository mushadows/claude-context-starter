# INTERVIEW.md — Configuration initiale (première session)
> Lu uniquement si `CLAUDE.local.md` est absent ou contient des `SETUP_REQUIRED` (règle « Première session » de `core.md`). Ensuite la checklist normale reprend. Ne jamais modifier `core.md`, `RULES_*.md` ni `contexts/ctx-dev.md` : fichiers versionnés, mis à jour par `git pull`.

## Règles
- Utilisateur = développeur : vocabulaire technique direct, pas de pédagogie.
- Détecter ce qui est détectable (`uname`, `$OSTYPE`, `$SHELL`, `git config --global user.name/email`, `command -v code nvim`, `gh api user -q .login`) et proposer la valeur détectée comme défaut. Ne demander que le reste.
- Questions groupées (une seule réponse libre possible), valeur par défaut proposée à chaque fois. « Passe » = défaut, jamais de blocage.
- Écrire les fichiers au fil des réponses ; ne pas montrer leur contenu brut.

## Questions (8 max)
1. **Identité Git** : nom, email de commit, compte GitHub/GitLab. Si le forge refuse l'email réel au push (protection email), utiliser l'adresse noreply fournie par le forge.
2. **Machine** : OS, shell, éditeur/IDE, terminal (détectés d'abord). Windows → Git Bash requis pour `install.sh`.
3. **Langages et stack** : langages principaux, frameworks, outils (Docker, DB, cloud…).
4. **Projets actifs** : nom, chemin local, URL du repo, stack en une ligne, et pour chacun **sensible ou non** (scolaire, entreprise, repo d'un tiers → lecture seule, jamais de commit/push).
5. **Dossier des projets** : défaut `~/dev/`. Ne rien déplacer automatiquement dans `~/`.
6. **Langue et style de réponse** : langue (défaut français avec accents), concision (défaut : action d'abord, sans préambule ni récap), commentaires de code (défaut : seulement le « pourquoi » non évident).
7. **Autonomie** : défaut = exécuter sans confirmation et informer après coup, push direct sur les repos perso. Alternative : confirmer avant tout push.
8. **Conventions de code** : indentation, nommage, style d'accolades (défauts : ceux de la stack, ou ceux déjà visibles dans les projets listés — lire un projet existant avant de demander).

## Fichiers à produire
| Fichier | Contenu | Source |
|---|---|---|
| `CLAUDE.local.md` | Créé depuis `templates/CLAUDE.local.md` : profil (Q1-2, Q5), langue/style (Q6), autonomie (Q7), conventions (Q8), habitudes, section OS correspondante : remplacer **tous** les `SETUP_REQUIRED` | `templates/CLAUDE.local.md` |
| `PROJECTS.md` | Une section `###` par projet avec chemin entre backticks, `Repo :`, `Stack :`, `Sensible : oui/non` (Q4) | `templates/PROJECTS.md` |
| `CONF.md` | OS, shell, éditeur, outils détectés, stack (Q2-3) | `templates/CONF.md` |
| `contexts/ctx-[projet].md` | Un par projet non trivial, nommé comme le dossier du projet (optionnel, `contexts/README.md`, ignoré par git) | `contexts/ctx-projet.template.md` |
| `etat/` | Créer le dossier ; un `etat/[projet].md` par projet depuis `templates/etat-template.md` | `templates/etat-template.md` |
Projet sensible : mettre `Sensible : oui` dans `PROJECTS.md` et, si `settings-template.json` contient des chemins protégés, les y renseigner puis relancer `install.sh`.

## Fin d'interview
1. `~/CLAUDE.md` contient `@dev/claude-context/core.md` (sinon le créer/corriger, ne jamais ajouter d'autres imports).
2. `grep -rn SETUP_REQUIRED PROJECTS.md CONF.md CLAUDE.local.md` ne renvoie rien ; `etat/` existe (hors question volontairement ignorée, à signaler).
3. Fichiers personnels (`PROJECTS.md`, `CONF.md`, `CLAUDE.local.md`, `etat/`) : ne jamais les committer dans le repo public d'origine. Proposer de pointer `origin` vers un repo privé de l'utilisateur, sinon laisser en local.
4. Résumé en 5 lignes max : ce qui est configuré, comment relancer (`cd ~ && claude`), prochaine action (`/ctx dev` ou `/etat`).

## Interview interrompue
Relire `CLAUDE.local.md`, `PROJECTS.md`, `CONF.md`, ne reposer que les questions dont un `SETUP_REQUIRED` subsiste. Jamais une question dont la réponse est déjà écrite.
