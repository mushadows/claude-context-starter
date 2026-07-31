# Claudia — bootstrap Windows
# Usage :
#   iwr -useb https://raw.githubusercontent.com/mushadows/claudia/main/bootstrap.ps1 | iex
# Idempotent : peut être relancé pour mettre à jour.

$ErrorActionPreference = 'Stop'

# ────────────────────────────────────────────────────────────────
# Config
# ────────────────────────────────────────────────────────────────
$Repo         = 'mushadows/claudia'
$Branch       = 'main'
$DocsPath     = [Environment]::GetFolderPath('MyDocuments')
$ClaudiaHome  = if ($env:CLAUDIA_HOME) { $env:CLAUDIA_HOME } else { Join-Path $DocsPath 'Claudia' }
$ClaudiaState = if ($env:CLAUDIA_STATE) { $env:CLAUDIA_STATE } else { Join-Path $env:LOCALAPPDATA 'Claudia' }
$NodeMinMajor = 20
$LogDir       = Join-Path $ClaudiaState 'logs'
$LogFile      = Join-Path $LogDir ("install-{0:yyyyMMdd-HHmmss}.log" -f (Get-Date))

# ────────────────────────────────────────────────────────────────
# Sortie visuelle
# ────────────────────────────────────────────────────────────────
function Step($msg) { Write-Host ""; Write-Host "➤ $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "  ✓ $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "  ⚠ $msg" -ForegroundColor Yellow }
function Info($msg) { Write-Host "  · $msg" -ForegroundColor DarkGray }
function Fail($msg) { Write-Host "  ✗ $msg" -ForegroundColor Red }
function Log($msg)  { Add-Content -Path $LogFile -Value ("[{0:HH:mm:ss}] {1}" -f (Get-Date), $msg) }

# ────────────────────────────────────────────────────────────────
# Bannière
# ────────────────────────────────────────────────────────────────
@"

   ╭─────────────────────────────────╮
   │                                 │
   │      Bienvenue chez Claudia     │
   │                                 │
   ╰─────────────────────────────────╯

   Une assistante Claude qui te connaît, se souvient de toi,
   et s'adapte à ce que tu fais.

   Cette installation prend environ 3-5 minutes.
   Aucun droit administrateur ne sera demandé.

"@ | Write-Host

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Log "bootstrap.ps1 démarré — user=$env:USERNAME docs=$DocsPath"

try {
    # ────────────────────────────────────────────────────────────
    # 1. Système
    # ────────────────────────────────────────────────────────────
    Step "Je regarde ton système"
    $winVer = [System.Environment]::OSVersion.Version
    Ok "Windows $($winVer.Major).$($winVer.Minor) build $($winVer.Build) — architecture $env:PROCESSOR_ARCHITECTURE"
    Log "os=$winVer arch=$env:PROCESSOR_ARCHITECTURE"

    # ────────────────────────────────────────────────────────────
    # 2. Dossiers Claudia
    # ────────────────────────────────────────────────────────────
    Step "Je prépare ton dossier Claudia"
    New-Item -ItemType Directory -Force -Path $ClaudiaHome  | Out-Null
    New-Item -ItemType Directory -Force -Path $ClaudiaState | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $ClaudiaState 'backups') | Out-Null
    Set-Content -Path (Join-Path $ClaudiaState 'root') -Value $ClaudiaHome -Encoding UTF8
    Ok "Dossier : $ClaudiaHome"
    Info "État interne : $ClaudiaState"

    # ────────────────────────────────────────────────────────────
    # 3. Git for Windows (fournit git + bash pour les hooks)
    # ────────────────────────────────────────────────────────────
    Step "Je vérifie Git for Windows (nécessaire pour les automatismes)"
    $gitBash = @(
        "$env:ProgramFiles\Git\bin\bash.exe",
        "$env:ProgramFiles\Git\usr\bin\bash.exe",
        "${env:ProgramFiles(x86)}\Git\bin\bash.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $gitBash) {
        Info "Git for Windows absent — je l'installe (téléchargement ~50 Mo)…"
        $gitInstaller = Join-Path $env:TEMP 'git-installer.exe'
        $gitUrl = 'https://github.com/git-for-windows/git/releases/download/v2.47.0.windows.1/Git-2.47.0-64-bit.exe'
        Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstaller -UseBasicParsing
        Start-Process -FilePath $gitInstaller -ArgumentList '/VERYSILENT','/NORESTART','/NOCANCEL','/SP-','/CLOSEAPPLICATIONS','/RESTARTAPPLICATIONS','/COMPONENTS=gitlfs' -Wait
        $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
        $gitBash = @(
            "$env:ProgramFiles\Git\bin\bash.exe",
            "$env:ProgramFiles\Git\usr\bin\bash.exe"
        ) | Where-Object { Test-Path $_ } | Select-Object -First 1
    }
    if (-not $gitBash) { Fail "Git Bash introuvable après installation."; exit 20 }
    Ok "Git Bash : $gitBash"

    # ────────────────────────────────────────────────────────────
    # 4. Node.js
    # ────────────────────────────────────────────────────────────
    Step "Je vérifie Node.js"
    $needNode = $true
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $ver = (& node -v) -replace '^v',''
        $major = [int]($ver.Split('.')[0])
        if ($major -ge $NodeMinMajor) {
            Ok "Node.js v$ver — déjà installé"
            $needNode = $false
        } else {
            Info "Node v$ver trop ancien (min v$NodeMinMajor), j'installe une version dédiée."
        }
    } else {
        Info "Node.js absent, je l'installe."
    }

    if ($needNode) {
        # fnm-windows (single binary, pas d'admin)
        $fnmDir = Join-Path $ClaudiaState 'fnm'
        New-Item -ItemType Directory -Force -Path $fnmDir | Out-Null
        $fnmExe = Join-Path $fnmDir 'fnm.exe'
        if (-not (Test-Path $fnmExe)) {
            Info "Téléchargement de fnm…"
            $fnmZip = Join-Path $env:TEMP 'fnm.zip'
            $arch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'arm64' } else { 'x64' }
            Invoke-WebRequest -Uri "https://github.com/Schniz/fnm/releases/latest/download/fnm-windows.zip" -OutFile $fnmZip -UseBasicParsing
            Expand-Archive -Path $fnmZip -DestinationPath $fnmDir -Force
            Remove-Item $fnmZip
        }
        $env:Path = "$fnmDir;$env:Path"
        & $fnmExe env --use-on-cd --shell power-shell | Out-String | Invoke-Expression
        & $fnmExe install --lts | Out-Null
        & $fnmExe use lts-latest | Out-Null
        Ok "Node.js $(& node -v) installé (isolé)"
    }

    # ────────────────────────────────────────────────────────────
    # 5. Claude Code
    # ────────────────────────────────────────────────────────────
    Step "Je vérifie Claude Code"
    if (Get-Command claude -ErrorAction SilentlyContinue) {
        Ok "Claude Code déjà présent"
    } else {
        Info "Installation de Claude Code (peut prendre 30-60 s)…"
        & npm install -g '@anthropic-ai/claude-code' 2>&1 | Out-File -Append $LogFile
        Ok "Claude Code installé"
    }

    # ────────────────────────────────────────────────────────────
    # 6. Télécharger le contenu Claudia
    # ────────────────────────────────────────────────────────────
    Step "Je télécharge les fichiers Claudia"
    $tmp = Join-Path $env:TEMP ("claudia-" + [Guid]::NewGuid().ToString('N').Substring(0,8))
    New-Item -ItemType Directory -Force -Path $tmp | Out-Null
    $zip = Join-Path $tmp 'src.zip'
    Invoke-WebRequest -Uri "https://github.com/$Repo/archive/refs/heads/$Branch.zip" -OutFile $zip -UseBasicParsing
    Expand-Archive -Path $zip -DestinationPath $tmp -Force
    $srcRoot = (Get-ChildItem $tmp -Directory | Where-Object { $_.Name -like 'claudia-*' } | Select-Object -First 1).FullName
    if (-not $srcRoot) { Fail "Extraction impossible."; exit 12 }

    # Backup fichiers user si upgrade
    if (Test-Path (Join-Path $ClaudiaHome '.claudia-version')) {
        Info "Claudia est déjà installée — je mets à jour (tes fichiers persos sont préservés)."
        $backup = Join-Path (Join-Path $ClaudiaState 'backups') (Get-Date -Format 'yyyyMMdd-HHmmss')
        New-Item -ItemType Directory -Force -Path $backup | Out-Null
        foreach ($f in @('profil.md','memoire.md')) {
            $src = Join-Path $ClaudiaHome $f
            if (Test-Path $src) { Copy-Item $src -Destination $backup }
        }
        $memDir = Join-Path $ClaudiaHome 'memory'
        if (Test-Path $memDir) { Copy-Item $memDir -Destination $backup -Recurse }
        Log "backup vers $backup"
    }

    # Copier les fichiers système (jamais user)
    foreach ($item in @('core.md','INTERVIEW.md','README.md','hooks','skills','lib','templates','settings-template.json','internals')) {
        $s = Join-Path $srcRoot $item
        if (Test-Path $s) { Copy-Item -Path $s -Destination $ClaudiaHome -Recurse -Force }
    }
    Set-Content -Path (Join-Path $ClaudiaHome '.claudia-version') -Value (Get-Date -Format 'yyyy-MM-dd') -Encoding UTF8
    Remove-Item -Recurse -Force $tmp
    Ok "Fichiers Claudia à jour"

    # ────────────────────────────────────────────────────────────
    # 7. Déployer hooks + skills + settings via install.sh (Git Bash)
    # ────────────────────────────────────────────────────────────
    Step "Je configure Claude Code"
    $installSh = Join-Path $ClaudiaHome 'install.sh'
    $installShBash = ($installSh -replace '\\','/')
    & $gitBash -c "bash '$installShBash' --yes --claudia-home '$($ClaudiaHome -replace '\\','/')'" 2>&1 | Out-File -Append $LogFile
    Ok "Automatismes et raccourcis en place"

    # ────────────────────────────────────────────────────────────
    # 8. ~/CLAUDE.md
    # ────────────────────────────────────────────────────────────
    Step "Je connecte Claude à ton profil"
    $claudeMd = Join-Path $env:USERPROFILE 'CLAUDE.md'
    $coreLine = "@Documents/Claudia/core.md"
    if (-not (Test-Path $claudeMd)) {
        Set-Content -Path $claudeMd -Value $coreLine -Encoding UTF8
        Ok "$claudeMd créé"
    } elseif ((Get-Content $claudeMd -Raw) -match [Regex]::Escape($coreLine)) {
        Ok "$claudeMd déjà connecté"
    } else {
        Copy-Item $claudeMd -Destination "$claudeMd.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        $existing = Get-Content $claudeMd -Raw
        Set-Content -Path $claudeMd -Value ("$coreLine`n$existing") -Encoding UTF8
        Ok "$claudeMd mis à jour (ton ancien contenu est conservé)"
    }

    # ────────────────────────────────────────────────────────────
    # Terminé
    # ────────────────────────────────────────────────────────────
    @"

   ╭─────────────────────────────────╮
   │                                 │
   │      C'est prêt !               │
   │                                 │
   ╰─────────────────────────────────╯

   Pour parler à Claudia, ouvre Windows Terminal (ou PowerShell)
   et tape simplement :

       claude

   La première fois, elle va se présenter et te poser
   quelques questions pour apprendre à te connaître.

   Ton dossier Claudia (tu peux y jeter un œil) :
   $ClaudiaHome

"@ | Write-Host

    Log "bootstrap terminé avec succès"
}
catch {
    Fail "Quelque chose s'est mal passé : $($_.Exception.Message)"
    Write-Host ""
    Write-Host "  Log complet : $LogFile"
    Write-Host "  Ce qui a été fait est conservé — tu peux relancer cette commande."
    Write-Host "  Aide : https://github.com/$Repo/issues"
    exit 1
}
