[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$Manifest
)

$ErrorActionPreference = 'Stop'
$manifestPath = [IO.Path]::GetFullPath($Manifest)
$projectRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $manifestPath))
$prototype = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$errors = [System.Collections.Generic.List[string]]::new()

if ($prototype.schema -ne 'durins-vault.cooked-prototype/v1') { $errors.Add('Unsupported prototype schema') }
if ($prototype.id -notmatch '^[a-z0-9][a-z0-9._-]*$') { $errors.Add('Invalid prototype id') }
if (-not $prototype.source_piece) { $errors.Add('Missing source_piece') }
elseif (-not (Test-Path -LiteralPath (Join-Path $projectRoot $prototype.source_piece) -PathType Leaf)) { $errors.Add("Missing source piece: $($prototype.source_piece)") }
if ($prototype.target.blueprint_package -notmatch '^/Game/') { $errors.Add('target.blueprint_package must be a /Game/ path') }
if (-not $prototype.target.blueprint_class) { $errors.Add('Missing target.blueprint_class') }
if (-not $prototype.recipe.row_name) { $errors.Add('Missing recipe.row_name') }
if ($prototype.recipe.datatable -notmatch '^/Game/') { $errors.Add('recipe.datatable must be a /Game/ path') }
if (@($prototype.acceptance).Count -lt 5) { $errors.Add('At least five acceptance checks are required') }

if ($errors.Count -gt 0) {
    Write-Error (($errors | ForEach-Object { "- $_" }) -join [Environment]::NewLine)
    exit 2
}

[pscustomobject]@{
    Manifest = $manifestPath
    Prototype = $prototype.id
    SourcePiece = $prototype.source_piece
    Blueprint = $prototype.target.blueprint_class
    Recipe = $prototype.recipe.row_name
    AcceptanceChecks = @($prototype.acceptance).Count
    Status = 'READY_FOR_AUTHORING'
    Buildable = $false
} | Format-List
