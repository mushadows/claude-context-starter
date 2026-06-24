# contexts/ — Modules de context projet

Ce dossier contient les modules de context chargés selon le projet actif.

## Principe

`core.md` est chargé à chaque session. Les modules `ctx-*.md` sont chargés **à la demande** ou **automatiquement** selon le `cwd` courant (défini dans la table "Modules context" de `core.md`).

Avantage : au lieu de charger 20 000 tokens à chaque session, seul le context pertinent est injecté.

## Syntaxe dans core.md

```markdown
## Modules context

| cwd | Modules à charger |
|---|---|
| `~/dev/mon-projet/` | ctx-dev + ctx-mon-projet |
| `~/dev/autre-projet/` | ctx-dev + ctx-autre-projet |
| fallback | attendre `/ctx [module]` |
```

## Créer un nouveau module

1. Créer `contexts/ctx-[nom].md`
2. Y mettre uniquement les infos nécessaires pour ce projet/contexte
3. Ajouter une ligne dans la table "Modules context" de `core.md`
4. Commiter et pusher `my-context`

## Modules fournis

- `ctx-dev.md` — règles de code universelles (adapter aux langages de tes projets)

## Modules à créer selon ton profil

Exemples courants :
- `ctx-[projet].md` — état, stack, accès, commandes clés pour chaque projet actif
- `ctx-homeserver.md` — si tu as un serveur ou un homelab
- `ctx-finance.md` — si tu veux que Claude gère un suivi financier
- `ctx-professor.md` — si tu utilises le mode professeur (cours Obsidian)

## Format recommandé pour un module projet

```markdown
# ctx-[projet].md — [Nom du projet]

## État actuel
[une ligne : où en est le projet, accès si déployé]

## Stack
[technologies principales]

## Commandes clés
- Build : `[commande]`
- Deploy : `[commande]`
- Logs : `[commande]`

## Fichiers importants
| Fichier | Rôle |
|---|---|
| `src/` | ... |

## Règles spécifiques au projet
[overrides ou règles supplémentaires par rapport à ctx-dev.md]
```
