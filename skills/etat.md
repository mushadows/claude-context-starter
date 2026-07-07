Affiche et gère le fichier ETAT.md du projet courant.

## Comportement

**Déterminer le projet actif :**
```bash
pwd
```
Le projet actif est le repo git dans le cwd courant (ex: `~/dev/mon-projet/` → projet mon-projet).

**Vérifier si le projet est scolaire ou sensible :**
Consulter `core.md` — si des projets y sont marqués comme scolaires/sensibles (interdiction IA de commit/push).
- Si le projet est scolaire/sensible → lire `~/dev/my-context/etat/[projet].md` et afficher son contenu. Ne jamais créer ni modifier de fichier dans le repo. Ne jamais commiter.

**Si `ETAT.md` existe dans le cwd (projets non scolaires/sensibles uniquement) :**
1. Lire et afficher son contenu complet
2. Proposer une mise à jour : "Mettre à jour ETAT.md avec la session courante ? (résumé de ce qui a été fait, décisions prises, prochaine étape)"
3. Si l'utilisateur confirme → mettre à jour les sections pertinentes sans effacer les décisions architecturales existantes

**Si `ETAT.md` est absent (projets non scolaires/sensibles uniquement) :**
1. Lire le template : `~/dev/my-context/templates/etat-template.md`
2. Explorer le repo pour remplir le template :
   - `git log --oneline -10` — derniers commits
   - `ls` — structure racine
   - Lire `README.md` si présent
   - Lire le module ctx-* correspondant dans `~/dev/my-context/contexts/` si disponible
3. Générer un `ETAT.md` complet et réaliste (pas de placeholders vides)
4. Écrire le fichier dans le cwd
5. Commiter : `git add ETAT.md && git commit -m "chore: add ETAT.md"`

**Arguments :** `$ARGUMENTS`
- Sans argument → comportement par défaut ci-dessus
- `update` → forcer la mise à jour même si le fichier est récent
- `create` → forcer la création (écraser si existant)
