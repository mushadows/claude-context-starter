# contexts/ — Modules de context
Modules `ctx-[nom].md` chargés selon le projet actif (table « Modules context » de `core.md`), pour ne pas charger tout le context à chaque session.

| Fichier | Rôle |
|---|---|
| `ctx-dev.md` | Règles de code, actif sur tout projet de code (versionné, ne pas modifier : les écarts vont dans `CLAUDE.local.md`) |
| `ctx-projet.template.md` | Modèle à copier pour un nouveau module |
| `ctx-[projet].md` | Stack, commandes, pièges d'un projet précis (à créer, ignoré par git) |

## Créer un module
1. Copier `ctx-projet.template.md` en `contexts/ctx-[nom du dossier du projet].md` : le nom du dossier suffit à le router, aucune ligne à ajouter dans `core.md`
2. Y mettre uniquement ce qui est utile à ce projet
3. Erreurs propres au projet → ce module, jamais `CLAUDE.local.md`

Autres modules courants : infra/homelab, base de données, déploiement, client/entreprise.
