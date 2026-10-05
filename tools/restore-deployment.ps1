[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$BackupRoot,
    [Parameter(Mandatory = $true)] [string]$DestinationRoot,
    [switch]$Apply,
    [switch]$ConfirmApply
)

$ErrorActionPreference = 'Stop'
$backupPath = [IO.Path]::GetFullPath($BackupRoot)
if (-not (Test-Path -LiteralPath $backupPath -PathType Container)) { throw "Backup directory does not exist: $backupPath" }
$files = @(Get-ChildItem -LiteralPath $backupPath -File -Recurse)
if ($files.Count -eq 0) { throw "Backup directory contains no files: $backupPath" }
$mapPath = Join-Path $backupPath 'deployment-map.json'
$map = if (Test-Path -LiteralPath $mapPath -PathType Leaf) { @(Get-Content $mapPath -Raw -Encoding UTF8 | ConvertFrom-Json) } else { @() }
Write-Output "Restore candidate: $($files.Count) file(s)"
foreach ($file in $files | Where-Object { $_.Name -ne 'deployment-map.json' }) {
    $relative = $file.FullName.Substring($backupPath.Length).TrimStart('\', '/')
    Write-Output ("  " + $relative)
}
if (-not $Apply) { Write-Output 'DRY_RUN: no files were changed.'; exit 0 }
if (-not $ConfirmApply) { throw 'Applying a restore requires both -Apply and -ConfirmApply.' }
$restored = 0
foreach ($file in $files | Where-Object { $_.Name -ne 'deployment-map.json' }) {
    $mapping = @($map | Where-Object { $_.Backup -eq $file.FullName }) | Select-Object -First 1
    $relative = $file.FullName.Substring($backupPath.Length).TrimStart('\', '/')
    $destination = if ($mapping) { [string]$mapping.Original } else { Join-Path $destinationRoot $relative }
    New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
    Copy-Item -LiteralPath $file.FullName -Destination $destination -Force
    $restored++
}
[pscustomobject]@{ Restored = $restored; BackupRoot = $backupPath; Status = 'RESTORED' } | Format-List
