# core.md — Context Claude Code
> Chargé à chaque session. Modules ctx-* chargés selon le projet actif (~/dev/my-context/contexts/).
> Fichier généré lors de l'interview de configuration — remplacer les SETUP_REQUIRED.

## Profil
- Nom : SETUP_REQUIRED — GitHub : SETUP_REQUIRED
- Email : SETUP_REQUIRED
- OS principal : SETUP_REQUIRED (ex: Arch Linux, Ubuntu, macOS, Windows 11)
- Shell : SETUP_REQUIRED (ex: zsh, bash, fish)

## Langue
Répondre dans la langue de l'utilisateur. Identifiants de code en anglais.

## Autonomie
Exécuter sans demander confirmation. Informer après coup en une ligne.
- **Repos perso** : pusher d'office après modification.
- **Projets scolaires ou sensibles** (marqués dans PROJECTS.md) : JAMAIS de commit/push/add — interdiction absolue. ETAT dans `~/dev/my-context/etat/[projet].md`.
- **Nouveau repo ou type inconnu** : demander si le projet est scolaire avant tout commit/push.
- Garde-fou technique disponible : `settings-template.json` contient un hook `PreToolUse` qui bloque physiquement les commandes git destructrices (`commit`/`push`/`add`/`stash`/`merge`/`rebase`/`reset`) dans les chemins configurés — remplacer les `SETUP_REQUIRED-projet-*` par les vrais chemins de tes projets scolaires/sensibles.

## Structure home
<!-- SETUP_REQUIRED : adapter les dossiers autorisés à ta structure personnelle -->
Seuls dossiers autorisés à la racine de `~/` : `dev/` `Documents/` SETUP_REQUIRED
Seul fichier autorisé : `CLAUDE.md` (les fichiers cachés sont ignorés)
Tout le reste → `mv ~/Documents/` automatiquement, signaler en une ligne.

## Modules context
Lire le module correspondant au projet actif avant toute intervention :

| cwd | Modules à charger |
|---|---|
| SETUP_REQUIRED | SETUP_REQUIRED |
| `~/dev/obsidian-vault/` | ctx-professor (si Obsidian configuré) |
| fallback | attendre `/ctx [module]` |

Tous dans `~/dev/my-context/contexts/ctx-[nom].md`.
Ajouter une ligne par projet actif (voir contexts/README.md pour la syntaxe).

## Skills — utilisation proactive (NON NÉGOCIABLE)

### Proposer un skill existant si plus efficace

Avant de traiter une tâche manuellement, détecter si un skill existant ferait mieux :

| Situation détectée | Skill à proposer |
|---|---|
| Tâche couvre plusieurs dimensions indépendantes (audit, refonte, migration, review) | `/agents [tâche]` — parallélisme → résultat plus complet et plus rapide |
| Demande sur un projet actif sans context chargé | `/ctx [module]` — charger le bon module d'abord |
| Fin de session avec modifications importantes | `/bilan` — clôture propre + ETAT.md à jour |
| Déploiement d'un projet | `/deploy [projet]` — workflow guidé avec vérifications |
| Récap des tâches du jour | `/today` — agrège projets, agenda, dettes |
| Audit du contexte avant grosse tâche | `/check` — qualité des fichiers, marge contexte, verdict |
| Demande liée à un cours / apprentissage | `/prof [matière]` — mode prof avec context Obsidian |
| "Où en est le projet", "reprendre le projet" | `/etat` — lire ETAT.md avant de commencer |

**Règle** : si un skill rend la tâche plus rapide, plus complète ou moins risquée → le mentionner avant de commencer, pas après. Une phrase suffit : *"Je peux utiliser `/agents` pour analyser ça en parallèle — plus rapide. Je le lance ?"*

### Proposer la création d'un nouveau skill

Si aucun skill n'existe mais que la tâche remplit **au moins un** de ces critères :
- Tâche susceptible d'être redemandée (même workflow, même structure)
- Tâche qui gagnerait à être automatisée (plusieurs étapes répétitives)
- Tâche complexe qui mérite un protocole fixe pour éviter les erreurs

→ Proposer la création d'un skill **avant de commencer** :
*"Cette tâche reviendra probablement — je peux créer un skill `/[nom]` pour l'automatiser. Ça prend 2 min maintenant, ça économise 10 min à chaque fois. Je le fais ?"*

Si accepté : écrire `skills/[nom].md` + symlinker via `bash install.sh` + pusher `my-context`.

**Ne pas proposer** si la tâche est unique, trop spécifique ou triviale.

## Checklist début de session (silencieuse, dans cet ordre)
0. Détecter l'OS (voir CLAUDE.local.md §1) — Linux (`~/`) vs Windows Git Bash (`C:/Users/[user]/`)
1. `git -C ~/dev/my-context pull` — informer si mises à jour récupérées
2. Vérifier que `~/CLAUDE.md` contient `@dev/my-context/core.md` — corriger si absent
3. Cloner les projets manquants selon PROJECTS.md (voir script dans CLAUDE.local.md §3)
4. Scanner le dossier téléchargements (voir CLAUDE.local.md §8 pour le chemin selon l'OS) : cours → `notes/` du vault, TPs → `TP/`, inconnus → `a-trier/`
5. Vérifier racine `~/` : tout dossier/fichier non autorisé → `mv ~/Documents/`
6. Si jour du mois ≥ 25 : vérifier revue mensuelle (voir ctx-finance.md ou ROUTINES.md)

`/today` est disponible à la demande uniquement — ne jamais le lancer automatiquement.

Pour les détails d'implémentation bash des étapes 3-6, voir CLAUDE.local.md (chargé sur demande).

## Erreurs à ne pas reproduire (critiques)
- Toujours `git pull` avant de modifier un fichier dans un repo git
- Symlinks : résoudre avec `readlink -f` avant tout Edit/Write
- Docker bind mount sur fichier individuel → monter le dossier parent (inode stale si le fichier est recréé)
- Projets scolaires : vérifier PROJECTS.md avant tout `git commit/push` — interdiction absolue sur les repos marqués scolaires

## Fichiers context disponibles
- `CONF.md` — état système (machines, outils, config, problèmes connus)
- `PROJECTS.md` — projets actifs (repos, stacks, états)
- `ROUTINES.md` — checklist maintenance mensuelle
- `CLAUDE.local.md` — profil détaillé, habitudes, erreurs complètes, scripts de session
- `HOMESERVER.md` — infra homeserver (optionnel — si applicable)
- `PROFESSOR.md` — mode prof Obsidian (optionnel — si applicable)
