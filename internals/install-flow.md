# install-flow.md — Séquence bootstrap

## Vue d'ensemble

```
User tape one-liner
        │
        ▼
  bootstrap.sh|.ps1  (téléchargé et exécuté en mémoire)
        │
        ├─── 1. Détecter OS + arch
        ├─── 2. Vérifier outils de base (curl, tar / PowerShell)
        ├─── 3. Créer ~/Documents/Claudia/ et ~/.claudia/
        ├─── 4. Installer Node via fnm si absent (isolé, pas de sudo)
        ├─── 5. Installer Claude Code via npm si absent
        ├─── 6. Télécharger tarball repo → ~/Documents/Claudia/
        ├─── 7. Lancer install.sh (déploie hooks/skills/settings)
        └─── 8. Écrire ~/CLAUDE.md avec @Documents/Claudia/core.md
        │
        ▼
   User tape `claude`
        │
        ▼
  Hook session-start → détecte SETUP_REQUIRED
        │
        ▼
   Interview via INTERVIEW.md
```

## Fichiers créés / touchés

| Chemin | Créé par | Notes |
|---|---|---|
| `~/Documents/Claudia/` | bootstrap | Contenu personnel + fichiers système Claudia |
| `~/.claudia/` | bootstrap | État interne : fnm/, logs/, backups/, root |
| `~/.claude/hooks/*.sh` | install.sh | Symlinks (Linux/Mac) ou copies (Windows) |
| `~/.claude/commands/*.md` | install.sh | Idem |
| `~/.claude/settings.json` | install.sh | Depuis settings-template.json, backup si existant |
| `~/CLAUDE.md` | bootstrap | Ligne `@Documents/Claudia/core.md` |

## Idempotence

Chaque étape doit être ré-exécutable sans casse :
- `mkdir -p` (pas d'erreur si présent)
- fnm : détecte version installée, no-op
- npm install -g : no-op si à jour
- Copie tarball : backup des fichiers user avant écrasement des fichiers système (`profil.md`, `memoire.md`, `contexts/`)
- install.sh : `link_or_copy` supprime la cible avant de créer

## Fichiers user vs fichiers système (à préserver pendant l'upgrade)

**Fichiers SYSTÈME (écrasés à chaque upgrade)** :
- `core.md`
- `INTERVIEW.md`
- `README.md`
- `hooks/*.sh`
- `skills/*.md` (sauf skills créés par l'user via `/claudia` → détectés par frontmatter `custom: true` — TODO)
- `lib/*.sh`
- `templates/*`
- `settings-template.json`
- `internals/*`

**Fichiers USER (jamais écrasés)** :
- `profil.md`
- `memoire.md`
- `contexts/ctx-*.md`
- `CLAUDE.local.md`

Toujours backup avant écrasement dans `~/.claudia/backups/YYYYMMDD-HHMMSS/`.

## Rollback

En cas d'échec, `bootstrap.sh` trap ERR et affiche :
- Chemin du log complet
- Message "Ce qui a été fait est conservé, tu peux relancer"

Pas de rollback automatique — la réinstallation est idempotente donc relancer suffit.

## Désinstallation

Voir `skills/desinstaller.md` — accessible via `/desinstaller` ou action 6 du menu `/claudia`.
