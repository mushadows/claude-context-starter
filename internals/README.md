# internals/ — Détails techniques

Ce dossier contient les scripts, procédures et détails techniques qui **ne devraient pas encombrer** les fichiers principaux (`core.md`, `CLAUDE.local.md`, `README.md`).

Pas destiné à être lu par un utilisateur non-technicien. Utile pour :
- Développeurs qui veulent contribuer ou forker
- Debugging quand quelque chose casse
- Documentation des mécanismes internes

## Contenu

| Fichier | Sujet |
|---|---|
| `start-of-session.md` | Détection OS, pull des dépôts, checks silencieux au démarrage |
| `os-paths.md` | Chemins qui varient selon l'OS (Documents, Téléchargements, vault…) |
| `error-catalog.md` | Erreurs connues + fix (git/npm/docker/hyprland/etc.) |
| `hooks-spec.md` | Contrat des hooks Claude Code (Stop, PreCompact, PostCompact, PostEdit, SessionStart) |
| `install-flow.md` | Séquence complète du bootstrap Linux/Mac + Windows |

## Contribuer

Les fichiers ici peuvent être hautement techniques (bash, PowerShell, chemins absolus, jargon Anthropic). Contrairement aux autres fichiers du projet, **le jargon est autorisé et attendu** — c'est le lieu où on documente précisément.
