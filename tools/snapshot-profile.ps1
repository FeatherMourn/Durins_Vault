[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$ProjectFile = '',
    [string]$Profile = '',
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($ProjectFile)) { $ProjectFile = Join-Path (Get-Location).Path 'durins-vault.project.json' }
$projectPath = [IO.Path]::GetFullPath($ProjectFile)
$projectRoot = Split-Path -Parent $projectPath
$project = Get-Content -LiteralPath $projectPath -Raw -Encoding UTF8 | ConvertFrom-Json
$profileName = if ($Profile) { $Profile } else { $project.game.test_profile }
$profile = $project.profiles.$profileName
if ($null -eq $profile) { throw "Profile '$profileName' is not defined." }
$gameRoot = $null
foreach ($candidate in $project.game.install_roots) {
    if (Test-Path -LiteralPath $candidate -PathType Container) { $gameRoot = [IO.Path]::GetFullPath($candidate); break }
}
if (-not $gameRoot) { throw 'No configured game installation was found.' }
$ue4ssRoot = [IO.Path]::GetFullPath(($profile.ue4ss_root.Replace('${game_root}', $gameRoot)))
$backupRoot = $profile.backup_root
if (-not [IO.Path]::IsPathRooted($backupRoot)) { $backupRoot = Join-Path $projectRoot $backupRoot }
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$destination = Join-Path ([IO.Path]::GetFullPath($backupRoot)) $stamp
$manifest = [pscustomobject]@{
    schema = 'durins-vault.profile-snapshot/v1'
    profile = $profileName
    created = (Get-Date).ToUniversalTime().ToString('o')
    source = $ue4ssRoot
    destination = $destination
    mode = if ($Apply) { 'APPLY' } else { 'REVIEW_ONLY' }
}
$manifest | ConvertTo-Json -Depth 5 | Write-Output
if (-not $Apply) { Write-Output 'No files copied. Re-run with -Apply to create this snapshot.'; exit 0 }
if (-not (Test-Path -LiteralPath $ue4ssRoot -PathType Container)) { throw "UE4SS root not found: $ue4ssRoot" }
if ($PSCmdlet.ShouldProcess($destination, "Snapshot UE4SS profile")) {
    New-Item -ItemType Directory -Force -Path $destination | Out-Null
    Copy-Item -LiteralPath $ue4ssRoot -Destination (Join-Path $destination 'ue4ss') -Recurse -Force
    $manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $destination 'snapshot.json') -Encoding UTF8
    Write-Output "Snapshot created: $destination"
}
