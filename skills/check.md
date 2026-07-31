---
description: Audit rapide — Claudia vérifie qu'elle a bien tout ce qu'il lui faut avant une grosse tâche.
---

# /check — Es-tu au clair ?

Sert à faire un point avant de se lancer dans quelque chose d'important : Claudia regarde si ses fichiers de mémoire sont à jour, complets, et si elle a assez de place dans la conversation pour bosser.

## Préparation

```bash
source "$CLAUDIA_HOME/lib/paths.sh"
```

## Étape 1 — Lire les fichiers Claudia

Lire en parallèle (ceux qui existent) :
- `$CLAUDIA_HOME/core.md`
- `$CLAUDIA_HOME/profil.md`
- `$CLAUDIA_HOME/memoire.md`
- Tous les `$CLAUDIA_HOME/contexts/ctx-*.md`

## Étape 2 — Évaluer chaque fichier

Pour chaque fichier, 3 critères :
- **Complétude** : sections remplies ? Pas de `SETUP_REQUIRED`, `TODO`, ou trous ?
- **Fraîcheur** : les dates mentionnées sont-elles récentes et cohérentes ?
- **Clarté** : lisible, sans contradiction, sans doublon ?

Afficher un tableau simple :

```
Fichier             Complétude   Fraîcheur   Clarté   Note
────────────────────────────────────────────────────────────
core.md             ██████████   ✓ récent    ✓       10/10
profil.md           ██████░░░░   ✓ récent    ✓        6/10
memoire.md          ████████░░   ✓ récent    ✓        8/10
ctx-cuisine.md      █████░░░░░   ✗ ancien    ✓        5/10
...
```

## Étape 3 — Estimer la place dans la conversation

La fenêtre de conversation fait environ **200 000 unités** (« tokens »). Le nettoyage automatique se déclenche vers **~175 000** (à peu près 87 %).

Estimer ce qui est déjà pris :
- Fichiers chargés automatiquement (~1 500)
- La conversation elle-même (estimation)
- Les contextes chargés manuellement

Afficher (en évitant le jargon si possible) :

```
Place dans la conversation
──────────────────────────────────────────────
Chargé au démarrage           :   ~1 500
Conversation actuelle         :   ~X 000
Contextes chargés             :   ~Y 000
──────────────────────────────────────────────
Total estimé                  :   ~Z 000  (Z% / 200k)
Nettoyage auto vers           :   ~175 000
Marge restante                :   ~W 000  (≈ N échanges)
```

Un échange moyen ≈ 2 000 unités (question + réponse).

## Étape 4 — Repérer les manques

- Fichiers avec sections vides ou `SETUP_REQUIRED`
- Dates anciennes (> 2 mois sans mise à jour)
- Infos qui se contredisent entre fichiers
- Contextes très courts (< 20 lignes)
- Projets mentionnés dans le profil sans fichier d'avancement

## Étape 5 — Verdict

```
══════════════════════════════════════════════
  VERDICT : [PRÊTE ✓ / ATTENTION ⚠ / PAS PRÊTE ✗]
══════════════════════════════════════════════
Contexte général : X/10
Fraîcheur        : X/10
Marge            : X/10 (W k restants)

[Si ATTENTION ou PAS PRÊTE] : ce qu'il faut faire avant :
  → Remplir la section X de profil.md
  → Charger `/ctx [nom]` si la tâche concerne un projet précis
  → Faire `/bilan` si la session précédente n'a pas été clôturée
```

**Règles :**
- PRÊTE ✓ : moyenne ≥ 7/10 ET marge > 80k ET rien de contradictoire
- ATTENTION ⚠ : 5-7 OU marge 40-80k OU un fichier important ancien
- PAS PRÊTE ✗ : < 5 OU marge < 40k OU contradiction sérieuse

Finir par une phrase courte, chaleureuse :
> « Tu peux y aller. » / « Il manque deux ou trois trucs, tu veux qu'on répare avant ? »
