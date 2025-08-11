<#
MAIN.ps1
- Copies originals from DONOTRENAME\original into DONOTRENAME (if present)
- Opens Colors.png (next to the script) before asking for replacement text
- Edits the copies in DONOTRENAME (NO .bak files created)
- Preview -> Confirm -> Edit -> Compile -> Move .smx -> Prompt to delete edited copies
- Compiled .smx files are moved to:
    <scriptDir>\draganddrop\addons\sourcemod\plugins
#>

# ---------------- Resolve script & reference image ----------------
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$colorsPath = Join-Path $scriptDir 'Colors.png'

if (Test-Path -Path $colorsPath -PathType Leaf) {
    try {
        Write-Host "Opening Colors.png for reference..."
        Start-Process -FilePath $colorsPath -ErrorAction SilentlyContinue | Out-Null
    } catch {
        Write-Warning ("Failed to open {0}: {1}" -f $colorsPath, $_.Exception.Message)
    }
} else {
    Write-Host "Colors.png not found in script folder ($scriptDir). Continuing without opening image." -ForegroundColor Yellow
}

# ---------------- Prompt for replacement text ----------------
$userInput = Read-Host "Enter replacement text (example: `\x03[shiba]\x01`). PLEASE have \x01 at the edit else all of your colors will mess up. Leave empty to cancel"
if ([string]::IsNullOrWhiteSpace($userInput)) {
    Write-Host "No input provided — exiting." -ForegroundColor Yellow
    exit 0
}

# ---------------- Paths ----------------
$targetDir = Join-Path $scriptDir 'DONOTRENAME'
$originalDir = Join-Path $targetDir 'original'

# destination: scriptDir\draganddrop\addons\sourcemod\plugins
$destFull = Join-Path $scriptDir 'draganddrop'
$destFull = Join-Path $destFull 'addons'
$destFull = Join-Path $destFull 'sourcemod'
$destFull = Join-Path $destFull 'plugins'

Write-Host "Script directory : $scriptDir"
Write-Host "Target (DONOTRENAME): $targetDir"
Write-Host "Originals folder  : $originalDir"
Write-Host "Destination (plugins): $destFull"

if (-not (Test-Path -Path $targetDir -PathType Container)) {
    Write-Error "Target folder '$targetDir' does not exist. Create it and place compile.exe (optional) and/or an 'original' folder inside."
    exit 1
}

# ---------------- Files to handle ----------------
$files = @(
    'hvhgg_csgo_essentials.sp',
    'hvhgg_weapon_selector.sp',
    'map.sp'
)

# ---------------- Copy originals (if present) ----------------
if (Test-Path -Path $originalDir -PathType Container) {
    Write-Host "`nOriginals folder detected. Copying originals into $targetDir (overwriting)..."
    $copiedAny = $false
    foreach ($f in $files) {
        $src = Join-Path $originalDir $f
        $dst = Join-Path $targetDir $f
        if (Test-Path -Path $src -PathType Leaf) {
            try {
                Copy-Item -LiteralPath $src -Destination $dst -Force
                Write-Host (" Copied {0} -> {1}" -f $src, $dst)
                $copiedAny = $true
            } catch {
                Write-Warning (" Failed copying {0}: {1}" -f $src, $_.Exception.Message)
            }
        } else {
            Write-Host (" Original not found: {0}" -f $src) -ForegroundColor DarkYellow
        }
    }
    if (-not $copiedAny) {
        Write-Host "No originals were copied (none of the expected files found in 'original')." -ForegroundColor Yellow
    }
} else {
    Write-Host "`nNo 'original' folder found — will operate on .sp files already in DONOTRENAME (if present)." -ForegroundColor Yellow
}

# ---------------- Build list of files currently present in DONOTRENAME to operate on ----------------
$foundFiles = @()
foreach ($f in $files) {
    $p = Join-Path $targetDir $f
    if (Test-Path -Path $p -PathType Leaf) { $foundFiles += $p }
}

if ($foundFiles.Count -eq 0) {
    Write-Warning "No target .sp files found in $targetDir. Aborting."
    exit 1
}

Write-Host "`nFound .sp files to operate on:"
$foundFiles | ForEach-Object { Write-Host " - $_" }

# ---------------- Detect first color code (e.g. \x0E) ----------------
$firstColor = $null
if ($userInput -match '^(\\x[0-9A-Fa-f]{2})') {
    $firstColor = $matches[1]
    Write-Host ("Detected first color: {0}" -f $firstColor)
} else {
    Write-Host "No leading color found in input; command-color replacement will be skipped." -ForegroundColor Yellow
}

# ---------------- Preview helper ----------------
function Show-Preview {
    param($path, $userInput, $firstColor)
    Write-Host "`nPreview for: $path" -ForegroundColor Cyan
    $raw = Get-Content -Raw -LiteralPath $path -ErrorAction Stop

    $matches = [regex]::Matches($raw, [regex]::Escape('\x03[nebula]\x01'))
    if ($matches.Count -gt 0) { Write-Host " Occurrences of '\x03[nebula]\x01' : $($matches.Count)" }
    else { Write-Host " No '\x03[nebula]\x01' occurrences found." }

    $lines = Get-Content -LiteralPath $path
    $found = 0
    for ($i = 0; $i -lt $lines.Count -and $found -lt 10; $i++) {
        if ($lines[$i] -like '*\x03[nebula]\x01*' -or ($firstColor -and $lines[$i] -like '*\x03!*')) {
            $before = $lines[$i]
            $after = $before.Replace('\x03[nebula]\x01', $userInput)
            if ($firstColor) {
                $after = [regex]::Replace($after, '\\x03(?=[!/])', [regex]::Escape($firstColor))
            }
            Write-Host (" {0,4}: {1}" -f ($i+1), $before)
            Write-Host ("       -> {0}" -f $after) -ForegroundColor DarkGray
            $found++
        }
    }
    if ($found -eq 0) { Write-Host " (no preview lines matched criteria)" }
}

# ---------------- Show previews ----------------
foreach ($p in $foundFiles) { Show-Preview -path $p -userInput $userInput -firstColor $firstColor }

# ---------------- Confirm to proceed ----------------
$ok = Read-Host "`nProceed to modify files and compile? (Y/N)"
if ($ok -notin @('Y','y','Yes','yes')) {
    Write-Host "Aborted by user." -ForegroundColor Yellow
    exit 0
}

# ---------------- Apply edits (NO backups) ----------------
$editedPaths = @()
foreach ($path in $foundFiles) {
    try {
        $content = Get-Content -Raw -LiteralPath $path -Encoding UTF8

        # Replace the main marker \x03[nebula]\x01 -> user input
        $content = $content.Replace('\x03[nebula]\x01', $userInput)

        # For hvhgg_weapon_selector.sp only, replace \x03 before ! or / with the first color (if given)
        if ([System.IO.Path]::GetFileName($path) -ieq 'hvhgg_weapon_selector.sp' -and $firstColor) {
            $content = [regex]::Replace($content, '\\x03(?=[!/])', [regex]::Escape($firstColor))
        }

        # Overwrite the file in DONOTRENAME
        Set-Content -LiteralPath $path -Value $content -Encoding UTF8
        Write-Host ("Updated: {0}" -f $path)
        $editedPaths += $path
    } catch {
        Write-Warning ("Failed to update {0}: {1}" -f $path, $_.Exception.Message)
    }
}

# ---------------- Compile (if compile.exe exists in DONOTRENAME) ----------------
$compileExe = Join-Path $targetDir 'compile.exe'
if (-not (Test-Path -Path $compileExe -PathType Leaf)) {
    Write-Warning "compile.exe not found in $targetDir. Skipping compilation step."
} else {
    Write-Host "`nCompiling .sp files with: $compileExe (working dir: $targetDir)"
    foreach ($fullPath in $foundFiles) {
        $leaf = [System.IO.Path]::GetFileName($fullPath)
        try {
            $proc = Start-Process -FilePath $compileExe -ArgumentList $leaf -WorkingDirectory $targetDir -NoNewWindow -Wait -PassThru
            if ($proc.ExitCode -ne 0) {
                Write-Warning ("compile.exe returned exit code {0} for {1}" -f $proc.ExitCode, $leaf)
            } else {
                Write-Host ("Compiled: {0}" -f $leaf)
            }
        } catch {
            Write-Warning ("Compilation error for {0}: {1}" -f $leaf, $_.Exception.Message)
        }
    }
}

# ---------------- Move .smx outputs to destination ----------------
try { New-Item -ItemType Directory -Path $destFull -Force | Out-Null } catch {
    Write-Warning ("Failed to ensure destination folder {0}: {1}" -f $destFull, $_.Exception.Message)
}

$smxFiles = Get-ChildItem -Path $targetDir -Recurse -Filter *.smx -ErrorAction SilentlyContinue
if (-not $smxFiles -or $smxFiles.Count -eq 0) {
    Write-Warning "No .smx files found under $targetDir after compilation."
} else {
    foreach ($s in $smxFiles) {
        try {
            $dest = Join-Path $destFull $s.Name
            Move-Item -LiteralPath $s.FullName -Destination $dest -Force
            Write-Host ("Moved {0} -> {1}" -f $s.Name, $dest)
        } catch {
            Write-Warning ("Failed to move {0}: {1}" -f $s.FullName, $_.Exception.Message)
        }
    }
}

# ---------------- Prompt for cleanup (delete edited copies in DONOTRENAME) ----------------
if ($editedPaths.Count -gt 0) {
    $cleanup = Read-Host "`nCleanup? (Y/N)"
    if ($cleanup -in @('Y','y','Yes','yes')) {
        foreach ($p in $editedPaths) {
            try {
                Remove-Item -LiteralPath $p -Force
                Write-Host ("Deleted: {0}" -f $p)
            } catch {
                Write-Warning ("Failed to delete {0}: {1}" -f $p, $_.Exception.Message)
            }
        }
    } else {
        Write-Host "Kept edited copies in DONOTRENAME."
    }
} else {
    Write-Host "No edited files to consider for cleanup."
}

Write-Host "`nAll done."
