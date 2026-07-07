# INTERVIEW.md — Configuration initiale (première session uniquement)

> Ce fichier n'est lu que si `core.md` contient encore des `SETUP_REQUIRED`.
> Une fois l'interview terminée, il n'est plus jamais rechargé automatiquement — la checklist normale de `core.md` reprend le dessus.

## Public cible — lire avant de commencer

La personne en face n'a pas forcément de connaissances en informatique, en Git ou en ligne de commande. Elle a suivi un guide pour arriver jusqu'ici, mais ne sait pas ce qui se passe techniquement. Se comporter en conséquence :

- **Jamais de jargon non expliqué** : pas de "shell", "repo", "commit", "symlink" sans reformulation immédiate en langage courant
- **Jamais de commande à taper par l'utilisateur** pendant l'interview — Claude exécute tout lui-même (fichiers, Git). Si une commande doit vraiment être tapée par l'utilisateur (ex: `claude` pour relancer), le dire explicitement et simplement
- **Jamais de mur de questions** : poser 2 à 4 questions à la fois maximum, attendre la réponse, enchaîner
- **Toujours un choix par défaut proposé** : ne jamais poser de question ouverte sans suggestion ("Tabs ou espaces ? Par défaut je mets 2 espaces, c'est le plus courant — ça te va ?")
- **"Je ne sais pas" est une réponse valide à tout moment** → Claude choisit une valeur par défaut raisonnable et continue, sans bloquer
- **Rassurer sur la réversibilité** : rappeler une fois en début d'interview que tout peut être changé plus tard en le demandant simplement en français

## Message d'ouverture (à adapter, pas à réciter mot pour mot)

Expliquer en 2-3 phrases : ce qui va se passer (une dizaine de questions simples, 5-10 minutes), qu'aucune connaissance technique n'est requise, que Claude s'occupe de toute la partie technique (fichiers, sauvegarde), et que tout est modifiable plus tard.

## Déroulé (dans cet ordre, par groupes)

### Groupe 1 — Identité
1. Prénom ou pseudo à utiliser dans les échanges
2. Adresse email (sert à identifier les sauvegardes de fichiers)
3. Compte GitHub existant ? (c'est le service qui héberge la sauvegarde en ligne du context)
   - Si oui → nom d'utilisateur
   - Si non → proposer de créer un compte gratuit sur https://github.com/signup, attendre confirmation, ou continuer sans et revenir dessus plus tard (ne jamais bloquer l'interview pour ça)

### Groupe 2 — Machine (détecter automatiquement ce qui est détectable, ne demander que le reste)
4. Détecter l'OS soi-même (`$OSTYPE`, `uname`) — ne pas demander si détectable
5. Si Windows détecté → prévenir simplement que certaines fonctions avancées demandent le "mode développeur" de Windows, sans creuser si l'utilisateur ne comprend pas — proposer de le configurer plus tard si besoin

### Groupe 3 — Usage
6. "Est-ce que tu écris du code (développement, études en informatique...) ou pas du tout ?"
   - Non codeur → ignorer entièrement RULES_GENERIC.md / RULES_LANGAGES.md / contexts/ctx-dev.md, les laisser tels quels (vides), ne pas poser les questions de style de code
   - Codeur → langages principaux utilisés, puis proposer des valeurs par défaut plutôt que des questions ouvertes (indentation : "2 espaces, ça te va ?", accolades : "style classique (même ligne), ça te va ?")
7. Projets existants (perso ou professionnels) à suivre — noms + où ils sont hébergés (GitHub, GitLab...). Si aucun → passer, `PROJECTS.md` reste vide pour l'instant
8. Utilise-t-il/elle Obsidian pour prendre des notes ? Si oui → chemin du dossier de notes (vault)
9. Y a-t-il des projets "sensibles" où il ne faut jamais que Claude sauvegarde ou publie quoi que ce soit tout seul (ex: projet scolaire noté, projet d'un tiers) ? → noter les noms/chemins

### Groupe 4 — Organisation des fichiers (uniquement Linux/Mac — non applicable sur Windows)
10. Proposer la structure par défaut (`dev/` `Documents/` `Téléchargements/` `VM/` `wallpaper/`) en une phrase simple ("je range automatiquement les fichiers qui traînent dans ces dossiers, ça te va ou tu préfères une autre organisation ?") — ne jamais activer le rangement automatique sans cette confirmation explicite, car il déplace des fichiers

## Actions techniques (après avoir les réponses nécessaires à un groupe — pas besoin d'attendre la fin totale)

Traiter groupe par groupe, remplir au fur et à mesure plutôt que d'attendre la fin de toutes les questions :

| Réponse obtenue | Fichier(s) à mettre à jour |
|---|---|
| Prénom / GitHub / Email / OS | `core.md` (section Profil), `CLAUDE.local.md` (section Profil utilisateur) |
| Codeur oui/non + langages + style | `RULES_GENERIC.md`, `RULES_LANGAGES.md`, `contexts/ctx-dev.md` (laisser vides si non codeur) |
| Projets existants | `PROJECTS.md` (une section `###` par projet, avec le chemin `~/dev/[nom]/` entre backticks) |
| Vault Obsidian | `core.md` (table Modules context + Fichiers disponibles), décommenter le bloc Obsidian dans `hooks/session-start.sh` et `hooks/stop.sh` |
| Projets sensibles | `core.md` (section Autonomie — lister les noms), `settings-template.json` (remplacer les `SETUP_REQUIRED-projet-1/2` du hook `PreToolUse` par les vrais chemins) |
| Structure home confirmée | `core.md` (section Structure home), `CLAUDE.local.md` (§9), décommenter le bloc racine `~/` dans `hooks/session-start.sh` si accepté — sinon laisser commenté |

Ne jamais montrer à l'utilisateur le contenu brut de ces fichiers pendant l'interview sauf s'il le demande — juste confirmer en une phrase simple après chaque groupe ("C'est noté, je passe à la suite.").

## Fin d'interview

1. Vérifier que `~/CLAUDE.md` contient bien `@dev/my-context/core.md` (normalement déjà fait par `install.sh`)
2. Retirer la ligne d'avertissement en haut de `core.md` (`> Fichier généré lors de l'interview... remplacer les SETUP_REQUIRED`)
3. Vérifier qu'il ne reste plus aucun `SETUP_REQUIRED` dans les fichiers concernés par les réponses obtenues — pour les groupes sautés (ex: pas codeur), laisser les fichiers concernés inchangés, ce n'est pas une erreur
4. Sauvegarder soi-même, sans demander à l'utilisateur de taper quoi que ce soit :
   ```bash
   git -C ~/dev/my-context add -A && git commit -m "config: interview initiale" && git push
   ```
5. Message de clôture, en langage simple : confirmer que la configuration est prête, dire comment relancer Claude la prochaine fois (`cd ~` puis `claude`), et donner un ou deux exemples concrets de ce qui est possible maintenant (ex: "tu peux juste me parler normalement, je me souviendrai de tout d'une session à l'autre").

## Si l'interview est interrompue en cours de route

Au prochain lancement, ne pas repartir de zéro : relire les fichiers concernés, identifier les `SETUP_REQUIRED` restants uniquement, et ne reposer que les questions correspondantes. Ne jamais reposer une question dont la réponse est déjà visible dans un fichier.
