# ctx-dev.md — Règles de code
> SETUP_REQUIRED — adapter aux langages de tes projets.
> Actif pour tout projet de code. Sources : RULES_GENERIC.md + RULES_LANGAGES.md

## Règles universelles
- **Langue** : UI/messages/commentaires en [SETUP_REQUIRED : ta langue] — identifiants en anglais
- **Nommage** : variables/fonctions `camelCase` · classes/types `PascalCase` · constantes `UPPER_SNAKE_CASE` · CSS `kebab-case`
- **Indentation** : SETUP_REQUIRED (ex: tabs de 4, 2 espaces)
- **Accolades** : SETUP_REQUIRED (ex: Allman — ouvrante à la ligne suivante)
- **Structure** : guard clauses en tête, imports groupés (lib externe → composants → utils)
- **Fin de fichier** : LF final obligatoire

## TypeScript / TSX / JavaScript
- `type`/`interface` : `;` après chaque membre y compris le dernier
- Props : `interface` avec suffix `Props` — shapes de données : `lowercase` sans suffix
- Composants : `export default function NomComposant`
- Async dans `useEffect` : fonction nommée déclarée puis appelée (pas d'IIFE)
- Pattern erreur : `(err instanceof Error) ? err.message : "Erreur inconnue"`
- Valeurs par défaut : `??` (nullish) pas `||`
- Fetch : `if (!res.ok) throw new Error(\`HTTP ${res.status}\`)` + `credentials: 'include'` + `await`
- `BASE_URL` depuis `config/constants` — jamais hardcodé

## React — règle composants (NON NÉGOCIABLE)
Avant d'écrire du JSX :
1. `ls src/components/` — lister les composants existants
2. Lire les composants pertinents pour connaître leurs props exactes
3. Construire avec les existants — JSX inline en dernier recours

## Go
Conventions à compléter à l'observation du code source.

## Docker / Docker Compose
- Indentation : 2 espaces — clé `environment` (pas `environnement`)
- Secrets via `.secrets/` ou env — jamais hardcodés
- Volumes : chemins vérifiés contre la structure réelle du repo

## SQL
- ENGINE InnoDB explicite sur toutes les tables avec FK
- Types cohérents entre clé primaire et clé étrangère

## YAML / HTML / CSS
- YAML : 2 espaces — HTML : `lang` correct sur `<html>` — CSS/HTML : tabs

## Bash
Conventions à compléter à l'observation du code source.
