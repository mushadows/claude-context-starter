# /context-check — Audit complet d'un repo de contexte
Audit multi-axes d'un repo de contexte Claude Code entier : correction, cohérence structurelle, coût token, redondance, portabilité, sécurité. Dispatche 4 subagents en parallèle (un par catégorie de fichiers), synthétise, priorise — ne corrige rien tout seul, propose un plan de correction validé avant d'éditer.
**Arguments :** `$ARGUMENTS` — optionnel, chemin du repo à auditer (défaut le dossier du repo de contexte (contenu de `~/.claude/context-dir`)). Fonctionne sur tout repo de contexte structuré en `core.md`/`CLAUDE.md` + dossier de modules + dossier de skills + automatisation — adapter les 4 périmètres à la structure réelle du repo cible si elle diffère.
## Décision d'orchestration (déjà tranchée, ne pas redemander)
Tâche systématiquement parallélisable à 4 workers read-only aux périmètres disjoints — cas d'usage canonique d'`/orchestre` (« audit multi-axes d'un même projet »). Lancer directement la Phase 2 d'`/orchestre` sans repasser par son garde-fou Phase 1.
## Les 4 workers (un seul message, modèle sonnet, lecture seule)
1. **Noyau toujours chargé** — `core.md`/`CLAUDE.md` (chargé à CHAQUE session, le plus critique en coût token), `CLAUDE.local.md`, `PROJECTS.md`, `CONF.md`. Axes : affirmations fausses/obsolètes, contradictions inter-fichiers, poids token (contenu qui pourrait vivre dans un fichier chargé à la demande), chemins/fichiers référencés (vérifier qu'ils existent, ne jamais supposer).
2. **Modules de contexte** — `contexts/ctx-*.md`. Axes : chaque module est-il référencé dans le tableau de routage du noyau (sinon orphelin) ? redondance entre modules ? fraîcheur/correction ? taille anormale ?
3. **Skills** — `skills/*.md`. Axes : skill mort, cohérence avec le mécanisme de déploiement (liens via `install.sh`), portabilité Linux ET Git Bash Windows des commandes bash embarquées, chevauchement entre deux skills.
4. **Automatisation** — `hooks/*.sh`, `install.sh`, `settings*.json`. Axes : idempotence (relançable sans effet cumulatif : liens dupliqués, backups qui s'accumulent), portabilité multi-OS, sécurité (secrets en dur, hooks qui bloquent silencieusement), robustesse (`set -e`, erreurs réseau).
Chaque worker reçoit : périmètre positif (fichiers à lire), périmètre négatif (ne pas toucher aux fichiers des 3 autres), règle multi-OS si pertinente, et le format de sortie : bullets actionnables (fichier:ligne + correction concrète), < 300 mots, classés **P0** (bug/incohérence réelle/non-idempotent/sécurité) / **P1** (redondance/poids token/portabilité) / **P2** (nice-to-have/clarté).
## Synthèse (jamais déléguée)
1. Dédoublonner les findings entre workers.
2. Fusionner en une liste unique P0 → P1 → P2.
3. Chiffrer le coût token du noyau toujours chargé (`wc -l`/taille de `core.md`) et dire s'il est raisonnable ou à alléger.
4. Présenter la synthèse **avant toute correction**, avec un plan de fix groupé par fichier ; attendre validation (jamais de commit/push après un audit multi-agents sans passer par l'utilisateur).
5. Une fois validé : appliquer les corrections directement (pas de nouveaux subagents pour des fixes ciblés), puis proposer le commit/push selon les règles git du repo audité.
## Format de synthèse
```
## Audit [repo] — [date]
### P0 — à corriger
  - [fichier] : [problème] → [fix proposé]
### P1 — à corriger si le temps le permet
### P2 — nice-to-have
### Coût token du noyau
  [core.md] : [N] lignes — [raisonnable / à alléger, pourquoi]
### Prêt à corriger ? [attend validation utilisateur]
```
