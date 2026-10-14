# core.md — Contexte Claude Code
> Chargé à chaque session (via `~/CLAUDE.md` → `@dev/claude-context/core.md`). Ce fichier est générique et versionné : ne jamais y écrire de données personnelles (elles vont dans `CLAUDE.local.md`, ignoré par git).
## Première session (NON NÉGOCIABLE)
Si `CLAUDE.local.md` (dossier du repo) est absent ou contient encore `SETUP_REQUIRED` → ne pas dérouler la checklist plus bas : lire `INTERVIEW.md` et l'exécuter avant toute autre tâche.
## Profil, langue, préférences
@CLAUDE.local.md
Défauts si non précisé : français avec accents, identifiants de code en anglais.
## Modèle
`settings-template.json` fixe des **alias** (`"model": "sonnet"`, `"advisorModel": "opus"`) : toujours la dernière version, jamais un ID figé qui deviendrait obsolète. Appliqué par `install.sh` sur un `settings.json` neuf ; sur un `settings.json` existant, seuls les hooks sont fusionnés (le reste est à régler à la main).
## Ponytail — philosophie de code (recommandé, optionnel)
Plugin `ponytail` (`install.sh --plugins`). Échelle de décision avant d'écrire du code :
1. Nécessaire (YAGNI) ? 2. Déjà dans le codebase ? 3. Stdlib ? 4. Fonction native ? 5. Dépendance déjà installée ? 6. Une ligne ? 7. Sinon le minimum qui marche.
Ne jamais sacrifier : compréhension du problème, validation aux frontières, gestion d'erreur anti-perte de données, sécurité, accessibilité, ce qui est demandé. Bug = cause racine (grep les appelants). Raccourci volontaire = commentaire `shortcut: <limite>, <quand améliorer>`.
## Multi-OS (NON NÉGOCIABLE)
Tout script, hook ou snippet bash doit fonctionner sur Linux ET Windows (Git Bash) si la machine l'exige :
- Détecter l'OS si le comportement diffère (`case "${OSTYPE:-}" in msys*|cygwin*|win*) ... esac`)
- Pas de `/dev/stdin` (Git Bash) ; options GNU non portables à éviter ou protéger (`date -d`, `stat -c`, `find -printf`, `xargs -d`, `hostname -s`)
- Variables env Claude Code : `${VAR:-default}` avec `set -u` ; dossiers utilisateur variables selon l'OS (`Downloads`/`Téléchargements`)
- `sudo`/`systemctl`/gestionnaires de paquets : Linux seulement, isolés explicitement
- Ne jamais conclure « ça passe » sur Windows si testé uniquement sur Linux ; doute → skip OS explicite plutôt qu'un `|| true` silencieux qui masque les bugs
## Autonomie
Exécuter sans demander confirmation, informer après coup en une ligne. Préférence dans `CLAUDE.local.md` (défaut : autonomie totale sur les repos perso).
- **Repos perso** : commit et push directement.
- **Repos sensibles** (marqués `Sensible : oui` dans `PROJECTS.md` : scolaire, entreprise, tiers) : lecture seule — jamais `add`/`commit`/`push`/`stash`/`merge`/`rebase` ; `pull`/`fetch` autorisés ; modifier des fichiers seulement sur demande explicite. L'état du projet va dans `etat/[projet].md`, jamais dans le repo.
- **Repo inconnu ou nouveau** : demander « Ce projet est-il sensible ? » avant tout commit/push.
- `git add`/`commit` bloqué parce que le diff contient un secret en clair : pas de contournement, laisser en local et prévenir.
- Un refus du classifieur de permissions prime sur cette autonomie : ne pas boucler (max 1-2 essais), écrire un script et passer la main.
- Tout ajout au workflow (plugin, config) doit être auto-synchronisable : fichier versionné ou étape dans `install.sh`.
## Modules context
Lire le module du projet actif avant toute intervention (dans `contexts/ctx-[nom].md`).
| cwd | Modules à charger |
|---|---|
| tout projet de code | ctx-dev |
| projet dont `contexts/ctx-[nom du dossier].md` existe | ctx-dev + ctx-[projet] |
| fallback | attendre `/ctx [module]` |
Nouveau module : créer `contexts/ctx-[nom].md` (nom = nom du dossier du projet) ; aucune ligne à ajouter ici. Les modules perso sont ignorés par git.
## Skills — utilisation proactive
Avant de traiter une tâche à la main, proposer le skill adapté (une phrase, avant de commencer) :
| Situation | Skill |
|---|---|
| Tâche multi-dimensions (audit, refonte, migration) | `/orchestre [tâche]` — subagents en parallèle + vérification |
| Projet actif sans contexte chargé | `/ctx [module]` |
| Fin de session avec modifications | `/bilan` — clôture + `etat/[projet].md` |
| « Où en est le projet », reprise | `/etat` |
| Avant une grosse tâche ou contexte incertain | `/check` ; `/context-check` pour auditer ce repo |
| Déploiement d'un projet | `/deploy [projet]` |
| Début de journée | `/today` |
| Nouveau service avec auth/API, ou changement touchant auth/secrets/endpoints | `/security-audit [projet]` — proactif, sans attendre la demande |
| Après un fix sécurité | `/pentest-self [projet]` — jamais destructif, jamais hors de tes propres services |
| Mise à jour du contexte | `/refresh` |
Tâche répétitive sans skill → proposer d'en créer un (`skills/[nom].md` + `bash install.sh`). Besoin générique couvert par la stack → chercher un skill communautaire, lire son `SKILL.md` en entier avant d'installer, jamais sur un repo sensible. Scope explicite : projet (défaut, confine le risque) pour un skill lié à la stack d'un repo, global (`-g`) seulement pour un outil transversal, après confirmation.
## Checklist début de session (silencieuse)
1. Le hook `session-start` met le repo à jour en arrière-plan (`git pull --ff-only`) ; en cas d'échec, `~/.local/share/claude/last-session.log` le dit. Informer si mises à jour.
2. Vérifier que `~/CLAUDE.md` contient `@dev/claude-context/core.md` — corriger sinon
3. Cloner les projets de `PROJECTS.md` absents sur la machine (section `###` avec chemin entre backticks + ligne `Repo :`)
`/refresh` et `/today` : à la demande uniquement, jamais automatiques.
## Erreurs à ne pas reproduire
- `git pull` avant de modifier un fichier dans un repo git
- Symlinks : `readlink -f` avant tout Edit/Write (refus d'écrire à travers un symlink)
- PowerShell : `$ErrorActionPreference = 'Stop'` + `2>&1` sur une commande native transforme chaque ligne stderr (git écrit sa progression dessus) en erreur terminante — assouplir localement. Ne pas détecter l'OS via `$OSTYPE` depuis l'outil Bash (presque toujours Git Bash)
- `pkill -f`/`pgrep -f` dont le motif figure dans sa propre ligne de commande tue son propre shell → fichier PID + `kill -0`, ou `ps -eo pid,args | awk '/motif/ && !/awk/'`
- Docker bind mount sur fichier individuel → monter le dossier parent (inode stale si recréé) ; `docker restart` ne recharge pas une image rebuild → `stop && rm && run`
- Édition manuelle d'un fichier de config d'outil : le relire après le restart du service (certains restarts effacent silencieusement des clés)
- Docker : build avec layer cache suspect (fonctions ajoutées, résultat périmé) → `--no-cache`
- Ne jamais déplacer automatiquement des dossiers de `~/` sans confirmation : signaler seulement
- Erreur transversale → `CLAUDE.local.md` ; erreur propre à un projet → `ctx-[projet].md`
## Fichiers context
`CLAUDE.local.md` (profil, habitudes, erreurs) · `CONF.md` (machine, outils) · `PROJECTS.md` (projets) · `RULES_GENERIC.md` / `RULES_LANGAGES.md` (conventions de code, chargées via `ctx-dev`) · `etat/` (états par projet)
