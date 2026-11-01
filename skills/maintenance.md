---
description: "Checklist de maintenance système mensuelle (Linux)"
---
# /maintenance — Checklist système mensuelle
Lecture seule : ne supprime ni ne met à jour rien sans confirmation. À la demande uniquement.
**Garde OS :** `source "$(cat "$HOME/.claude/context-dir")/lib/paths.sh"` puis `[ "$OS_KIND" = linux ]` — sinon s'arrêter et le dire (jamais détecter l'OS via `$OSTYPE`/`$WINDIR` dans le skill).
Si `ROUTINES.md` existe dans le repo de contexte, il prime : exécuter sa section « Maintenance système ». Sinon, vérifier et rapporter en un tableau (OK / à traiter) :
1. Disque : `df -h /` et `/home` (alerte > 85 %)
2. Services en échec : `systemctl --failed --no-pager`
3. Mises à jour en attente (selon le gestionnaire : `checkupdates`, `apt list --upgradable`, `dnf check-update`)
4. Journal : `journalctl -p err -b --no-pager | tail -20`
5. Santé disque si dispo : `smartctl -H` (peut exiger sudo : tester `sudo -n true` avant, sinon sauter)
6. Backups : date du dernier backup connu, si un outil est configuré
Terminer par les 1-3 actions prioritaires, chacune avec sa commande.
