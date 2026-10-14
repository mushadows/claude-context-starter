# RULES_GENERIC.md
Conventions communes à tout le code. Valeurs par défaut — l'interview les ajuste. `RULES_LANGAGES.md` surcharge ce fichier pour un langage donné ; modifier une règle ici → vérifier la surcharge correspondante.
## Langue
- Commentaires et messages utilisateur : langue de `core.md` — identifiants de code : anglais
## Nommage
- Variables, fonctions : `camelCase` — classes, types : `PascalCase` — constantes de config : `UPPER_SNAKE_CASE` — classes CSS : `kebab-case`
## Format
- Indentation : 2 espaces (ajuster : tabs, 4 espaces)
- Accolades : ouvrante sur la même ligne (K&R) (ajuster : Allman)
- LF final obligatoire
## Structure
- Guard clauses en tête de fonction avant tout traitement
- Imports groupés : lib externe → modules locaux → config/utils
- Réutiliser l'existant avant d'écrire (composants, helpers, utils)
## Documentation
- README schématique : tableaux, arbres de fichiers, commandes. Toute explication longue va dans `docs/*.md`
