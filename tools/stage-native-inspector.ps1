[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$BuildDll,
    [Parameter(Mandatory = $true)] [string]$GameRoot,
    [string]$BackupRoot = 'working\backups\native-inspector'
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Get-Location).Path
$buildPath = [IO.Path]::GetFullPath($BuildDll)
$gamePath = [IO.Path]::GetFullPath($GameRoot)
$backupPath = [IO.Path]::GetFullPath((Join-Path $projectRoot $BackupRoot))

if (-not (Test-Path -LiteralPath $buildPath -PathType Leaf)) {
    throw "Native inspector DLL does not exist: $buildPath"
}
if (-not (Test-Path -LiteralPath $gamePath -PathType Container)) {
    throw "Game root does not exist: $gamePath"
}

$destination = Join-Path $gamePath 'Moria\Binaries\Win64\ue4ss\Mods\DurinsVaultInspector\dlls\main.dll'
New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

if (Test-Path -LiteralPath $destination -PathType Leaf) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    Copy-Item -LiteralPath $destination -Destination (Join-Path $backupPath "main-$stamp.dll") -Force
}
Copy-Item -LiteralPath $buildPath -Destination $destination -Force

New-Item -ItemType File -Path (Join-Path (Split-Path -Parent $destination) '..\enabled.txt') -Force | Out-Null
[pscustomobject]@{
    Source = $buildPath
    Destination = $destination
    BackupDirectory = $backupPath
    Status = 'STAGED'
} | Format-List
