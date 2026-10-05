[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$Export,
    [Parameter(Mandatory = $true)] [ValidateSet('blueprint','datatable','static-mesh','material','texture','other')] [string]$AssetKind,
    [Parameter(Mandatory = $true)] [string]$Output,
    [string]$ReaderVersion = '4.4.4.0',
    [string]$GameBuild = 'Steam installation / UE4.27 capture'
)

$ErrorActionPreference = 'Stop'
$exportPath = [IO.Path]::GetFullPath($Export)
$raw = Get-Content -LiteralPath $exportPath -Raw -Encoding UTF8 | ConvertFrom-Json
$objects = @($raw)
$root = $objects | Where-Object { [string]$_.Package -match '^/Game/' } | Select-Object -First 1
if ($null -eq $root) { throw 'FModel export does not contain a /Game/ Package field.' }
$assetPath = [string]$root.Package
$properties = [ordered]@{}
$rows = @()
if ($AssetKind -eq 'datatable') {
    $properties.row_struct = [string]$root.Properties.RowStruct.ObjectName -replace "^Class'|'$", ''
    $rows = @($root.Rows.PSObject.Properties | ForEach-Object {
        [ordered]@{ id = $_.Name; data = $_.Value }
    })
    $properties.row_count = $rows.Count
} else {
    $properties.object_types = @($objects | ForEach-Object { [string]$_.Type } | Where-Object { $_ } | Sort-Object -Unique)
    $properties.object_count = $objects.Count
}
$result = [ordered]@{
    schema = 'durins-vault.asset-export/v1'
    game = 'return-to-moria'
    game_build = $GameBuild
    asset_path = $assetPath
    asset_kind = $AssetKind
    reader = [ordered]@{ name = 'FModel'; version = $ReaderVersion }
    source = [ordered]@{ container = 'Moria-WindowsNoEditor.utoc'; exported_on = (Get-Date -Format 'yyyy-MM-dd'); export_file = $exportPath }
    properties = $properties
    rows = $rows
    notes = 'Generated from a FModel properties export; original cooked assets are not included.'
}
$outputPath = [IO.Path]::GetFullPath($Output)
New-Item -ItemType Directory -Path (Split-Path -Parent $outputPath) -Force | Out-Null
ConvertTo-Json -InputObject $result -Depth 20 | Set-Content -LiteralPath $outputPath -Encoding UTF8
& powershell -ExecutionPolicy Bypass -File (Join-Path (Get-Location).Path 'tools\validate-asset-export.ps1') -Export $outputPath
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
