SETUP_REQUIRED

---

> Ce fichier sera généré automatiquement lors de l'interview de configuration si tu codes.
> Si tu ne codes pas, ce fichier reste vide et est ignoré.
>
> Voici le template de base qui sera personnalisé selon tes préférences :

# RULES_GENERIC.md

Source unique des règles communes à tout le code.

## Exceptions

Toute règle de ce fichier peut être surchargée par langage dans `RULES_LANGAGES.md`.
En cas de conflit, `RULES_LANGAGES.md` a priorité pour le langage concerné.

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
