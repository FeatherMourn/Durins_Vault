[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$ModsRoot,
    [string[]]$ModId,
    [switch]$Apply,
    [switch]$ConfirmApply,
    [string]$ProjectFile = ''
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Get-Location).Path
$planPath = 'working\reports\deployment-plan.json'
$planArgs = @{ ModsRoot = $ModsRoot; JsonOutput = $planPath }
if ($ModId) { $planArgs.ModId = $ModId }
& powershell -ExecutionPolicy Bypass -File (Join-Path $projectRoot 'tools\plan-profile.ps1') @planArgs
if ($LASTEXITCODE -ne 0) { throw 'Deployment plan contains missing sources or collisions; no files were changed.' }
$plan = @(Get-Content -LiteralPath (Join-Path $projectRoot $planPath) -Raw -Encoding UTF8 | ConvertFrom-Json)

if (-not $Apply) {
    Write-Output 'DRY_RUN: no files were changed.'
    exit 0
}
if (-not $ConfirmApply) { throw 'Applying deployment requires both -Apply and -ConfirmApply.' }

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path $projectRoot ("working\backups\deployment\" + $timestamp)
$backedUp = 0
$copied = 0
foreach ($entry in $plan) {
    $destination = [IO.Path]::GetFullPath([string]$entry.Destination)
    $source = [IO.Path]::GetFullPath([string]$entry.Source)
    if (Test-Path -LiteralPath $destination -PathType Leaf) {
        $relative = $destination.Substring([IO.Path]::GetPathRoot($destination).Length).TrimStart('\', '/')
        $backupPath = Join-Path $backupRoot $relative
        New-Item -ItemType Directory -Path (Split-Path -Parent $backupPath) -Force | Out-Null
        Copy-Item -LiteralPath $destination -Destination $backupPath
        $backedUp++
    }
    New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
    Copy-Item -LiteralPath $source -Destination $destination -Force
    $copied++
}
[pscustomobject]@{ Copied = $copied; BackedUp = $backedUp; BackupRoot = $backupRoot; Status = 'APPLIED' } | Format-List
