$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ReposFile = Join-Path $ScriptDir "repos.txt"

if (-not (Test-Path $ReposFile)) {
    Write-Error "repos.txt not found at $ReposFile"
    exit 1
}

Get-Content $ReposFile | ForEach-Object {
    $line = $_ -replace '#.*', ''
    $line = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($line)) { return }

    $repoName = ($line -split '/')[-1]
    $repoDir = Join-Path $ScriptDir $repoName

    if (Test-Path (Join-Path $repoDir ".git")) {
        Write-Host "Syncing $repoName..."
        git -C $repoDir pull --ff-only
    } else {
        Write-Host "Cloning $repoName..."
        git clone "git@github.com:$line.git" $repoDir
    }
}

Write-Host "Done."
