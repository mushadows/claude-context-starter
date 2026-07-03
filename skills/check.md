# /check — Audit du contexte général avant une grosse tâche

Effectue un bilan complet de l'état du contexte Claude Code : qualité des fichiers, fraîcheur, usage mémoire estimé, verdict de préparation.

## Comportement

**Arguments :** `$ARGUMENTS` (ignorés)

### Étape 1 — Lire les fichiers de contexte

Lire en parallèle :
- `~/dev/my-context/CONF.md`
- `~/dev/my-context/PROJECTS.md`
- `~/dev/my-context/ROUTINES.md`
- `~/dev/my-context/CLAUDE.local.md`
- `~/dev/my-context/core.md`
- Tous les `~/dev/my-context/contexts/ctx-*.md`

### Étape 2 — Évaluer chaque fichier

Pour chaque fichier, noter sur 3 critères :
- **Complétude** : sections remplies ? Pas de `TODO` / `À compléter` / champs vides ?
- **Fraîcheur** : dates mentionnées récentes ? Cohérentes avec aujourd'hui ?
- **Clarté** : structure lisible, pas de contradictions, pas d'infos dupliquées ?

Afficher un tableau synthétique :

```
Fichier           Complétude   Fraîcheur   Clarté   Note
─────────────────────────────────────────────────────────
CONF.md           ██████░░░░   ✓ récent    ✓        6/10
PROJECTS.md       ████████░░   ✓ récent    ✓        8/10
ROUTINES.md       █████░░░░░   ✗ périmé    ✓        5/10
CLAUDE.local.md   ████████░░   ✓ récent    ✓        8/10
core.md           ██████████   ✓ récent    ✓       10/10
ctx-dev.md        ████████░░   ✓ récent    ✓        8/10
...
```

### Étape 3 — Estimer l'usage du contexte

Le modèle courant (claude-sonnet-4-6) dispose d'une fenêtre de **200 000 tokens**.
L'auto-compact se déclenche autour de **~175 000 tokens** (≈87% utilisés).

Estimer ce qui est déjà chargé dans cette session :
- core.md chargé automatiquement (~1 000 tokens)
- MEMORY.md chargé automatiquement (~500 tokens)
- Modules ctx chargés manuellement ce jour (si applicable)
- Historique de conversation estimé

Afficher :
```
Usage contexte estimé
──────────────────────────────────────────────
Chargé auto (core + memory)  :   ~1 500 tok
Conversation actuelle        :   ~X 000 tok
Modules ctx chargés          :   ~Y 000 tok
─────────────────────────────────────────────
Total estimé                 :   ~Z 000 tok  (Z% / 200k)
Auto-compact prévu vers      :   ~175 000 tok
Marge restante               :   ~W 000 tok  (≈ N échanges moyens)
```

Un "échange moyen" ≈ 2 000 tokens (question + réponse + outils).

### Étape 4 — Identifier les lacunes

Lister les problèmes détectés :
- Fichiers avec sections vides ou `TODO`
- Dates stales (> 2 mois sans mise à jour)
- Infos contradictoires entre fichiers
- Modules ctx absents ou très courts (< 20 lignes)
- Projets dans PROJECTS.md sans ETAT.md correspondant

### Étape 5 — Verdict

```
══════════════════════════════════════════════
  VERDICT : [PRÊT ✓ / ATTENTION ⚠ / NON PRÊT ✗]
══════════════════════════════════════════════
Contexte global    : X/10
Fraîcheur          : X/10
Marge contexte     : X/10 (W k tokens libres)

[Si ATTENTION ou NON PRÊT] : actions recommandées avant de commencer :
  → Mettre à jour CONF.md (section X périmée)
  → Charger /ctx [module] si tâche projet spécifique
  → Faire /bilan si session précédente non clôturée
```

**Règle de verdict :**
- PRÊT ✓ : score moyen ≥ 7/10 ET marge > 80k tokens ET pas de contradiction critique
- ATTENTION ⚠ : score 5-7 OU marge 40-80k tokens OU fichier important périmé
- NON PRÊT ✗ : score < 5 OU marge < 40k tokens OU contradiction critique détectée
