# /security-audit — Audit sécurité DevSecOps
Audit défensif d'une app web (code source + service déployé) contre les classes de vulnérabilités les plus courantes : auth uniquement côté client, secrets embarqués dans le bundle, endpoints non protégés, etc.
**Argument :** `$ARGUMENTS` — nom du projet ou vide → détecter depuis le cwd. Peut aussi être une URL déployée seule si le code n'est pas disponible localement.
## Quand ce skill doit tourner (rappel comportemental)
- **Proposer/lancer** avant un premier déploiement d'un service avec backend + auth ou API.
- **Proposer/lancer** après une modification touchant : auth, comptes/utilisateurs, endpoints API, variables d'env sensibles, build frontend (variables d'env injectées par Vite/webpack).
- **Sur jugement** : pattern suspect repéré en travaillant (comparaison de mot de passe, `VITE_*`/`NEXT_PUBLIC_*` au nom sensible, route sans middleware visible) → proposer l'audit avant de continuer.
- Toujours utilisable manuellement : `/security-audit [projet]`.
## Phase 1 — Périmètre
Identifier :
- Le repo local (cwd ou chemin indiqué dans `PROJECTS.md`)
- L'URL déployée si applicable (`PROJECTS.md` → section du projet)
- La stack (backend, framework frontend) — détermine quels checks s'appliquent
Repo non cloné localement → le cloner uniquement s'il est listé dans `PROJECTS.md` et si les règles d'autonomie de `core.md` le permettent.
## Phase 2 — Checks statiques (code source)
### Auth & contrôle d'accès
- [ ] Toute route qui modifie des données (POST/PUT/PATCH/DELETE) a un middleware d'auth serveur explicite — pas seulement un gate visuel côté frontend (`sessionStorage`, `useState`, comparaison JS locale)
- [ ] Toute route qui renvoie des données sensibles (PII : emails, noms, tokens) est protégée par la même auth
- [ ] Grep des comparaisons de mot de passe/secret côté **frontend** : `import.meta.env.VITE_*`, `process.env.NEXT_PUBLIC_*`, `process.env.REACT_APP_*` au nom sensible (`PASSWORD`, `SECRET`, `KEY`, `TOKEN`, `ADMIN`) → bundle public, donc fuite garantie ; à vérifier côté serveur uniquement
- [ ] Pas de mot de passe par défaut fragile en fallback (`?? 'admin'`, `?? 'changeme'`, `?? ''` sur un check d'auth qui laisserait passer si vide)
- [ ] Pas de réutilisation d'un même secret entre deux services distincts
### Secrets
- [ ] `git log -p --all -- '*.env' '*secret*' '*creds*'` et `git grep` sur des patterns de clé (`AIza`, `sk-`, `ghp_`, chaînes hexadécimales longues assignées à des variables `*_KEY`/`*_TOKEN`) → rien de commité en clair dans l'historique
- [ ] `.env`, `.env.local` dans `.gitignore`
- [ ] Build frontend : construire le projet (ou lire `dist/`/`build/`) et grep les valeurs de secrets connues (voir Phase 3)
### Injection / entrées utilisateur
- [ ] Requêtes DB paramétrées (pas de concaténation avec une entrée utilisateur)
- [ ] Pas de `dangerouslySetInnerHTML`/`innerHTML` avec une donnée utilisateur non sanitisée
- [ ] Pas d'`exec`/`spawn` shell avec une entrée utilisateur non échappée
- [ ] Chemins de fichier validés (pas de path traversal `../`)
### Réseau / headers
- [ ] CORS pas grand ouvert (`Access-Control-Allow-Origin: *`) sur une route qui accepte des credentials
- [ ] Rate limiting présent sur les routes d'auth / création de compte (volume faible → Medium, pas Critical)
### Dépendances
- [ ] `npm audit` / équivalent Go/Python/etc. → lister les CVE High/Critical
## Phase 3 — Checks dynamiques (service déployé, si URL disponible)
```bash
# Headers et fingerprint serveur
curl -sI https://[url]/

# Pour chaque route API identifiée en Phase 2 : sans auth, puis avec un mauvais mot de passe → 401/403 attendu
curl -s -o /dev/null -w "%{http_code}\n" https://[url]/api/[route]
curl -s -o /dev/null -w "%{http_code}\n" -H "Authorization: Bearer mauvais" https://[url]/api/[route]

# Secrets dans le bundle JS public (grep -E portable ; -P absent sur certains Git Bash)
JS=$(curl -s https://[url]/ | grep -oE 'src="/assets/[^"]+\.js"' | head -1 | sed 's/^src="//;s/"$//')
curl -s "https://[url]$JS" | grep -oE "[secrets connus du projet]"

# Fichiers sensibles exposés par erreur
for p in /.env /.git/config /.git/HEAD /config.json /debug; do
  echo "$p -> $(curl -s -o /dev/null -w '%{http_code}' "https://[url]$p")"
done
```
**Ne jamais tester de route DELETE/reset avec un ID réel sans confirmation explicite de l'utilisateur dans la session courante** — utiliser un ID inexistant : un 401 avant le 404 prouve que l'auth est en place ; un vrai résultat métier sans auth est la faille.
## Phase 4 — Rapport
Si un outil de rapport structuré est disponible (même format que `/code-review`), l'utiliser, sinon :
```
## Audit sécurité — [projet]
### Critique (exploitable maintenant, données/comptes réels en jeu)
### Important (à corriger avant le prochain déploiement)
### Mineur / durcissement (pas urgent)
### OK — vérifié et sain
```
Pour chaque finding : fichier + ligne si statique, requête curl reproductible si dynamique, et le fix concret (middleware/pattern exact cohérent avec le projet, pas juste « ajouter de l'auth »).
## Phase 5 — Fix
Par défaut, **proposer le fix et demander confirmation avant de l'appliquer** s'il touche à l'auth ou aux secrets. Si l'utilisateur a déjà demandé « corrige et redéploie » → appliquer directement, en annonçant avant tout redéploiement l'interruption attendue.
Après un fix touchant un secret : le roter (ne jamais réutiliser une valeur qui a pu fuiter), mettre à jour la doc concernée, ne jamais laisser l'ancienne valeur traîner.
## Après l'audit
Findings Critique/Important corrigés → proposer `/pentest-self [projet]` pour vérifier depuis une perspective attaquant que le fix tient.
