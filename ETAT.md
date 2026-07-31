# ETAT.md — claude-context-starter
> Mis à jour automatiquement — ne pas éditer manuellement

## État actuel
Template public fonctionnel. Guide complet A→Z (GitHub, Git, Claude Code) + interview automatique au premier lancement (déroulé dédié dans `INTERVIEW.md`). Synchronisé avec `my-context/` pour les changements majeurs.

## Dernière session (2026-07-31)
- Compat multi-OS Git Bash Windows : `install.sh` avait déjà fallback `cp` — propagé `lib/paths.sh` (helper `OS_KIND`/`VAULT_DIR`/`DOWNLOADS_DIR` avec `SETUP_REQUIRED` pour le chemin Windows Obsidian), nouvelle section "Multi-OS" dans `core.md` (pattern détection OS, pièges Git Bash, obligation de sourcer paths.sh), fix `< /dev/stdin` dans 3 hooks (`stop`, `session-start`, `post-compact`) — n'existe pas sur Git Bash Windows, blocage silencieux
- `.gitattributes` : force LF sur `*.sh`/`*.bash` (évite bug CRLF Docker + hooks Linux). Erreurs Windows connues ajoutées dans `CLAUDE.local.md` (CRLF, `/dev/stdin`, `docker restart`, chemins vault variables)
- Refonte skill `/agents` → `/orchestre` (chef d'orchestre 5 phases : garde-fou → plan → checkpoint utilisateur → dispatch avec briefings rigoureux → vérification+synthèse). Basée sur patterns Anthropic (orchestrator-worker, verification subagent) et contre-arguments Cognition. Refuse la parallélisation si elle n'apporte rien

## Dernière session (2026-07-07)
- Sync depuis `my-context` : `bilan.md` (étapes ctx projet + propagation mémoire→context), `etat.md` (garde-fou projet scolaire/sensible), `settings-template.json` (hook `PreToolUse` anti-git-destructeur, placeholders `SETUP_REQUIRED-projet-1/2`), `core.md` (note sur ce garde-fou)
- Création `INTERVIEW.md` : déroulé déterministe de la configuration initiale (groupes de questions, valeurs par défaut, table réponse→fichier), pensé pour un public non technique — accroché en tête de `core.md` (court-circuite la checklist normale tant que des `SETUP_REQUIRED` subsistent)
- README.md mis à jour (arborescence + description étape 9) pour référencer `INTERVIEW.md`

## En cours
- Aucune tâche en cours connue

## Décisions architecturales
| Décision | Raison | Date |
|---|---|---|
| Repo public séparé de `context` (privé) | Partager le système sans exposer les données perso | 2026 |
| Propagation manuelle depuis `my-context/` | Changements perso filtrés avant propagation | 2026 |
| Interview extraite dans `INTERVIEW.md` séparé | Garder `core.md` court (~100 lignes) tout en fiabilisant le premier lancement pour un public non technique | 2026-07-07 |
| `lib/paths.sh` helper multi-OS + skill `/orchestre` chef d'orchestre 5 phases | Compat Git Bash Windows sans dupliquer la logique de détection OS · orchestration multi-agents avec garde-fou explicite | 2026-07-31 |

## Règle de synchronisation
Tout changement majeur dans `my-context/` applicable en générique → propager dans ce repo.
