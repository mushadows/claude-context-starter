---
description: Met en ligne un site ou un service. Pour les personnes qui gèrent un site ou un serveur (opt-in).
audience: utilisateurs techniques ou personnes qui gèrent activement un site / un serveur
---

# /deploy — Mettre en ligne

Ce skill sert à mettre en ligne un site ou un service qui tourne quelque part (serveur perso, hébergeur, machine à la maison). Si tu ne gères pas ce genre de chose, ce skill n'est pas pour toi — dis simplement à Claudia ce que tu veux faire et elle trouvera mieux.

## Préparation

```bash
source "$CLAUDIA_HOME/lib/paths.sh"
```

## Arguments : `$ARGUMENTS`

- Sans argument → repérer le projet depuis le dossier où on est
- Avec argument → utiliser le projet nommé (ex: `/deploy mon-site`)

## Étapes

### 1. Repérer le projet et sa façon de se mettre en ligne

```bash
pwd
cat ETAT.md 2>/dev/null | grep -A2 "Déploiement\|deploy\|Mise en ligne"
ls deploy.sh Dockerfile docker-compose.yml 2>/dev/null
```

Chercher dans l'ordre :
- `deploy.sh` à la racine → `./deploy.sh`
- `docker-compose.yml` → `docker compose up -d --build`
- `Dockerfile` seul → construction + lancement manuel (demander les paramètres)
- Fichier de contexte du projet dans `$CLAUDIA_HOME/contexts/` → lire la commande documentée

### 2. Vérifier l'état du dossier

```bash
git status --porcelain 2>/dev/null
git diff --stat HEAD 2>/dev/null
```

Si des fichiers modifiés ne sont pas encore sauvegardés → avertir :

> « Attention, il y a des changements pas encore sauvegardés. Si la mise en ligne tourne mal, ça va être plus dur de comprendre pourquoi. On sauvegarde d'abord, ou on y va quand même ? »

### 3. Lancer les tests si disponibles

```bash
ls package.json 2>/dev/null && grep -q '"test"' package.json && npm test -- --passWithNoTests 2>/dev/null
ls go.mod 2>/dev/null && go test ./... 2>/dev/null
```

Si les tests échouent → stopper et afficher l'erreur. Ne pas mettre en ligne.
Si pas de tests → continuer sans bloquer.

### 4. Mettre en ligne

Lancer la commande repérée à l'étape 1.
Pour un `deploy.sh` : vérifier qu'il est exécutable (`chmod +x deploy.sh`).

### 5. Vérifier le résultat

Si Docker :

```bash
docker ps --filter name=[projet] --format "{{.Names}} {{.Status}}"
```

- Container `Up` → c'est en ligne, informer en une ligne
- Container absent ou `Exited` → afficher `docker logs [projet] --tail 30` pour comprendre

### 6. Mettre à jour le fichier d'avancement

Si la mise en ligne a réussi → mettre à jour la section **Dernière session** dans `ETAT.md` (si présent).

Informer en une ligne :
> « C'est en ligne. Si quelque chose cloche, dis-le, je regarde. »
