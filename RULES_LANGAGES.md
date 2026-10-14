# RULES_LANGAGES.md
Conventions par langage, prioritaires sur `RULES_GENERIC.md`. Garder uniquement les langages utilisés ; compléter à l'observation du code réel.
## TypeScript / JavaScript
- `??` plutôt que `||` pour les valeurs par défaut
- Fetch : `await` (pas de `.then()` chaîné), vérifier `res.ok`, URL de base depuis la config — jamais en dur
- Erreurs : `(err instanceof Error) ? err.message : "Unknown error"`
- Async dans `useEffect` : fonction nommée puis appelée (pas d'IIFE)
## Python
- `snake_case`, type hints sur les API publiques, `pathlib` plutôt que `os.path`
## Go
- `gofmt` fait foi ; erreurs retournées et vérifiées, jamais ignorées
## Bash
- `set -euo pipefail` ; variables entre guillemets ; portabilité Linux/Git Bash (voir `core.md`)
## Docker / Compose
- YAML en 2 espaces ; secrets via Docker secrets ou env, jamais en dur ; volumes vérifiés contre la structure réelle ; monter le dossier parent plutôt qu'un fichier
## SQL
- Types cohérents entre clé primaire et clé étrangère ; moteur transactionnel explicite si le SGBD le demande
## YAML / HTML / CSS
- YAML 2 espaces ; `lang` renseigné sur `<html>` ; CSS en `kebab-case`
