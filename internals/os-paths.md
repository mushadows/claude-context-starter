# os-paths.md — Chemins variables selon l'OS

Toujours passer par `lib/paths.sh` pour récupérer les bons chemins.

```bash
source "$CLAUDIA_HOME/lib/paths.sh"
echo "$VAULT_DIR"        # obsidian vault
echo "$DOWNLOADS_DIR"    # dossier téléchargements
echo "$CLAUDIA_HOME"     # dossier Claudia
```

## Table de résolution

| Variable | Linux | macOS | Windows (Git Bash) |
|---|---|---|---|
| `$CLAUDIA_HOME`  | `~/Documents/Claudia`  | `~/Documents/Claudia`  | `$MyDocuments/Claudia` (peut être sous OneDrive) |
| `$CLAUDIA_STATE` | `~/.claudia`           | `~/.claudia`           | `$LOCALAPPDATA/Claudia` |
| `$DOWNLOADS_DIR` | `~/Téléchargements` ou `~/Downloads` | `~/Downloads` | `$USERPROFILE/Downloads` |
| `$VAULT_DIR`     | selon config user      | selon config user      | selon config user |

## Résolution Windows (attention OneDrive)

Sur Windows, le dossier « Documents » peut être redirigé vers OneDrive. **Ne jamais hardcoder** `$USERPROFILE/Documents`. Toujours résoudre via l'API Windows :

**PowerShell** :
```powershell
[Environment]::GetFolderPath('MyDocuments')
```

**Git Bash** :
```bash
# Lire le pointeur écrit par le bootstrap
cat "$LOCALAPPDATA/Claudia/root"
```

## Pièges connus

- Git Bash Windows : `/dev/stdin` n'existe pas comme fichier
- Symlinks Windows : nécessitent Developer Mode ou admin → fallback copie
- Chemins avec accents/espaces : toujours quoter les variables (`"$path"`)
- macOS < 12 : plus supporté par Node 20+
- Alpine Linux : musl vs glibc — binaires Node officiels ne marchent pas, prendre les binaires musl explicites
