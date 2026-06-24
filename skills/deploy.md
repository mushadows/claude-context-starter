Workflow de déploiement guidé pour les projets avec un script de déploiement.

## Arguments : `$ARGUMENTS`

Sans argument → détecter le projet depuis le cwd courant.
Avec argument → utiliser le projet nommé (ex: `/deploy mon-projet`).

## Étapes

### 1. Identifier le projet et sa commande de déploiement
```bash
pwd
cat ETAT.md 2>/dev/null | grep -A2 "Déploiement\|deploy"
ls deploy.sh Dockerfile docker-compose.yml 2>/dev/null
```

Chercher dans cet ordre :
- `deploy.sh` à la racine → `./deploy.sh`
- `docker-compose.yml` → `docker compose up -d --build`
- `Dockerfile` seul → build + run manuel (demander les paramètres)
- Module ctx-* du projet dans `~/dev/my-context/contexts/` → lire la commande de déploiement documentée

### 2. Vérifier l'état du repo
```bash
git status --porcelain
git diff --stat HEAD
```
Si des fichiers non commités existent → avertir et demander confirmation avant de continuer.
(Un déploiement depuis un état non commité peut être difficile à tracer.)

### 3. Lancer les tests si disponibles
```bash
ls package.json 2>/dev/null && grep -q '"test"' package.json && npm test -- --passWithNoTests 2>/dev/null
ls go.mod 2>/dev/null && go test ./... 2>/dev/null
```
Si les tests échouent → stopper et afficher l'erreur. Ne pas déployer.
Si pas de tests → continuer sans bloquer.

### 4. Déployer
Exécuter la commande de déploiement identifiée à l'étape 1.
Pour `deploy.sh` : s'assurer que le script est exécutable (`chmod +x deploy.sh`).

### 5. Vérifier le résultat
Si Docker :
```bash
docker ps --filter name=[projet] --format "{{.Names}} {{.Status}}"
```
- Container `Up` → succès, informer en une ligne
- Container absent ou `Exited` → afficher `docker logs [projet] --tail 30` pour diagnostic

### 6. Mettre à jour ETAT.md
Si le déploiement réussit → mettre à jour la section **Dernière session** dans ETAT.md.
