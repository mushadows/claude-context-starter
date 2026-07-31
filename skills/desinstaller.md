---
description: Retire Claudia complètement de la machine, proprement
---

# /desinstaller — Retirer Claudia proprement

Supprime tout ce que Claudia a installé, avec possibilité de sauvegarder les données personnelles avant.

## Comportement

### Étape 1 — Lister ce qui va être supprimé

Toujours afficher la liste explicite avant toute action :

```
Voici ce qui va disparaître de ta machine :

  Tes fichiers personnels :
    ~/Documents/Claudia/          (profil, mémoire, contextes)

  Les automatismes Claude Code :
    ~/.claude/hooks/*.sh          (fichiers déployés par Claudia)
    ~/.claude/commands/*.md       (raccourcis Claudia)

  Le fichier de connexion :
    ~/CLAUDE.md                    (ligne qui pointe vers Claudia)

  L'état interne de Claudia :
    ~/.claudia/                    (logs, versions Node isolées, sauvegardes)

Ce qui NE sera PAS touché :
  · Claude Code lui-même (l'outil de base)
  · Node.js (si tu l'utilises pour autre chose)
  · Tes autres fichiers dans ~/Documents/
  · Ton compte Anthropic
```

### Étape 2 — Proposer une sauvegarde

> « Veux-tu que je te fasse une copie de ton profil et de ta mémoire avant de tout retirer ? Ça ira dans `~/Documents/claudia-sauvegarde-[date]/` — tu pourras y jeter un œil ou tout jeter plus tard. »

Si oui :
```bash
BACKUP_DIR="$HOME/Documents/claudia-sauvegarde-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"
cp -R ~/Documents/Claudia/profil.md ~/Documents/Claudia/memoire.md ~/Documents/Claudia/contexts "$BACKUP_DIR/" 2>/dev/null || true
```

Confirmer avec le chemin exact où la sauvegarde a été faite.

### Étape 3 — Double confirmation

> « Dernière vérification : je supprime tout maintenant ? Tape `oui, désinstalle` pour confirmer. Autre chose = j'annule. »

Si la personne répond exactement `oui, désinstalle` (ou une variante claire type `confirme` / `vas-y`), procéder. Sinon → *« OK, j'arrête ici. Rien n'a été supprimé. »*

### Étape 4 — Suppression propre

Exécuter dans cet ordre (chaque étape encapsulée, ne pas s'arrêter à la première erreur — informer et continuer) :

```bash
# 0. Résoudre les vrais chemins (Claudia peut être déplacée / sous OneDrive)
source "$HOME/Documents/Claudia/lib/paths.sh" 2>/dev/null || {
    CLAUDIA_HOME="$HOME/Documents/Claudia"
    CLAUDIA_STATE="$HOME/.claudia"
}
[ -f "$HOME/.claudia/root" ] && CLAUDIA_HOME="$(cat "$HOME/.claudia/root")"

# 1. Retirer les hooks et skills déployés
for f in ~/.claude/hooks/*.sh; do
  [ -f "$f" ] && rm -f "$f"
done
for f in ~/.claude/commands/*.md; do
  [ -f "$f" ] && rm -f "$f"
done

# 2. Retirer la ligne Claudia dans ~/CLAUDE.md
if [ -f ~/CLAUDE.md ]; then
  cp ~/CLAUDE.md ~/CLAUDE.md.bak-avant-desinstall-$(date +%Y%m%d)
  grep -v "Documents/Claudia/core.md" ~/CLAUDE.md > ~/CLAUDE.md.tmp && mv ~/CLAUDE.md.tmp ~/CLAUDE.md
  [ ! -s ~/CLAUDE.md ] && rm ~/CLAUDE.md
fi

# 3. Supprimer le dossier Claudia (contenu personnel)
rm -rf "$CLAUDIA_HOME"

# 4. Supprimer l'état interne
rm -rf "$CLAUDIA_STATE"
```

**Sur Windows**, adapter les chemins :
- `~/Documents/Claudia/` = `[Environment]::GetFolderPath('MyDocuments')/Claudia/`
- `~/.claudia/` = `$env:LOCALAPPDATA/Claudia/`

### Étape 5 — Log final visible

Écrire un petit fichier de log dans le dossier Documents de la personne (visible, pas caché) :

```
~/Documents/claudia-desinstallation-[date].txt
```

Contenu :
```
Claudia a été désinstallée le [date exacte].

Sauvegarde de tes données : [chemin ou "aucune sauvegarde demandée"]
Fichiers supprimés : [liste des chemins]

Pour réinstaller un jour, tape dans ton terminal :
  Linux/Mac : curl -fsSL https://raw.githubusercontent.com/mushadows/claudia/main/bootstrap.sh | bash
  Windows   : iwr -useb https://raw.githubusercontent.com/mushadows/claudia/main/bootstrap.ps1 | iex

À bientôt peut-être. — Claudia
```

### Étape 6 — Message de sortie

> « C'est fait. Tout est retiré de ta machine.
> [Si sauvegarde] Ta copie de sauvegarde est là : [chemin]
> Le petit récap de ce qui a été fait est dans : [chemin du log]
>
> Si un jour tu veux me réinstaller, la commande est dans le récap. À bientôt. »

Ne pas continuer la conversation après — l'user a demandé à partir.

---

## Cas particuliers

- **Si `~/Documents/Claudia/` a été déplacé** : lire `~/.claudia/root` pour trouver le vrai chemin
- **Si la personne annule après sauvegarde** : conserver la sauvegarde, ne rien supprimer
- **Si erreur pendant la suppression** : ne pas paniquer, lister ce qui a été fait vs ce qui a échoué, proposer de finir manuellement
- **Ne jamais toucher** à `~/.claude/settings.json` : c'est global à Claude Code, l'utilisateur pourrait s'en servir pour d'autres choses. Restaurer la version pré-Claudia depuis le backup le plus ancien `.bak-*` si présent.
