# bootstrap-win.ps1 — Setup Claude Code sur Windows 11
# Lancer dans PowerShell en tant qu'Administrateur

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# 1. Execution policy (bloque npm sans ça)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Write-Host "==> Execution policy OK"

# 2. Dépendances via winget
Write-Host "==> Installation des dépendances..."
winget install -e --id Git.Git         --silent --accept-package-agreements --accept-source-agreements
winget install -e --id OpenJS.NodeJS   --silent --accept-package-agreements --accept-source-agreements
winget install -e --id GitHub.cli      --silent --accept-package-agreements --accept-source-agreements

# Rafraîchir le PATH sans relancer le terminal
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + `
            [System.Environment]::GetEnvironmentVariable("Path","User")

# 3. Clé SSH — générer si absente
if (-not (Test-Path "$env:USERPROFILE\.ssh\id_ed25519")) {
    Write-Host "==> Génération de la clé SSH..."
    # SETUP_REQUIRED : remplacer l'email
    ssh-keygen -t ed25519 -C "SETUP_REQUIRED@example.com" -f "$env:USERPROFILE\.ssh\id_ed25519" -N '""'
}

# 4. Ajouter GitHub à known_hosts
ssh-keyscan github.com 2>$null | Add-Content "$env:USERPROFILE\.ssh\known_hosts"

# 5. Afficher la clé publique
Write-Host ""
Write-Host "==> Ajoute cette clé sur https://github.com/settings/ssh/new"
Write-Host ""
Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub"
Write-Host ""
Read-Host "Appuie sur Entrée une fois la clé ajoutée sur GitHub"

# 6. Auth GitHub CLI
gh auth login

# 7. Claude Code
Write-Host "==> Installation de Claude Code..."
npm install -g @anthropic-ai/claude-code

# 8. Cloner le context
# SETUP_REQUIRED : remplacer l'URL par ton repo my-context
$CONTEXT_REPO = "git@github.com:SETUP_REQUIRED/context.git"
$CONTEXT_DIR  = "$env:USERPROFILE\dev\my-context"

New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\dev" | Out-Null
if (-not (Test-Path $CONTEXT_DIR)) {
    git clone $CONTEXT_REPO $CONTEXT_DIR
} else {
    Write-Host "==> $CONTEXT_DIR déjà présent, pull..."
    git -C $CONTEXT_DIR pull
}

# 9. Ajouter ~/.local/bin au PATH utilisateur si absent
$userPath = [System.Environment]::GetEnvironmentVariable("Path","User")
$localBin = "$env:USERPROFILE\.local\bin"
if ($userPath -notlike "*$localBin*") {
    [System.Environment]::SetEnvironmentVariable("Path", $userPath + ";$localBin", "User")
    $env:Path += ";$localBin"
    Write-Host "==> $localBin ajouté au PATH"
}

# 10. Bootstrap — CLAUDE.md, hooks, skills, settings.json
# Note : install.sh nécessite Git Bash (pas PowerShell natif)
if (Get-Command bash -ErrorAction SilentlyContinue) {
    bash "$CONTEXT_DIR\install.sh"
} else {
    # Fallback minimal si Git Bash absent
    "@dev/my-context/core.md" | Set-Content "$env:USERPROFILE\CLAUDE.md"
    Write-Host "==> CLAUDE.md créé."
    Write-Host "==> Installe Git Bash puis relance : bash ~/dev/my-context/install.sh"
    Write-Host "==> (pour les hooks et skills)"
}

# 11. Note Windows spécifique
Write-Host ""
Write-Host "==> Notes importantes pour Windows :"
Write-Host "    • Toujours utiliser Git Bash (pas PowerShell) pour lancer claude"
Write-Host "    • Si les symlinks échouent dans install.sh :"
Write-Host "      Paramètres → Système → Pour les développeurs → activer Developer Mode"
Write-Host "    • Alternative recommandée : WSL2 (ubuntu) pour une expérience identique à Linux"
Write-Host "    • Dans chaque repo git : git config core.filemode false"
Write-Host ""
Write-Host "==> Bootstrap terminé. Lance depuis Git Bash : cd ~/dev/<projet> && claude"
Write-Host ""
