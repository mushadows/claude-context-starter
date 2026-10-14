# /check — Audit du contexte avant une grosse tâche
Bilan de l'état du contexte Claude Code : qualité des fichiers, fraîcheur, usage mémoire estimé, verdict de préparation. Ne synchronise rien (`/refresh` le fait) et ne liste pas les tâches (`/today` le fait) — uniquement un jugement de qualité/fraîcheur du contexte lui-même.
## Comportement
**Arguments :** `$ARGUMENTS` (ignorés)
Variable : `CTX="$(cat "$HOME/.claude/context-dir" 2>/dev/null || echo "$HOME/dev/claude-context")"`.
### Étape 1 — Lire les fichiers de contexte
Lire en parallèle (ignorer sans erreur ceux qui n'existent pas, mais le signaler) :
- `$CTX/core.md`, `$CTX/CONF.md`, `$CTX/PROJECTS.md`, `$CTX/CLAUDE.local.md`
- Tous les `$CTX/contexts/ctx-*.md`
### Étape 2 — Évaluer chaque fichier
Noter sur 3 critères :
- **Complétude** : sections remplies ? Pas de `TODO` / `À compléter` / champs vides ?
- **Fraîcheur** : dates récentes et cohérentes avec aujourd'hui ?
- **Clarté** : structure lisible, pas de contradictions, pas d'infos dupliquées ?
Tableau synthétique :
```
Fichier           Complétude   Fraîcheur   Clarté   Note
─────────────────────────────────────────────────────────
CONF.md           ██████░░░░   ✓ récent    ✓        6/10
PROJECTS.md       ████████░░   ✓ récent    ✓        8/10
core.md           ██████████   ✓ récent    ✓       10/10
ctx-dev.md        ████████░░   ✓ récent    ✓        8/10
```
### Étape 3 — Estimer l'usage du contexte
Se baser sur la fenêtre du modèle courant (200 000 tokens par défaut, à adapter si le modèle en a une autre). L'auto-compact se déclenche vers ~87 % d'utilisation.
Estimer ce qui est déjà chargé : `core.md` (chargé auto), MEMORY.md (chargé auto), modules ctx chargés pendant la session, historique de conversation.
```
Usage contexte estimé
──────────────────────────────────────────────
Chargé auto (core + memory)  :   ~X tok
Conversation actuelle        :   ~X tok
Modules ctx chargés          :   ~X tok
Total estimé                 :   ~Z tok  (Z% de la fenêtre)
Marge avant auto-compact     :   ~W tok  (≈ N échanges moyens)
```
Un « échange moyen » ≈ 2 000 tokens.
### Étape 4 — Identifier les lacunes
- Fichiers avec sections vides ou `TODO`
- Dates stales (> 2 mois)
- Infos contradictoires entre fichiers
- Modules ctx absents ou très courts (< 20 lignes)
- Projets de `PROJECTS.md` sans état correspondant (`ETAT.md` ou `$CTX/etat/[projet].md`)
### Étape 5 — Verdict
```
══════════════════════════════════════════════
  VERDICT : [PRÊT ✓ / ATTENTION ⚠ / NON PRÊT ✗]
══════════════════════════════════════════════
Contexte global : X/10
Fraîcheur       : X/10
Marge contexte  : X/10 (W k tokens libres)
[Si ATTENTION ou NON PRÊT] actions recommandées :
  → Mettre à jour CONF.md (section X périmée)
  → Charger /ctx [module] si tâche projet spécifique
  → Faire /bilan si session précédente non clôturée
```
**Règle de verdict :**
- PRÊT ✓ : score moyen ≥ 7/10 ET marge > 40 % de la fenêtre ET pas de contradiction critique
- ATTENTION ⚠ : score 5-7 OU marge 20-40 % OU fichier important périmé
- NON PRÊT ✗ : score < 5 OU marge < 20 % OU contradiction critique détectée
