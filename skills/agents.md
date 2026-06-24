Orchestre plusieurs subagents en parallèle pour analyser un projet ou une tâche complexe.

## Arguments : `$ARGUMENTS`

Format : `/agents [type] [cible]`
- `/agents audit mon-projet` → audit multi-axes du projet
- `/agents review` → review du diff courant (sécurité + perf + dette)
- `/agents explore [question]` → recherche multi-angles dans le codebase

## Comportement

### 1. Analyser la tâche
Lire `$ARGUMENTS` et identifier :
- La **cible** (projet, fichier, question)
- Le **type de travail** (audit, review, exploration, refactoring)
- Les **axes indépendants** qui peuvent être traités en parallèle

### 2. Décomposer en sous-tâches
Définir 2 à 4 sous-tâches indépendantes selon le type :

**`audit [projet]`** → 3 agents en parallèle :
- Agent sécurité : authentification, secrets exposés, CORS, XSS, injections
- Agent performance : requêtes N+1, cache, taille bundles, latences
- Agent dette technique : TODO/FIXME, dépendances obsolètes, code mort, couplage fort

**`review`** → 2 agents en parallèle :
- Agent correctness : bugs, cas limites, logique incorrecte
- Agent qualité : duplication, abstractions prématurées, nommage, lisibilité

**`explore [question]`** → agents ciblés selon la question :
- Agent recherche fichiers : `find` + `grep` pour localiser le code concerné
- Agent analyse : lecture et compréhension du code trouvé
- Agent impact : quels autres fichiers sont affectés

### 3. Dispatcher les agents
Utiliser l'outil `Agent` pour lancer chaque sous-tâche **en parallèle** (plusieurs appels dans le même message).
Chaque agent reçoit :
- Un prompt auto-suffisant avec le contexte nécessaire (chemin repo, question précise)
- Un périmètre clair (ce qu'il doit chercher, ce qu'il doit ignorer)
- Une instruction de format de réponse (bullet list, < 300 mots)

### 4. Synthétiser
Collecter les résultats de tous les agents.
Produire une synthèse structurée :
```
## Résultats [type] — [cible]

### [Axe 1]
[findings de l'agent 1]

### [Axe 2]
[findings de l'agent 2]

## Priorités
1. [finding le plus critique]
2. ...
```

### Routing modèle recommandé
- Agents de recherche/exploration → modèle `haiku` (rapide, moins coûteux)
- Agents d'analyse et review → modèle `sonnet` (défaut)
- Synthèse finale complexe ou audit sécurité → passer en `opus` manuellement si besoin
