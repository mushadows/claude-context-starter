# ETAT.md — Claudia (ex claude-context-starter)
> Mis à jour automatiquement — ne pas éditer manuellement

## État actuel
Pivot complet vers **Claudia**, une assistante Claude CLI pour non-techs (boulanger, coach, secrétaire, freelance). Installation par one-liner cross-platform (`curl | bash` / `iwr | iex`), context personnel dans `~/Documents/Claudia/`, ton chaleureux zéro jargon, prise en main continue via `/claudia`. Repo GitHub renommé `mushadows/claudia`.

## Dernière session (2026-07-31 soir — pivot Claudia)
- Vague 1 design multi-agents : threat model 43 scénarios + section RGPD, spec install cross-platform (fnm, tarball, rollback), UX prise en main continue (interview 6 groupes, règles proactives, wording exact, anti-jargon ~25 mots bannis)
- Vague 2 implémentation : `bootstrap.sh` + `bootstrap.ps1` (installateurs one-liner, fnm, gestion OneDrive Windows, Git for Windows auto), `install.sh` refactor pour `~/Documents/Claudia/` via `--claudia-home`, `core.md` réécrit (voix Claudia, règles suggestion proactive, révélation progressive des skills), `INTERVIEW.md` réécrit (6 groupes chaleureux + alerte RGPD données sensibles), `README.md` réécrit (3 sections + confidentialité), skills `/claudia` (hub 7 actions) et `/desinstaller` (avec sauvegarde optionnelle), `internals/` créé (docs techniques déportées), hooks `session-start` `stop` `post-compact` simplifiés pour Claudia, `lib/paths.sh` expose `$CLAUDIA_HOME` `$CLAUDIA_STATE`, `bootstrap-win.ps1` supprimé
- Repo GitHub renommé `claude-context-starter` → `claudia` (redirect auto)

## Dernière session (2026-07-31)
- Compat multi-OS Git Bash Windows : `install.sh` avait déjà fallback `cp` — propagé `lib/paths.sh` (helper `OS_KIND`/`VAULT_DIR`/`DOWNLOADS_DIR` avec `SETUP_REQUIRED` pour le chemin Windows Obsidian), nouvelle section "Multi-OS" dans `core.md` (pattern détection OS, pièges Git Bash, obligation de sourcer paths.sh), fix `< /dev/stdin` dans 3 hooks (`stop`, `session-start`, `post-compact`) — n'existe pas sur Git Bash Windows, blocage silencieux
- `.gitattributes` : force LF sur `*.sh`/`*.bash` (évite bug CRLF Docker + hooks Linux). Erreurs Windows connues ajoutées dans `CLAUDE.local.md` (CRLF, `/dev/stdin`, `docker restart`, chemins vault variables)
- Refonte skill `/agents` → `/orchestre` (chef d'orchestre 5 phases : garde-fou → plan → checkpoint utilisateur → dispatch avec briefings rigoureux → vérification+synthèse). Basée sur patterns Anthropic (orchestrator-worker, verification subagent) et contre-arguments Cognition. Refuse la parallélisation si elle n'apporte rien

## En cours
- Vague 3 restante (nice-to-have) : refactoriser skills legacy (`bilan`, `check`, `ctx`, `deploy`, `etat`, `prof`, `today`) qui référencent encore `~/dev/my-context/` pour qu'ils marchent avec `$CLAUDIA_HOME` ; décider du sort des fichiers root legacy (`CONF.md`, `PROJECTS.md`, `ROUTINES.md`, `RULES_*`, `PROFESSOR.md`)

## Décisions architecturales
| Décision | Raison | Date |
|---|---|---|
| Repo public séparé de `context` (privé) | Partager le système sans exposer les données perso | 2026 |
| Propagation manuelle depuis `my-context/` | Changements perso filtrés avant propagation | 2026 |
| Interview extraite dans `INTERVIEW.md` séparé | Garder `core.md` court (~100 lignes) tout en fiabilisant le premier lancement pour un public non technique | 2026-07-07 |
| `lib/paths.sh` helper multi-OS + skill `/orchestre` chef d'orchestre 5 phases | Compat Git Bash Windows sans dupliquer la logique de détection OS · orchestration multi-agents avec garde-fou explicite | 2026-07-31 |
| Pivot Claudia : renommage + one-liner install + `~/Documents/Claudia/` + fnm + ton zéro jargon + `/claudia` hub central + prise en main continue | Rendre le context utilisable par n'importe qui (boulanger, coach, secrétaire) sans prérequis technique, tout en gardant la puissance write-access du CLI qu'aucune surface Anthropic (web/mobile/Projects) ne permet aujourd'hui | 2026-07-31 |

## Règle de synchronisation
Tout changement majeur dans `my-context/` applicable en générique → propager dans ce repo.
