[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$BlueprintSummary,
    [Parameter(Mandatory = $true)] [string]$DataTableSummary,
    [Parameter(Mandatory = $true)] [string]$Output,
    [string]$Id = 'moria.crude-wall-3x4-a'
)

$ErrorActionPreference = 'Stop'
$blueprint = Get-Content -LiteralPath ([IO.Path]::GetFullPath($BlueprintSummary)) -Raw -Encoding UTF8 | ConvertFrom-Json
$table = Get-Content -LiteralPath ([IO.Path]::GetFullPath($DataTableSummary)) -Raw -Encoding UTF8 | ConvertFrom-Json
$row = $table.verified.sample_row
$class = [string]$blueprint.verified.blueprint_class
if ([string]$row.actor -notmatch [regex]::Escape($class)) { throw 'Blueprint summary and DataTable summary do not refer to the same actor.' }
$blueprintPath = [string]$blueprint.asset_path
$projectRoot = (Get-Location).Path
$sourcePath = [IO.Path]::GetFullPath($BlueprintSummary).Substring($projectRoot.Length).TrimStart([char]'\', [char]'/').Replace('\', '/')
$record = [ordered]@{
    schema = 'durins-vault.building-piece/v1'
    id = $Id
    display_name = [string]$row.display_name
    blueprint_class = $class
    blueprint_path = $blueprintPath
    recipe_id = [string]$row.id
    buildable = $false
    dimensions = $null
    snap_points = @()
    stability = [ordered]@{ row = [string]$blueprint.verified.stability_row; snap_rule = [string]$blueprint.verified.snap_rule }
    source = [ordered]@{
        kind = 'fmodel'
        path = $sourcePath
        captured_on = (Get-Date -Format 'yyyy-MM-dd')
        tool_version = 'FModel 4.4.4.0 / DurinsVault promotion tool'
    }
}
$outputPath = [IO.Path]::GetFullPath($Output)
New-Item -ItemType Directory -Path (Split-Path -Parent $outputPath) -Force | Out-Null
ConvertTo-Json -InputObject $record -Depth 8 | Set-Content -LiteralPath $outputPath -Encoding UTF8
[pscustomobject]@{ Output = $outputPath; BlueprintClass = $class; RecipeId = $row.id; Buildable = $false; Status = 'PROMOTED_RESEARCH_RECORD' } | Format-List
