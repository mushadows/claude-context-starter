# /orchestre — Orchestration multi-agents (chef d'orchestre)

Découpe une tâche complexe en sous-tâches, les délègue à des subagents en parallèle avec des briefings rigoureux, vérifie les résultats et synthétise. **Refuse la parallélisation si elle n'apporte rien** — c'est un chef d'orchestre, pas un dispatcher aveugle.

**Argument :** `$ARGUMENTS` — description libre de la tâche.

---

## Phase 1 — Analyse et décision d'orchestration (garde-fou)

Avant de faire quoi que ce soit d'autre, répondre **à voix haute** (visible à l'utilisateur) aux 3 questions :

1. **Parallélisable ?** Les sous-tâches sont-elles vraiment indépendantes, ou tightly-coupled ?
2. **Frontières de contexte propres ?** Chaque sous-tâche peut-elle être briefée avec un contexte auto-suffisant sans nécessiter les résultats des autres ?
3. **Budget tokens justifié ?** Multi-agents = 3 à 10× plus de tokens qu'un single-agent. Le gain de qualité/vitesse le justifie ?

**Si NON à au moins une des trois → REFUSER l'orchestration.**
Répondre en 2 lignes : "L'orchestration n'apporte rien ici parce que [raison]. Je préfère faire ça en single agent : [approche proposée]." Puis s'arrêter — laisser l'utilisateur reprendre.

**Anti-patterns à refuser d'office :**
- Bug fix qui touche 2-3 fichiers couplés → single agent
- Rédaction d'un texte, doc, mail → single agent
- Refactoring qui nécessite de comprendre l'ensemble avant de découper → single agent (explorer d'abord)
- Tâche déjà cadrée en < 5 min de travail → single agent

**Cas où l'orchestration est justifiée** :
- Audit multi-axes (sécurité + perf + dette technique) d'un même projet
- Refactoring de N composants indépendants dans des fichiers/dossiers séparés
- Recherche exploratoire dans un gros codebase inconnu
- Migration/dépréciation qui touche N modules isolés
- Génération/mise à jour parallèle de N artefacts sans dépendance (ex : 5 fichiers cours Obsidian pour 5 matières différentes)

---

## Phase 2 — Plan explicite

Produire un plan structuré au format suivant, **avant tout dispatch** :

```
## Plan d'orchestration

Objectif : [reformulation en 1 phrase]

Sous-tâches :
  [1] [nom court] — parallèle
      Périmètre  : [dossiers/fichiers ciblés]
      Ignore     : [ce que le worker ne doit pas toucher]
      Output     : [format attendu, longueur max]
      Modèle     : haiku | sonnet
      Worktree   : oui / non — [justification si oui]

  [2] [nom court] — parallèle avec [1]
      ...

  [3] [nom court] — séquentiel après [1] et [2]
      Dépend de : [pourquoi il doit attendre]
      ...

Vérification : oui / non — [si code committable → oui, sinon non]
Budget estimé : ~[N] appels agents, coût attendu [léger/moyen/lourd]
Risques      : [collisions git, dépendances cachées, tâches sous-briefées]
```

**Règles de décomposition (d'après Anthropic) :**
- **Découper par frontière de contexte, pas par rôle.** "Un agent qui code une feature doit aussi écrire ses tests." Ne pas faire "agent code" + "agent tests" séparés sur le même fichier.
- **Éviter les templates par type.** Chaque tâche est unique — adapter la décomposition à la nature réelle du travail, pas à une grille "audit/review/explore".
- **Nommer explicitement les exclusions dans chaque briefing** : "ne touche pas à X, c'est le boulot de l'agent Y." Sinon les workers empiètent et le résultat est incohérent.
- **Un worker = un contexte cohérent.** Si deux sous-tâches ont besoin des mêmes fichiers en lecture ET écriture → les fusionner en un seul worker.

**Worktree isolation (opt-in par sous-tâche) :** activer `isolation: "worktree"` uniquement si **deux workers écrivent dans les mêmes fichiers ou dossiers**. Sinon coût de setup inutile. Un worker read-only n'a jamais besoin de worktree.

---

## Phase 3 — Checkpoint utilisateur (systématique, court)

Après le plan, poser **une seule question** à l'utilisateur :

> "Plan ci-dessus : N sous-tâches, dont M en parallèle. Vérification [activée/désactivée]. Go, ajuste ou annule ?"

**Attendre la réponse.** Ne pas dispatcher tant qu'il n'a pas validé.

Si l'utilisateur ajuste → refaire un plan minimal (juste les deltas), reposer la question, attendre.

---

## Phase 4 — Dispatch (briefings rigoureux)

Lancer les sous-tâches parallèles dans **un seul message avec plusieurs appels `Agent` en parallèle**. Les séquentielles viennent après.

**Chaque prompt de délégation DOIT contenir :**

1. **Contexte projet** : chemin du repo, OS de travail (Linux/Windows Git Bash), version des outils si pertinent, extrait de ETAT.md si utile.
2. **Objectif explicite** : "Tu dois faire X, précisément."
3. **Périmètre positif** : liste des fichiers/dossiers autorisés à lire et écrire.
4. **Périmètre négatif (exclusions)** : "ne touche pas à Y" — reprendre les exclusions listées dans le plan phase 2.
5. **Contraintes de sécurité** :
   - "Ne commit rien, ne push rien, ne deploy rien — je m'en occupe après."
   - "Ne peux pas demander de validation utilisateur — les subagents n'ont pas accès à `AskUserQuestion`. Toute décision qui nécessiterait un choix humain → laisser en TODO dans le rapport final."
6. **Format de sortie contraint** : "Bullets, <200 mots, pas de transcript. Pour chaque item : fait/partiel/bloqué, fichier(s) modifié(s), 1 ligne technique."
7. **Critères de succès mesurables** : "Le build TypeScript doit passer. Aucune erreur nouvelle dans `npm run build`."
8. **Décisions déjà prises** : tout choix architectural déjà pris qu'il faut respecter (extrait ETAT.md, contraintes du CLAUDE.local.md).

**Modèle recommandé selon le worker :**
- Recherche / exploration read-only → `haiku` (agent Explore natif)
- Implémentation, review, analyse → `sonnet` (défaut)
- Cas complexe qui bénéficie d'un modèle plus fort → `sonnet` reste souvent suffisant, escalader à Opus uniquement si preuve d'un cas où sonnet a raté

---

## Phase 5 — Vérification (auto-activée si code committable) + synthèse

**Verifier subagent** (auto-activé quand les workers de phase 4 ont produit du code destiné à être commité) :
- Lancer un agent séparé qui reçoit : les artefacts produits + les critères de succès + les tools de test (build, lint, tests).
- Il **ne reçoit pas** l'historique de la construction — juste l'artefact et les critères.
- Prompt type : "Voici les fichiers modifiés : [liste]. Voici les critères de succès : [liste]. Exécute la vérification complète et rends un verdict binaire par critère. Ne présume pas — teste."
- Anti-pattern à éviter : "Make sure it works" (trop vague). Utiliser : "Run the full test suite and report all failures", "Verify build passes", "Grep for TODO added by workers", etc.

**Synthèse (par l'orchestrateur — moi, jamais délégué) :**
- Réconcilier les résultats des workers + verdict du vérifieur.
- Dédoublonner si deux workers ont trouvé la même chose.
- Prioriser (P0 bloquant, P1 important, P2 nice-to-have).
- Signaler les surprises et les décisions restées en TODO (validations utilisateur non-délégables).
- **Présenter à l'utilisateur avant tout commit/push/deploy.** L'orchestrateur ne pousse jamais de lui-même après une session multi-agents.

Format de la synthèse :

```
## Résultats — [tâche]

### Workers
  [1] [nom] : ✓ / ⚠ / ✗ — [résumé 1 ligne]
  [2] ...

### Vérification
  Build       : ✓ / ✗
  Tests       : ✓ / ✗ ([N] échecs si ✗)
  Critères spécifiques : ...

### Priorités
  P0 : [ce qui bloque]
  P1 : [important à traiter avant push]
  P2 : [nice-to-have, peut attendre]

### TODO restés à trancher (non-délégables)
  → [décisions qui nécessitaient l'utilisateur, laissées ouvertes]

### Prêt pour commit ? [oui / non / après trancher les TODO]
```

---

## Règles opérationnelles (non négociables)

- **Phase 1 obligatoire** — jamais de dispatch sans avoir répondu aux 3 questions.
- **Phase 3 obligatoire** — jamais de dispatch sans validation utilisateur du plan.
- **Ne jamais faire écrire par un subagent des choses que l'utilisateur devrait valider en cours d'exécution** — les subagents n'ont pas `AskUserQuestion`, ça échouera silencieusement.
- **Ne jamais confier la synthèse à un subagent** — c'est le job de l'orchestrateur qui a la vision d'ensemble.
- **Ne jamais commit/push/deploy après une session multi-agents sans passer par l'utilisateur** — présenter d'abord la synthèse.
- **Refuser fermement** l'orchestration si le garde-fou phase 1 dit non. Ne pas céder à la pression "vas-y quand même".
