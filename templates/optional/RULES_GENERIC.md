SETUP_REQUIRED

---

> Si tu codes, copie ce fichier dans `contexts/` et adapte-le à tes préférences.
> Si tu ne codes pas, ignore-le.
>
> Template de base :

# RULES_GENERIC.md

Source unique des règles communes à tout le code.

## Exceptions

Une règle propre à un langage peut être ajoutée dans `ctx-dev.md` et a alors priorité.

---

## Langue
- UI, messages d'erreur, commentaires : [à définir selon la langue choisie]
- Identifiants de code : anglais

## Nommage
- Variables, fonctions : `camelCase`
- Classes, types, interfaces : `PascalCase`
- Constantes de configuration : `UPPER_SNAKE_CASE`
- Classes CSS : `kebab-case`

## Indentation
- [à définir : tabs ou espaces, taille]

## Accolades
- [à définir : Allman / K&R / autre]

## Structure
- Guard clauses en tête de fonction avant tout traitement
- Imports groupés : lib externe → composants locaux → config/utils

## Fichiers
- Retour à la ligne en fin de fichier
