# CHANGELOG — Claudia

Historique des changements majeurs du projet.

## 2026-07-31 — Pivot Claudia (v0.1)

Refonte complète depuis `claude-context-starter` pour rendre l'outil utilisable par n'importe qui (boulanger, coach, secrétaire, freelance) sans prérequis technique.

**Ajouts :**
- `bootstrap.sh` / `bootstrap.ps1` — installateurs one-liner cross-platform (fnm isolé, tarball GitHub, idempotents, gestion OneDrive Windows, Git for Windows auto)
- `skills/claudia.md` — hub central 7 actions
- `skills/desinstaller.md` — désinstallation propre avec sauvegarde optionnelle
- `internals/` — docs techniques déportées (os-paths.md, install-flow.md)
- `templates/profil.md`, `templates/memoire.md` — templates user copiés par le bootstrap uniquement si absents
- `templates/optional/` — modules et règles opt-in pour utilisateurs avancés

**Refontes majeures :**
- `core.md` — identité Claudia, voix chaleureuse tutoie, anti-jargon (~25 mots bannis), règles suggestion proactive, révélation progressive des skills
- `INTERVIEW.md` — 6 groupes chaleureux, alerte RGPD données sensibles
- `README.md` — 3 sections publiques + confidentialité + section dev en fin
- `install.sh` — refactor pour cibler `$CLAUDIA_HOME` via `--claudia-home`
- `lib/paths.sh` — expose `$CLAUDIA_HOME`, `$CLAUDIA_STATE`, `$OS_KIND`
- Skills legacy (`bilan`, `check`, `ctx`, `deploy`, `etat`, `prof`, `today`) — chemins basés sur `$CLAUDIA_HOME`, voix Claudia, sauvegarde conditionnelle
- Hooks (`session-start`, `stop`, `pre-compact`, `post-compact`) — simplifiés pour Claudia, autosync gaté sur `.autosync`

**Suppressions :**
- `bootstrap-win.ps1` (remplacé par `bootstrap.ps1`)
- `hooks/post-edit.sh` (dev-only)
- Fichiers de travail personnels du repo public : `CLAUDE.md`, `CLAUDE.local.md`, `ETAT.md`, `CONF.md`, `PROJECTS.md`, `ROUTINES.md`, `RULES_LANGAGES.md`
- Bloc PreToolUse hardcodé `SETUP_REQUIRED-projet-*` dans `settings-template.json`

**Repo GitHub** : renommé `mushadows/claude-context-starter` → `mushadows/claudia` (redirect auto).
