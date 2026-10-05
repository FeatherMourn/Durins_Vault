[CmdletBinding()]
param(
    [string]$ProjectFile = '' ,
    [string]$Profile = '',
    [string]$JsonOutput = ''
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ProjectFile)) {
    $scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    $ProjectFile = Join-Path $scriptRoot '..\durins-vault.project.json'
}

function Resolve-ConfiguredPath([string]$Path, [string]$GameRoot, [string]$ProjectRoot) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    $resolved = $Path.Replace('${game_root}', $GameRoot)
    if (-not [IO.Path]::IsPathRooted($resolved)) {
        $resolved = Join-Path $ProjectRoot $resolved
    }
    return [IO.Path]::GetFullPath($resolved)
}

$projectPath = [IO.Path]::GetFullPath($ProjectFile)
$projectRoot = Split-Path -Parent $projectPath
$project = Get-Content -LiteralPath $projectPath -Raw -Encoding UTF8 | ConvertFrom-Json
$profileName = if ($Profile) { $Profile } else { $project.game.test_profile }
$profile = $project.profiles.$profileName

if ($null -eq $profile) {
    throw "Profile '$profileName' is not defined in $projectPath"
}

$gameRoot = $null
foreach ($candidate in $project.game.install_roots) {
    if (Test-Path -LiteralPath $candidate -PathType Container) {
        $gameRoot = [IO.Path]::GetFullPath($candidate)
        break
    }
}

$checks = @()
$checks += [pscustomobject]@{ Check = 'Project manifest'; Status = 'OK'; Path = $projectPath }
$checks += [pscustomobject]@{ Check = "Profile: $profileName"; Status = 'OK'; Path = $null }

if ($gameRoot) {
    $checks += [pscustomobject]@{ Check = 'Game installation'; Status = 'OK'; Path = $gameRoot }
} else {
    $checks += [pscustomobject]@{ Check = 'Game installation'; Status = 'MISSING'; Path = ($project.game.install_roots -join '; ') }
}

foreach ($entry in @(
    @{ Name = 'UE4SS root'; Value = $profile.ue4ss_root },
    @{ Name = 'Content root'; Value = $profile.content_root },
    @{ Name = 'Pak root'; Value = $profile.pak_root }
)) {
    $path = Resolve-ConfiguredPath $entry.Value $gameRoot $projectRoot
    $status = if ($path -and (Test-Path -LiteralPath $path)) { 'OK' } else { 'MISSING' }
    $checks += [pscustomobject]@{ Check = $entry.Name; Status = $status; Path = $path }
}

if ($gameRoot) {
    $ue4ssPath = Resolve-ConfiguredPath $profile.ue4ss_root $gameRoot $projectRoot
    $modPath = Join-Path $ue4ssPath 'Mods\MoriaCppMod'
    $dllPath = Join-Path $modPath 'dlls\main.dll'
    $enabledPath = Join-Path $modPath 'enabled.txt'
    $checks += [pscustomobject]@{
        Check = 'MoriaCppMod installed'
        Status = if (Test-Path -LiteralPath $dllPath) { 'OK' } else { 'MISSING' }
        Path = $dllPath
    }
    $checks += [pscustomobject]@{
        Check = 'MoriaCppMod enabled'
        Status = if (Test-Path -LiteralPath $enabledPath) { 'OK' } else { 'DISABLED' }
        Path = $enabledPath
    }
}

foreach ($tool in $project.tools.psobject.Properties) {
    if ([string]::IsNullOrWhiteSpace([string]$tool.Value)) {
        $checks += [pscustomobject]@{ Check = "Tool: $($tool.Name)"; Status = 'UNCONFIGURED'; Path = $null }
    } else {
        $toolPath = Resolve-ConfiguredPath ([string]$tool.Value) $gameRoot $projectRoot
        $status = if (Test-Path -LiteralPath $toolPath) { 'OK' } else { 'MISSING' }
        $checks += [pscustomobject]@{ Check = "Tool: $($tool.Name)"; Status = $status; Path = $toolPath }
    }
}

$checks | Format-Table -AutoSize
$checks | ConvertTo-Json -Depth 4 | ForEach-Object {
    if (-not [string]::IsNullOrWhiteSpace($JsonOutput)) {
        $outputPath = [IO.Path]::GetFullPath((Join-Path $projectRoot $JsonOutput))
        $outputDirectory = Split-Path -Parent $outputPath
        if (-not (Test-Path -LiteralPath $outputDirectory)) {
            New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
        }
        $_ | Set-Content -LiteralPath $outputPath -Encoding UTF8
    }
}
if ($checks.Status -contains 'MISSING') { exit 2 }
