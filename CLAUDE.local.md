# CLAUDE.local.md
> Remplacer les SETUP_REQUIRED par tes valeurs avant la première session.

## Cascade — mises à jour en chaîne

Modifier ce fichier → mettre à jour aussi :
- `memory/` — si une préférence ou habitude utilisateur change
- `CONF.md` — si une erreur est liée à une config système spécifique

---

## Auto-amélioration

Après **chaque action**, mettre à jour immédiatement le fichier concerné et pusher :

| Action effectuée | Fichier à mettre à jour |
|---|---|
| Problème système résolu | `CONF.md` |
| Nouveau projet créé ou archivé | `PROJECTS.md` |
| Préférence ou habitude utilisateur révélée | `CLAUDE.local.md` + fichier mémoire |
| Erreur commise | `CLAUDE.local.md` (section "Erreurs à ne pas reproduire") |
| Changement majeur dans le context | `claude-context-starter/` — propager si applicable |

Ne jamais attendre que l'utilisateur demande de mettre à jour le context.
Toujours pusher après mise à jour.

## §1 — Détecter l'OS (silencieux, à chaque début de session)

```bash
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || -n "${WINDIR:-}" ]]; then
    echo "windows"
    # HOME_DIR = C:/Users/[SETUP_REQUIRED]/
    # DOWNLOADS = C:/Users/[SETUP_REQUIRED]/Downloads/
    # OBSIDIAN  = C:/Users/[SETUP_REQUIRED]/Documents/Obsidian/  (si applicable)
else
    echo "linux"
    # HOME_DIR = ~/
    # DOWNLOADS = ~/Téléchargements/  (ou ~/Downloads/ selon la locale)
    # OBSIDIAN  = ~/dev/obsidian-vault/  (si applicable)
fi
```

## §2 — Pull repos en début de session

**Linux :**
```bash
bash ~/dev/my-context/install.sh 2>&1 | grep -E "✗|⚠|erreur" || true
git -C ~/dev/obsidian-vault pull 2>/dev/null || true  # si applicable
for dir in ~/dev/*/; do
    name=$(basename "$dir")
    [[ "$name" == "my-context" || "$name" == "obsidian-vault" ]] && continue
    [ -d "$dir/.git" ] || continue
    git -C "$dir" pull --ff-only 2>&1 | grep -v "Already up to date" | grep -v "Déjà à jour" || true
done
```

**Windows (Git Bash) :**
```bash
git -C ~/dev/my-context pull
# Vault Obsidian (adapter le chemin) :
# git -C "C:/Users/[SETUP_REQUIRED]/Documents/Obsidian" pull 2>/dev/null || true
```

Note : sur Windows, `~/` = `C:/Users/[username]/` en Git Bash.

## §3 — Auto-cloner les projets manquants

Source de vérité : `PROJECTS.md`. Script dans le hook `session-start.sh` (section pull des projets).
Sur Windows : adapter les chemins vers `C:/Users/[user]/dev/`.

## §8 — Scanner les téléchargements

**Linux (français) :** `ls ~/Téléchargements/`
**Linux (anglais) :** `ls ~/Downloads/`
**Windows (Git Bash) :** `ls "$USERPROFILE/Downloads/" 2>/dev/null || ls ~/Downloads/ 2>/dev/null`

Règle : cours → `notes/` de la matière, TPs → `TP/`, inconnus → `a-trier/`.
Ne jamais scanner `_en-attente/` s'il existe — contenu déjà traité.

## §9 — Vérifier la structure du home

**Linux uniquement** — adapter ALLOWED selon ta structure :
```bash
ALLOWED=(dev Documents Téléchargements VM wallpaper)  # SETUP_REQUIRED : adapter
```

**Windows** : non applicable (structure NTFS différente, Desktop/AppData/etc. à ne pas toucher).

---

## Projets

Si le dossier d'un projet listé dans `PROJECTS.md` est absent sur la machine, le cloner :
- Linux : dans `~/dev/`
- Windows : dans `C:/Users/[SETUP_REQUIRED]/dev/`

## Garde-fou contexte — `ctx ?`

Quand l'utilisateur tape `ctx ?`, répondre avec un bilan court :
- Projet / sujet en cours, dernière action, décisions prises
- Si flou → "Contexte dégradé — nouvelle session recommandée."

## Habitudes utilisateur

- SETUP_REQUIRED : compléter après les premières sessions

## Profil utilisateur

- **Nom** : SETUP_REQUIRED
- **Email** : SETUP_REQUIRED
- **GitHub** : SETUP_REQUIRED
- **OS** : SETUP_REQUIRED
- **Shell** : SETUP_REQUIRED

## Erreurs à ne pas reproduire

- Toujours `git pull` avant de modifier un fichier dans un repo git
- Symlinks : résoudre avec `readlink -f` avant tout Edit/Write (Linux)
- Windows : `git config core.filemode false` dans chaque repo pour éviter les faux commits de permissions
- Docker bind mount sur fichier individuel → monter le dossier parent (inode stale si recréé)
