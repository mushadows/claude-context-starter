# Claudia

**Une assistante Claude qui te connaît, se souvient de toi, et s'adapte à ton quotidien.**

Que tu sois boulanger, coach sportif, secrétaire, freelance, parent au foyer, retraité, étudiant — Claudia apprend à te connaître et t'aide pour les tâches qui reviennent, sans jamais te demander de connaissances techniques.

---

## Ce que Claudia fait pour toi

- **Elle se souvient** — prénom, activité, outils, habitudes. Tu ne répètes jamais.
- **Elle s'adapte** — au fil des semaines, elle repère ce qui te prend du temps et propose des raccourcis.
- **Elle te prend par la main** — au premier lancement, elle se présente et te pose une dizaine de questions simples (5-10 minutes, aucune connaissance requise).
- **Elle reste à sa place** — jamais d'action irréversible sans te demander, jamais de sauvegarde en ligne sans ton feu vert, tes fichiers restent sur ta machine.

## Ce qu'il te faut

- Un ordinateur (Windows, macOS ou Linux)
- Une connexion internet
- Un compte Claude ([anthropic.com](https://claude.ai) — la version gratuite suffit pour commencer)

Rien d'autre. Pas besoin de savoir taper des commandes techniques — la commande d'installation ci-dessous s'occupe de tout (elle installe elle-même Node.js et Claude Code si tu ne les as pas).

---

## Installation en 1 commande

### Sur Mac ou Linux

Ouvre l'application **Terminal** et colle cette ligne, puis appuie sur Entrée :

```bash
curl -fsSL https://raw.githubusercontent.com/mushadows/claudia/main/bootstrap.sh | bash
```

### Sur Windows

Ouvre **PowerShell** (tape `PowerShell` dans le menu Démarrer) et colle cette ligne, puis appuie sur Entrée :

```powershell
iwr -useb https://raw.githubusercontent.com/mushadows/claudia/main/bootstrap.ps1 | iex
```

L'installation prend 3 à 5 minutes selon ta connexion. Aucun mot de passe administrateur ne sera demandé. Tout est visible à l'écran, tu peux relancer la commande à tout moment si ça coince.

---

## Premiers pas

Une fois l'installation terminée, tape simplement :

```
claude
```

Claudia se présente et t'accueille. Elle va te poser une dizaine de questions simples pour apprendre à te connaître. Tu peux répondre « je ne sais pas » à tout moment, elle choisira quelque chose de raisonnable et continuera.

À la fin, elle te propose d'essayer une vraie tâche avec toi (ranger un dossier, rédiger un mail-type, décortiquer une corvée). C'est le meilleur moyen de voir ce qu'elle sait faire.

**Après ça, à toi de jouer.** Parle-lui normalement, comme à une collègue qui prend des notes. Elle se souviendra de tout la prochaine fois.

---

## Comment ajuster Claudia (à tout moment)

Une commande unique donne accès à tout :

```
/claudia
```

Un petit menu s'affiche avec sept options :
1. Modifier ce qu'elle sait de toi
2. Ajouter une info à retenir
3. Voir ou créer un raccourci
4. Brancher un outil (agenda, drive, mails)
5. Revoir ce qu'on a fait ensemble récemment
6. Faire une pause ou la désinstaller
7. Rien, retour à la conversation

---

## Où sont tes fichiers

Tes fichiers Claudia sont dans un dossier visible sur ta machine :

- **Mac / Linux** : `~/Documents/Claudia/`
- **Windows** : `Documents\Claudia\`

Tu peux les ouvrir avec le bloc-notes ou n'importe quel éditeur — c'est du texte simple. Si tu supprimes le dossier, tu supprimes Claudia (mais elle te préviendra la prochaine fois qu'elle sera relancée).

---

## Confidentialité

- **Tes fichiers restent sur ta machine.** Aucune sauvegarde en ligne par défaut.
- **Tes conversations passent par les serveurs d'Anthropic** (l'entreprise derrière Claude), aux États-Unis, comme pour n'importe quelle utilisation de Claude. Anthropic n'entraîne pas son IA sur tes conversations par défaut (opt-out actif depuis 2025), mais vérifie tes réglages sur claude.ai si c'est un sujet.
- **Pour des données sensibles** (santé, juridique, données client détaillées) : Claudia te préviendra à chaque fois. Sur le compte gratuit ou Pro, il n'y a pas de contrat de protection renforcé (DPA) — pour cet usage, regarde l'offre Team d'Anthropic.
- **Désinstallation complète** disponible à tout moment via `/claudia` puis option 6.

---

## En cas de souci

- **L'installation a échoué** : relance la même commande — c'est fait pour être ré-exécuté sans casse. Un log complet est écrit dans `~/.claudia/logs/`.
- **Une question à Claudia** : tape simplement ta question, elle te répondra en langage normal.
- **Un bug** : ouvre une issue sur [github.com/mushadows/claudia/issues](https://github.com/mushadows/claudia/issues).

---

## Pour les développeurs curieux

Tout le code source est ici, ouvert et modifiable :
- `bootstrap.sh` / `bootstrap.ps1` — les scripts d'installation
- `core.md` — la personnalité et les règles de Claudia
- `INTERVIEW.md` — le déroulé du premier accueil
- `skills/*.md` — les raccourcis disponibles
- `hooks/*.sh` — les automatismes déclenchés par Claude Code
- `internals/` — spécs techniques, chemins OS, mécanismes internes

Contributions bienvenues. Voir `internals/README.md` pour les détails.
