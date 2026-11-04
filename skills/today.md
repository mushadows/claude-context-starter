---
description: "Récap des tâches du jour"
---
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
### Étape 2bis — Vérifier chaque item contre la réalité (OBLIGATOIRE)
Un fichier d'état vieillit : un item écrit n'est pas un item vrai. Avant d'afficher, tester chaque item candidat avec une commande en lecture seule (en parallèle) :
- Service/site : `curl -s -o /dev/null -w '%{http_code}' https://<hôte>` · serveur distant : `ssh -o BatchMode=yes -o ConnectTimeout=8 <hôte> '<commande>'`
- DNS/mail (DMARC, SPF…) : requête DNS-over-HTTPS (`curl -s -H 'accept: application/dns-json' 'https://cloudflare-dns.com/dns-query?name=<nom>&type=TXT'`) si `dig` est absent
- Outil/état local : `command -v`, `git -C <repo> status -sb`
- Échéance : comparer à la date du jour (passée = actionnable, future = « à partir du JJ/MM »)
Règles : résolu → l'omettre **et** barrer la ligne dans l'état (`~~…~~ — fait, vérifié AAAA-MM-JJ`) ; non résolu → afficher ; non vérifiable depuis cette machine (secret absent, hors réseau) → afficher avec le suffixe `(non vérifié)`.
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
