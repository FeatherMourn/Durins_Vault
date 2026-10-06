[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$ModsRoot,
    [string[]]$ModId,
    [switch]$Apply,
    [switch]$ConfirmApply,
    [string]$ProjectFile = ''
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$planPath = Join-Path $projectRoot 'working\reports\deployment-plan.json'
$modsRootPath = if ([IO.Path]::IsPathRooted($ModsRoot)) { $ModsRoot } else { Join-Path $projectRoot $ModsRoot }
$planArgs = @{ ModsRoot = $modsRootPath; JsonOutput = $planPath }
if ($ModId) { $planArgs.ModId = $ModId }
& powershell -ExecutionPolicy Bypass -File (Join-Path $projectRoot 'tools\plan-profile.ps1') @planArgs
if ($LASTEXITCODE -ne 0) { throw 'Deployment plan contains missing sources or collisions; no files were changed.' }
$plan = @(Get-Content -LiteralPath $planPath -Raw -Encoding UTF8 | ConvertFrom-Json)

if (-not $Apply) {
    Write-Output 'DRY_RUN: no files were changed.'
    exit 0
}
if (-not $ConfirmApply) { throw 'Applying deployment requires both -Apply and -ConfirmApply.' }

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path 'H:\DurinsVault_Work' ("DeploymentBackups\" + $timestamp)
$backedUp = 0
$copied = 0
$backupMap = [System.Collections.Generic.List[object]]::new()
foreach ($entry in $plan) {
    # plan-profile already emits absolute paths; avoid re-normalizing paths
    # containing the game's Unicode trademark directory name on older Windows
    # PowerShell/.NET combinations.
    $destination = ([string]$entry.Destination).Replace('/', '\')
    $source = [string]$entry.Source
    if (Test-Path -LiteralPath $destination -PathType Leaf) {
        $safeName = ($destination -replace '^[A-Za-z]:[\\/]', '') -replace '[\\/:]', '_'
        $backupPath = Join-Path $backupRoot $safeName
        New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
        Copy-Item -LiteralPath $destination -Destination $backupPath
        $backupMap.Add([pscustomobject]@{ Original = $destination; Backup = $backupPath })
        $backedUp++
    }
    $destinationParent = Split-Path -Parent $destination
    if (-not [IO.Directory]::Exists($destinationParent)) {
        [IO.Directory]::CreateDirectory($destinationParent) | Out-Null
    }
    Copy-Item -LiteralPath $source -Destination $destination -Force
    $copied++
}
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
ConvertTo-Json -InputObject @($backupMap) -Depth 4 | Set-Content -LiteralPath (Join-Path $backupRoot 'deployment-map.json') -Encoding UTF8
[pscustomobject]@{ Copied = $copied; BackedUp = $backedUp; BackupRoot = $backupRoot; Status = 'APPLIED' } | Format-List
