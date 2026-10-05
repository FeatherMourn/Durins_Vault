[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Manifest
)

$ErrorActionPreference = 'Stop'
$manifestPath = [IO.Path]::GetFullPath($Manifest)
$modRoot = Split-Path -Parent $manifestPath
$projectRoot = Split-Path -Parent (Split-Path -Parent $modRoot)
$mod = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$errors = [System.Collections.Generic.List[string]]::new()

function Require-Value([object]$Value, [string]$Name) {
    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        $errors.Add("Missing required value: $Name")
    }
}

function Test-RelativePath([string]$Value, [string]$Name) {
    Require-Value $Value $Name
    if ([string]::IsNullOrWhiteSpace($Value)) { return }
    if ([IO.Path]::IsPathRooted($Value) -or $Value -match '(^|[\\/])\.\.([\\/]|$)') {
        $errors.Add("$Name must be a relative path inside the project: $Value")
        return
    }
    $full = [IO.Path]::GetFullPath((Join-Path $projectRoot $Value))
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
        $errors.Add("Referenced file does not exist: $Name -> $Value")
    }
}

Require-Value $mod.schema 'schema'
Require-Value $mod.id 'id'
Require-Value $mod.name 'name'
Require-Value $mod.version 'version'
if ($mod.schema -ne 'durins-vault.mod/v1') { $errors.Add("Unsupported schema: $($mod.schema)") }
if ($mod.id -notmatch '^[a-z0-9][a-z0-9._-]*$') { $errors.Add("Invalid mod id: $($mod.id)") }
if ($mod.version -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') { $errors.Add("Version must use MAJOR.MINOR.PATCH: $($mod.version)") }

if ($null -eq $mod.game -or $mod.game.id -ne 'return-to-moria') { $errors.Add('game.id must be return-to-moria') }
if ($null -eq $mod.game -or $mod.game.engine -ne 'UE4.27') { $errors.Add('game.engine must be UE4.27') }
if ($null -eq $mod.requires) { $errors.Add('Missing required array: requires') }
if ($null -eq $mod.layers) { $errors.Add('Missing required object: layers') }

if ($null -ne $mod.layers) {
    foreach ($layerName in @('runtime', 'cooked_content', 'data_tables', 'research')) {
        if ($null -eq $mod.layers.$layerName) {
            $errors.Add("Missing layer: layers.$layerName")
        }
    }
    foreach ($layerName in @('runtime', 'cooked_content', 'data_tables')) {
        foreach ($artifact in @($mod.layers.$layerName)) {
            if ($null -eq $artifact.source) { $errors.Add("layers.$layerName artifact is missing source") }
            if ($null -eq $artifact.destination) { $errors.Add("layers.$layerName artifact is missing destination") }
            if ($null -ne $artifact.source) { Test-RelativePath $artifact.source "layers.$layerName.source" }
            if ($artifact.destination -and ([IO.Path]::IsPathRooted($artifact.destination) -or $artifact.destination -match '(^|[\\/])\.\.([\\/]|$)')) {
                $errors.Add("layers.$layerName.destination must be relative: $($artifact.destination)")
            }
        }
    }
    foreach ($researchFile in @($mod.layers.research)) {
        Test-RelativePath $researchFile 'layers.research'
    }
}

if ($errors.Count -gt 0) {
    Write-Error (($errors | ForEach-Object { "- $_" }) -join [Environment]::NewLine)
    exit 2
}

[pscustomobject]@{
    Manifest = $manifestPath
    Id = $mod.id
    Version = $mod.version
    Game = "$($mod.game.id) / $($mod.game.engine)"
    Status = 'OK'
} | Format-List
