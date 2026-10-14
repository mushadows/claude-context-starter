# claude-context — contexte Claude Code pour développeur
Template de contexte persistant pour Claude Code : profil, règles de code, projets, skills et hooks, versionnés dans un repo et déployés sur chaque machine. Un `core.md` compact est chargé à chaque session ; les modules projet sont chargés à la demande.

## Installation
```bash
git clone <URL-DU-REPO> ~/dev/claude-context
bash ~/dev/claude-context/install.sh            # ajouter --plugins pour les plugins recommandés
cd ~ && claude                                   # première session : interview (8 questions max)
```
Linux, macOS, Windows (Git Bash). `install.sh` est idempotent : le relancer ne casse rien.

## Structure
```
~/CLAUDE.md                 → @dev/claude-context/core.md
claude-context/
├── core.md                 chargé à chaque session (générique, jamais modifié chez toi)
├── INTERVIEW.md            configuration initiale
├── contexts/               ctx-dev.md + un module par projet
├── skills/                 slash commands (symlinks vers ~/.claude/commands/)
├── hooks/                  session-start, stop, pre/post-compact, post-edit
├── lib/paths.sh            chemins multi-OS
├── templates/              PROJECTS, CONF, CLAUDE.local, etat
├── RULES_GENERIC.md        conventions de code communes
├── RULES_LANGAGES.md       surcharges par langage
├── settings-template.json  réglages Claude Code déployés
└── install.sh
```
Générés par l'interview, **ignorés par git** : `CLAUDE.local.md` (ton profil, importé par `core.md`), `PROJECTS.md`, `CONF.md`, `etat/`, `contexts/ctx-[projet].md`. Ainsi `git pull` ne crée jamais de conflit.

## Skills
| Commande | Rôle |
|---|---|
| `/ctx [module]` | charger un module de contexte |
| `/etat` | état du projet courant (`etat/[projet].md`) |
| `/bilan` | clôture de session + mise à jour de l'état |
| `/check`, `/context-check` | audit du contexte avant une grosse tâche / de ce repo |
| `/orchestre [tâche]` | subagents en parallèle avec vérification |
| `/deploy [projet]` | déploiement guidé |
| `/today` | récap du jour |
| `/security-audit`, `/pentest-self` | audit sécurité statique / test d'intrusion sur tes propres services |
| `/refresh` | pull + resynchronisation (hooks, skills, settings) |

## Options
| Option | Effet |
|---|---|
| `install.sh --plugins` | installe/active les plugins recommandés (ex. `ponytail`) |
| `install.sh --quiet` | sortie d'une ligne (utilisé par le hook `session-start`) |
| `.autosync` | fichier vide à la racine du repo : `stop` commit en local, `session-start` fait un `git pull --ff-only` des repos de `~/dev`. Contenu `push` : `stop` pousse aussi (uniquement vers TON repo privé, jamais vers le template public) |

## Personnalisation
- Profil, langue, autonomie, écarts de conventions : `CLAUDE.local.md`
- Projets et sensibilité (`Sensible : oui` = lecture seule) : `PROJECTS.md`
- Conventions communes : `RULES_GENERIC.md`, `RULES_LANGAGES.md`, `contexts/ctx-dev.md` (versionnés ; tes écarts vont dans `CLAUDE.local.md`)
- Nouveau module : `contexts/README.md` ; nouveau skill : `skills/[nom].md` puis `bash install.sh`
- Pour sauvegarder tes fichiers perso, utilise un repo privé (fork) : ne les pousse jamais vers le template public

## Mise à jour
Automatique : le hook `session-start` fait un `git pull --ff-only` en arrière-plan et ré-applique `install.sh` si le repo a changé. À la demande : `/refresh`. `install.sh` seul ne tire rien : il redéploie hooks, skills et la ligne de `~/CLAUDE.md`.

## Avertissement — permissions
`settings-template.json` accorde des permissions larges (exécution shell, écriture de fichiers sans confirmation) pour limiter les interruptions. Relis-le avant `install.sh`, resserre `permissions` selon ton niveau de risque, et ne l'utilise pas tel quel sur une machine partagée ou avec des repos sensibles sans revue.
