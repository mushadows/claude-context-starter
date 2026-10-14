# ctx-dev.md — Règles de code
> Actif pour tout projet de code. Sources : `RULES_GENERIC.md` (commun) + `RULES_LANGAGES.md` (surcharges par langage, prioritaires). Ajuster aux conventions réelles de l'utilisateur.

## Règles universelles
Langue, nommage, guard clauses, imports, LF, réutilisation : voir `RULES_GENERIC.md` (source unique).
- Commentaires : seulement le « pourquoi » non évident, pas de docstrings multi-paragraphes

## Qualité
- Valider aux frontières de confiance (entrées utilisateur, réseau, fichiers) ; pas de validation défensive interne inutile
- Secrets : jamais dans le code ni dans git (`.env` ignoré, variables d'env ou secret manager)
- Bug : corriger la cause racine (grep tous les appelants), pas le symptôme
- Logique non triviale : un test ou un self-check minimal

## Git
- Commits atomiques, message à l'impératif, préfixe optionnel (`feat:`, `fix:`, `chore:`)
- `.gitattributes` avec `*.sh text eol=lf` si le projet est touché depuis Windows (CRLF casse les scripts shell dans Docker)

## Par langage
Voir `RULES_LANGAGES.md` (seulement les langages utilisés par l'utilisateur).
