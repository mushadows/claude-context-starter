---
description: Hub central pour ajuster Claudia (profil, raccourcis, connecteurs, historique, pause, désinstallation)
---

# /claudia — Le menu central

Point d'entrée unique pour tout ce qui touche à Claudia elle-même : profil, mémoire, raccourcis, connecteurs, désinstallation.

## Comportement

Quand la personne tape `/claudia` (ou dit « claudia » tout court dans une conversation), afficher ce menu simple :

```
Que veux-tu faire ?
  1. Modifier ce que tu m'as dit sur toi
  2. Ajouter une info dont je devrais me souvenir
  3. Voir ou créer un raccourci
  4. Brancher un outil (agenda, drive, mails)
  5. Revoir ce qu'on a fait ensemble récemment
  6. Faire une pause / me désinstaller
  7. Rien, retour à notre conversation
```

Attendre le choix. Un chiffre ou une phrase courte suffit.

---

## Action 1 — Modifier ce que Claudia sait

> « Dis-moi ce qu'on change (ex : *je change de métier*, *appelle-moi autrement*, *je n'utilise plus Google Agenda*). »

Écouter, comprendre, modifier `profil.md` en conséquence, confirmer en une ligne.

## Action 2 — Ajouter une info à retenir

> « Vas-y, raconte — je note et je te confirme où je l'ai rangée. »

Ajouter à `memoire.md` avec un horodatage. Signaler la ligne ajoutée :
> « C'est noté dans ma mémoire : *[extrait]*. Je m'en souviendrai à nos prochaines discussions. »

## Action 3 — Raccourcis

> « Tu veux voir la liste de tes raccourcis, ou en créer un nouveau ? »

- **Voir** → lister les skills disponibles dans `skills/` avec leur nom et une phrase courte. Adapter le nom au vocabulaire de la personne (pas de jargon).
- **Créer** → poser 3 questions :
  1. « Quel nom pour ton raccourci ? (ex: `/mails-semaine`) »
  2. « Que doit-il faire exactement ? »
  3. « Sous quel format ta réponse arrive-t-elle en général ? »
  Puis créer `skills/[nom].md` avec le contenu approprié. Confirmer : *« Ton raccourci est prêt. Essaie `/[nom]` pour voir. »*

## Action 4 — Brancher un outil externe

> « Quel outil ? (agenda, drive, mails, autre) — je te guide côté navigateur. »

Rappeler que les connecteurs (Google Drive, Google Agenda, Gmail, Notion, GitHub…) se branchent depuis **claude.ai dans le navigateur**, pas ici. Donner la marche à suivre pas-à-pas avec les mots simples :

1. Ouvrir `claude.ai` dans le navigateur
2. Aller dans les Réglages → « Connectors » ou « Passerelles »
3. Choisir l'outil, cliquer « Connecter »
4. Se connecter à son compte (Google, Microsoft…)
5. Revenir ici, taper `claudia connecteur ajouté [outil]` pour que Claudia le note dans le profil et l'utilise à bon escient

**Toujours prévenir avant l'ajout :** si l'outil touche à une zone marquée sensible dans le profil, alerter — *« Tu m'avais dit de faire attention avec X. Brancher cet outil signifie que Claude aura accès à Y. On continue ? »*

## Action 5 — Historique récent

> « Je te fais un résumé des 7 derniers jours ? Ou tu veux voir un jour précis ? »

Lire `memoire.md` + les entrées récentes des `ctx-*.md` pour produire un récap. Format : liste de bullets par jour, une ligne par échange notable.

## Action 6 — Pause ou désinstallation

Deux sous-options :

**Pause** :
> « OK, je me tais jusqu'à ton prochain bonjour. Pour reprendre, tape juste `claude` et dis-moi salut. »

Ne rien supprimer. Marquer dans `profil.md` la mise en pause.

**Désinstallation** :
> « Tu es sûre ? Ça va retirer Claudia complètement de ta machine. Ce qui va être supprimé :
> - Le dossier `~/Documents/Claudia/` (tes fichiers profil et mémoire)
> - Les automatismes Claude Code (`~/.claude/hooks/`, `~/.claude/commands/`)
> - La ligne dans `~/CLAUDE.md`
> - Le dossier interne `~/.claudia/` (logs, versions Node isolées)
>
> Tu veux que je te sauvegarde tes fichiers profil et mémoire dans ton dossier Documents avant ? »

Si oui à la sauvegarde → copier `profil.md`, `memoire.md`, `contexts/` vers `~/Documents/claudia-sauvegarde-[date]/`.

Puis exécuter la désinstallation propre (voir `skills/desinstaller.md` pour le détail).

## Action 7 — Retour à la conversation

> « OK, on reprend. »

Ne rien faire. Enchaîner immédiatement sur le sujet précédent si contexte disponible.

---

## Règles

- Le menu ne reste pas ouvert : dès qu'une action est faite, phrase courte de confirmation et retour à la conversation normale
- `annule` ou `échap` à n'importe quel moment ramène à la conversation
- Jamais d'action destructive sans double confirmation
- Toujours confirmer en une ligne ce qui a été fait, jamais en silence
