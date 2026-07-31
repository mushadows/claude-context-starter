---
description: Ton récap du jour — agenda, projets en cours, choses à débloquer.
---

# /today — Ta journée en un coup d'œil

Sert à te faire un point rapide en début de journée : ce que tu as à l'agenda, où en sont tes projets, ce qui traîne. À la demande — jamais lancé tout seul.

## Préparation

```bash
source "$CLAUDIA_HOME/lib/paths.sh"
```

## Comportement

**Arguments :** `$ARGUMENTS` (ignorés)

### Étape 0 — Récupérer les mises à jour Claudia (si configurées)

Si `$CLAUDIA_HOME` est un dossier suivi par une sauvegarde (présence d'un dossier `.git`) :

```bash
if [ -d "$CLAUDIA_HOME/.git" ]; then
    result=$(git -C "$CLAUDIA_HOME" pull 2>&1)
    [[ "$result" != *"Already up to date"* ]] && echo "$result"
fi
```

Si `VAULT_DIR` est défini et suivi → même chose.
Sinon → passer, ne rien afficher.

### Étape 1 — Cours à générer (si vault Obsidian configuré)

Seulement si `$VAULT_DIR` est défini et existe :

```bash
if [ -n "${VAULT_DIR:-}" ] && [ -d "$VAULT_DIR/Cours" ]; then
    for dir in "$VAULT_DIR"/Cours/*/; do
        matiere=$(basename "$dir")
        [ -d "${dir}notes" ] && [ "$(ls -A "${dir}notes" 2>/dev/null)" ] && \
        ! ls "${dir}"*-cours.md 2>/dev/null | head -1 >/dev/null 2>&1 && \
        echo "COURS_MANQUANT:$matiere"
    done
fi
```

Si des matières ressortent → les ajouter dans « À DÉBLOQUER » avec `→ /prof [matière] — notes présentes, cours pas encore fait`.

### Étape 2 — Lire les sources en parallèle

Lire simultanément (ceux qui existent) :
- `$CLAUDIA_HOME/profil.md` — projets connus, préférences
- `$CLAUDIA_HOME/memoire.md` — notes ponctuelles
- Tous les `$CLAUDIA_HOME/contexts/ctx-*.md` — état des projets
- Les `ETAT.md` des projets actifs si connus

**Agenda :**

Récupérer les événements Google Agenda du jour si la passerelle agenda est branchée :
- `mcp__claude_ai_Google_Calendar__list_events` avec la date d'aujourd'hui (minuit → 23h59)
- Si aucun agenda connu → lister d'abord via `mcp__claude_ai_Google_Calendar__list_calendars`

Si la passerelle n'est pas disponible → sauter la section agenda sans planter.

### Étape 3 — Extraire ce qui compte

**Par projet :**
- Tâches marquées « En cours », « À faire », « Bloqué », « ⚠ »
- Choses qui traînent explicitement notées
- Mises en ligne prévues ou réglages incomplets

**Général :**
- Rappels ou routines mentionnés dans le profil
- Éléments en attente notés dans la mémoire

**Agenda :**
- Événements du jour avec heure et titre
- Échéances imminentes (aujourd'hui ou demain)

### Étape 4 — Afficher le récap

Format court, sans en-tête verbeux. Afficher uniquement ce qui est actionnable.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  AUJOURD'HUI — [Jour DD/MM/YYYY]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

AGENDA
  [heure] Titre événement
  (vide si rien)

PROJETS — en cours / à débloquer
  [nom projet]   → [action concrète]
  (un projet par ligne, seulement ceux avec un item)

À DÉBLOQUER
  → Item qui coince
  (vide si rien)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  [N chose(s) à traiter]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Règles d'affichage :**
- Si aucun item → dire simplement : *« Rien de spécial aujourd'hui. Bonne journée. »* et s'arrêter
- Pas de section vide — enlever les blocs sans contenu
- Max 2 lignes par projet — synthétiser
- Si aucun projet n'est configuré → sauter la section « PROJETS » sans commenter
- Si aucun agenda branché → sauter la section « AGENDA » sans commenter
