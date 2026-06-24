Charge manuellement un module de context dans la session courante.

## Modules disponibles

Les modules disponibles sont définis dans `~/dev/my-context/contexts/`.
Lister les fichiers présents pour connaître les modules installés :
```bash
ls ~/dev/my-context/contexts/ctx-*.md
```

Modules fournis par défaut :
| Commande | Fichier chargé | Usage |
|---|---|---|
| `/ctx dev` | `ctx-dev.md` | Règles de code (TS, React, Go, etc.) |

Modules à créer selon ton profil (exemples) :
| Commande | Fichier | Usage |
|---|---|---|
| `/ctx [projet]` | `ctx-[projet].md` | Context d'un projet spécifique |
| `/ctx homeserver` | `ctx-homeserver.md` | Infra serveur, Docker, services |
| `/ctx finance` | `ctx-finance.md` | Routines financières, budget |
| `/ctx prof [matière]` | `ctx-professor.md` | Mode professeur, optionnel : matière |

## Comportement

**Arguments :** `$ARGUMENTS`

**Sans argument :**
Afficher la liste des modules disponibles (`ls ~/dev/my-context/contexts/ctx-*.md`) avec une ligne de description chacun.
Indiquer le module détecté automatiquement selon le cwd courant (si applicable).

**Avec argument :**
1. Identifier le module demandé (tolérer les fautes de frappe et variantes)
2. Lire le ou les fichiers ctx-*.md correspondants depuis `~/dev/my-context/contexts/`
3. Injecter leur contenu dans la session — confirmer en une ligne : "Contexte [module] chargé."

**Si le module demandé n'existe pas :**
Lister les modules disponibles et suggérer le plus proche.
Proposer de créer le module si la demande est légitime.
