[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$Id,
    [Parameter(Mandatory = $true)] [string]$DisplayName,
    [Parameter(Mandatory = $true)] [string]$RecipeId,
    [Parameter(Mandatory = $true)] [string]$Output,
    [string]$BlueprintClass = '',
    [string]$BlueprintPath = ''
)

$ErrorActionPreference = 'Stop'
if ($Id -notmatch '^[a-z0-9][a-z0-9._-]*$') { throw 'Id must contain lowercase letters, numbers, dots, underscores, or hyphens.' }
if ([string]::IsNullOrWhiteSpace($DisplayName) -or [string]::IsNullOrWhiteSpace($RecipeId)) { throw 'DisplayName and RecipeId are required.' }
$outputPath = [IO.Path]::GetFullPath($Output)
$projectRoot = (Get-Location).Path
$sourcePath = $outputPath.Substring($projectRoot.Length).TrimStart([char]'\', [char]'/').Replace('\', '/')
$record = [ordered]@{
    schema = 'durins-vault.building-piece/v1'
    id = $Id
    display_name = $DisplayName
    blueprint_class = if ($BlueprintClass) { $BlueprintClass } else { "${Id}_C" }
    blueprint_path = if ($BlueprintPath) { $BlueprintPath } else { $null }
    recipe_id = $RecipeId
    buildable = $false
    dimensions = $null
    snap_points = @()
    stability = $null
    source = [ordered]@{
        kind = 'manual'
        path = $sourcePath
        captured_on = (Get-Date -Format 'yyyy-MM-dd')
        tool_version = 'DurinsVault authoring scaffold'
    }
}
New-Item -ItemType Directory -Path (Split-Path -Parent $outputPath) -Force | Out-Null
ConvertTo-Json -InputObject $record -Depth 8 | Set-Content -LiteralPath $outputPath -Encoding UTF8
[pscustomobject]@{ Output = $outputPath; Id = $Id; Status = 'SCAFFOLD_CREATED'; NextStep = 'Replace manual-authoring provenance with verified inspection evidence before deployment.' } | Format-List
