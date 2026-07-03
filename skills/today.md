# /today — Récap des tâches du jour

Agrège l'état de tous les projets actifs, les éléments en attente, et les événements du jour pour donner un plan d'action immédiat.

À la demande uniquement — ne jamais lancer automatiquement.

## Comportement

**Arguments :** `$ARGUMENTS` (ignorés)

### Étape 0 — Pull des repos (obligatoire, avant tout)

```bash
pull_results=()
for repo in ~/dev/my-context ~/dev/obsidian-vault; do
  name=$(basename "$repo")
  result=$(git -C "$repo" pull 2>&1)
  [[ "$result" != *"Already up to date"* ]] && pull_results+=("$name: $result")
done
[ ${#pull_results[@]} -gt 0 ] && printf '%s\n' "${pull_results[@]}" || echo "Tous les repos sont à jour."
```

Afficher en une ligne dans le récap : `🔄 Repos à jour` si rien, ou `🔄 Mis à jour : [liste]` avec ce qui a changé.

### Étape 1 — Cours non générés (rapide)

```bash
for dir in ~/dev/obsidian-vault/Cours/*/; do
  matiere=$(basename "$dir")
  [ -d "${dir}notes" ] && [ "$(ls -A "${dir}notes" 2>/dev/null)" ] && \
  ! ls "${dir}"*-cours.md 2>/dev/null | head -1 >/dev/null 2>&1 && \
  echo "COURS_MANQUANT:$matiere"
done
```
Si des matières sont détectées → les ajouter dans ⚠️ DETTES avec `→ /prof [matière] — notes présentes, cours non généré`.

### Étape 2 — Lire les sources en parallèle

Lire simultanément :
- `~/dev/my-context/PROJECTS.md` — état de chaque projet (dettes git, blockers signalés)
- `~/dev/my-context/etat/*.md` — état détaillé et tâches de chaque projet
- `~/dev/my-context/ROUTINES.md` — si le jour du mois ≥ 25

Récupérer les événements Google Calendar du jour :
- Appeler `mcp__claude_ai_Google_Calendar__list_events` avec la date d'aujourd'hui (minuit → 23h59)
- Si aucun calendrier connu → lister d'abord via `mcp__claude_ai_Google_Calendar__list_calendars`

### Étape 3 — Extraire les items actionnables

**Par projet (depuis ETAT.md + PROJECTS.md) :**
- Tâches marquées "En cours", "À faire", "Bloqué", "⚠️"
- Dettes techniques signalées explicitement (ex: `⚠️ Dette git`)
- Deploiements en attente ou configs incomplètes

**Global :**
- Revue macro : vérifier **uniquement si jour ≥ 25** ET si elle est manquante. Si déjà faite ce mois-ci → ne pas mentionner du tout dans le récap.
- Emails ou actions Seerr/Sonarr/Radarr en suspens si mentionnés dans les ETAT

**Calendrier :**
- Événements du jour avec heure et titre
- Deadlines imminentes (aujourd'hui ou demain)

### Étape 4 — Afficher le récap

Format compact, sans en-tête verbeux. Afficher uniquement ce qui est actionnable.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  AUJOURD'HUI — [Jour DD/MM/YYYY]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔄 Repos à jour  (ou : Mis à jour — my-context: 3 fichiers, obsidian-vault: 12 fichiers)

📅 AGENDA
  [heure] Titre événement
  (vide si rien)

🔧 PROJETS — en cours / à débloquer
  taverne    → Résoudre divergence git (3 commits locaux vs 7 distants)
  sauron     → ...
  (un projet par ligne, seulement ceux avec des items)

⚠️ DETTES / BLOCKERS
  → Item urgent ou bloquant
  (vide si rien)

📊 SI JOUR ≥ 25 ET REVUE MANQUANTE SEULEMENT
  → Revue macro manquante ✗ — à faire maintenant

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  [N item(s) à traiter]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Règles d'affichage :**
- Si aucun item → afficher `Tout est clean. Bonne session.` et s'arrêter
- Pas de section vide — omettre les blocs sans contenu
- La section 📊 revue macro n'apparaît **jamais** si la revue est déjà faite ce mois-ci
- Max 2 lignes par projet — synthétiser, pas lister exhaustivement
- Si un ETAT.md est absent pour un projet actif → le signaler comme `ETAT manquant`
