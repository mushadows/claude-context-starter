# Claude Context Starter

**Un context personnalisé pour Claude qui le rend vraiment utile au quotidien.**

---

## C'est quoi ?

Par défaut, Claude ne se souvient de rien entre deux conversations. Il ne sait pas qui tu es, comment tu travailles, quels projets tu as, quelles sont tes préférences.

Ce projet change ça. Il donne à Claude un **context permanent** : un ensemble de fichiers que Claude lit à chaque démarrage pour te connaître, maintenir à jour ta config système, et s'améliorer automatiquement au fil du temps.

**Ce que tu obtiens :**
- Claude se souvient de toi entre les sessions (prénom, projets, préférences)
- Ta config système est documentée et maintenue automatiquement
- Claude met à jour ses propres notes après chaque session utile
- Mode professeur pour apprendre n'importe quel sujet avec une vraie pédagogie
- Synchronisation multi-machine via Git
- Architecture modulaire : seul le context pertinent est chargé selon ton projet actif
- 3 hooks automatiques (push, sauvegarde transcript, lint)
- 6 skills slash-commands (`/etat` `/ctx` `/bilan` `/deploy` `/prof` `/agents`)
- Template ETAT.md par projet pour reprendre où tu t'es arrêté

**Pour qui ?**
Pour tout le monde — que tu codes ou non. L'interview initiale adapte le context à ton profil.

---

## Architecture modulaire

### `core.md` — le seul fichier chargé à chaque session

`~/CLAUDE.md` contient une seule ligne : `@dev/my-context/core.md`

`core.md` est court (~100 lignes) et contient :
- Ton profil (nom, OS, préférences)
- Les règles d'autonomie
- La table des modules context (quel `ctx-*.md` charger selon le projet actif)
- La checklist de début de session

**Avant** : `~/CLAUDE.md` importait 8 fichiers (~20 000 tokens à chaque session).
**Après** : seul `core.md` est chargé (~500 tokens), les modules sont injectés à la demande.

### `contexts/` — modules chargés selon le projet actif

Chaque fichier `ctx-[nom].md` contient le context d'un projet ou d'un domaine spécifique.
Claude charge automatiquement le bon module selon le dossier où tu travailles.

```
contexts/
├── ctx-dev.md          ← règles de code (à adapter à tes langages)
├── ctx-[projet].md     ← à créer pour chaque projet actif
└── README.md           ← comment ajouter un module
```

### `hooks/` — automatismes transparents

Trois scripts exécutés automatiquement par Claude Code, sans action de ta part :

| Hook | Quand | Ce qu'il fait |
|---|---|---|
| `stop.sh` | Après chaque réponse | Pushe `my-context` si des fichiers ont été modifiés |
| `pre-compact.sh` | Avant compaction | Sauvegarde le transcript dans `~/.claude/session-state/` |
| `post-edit.sh` | Après chaque Edit/Write | Lance le linter (tsc, go vet, shellcheck) selon l'extension |

### `skills/` — slash-commands disponibles dans Claude

| Commande | Ce qu'elle fait |
|---|---|
| `/etat` | Affiche ou crée `ETAT.md` pour le projet courant |
| `/ctx [module]` | Charge manuellement un module de context |
| `/bilan` | Clôture de session : résumé + ETAT.md + push |
| `/deploy [projet]` | Déploiement guidé avec vérifications pré-déploiement |
| `/prof [matière]` | Génère ou met à jour les cours Obsidian d'une matière |
| `/agents [type]` | Lance plusieurs subagents en parallèle pour une analyse complexe |

### `templates/` — templates réutilisables

- `etat-template.md` — utilisé par `/etat` pour créer un ETAT.md structuré dans chaque projet

---

---

## Prérequis

- Un ordinateur (Windows, macOS, ou Linux)
- Une connexion internet
- Un abonnement Claude Code (payant — [voir les tarifs](https://claude.ai/claude-code))
- Environ 15-20 minutes pour l'installation initiale

---

## Installation — étape par étape

### Étape 1 — Créer un compte GitHub

GitHub est le service où ton context sera sauvegardé et synchronisé entre tes machines.

1. Va sur **[github.com](https://github.com)**
2. Clique sur **"Sign up"** en haut à droite
3. Remplis le formulaire (email, mot de passe, nom d'utilisateur)
4. Confirme ton email

> Si tu as déjà un compte GitHub, passe à l'étape 2.

---

### Étape 2 — Copier ce projet sur ton compte

1. En haut de cette page GitHub, clique sur **"Use this template"** → **"Create a new repository"**
2. Donne un nom à ton repo : `my-context` (recommandé)
3. Mets-le en **Private** (tes infos personnelles seront dedans)
4. Clique sur **"Create repository"**

Tu as maintenant ta propre copie du projet sur ton compte GitHub.

---

### Étape 3 — Installer Git

Git est l'outil qui synchronise ton context entre GitHub et ton ordinateur.

**Windows :**
1. Va sur **[git-scm.com/download/win](https://git-scm.com/download/win)**
2. Télécharge et installe Git (clique "Next" partout, les options par défaut sont bonnes)
3. Ouvre **Git Bash** (il vient d'être installé) ou **PowerShell**

**macOS :**
1. Ouvre **Terminal** (Applications → Utilitaires → Terminal)
2. Tape : `git --version`
3. Si Git n'est pas installé, macOS te proposera de l'installer automatiquement — accepte

**Linux :**
```bash
# Ubuntu/Debian
sudo apt install git

# Arch Linux
sudo pacman -S git

# Fedora
sudo dnf install git
```

**Vérifier que Git est installé :**
```bash
git --version
# Doit afficher quelque chose comme : git version 2.x.x
```

---

### Étape 4 — Configurer Git avec ton identité

```bash
git config --global user.name "Ton Prénom"
git config --global user.email "ton@email.com"
```

Remplace par ton vrai prénom et l'email utilisé sur GitHub.

---

### Étape 5 — Configurer l'authentification GitHub

Pour que Git puisse envoyer tes fichiers sur GitHub, tu dois te connecter.

**Option recommandée — SSH (une fois configuré, c'est transparent) :**

1. Générer une clé SSH :
```bash
ssh-keygen -t ed25519 -C "ton@email.com"
# Appuie sur Entrée 3 fois (accepter les options par défaut)
```

2. Afficher ta clé publique :
```bash
# Mac/Linux
cat ~/.ssh/id_ed25519.pub

# Windows (Git Bash)
cat ~/.ssh/id_ed25519.pub
```

3. Copier tout le texte affiché (commence par `ssh-ed25519`)

4. Sur GitHub :
   - Clique sur ta photo de profil → **Settings**
   - Dans le menu gauche : **SSH and GPG keys**
   - Clique **"New SSH key"**
   - Colle ta clé dans le champ "Key"
   - Clique **"Add SSH key"**

5. Tester :
```bash
ssh -T git@github.com
# Doit afficher : Hi [ton-nom]! You've successfully authenticated...
```

---

### Étape 6 — Cloner ton context

Maintenant on copie ton repo GitHub sur ton ordinateur.

**Sur Mac/Linux :**
```bash
mkdir -p ~/dev
cd ~/dev
git clone git@github.com:TON-USERNAME/my-context.git
```

**Sur Windows (dans Git Bash) :**
```bash
mkdir -p ~/dev
cd ~/dev
git clone git@github.com:TON-USERNAME/my-context.git
```

Remplace `TON-USERNAME` par ton nom d'utilisateur GitHub.

---

### Étape 7 — Installer Claude Code

Claude Code est l'interface en ligne de commande de Claude.

**Prérequis : Node.js**
Si tu n'as pas Node.js installé :
- Va sur **[nodejs.org](https://nodejs.org)** → télécharge la version LTS → installe

**Installer Claude Code :**
```bash
npm install -g @anthropic-ai/claude-code
```

**Vérifier l'installation :**
```bash
claude --version
```

---

### Étape 8 — Lancer le script d'installation

Ce script va créer le fichier de configuration qui active ton context.

**Sur Mac/Linux :**
```bash
cd ~/dev/my-context
bash install.sh
```

**Sur Windows (Git Bash) :**
```bash
cd ~/dev/my-context
bash install.sh
```

---

### Étape 9 — Laisser Claude configurer ton context

C'est l'étape magique. Lance Claude Code depuis ton dossier home :

**Mac/Linux :**
```bash
cd ~
claude
```

**Windows :**
```bash
cd ~
claude
```

Claude va détecter que c'est ta première utilisation et démarrer l'interview de configuration automatiquement. Il va te poser des questions sur toi, tes outils, tes projets, et générer tous les fichiers de configuration personnalisés.

**L'interview dure environ 5-10 minutes.** À la fin, ton context est prêt.

---

## Utilisation au quotidien

**Lancement :** toujours depuis ton dossier home (`~`) pour que le context soit chargé :

```bash
cd ~
claude
```

**Ce qui se passe à chaque démarrage :**
- Claude vérifie si ton context est à jour (git pull automatique)
- Claude clone les projets manquants sur ta machine si besoin
- Claude est au courant de qui tu es et de tes projets en cours

**Ce qui se passe au fil du temps :**
- Claude met à jour `CONF.md` après chaque changement système
- Claude met à jour `PROJECTS.md` après chaque nouveau projet
- Si tu révèles une préférence en conversation, Claude la mémorise dans `CLAUDE.local.md`

---

## Synchronisation multi-machine

Pour utiliser ton context sur une autre machine :

1. Installe Git + Claude Code sur la nouvelle machine (étapes 3-4-5-7 ci-dessus)
2. Clone ton repo :
   ```bash
   mkdir -p ~/dev
   cd ~/dev
   git clone git@github.com:TON-USERNAME/my-context.git
   cd my-context
   bash install.sh
   ```
3. Lance Claude : `cd ~ && claude`

Ton context complet sera récupéré depuis GitHub et tu seras immédiatement opérationnel.

---

## Structure du projet

```
my-context/
├── CLAUDE.md               ← Une ligne : @dev/my-context/core.md
├── core.md                 ← Context chargé à chaque session (profil, modules, checklist)
├── contexts/
│   ├── ctx-dev.md          ← Règles de code (à adapter)
│   ├── ctx-[projet].md     ← À créer pour chaque projet actif
│   └── README.md           ← Comment ajouter un module
├── hooks/
│   ├── stop.sh             ← Auto-push my-context après réponse
│   ├── pre-compact.sh      ← Sauvegarde transcript avant compaction
│   └── post-edit.sh        ← Lint après Edit/Write (tsc, go vet, shellcheck)
├── skills/
│   ├── etat.md             ← /etat — ETAT.md du projet courant
│   ├── ctx.md              ← /ctx — charger un module de context
│   ├── bilan.md            ← /bilan — clôture de session
│   ├── deploy.md           ← /deploy — déploiement guidé
│   ├── prof.md             ← /prof — génération cours Obsidian
│   └── agents.md           ← /agents — analyse multi-agents en parallèle
├── templates/
│   └── etat-template.md    ← Template utilisé par /etat
├── CLAUDE.local.md         ← Ton profil personnel (généré par l'interview)
├── CONF.md                 ← Ta config système (généré + maintenu automatiquement)
├── PROJECTS.md             ← Tes projets actifs (généré + maintenu automatiquement)
├── ROUTINES.md             ← Checklists de maintenance (généré selon ton profil)
├── RULES_GENERIC.md        ← Règles de code génériques (si tu codes)
├── RULES_LANGAGES.md       ← Règles par langage (si tu codes)
├── PROFESSOR.md            ← Mode apprentissage pédagogique complet
├── settings-template.json  ← Template settings.json avec hooks configurés
└── install.sh              ← Script d'installation (hooks + skills + CLAUDE.md)
```

---

## FAQ

**Q : Est-ce que Claude peut lire mes fichiers privés ?**
Claude Code tourne localement sur ta machine. Il ne lit que les fichiers que tu lui donnes accès ou dans les dossiers où tu lances la commande. Tes fichiers ne sont pas uploadés automatiquement.

**Q : Mon context est-il sécurisé sur GitHub ?**
Ton repo est en privé — seul ton compte GitHub peut y accéder. Ne mets jamais de mots de passe ou de tokens dans ces fichiers.

**Q : Puis-je modifier les fichiers générés ?**
Oui, tout le temps. Claude les mettra à jour si tu lui demandes, ou automatiquement quand c'est pertinent.

**Q : Est-ce que ça marche sur Windows ?**
Oui. Utilise Git Bash pour les commandes terminal. Les chemins utilisent `~` qui correspond à `C:\Users\ton-nom\` sur Windows.

**Q : Et si je ne code pas ?**
Lors de l'interview, Claude adapte le context à ton profil. Les sections de règles de code seront simplifiées ou ignorées. Le mode professeur fonctionne pour n'importe quel sujet, pas seulement la programmation.

**Q : Que se passe-t-il si je perds mon ordinateur ?**
Comme tout est sur GitHub, tu peux tout récupérer en quelques minutes sur n'importe quel autre ordinateur. Voir "Synchronisation multi-machine" ci-dessus.

---

## Contribuer

Ce projet est open source. Si tu as des améliorations à proposer (nouvelles fonctionnalités, corrections, traductions), ouvre une issue ou une pull request.

---

*Inspiré du context personnel de [@mushadows](https://github.com/mushadows)*
