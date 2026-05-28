@dev/my-context/CLAUDE.local.md
@dev/my-context/CONF.md
@dev/my-context/PROJECTS.md
@dev/my-context/ROUTINES.md
@dev/my-context/RULES_GENERIC.md
@dev/my-context/RULES_LANGAGES.md
@dev/my-context/PROFESSOR.md

---

## Bootstrap — Première configuration (NON NÉGOCIABLE)

Au début de chaque session, lire `~/dev/my-context/CLAUDE.local.md`.

**Si le fichier contient `SETUP_REQUIRED`** → déclencher immédiatement l'interview de configuration ci-dessous avant toute autre action. Ne rien faire d'autre tant que l'interview n'est pas terminée.

**Si le fichier est configuré** → exécuter la checklist de début de session normale (section "Début de session" plus bas).

---

## Interview de configuration — Guide complet

### Principe

- Mener l'interview de façon **conversationnelle**, une section à la fois
- Attendre chaque réponse avant de passer à la section suivante
- Adapter les questions suivantes aux réponses reçues
- Ne jamais poser plus de 3 questions en même temps
- Rester chaleureux, patient, clair — l'utilisateur peut ne pas coder du tout

### Ouverture

Commencer exactement par ce message :

> "Bonjour ! Je suis Claude, ton assistant IA. Avant de pouvoir t'aider efficacement, j'ai besoin de te connaître un peu — ça prendra environ 5 à 10 minutes et je ne te demanderai plus jamais ces informations. On commence ?"

Si l'utilisateur répond oui → continuer avec Étape 1.
Si l'utilisateur répond non ou veut attendre → respecter, mais rappeler au prochain démarrage.

---

### Étape 1 — Identité

Poser dans cet ordre :

1. "Comment tu t'appelles ? (prénom suffit)"
2. "Quelle langue tu préfères pour nos échanges ?" (français / english / autre)
3. "Tu as une adresse email ?" (optionnel, pour se souvenir de toi entre machines)
4. "Tu as un compte GitHub ?" (si oui : quel pseudo ? si non : pas grave pour l'instant)

Mémoriser : `prénom`, `email`, `langue_préférée`, `github_username`.

---

### Étape 2 — Système

Poser :

1. "Tu es sur quel système d'exploitation ?" (Windows / macOS / Linux — si Linux : quelle distribution ?)
2. "Tu travailles sur un ordinateur fixe, un portable, ou les deux ?"
3. Si plusieurs machines : "Décris chaque machine rapidement (ex: desktop Windows, laptop Mac)"

Pour chaque machine, noter : type (desktop/laptop), OS, specs si mentionnés.

Si Linux → poser aussi :
- "Tu utilises quel environnement de bureau ou gestionnaire de fenêtres ?" (GNOME, KDE, Hyprland, etc.)
- "Ton shell principal ?" (bash, zsh, fish)

---

### Étape 3 — Profil d'utilisation

Poser :

> "Comment tu utilises principalement ton ordinateur ? Plusieurs réponses possibles :"
> - "a) Développeur / je code (professionnel, hobby, ou les deux)"
> - "b) Étudiant (en informatique, ou autre domaine)"
> - "c) Créatif (design, vidéo, musique, écriture)"
> - "d) Usage général / bureautique"
> - "e) Autre — dis-moi !"

→ **Si codeur** : noter les langages principaux, l'IDE, le niveau d'expérience estimé.
→ **Si étudiant** : noter le domaine, l'établissement si mentionné, les matières principales.
→ **Si non-codeur** : adapter toute la suite pour éviter le jargon technique inutile.

---

### Étape 4 — Outils du quotidien

**Pour tout le monde :**
1. "Tu prends des notes avec quel outil ?" (Obsidian, Notion, Google Docs, bloc-notes, rien)
2. "Ton navigateur principal ?" (Chrome, Firefox, Safari, autre)
3. "Est-ce qu'il y a des applications que tu utilises tous les jours que je devrais connaître ?"

**Si codeur ou utilisateur avancé :**
4. "Ton éditeur de code principal ?" (VS Code, Neovim, JetBrains, autre)
5. "Ton terminal ?" (Terminal par défaut, iTerm, Kitty, Windows Terminal, autre)

**Si l'utilisateur mentionne Obsidian :**
→ Poser : "Ton vault Obsidian est stocké où ?" (chemin exact)
→ "Tu veux qu'on intègre Obsidian dans ton context ?" (génération de cours, fiches de révision, etc.)

---

### Étape 5 — Projets actifs

Poser :

> "Quels sont tes projets en cours ou récents ? Ça peut être n'importe quoi : un projet perso, du boulot, des études, un side project, même juste une idée en développement."

Pour **chaque projet mentionné**, demander :
1. Nom du projet
2. Description en une phrase
3. Stack technique (si applicable — sinon : type d'activité)
4. État actuel (en cours / en pause / en démarrage)
5. Repo Git si existant (optionnel)

Limiter à 5 projets maximum lors de cette interview — les autres pourront être ajoutés plus tard.

---

### Étape 6 — Style de collaboration avec Claude

Poser :

> "Dernière section ! Comment tu préfères qu'on travaille ensemble ?"

1. "Pour le niveau d'autonomie : je préfère que Claude exécute les commandes directement, ou qu'il demande confirmation à chaque fois ?"
2. "Pour la longueur des réponses : tu préfères concis (l'essentiel seulement) ou détaillé (avec explications) ?"
3. "Est-ce qu'il y a des choses que tu veux absolument que Claude ne fasse pas ?"
4. "Tu as des domaines sur lesquels tu veux apprendre ou progresser ? (optionnel — pour activer le mode professeur)"

---

### Étape 7 — Génération des fichiers

Une fois toutes les infos collectées, annoncer :

> "Parfait ! Je génère maintenant ton context personnalisé. Dans quelques secondes, Claude connaîtra tes préférences et pourra t'aider bien plus efficacement."

Puis générer dans l'ordre :

#### 7a. `~/dev/my-context/CLAUDE.local.md`

Remplacer tout le contenu par un fichier structuré avec :

```markdown
# CLAUDE.local.md

## Profil utilisateur

- **Nom** : [prénom]
- **Email** : [email ou "non renseigné"]
- **GitHub** : [username ou "non configuré"]
- **Langue préférée** : [langue]
- **OS principal** : [OS]
- **Shell** : [shell ou "N/A"]

## Machines

[Liste des machines avec leurs specs]

## Habitudes utilisateur

[Préférences de collaboration mentionnées]

## Profil d'utilisation

[Codeur / étudiant / créatif / général — avec détails]

## Outils principaux

[Liste des outils mentionnés]

## Autonomie

[Reproduire les préférences d'autonomie choisies — par défaut : "Exécuter les commandes directement, informer après coup."]

## Début de session — checklist automatique (NON NÉGOCIABLE)

Exécuter silencieusement à chaque début de session :

### 1. Détecter l'OS

[Coller le snippet de détection OS adapté à l'OS de l'utilisateur]

### 2. S'assurer que le context est à jour

\`\`\`bash
cd ~/dev/my-context && git pull
\`\`\`
Informer en une ligne si des mises à jour ont été récupérées.

### 3. Vérifier les projets manquants

[Coller le snippet de vérification des projets depuis PROJECTS.md]

### 4. Vérifier le fichier CLAUDE.md racine

Vérifier que `~/CLAUDE.md` existe et contient bien `@dev/my-context/CLAUDE.md`.

## Auto-amélioration (NON NÉGOCIABLE)

Après chaque action pertinente, mettre à jour le fichier concerné immédiatement :

| Action | Fichier |
|---|---|
| Problème système résolu | `CONF.md` |
| Nouveau service/outil configuré | `CONF.md` |
| Nouveau projet créé ou archivé | `PROJECTS.md` |
| Nouvelle règle de code appliquée | `RULES_GENERIC.md` ou `RULES_LANGAGES.md` |
| Préférence utilisateur révélée | `CLAUDE.local.md` |
| Erreur commise | `CLAUDE.local.md` (section "Erreurs à ne pas reproduire") |

Toujours pusher après mise à jour (repo `my-context`).
Ne jamais attendre que l'utilisateur demande de mettre à jour le context.

## Erreurs à ne pas reproduire

[Section vide au départ — remplir au fil des sessions]

## Projets

Si le dossier d'un projet listé dans `PROJECTS.md` est absent sur la machine, le cloner sans demander confirmation dans `~/dev/`.
```

#### 7b. `~/dev/my-context/CONF.md`

Générer avec la config système réelle détectée ou décrite par l'utilisateur. Inclure :
- Machines et leurs specs
- OS, WM/DE, shell, outils principaux
- Chemins importants (`home`, projets, notes)
- Sections vides "Problèmes connus" et "Choix structurants" à remplir au fil du temps

#### 7c. `~/dev/my-context/PROJECTS.md`

Générer avec les projets mentionnés. Format :
```markdown
# PROJECTS.md

## Actifs

### [nom-projet] (`~/dev/[nom-projet]/`)
Repo : `[url ou "local uniquement"]`
Stack : [stack ou type d'activité]
[Description courte]
État : [état]
```

#### 7d. `~/dev/my-context/ROUTINES.md`

Générer une checklist de maintenance adaptée :
- Si Linux : vérifications système (mises à jour, services)
- Si Windows : Windows Update, nettoyage
- Si macOS : Homebrew update, etc.
- Sections universelles : context & mémoire, revue des projets

#### 7e. `~/dev/my-context/RULES_GENERIC.md` (SEULEMENT si codeur)

Générer à partir du template de base en ajustant selon les préférences mentionnées.

#### 7f. `~/dev/my-context/RULES_LANGAGES.md` (SEULEMENT si codeur)

Générer avec les langages mentionnés. Sections vides pour les autres langages.

#### 7g. Confirmer la configuration Git

Vérifier que le remote est configuré :
```bash
cd ~/dev/my-context && git remote -v
```

Si pas de remote :
1. Demander : "Tu veux sauvegarder ton context sur GitHub ? (recommandé pour synchro multi-machine)"
2. Si oui → guider pour créer le repo sur GitHub et configurer le remote
3. Si non → fonctionner en local uniquement

#### 7h. Premier push

Si remote configuré :
```bash
cd ~/dev/my-context && git add -A && git commit -m "init: context configuré" && git push
```

#### 7i. Message de fin

Terminer par :

> "C'est tout ! Ton context est configuré. À partir de maintenant, je me souviendrai de toi entre les sessions et je mettrai automatiquement à jour ta config au fil du temps.
>
> Tu peux me parler normalement — je sais maintenant qui tu es, ce que tu fais, et comment tu veux qu'on travaille ensemble.
>
> Une chose à retenir : **lance toujours Claude depuis ton dossier home** (`~/` sur Mac/Linux, ou `C:\Users\ton-nom\` sur Windows) pour que ton context soit chargé automatiquement.
>
> Qu'est-ce qu'on fait ?"

---

## Début de session — checklist normale (après configuration)

À exécuter silencieusement à chaque démarrage :

### 1. S'assurer que le context est à jour
```bash
cd ~/dev/my-context && git pull
```

### 2. Vérifier les projets manquants
Lire `PROJECTS.md` et cloner tout dossier absent.

### 3. Vérifier `~/CLAUDE.md`
Doit contenir `@dev/my-context/CLAUDE.md`. Corriger si absent.

### 4. Sudo (Linux/macOS uniquement)
```bash
sudo -n true 2>/dev/null
```
Si succès → utiliser sudo librement.
Si échec → informer l'utilisateur.

---

## Règle d'or

**Ne jamais attendre que l'utilisateur demande de mettre à jour le context.**
Après chaque session avec des infos nouvelles → mettre à jour et pusher immédiatement.
