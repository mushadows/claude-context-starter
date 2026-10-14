Workflow de déploiement guidé (version générique, à adapter par projet).
## Arguments : `$ARGUMENTS`
Sans argument → projet du cwd. Avec argument → projet nommé.
## Étapes
### 1. Identifier la commande de déploiement
```bash
pwd
grep -iA2 "déploiement\|deploy" ETAT.md 2>/dev/null
ls deploy.sh Dockerfile docker-compose.yml compose.yml Makefile 2>/dev/null
```
Ordre de recherche : section « Déploiement » de l'état projet → module `contexts/ctx-[projet].md` → script `deploy.sh` / cible `make deploy` / `docker compose up -d --build`. Si rien n'est trouvé → demander la commande, puis la noter dans le module ctx du projet. Ne jamais deviner une cible de déploiement.
### 2. Vérifier l'état du repo
```bash
git status --porcelain
git diff --stat HEAD
```
Fichiers non commités → avertir et demander confirmation (un déploiement depuis un état non commité est difficile à tracer).
### 3. Lancer les tests si disponibles
```bash
[ -f package.json ] && grep -q '"test"' package.json && npm test -- --passWithNoTests
[ -f go.mod ] && go test ./...
{ [ -f pyproject.toml ] || [ -f pytest.ini ]; } && python3 -m pytest -q
```
Tests en échec → stopper, afficher l'erreur, ne pas déployer. Pas de tests → continuer.
### 3bis. Audit sécurité si zones sensibles
Si le diff touche l'auth, les comptes, les endpoints API ou des variables d'env sensibles → lancer `/security-audit [projet]` avant de continuer. Ne pas bloquer pour le reste.
### 4. Déployer
Exécuter la commande identifiée (`chmod +x deploy.sh` si besoin). Signaler les points propres au projet notés dans son module ctx (builds longs, migrations, checkpoint de base de données avant arrêt…).
### 5. Vérifier le résultat
- Conteneurs : `docker ps --filter name=[projet] --format "{{.Names}} {{.Status}}"` ; si absent ou `Exited` → `docker logs [projet] --tail 30`.
- Sinon : requête sur l'URL de santé du service (`curl -sI`).
Succès → informer en une ligne.
### 6. Mettre à jour l'état
Succès → mettre à jour **Dernière session** dans l'état projet (`ETAT.md` ou `$CTX/etat/[projet].md`, `CTX="$(cat "$HOME/.claude/context-dir" 2>/dev/null || echo "$HOME/dev/claude-context")"`), sans committer dans un repo en lecture seule.
