# /today — Récap des tâches du jour
Agrège l'état de tous les projets actifs pour donner un plan d'action immédiat. Ne touche pas au sync des repos/skills (voir `/refresh`).
À la demande uniquement — ne jamais lancer automatiquement.
## Comportement
**Arguments :** `$ARGUMENTS` (ignorés)
Variable : `CTX="$(cat "$HOME/.claude/context-dir" 2>/dev/null || echo "$HOME/dev/claude-context")"`.
### Étape 1 — Lire les sources en parallèle
- `$CTX/PROJECTS.md` — état de chaque projet (dettes git, blockers signalés)
- `$CTX/etat/*.md` — état détaillé et tâches de chaque projet
### Étape 2 — Extraire les items actionnables
Ignorer tout fichier d'état dont la 2e ligne contient `exclu de /today` (projet en pause).
**Par projet :**
- Tâches marquées « En cours », « À faire », « Bloqué », « ⚠️ »
- Dettes techniques signalées explicitement (ex : `⚠️ Dette git`)
- Déploiements en attente ou configs incomplètes
### Étape 3 — Afficher le récap
Format compact, uniquement ce qui est actionnable.
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  AUJOURD'HUI — [Jour DD/MM/YYYY]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔧 PROJETS — en cours / à débloquer
  projet-a   → Résoudre divergence git (3 commits locaux vs 7 distants)
  projet-b   → ...
⚠️ DETTES / BLOCKERS
  → Item urgent ou bloquant
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  [N item(s) à traiter]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
**Règles d'affichage :**
- Aucun item → afficher `Tout est clean. Bonne session.` et s'arrêter
- Pas de section vide — omettre les blocs sans contenu
- Max 2 lignes par projet — synthétiser
- État absent pour un projet actif → le signaler `ETAT manquant`
