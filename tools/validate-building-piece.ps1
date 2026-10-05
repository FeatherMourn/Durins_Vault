[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Record
)

$ErrorActionPreference = 'Stop'
$recordPath = [IO.Path]::GetFullPath($Record)
$projectRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $recordPath))
$piece = Get-Content -LiteralPath $recordPath -Raw -Encoding UTF8 | ConvertFrom-Json
$errors = [System.Collections.Generic.List[string]]::new()

foreach ($field in @('schema', 'id', 'display_name', 'blueprint_class', 'recipe_id', 'source')) {
    if ($null -eq $piece.$field -or [string]::IsNullOrWhiteSpace([string]$piece.$field)) {
        $errors.Add("Missing required field: $field")
    }
}
if ($piece.schema -ne 'durins-vault.building-piece/v1') { $errors.Add("Unsupported schema: $($piece.schema)") }
if ($piece.id -notmatch '^[a-z0-9][a-z0-9._-]*$') { $errors.Add("Invalid piece id: $($piece.id)") }
if ($null -eq $piece.source -or $piece.source.kind -notin @('native-inspection', 'fmodel', 'manual')) {
    $errors.Add('source.kind must be native-inspection, fmodel, or manual')
}
if ($null -ne $piece.source -and $piece.source.path) {
    $sourcePath = $piece.source.path
    if ([IO.Path]::IsPathRooted($sourcePath) -or $sourcePath -match '(^|[\\/])\.\.([\\/]|$)') {
        $errors.Add('source.path must be a relative project path')
    } else {
        $resolved = [IO.Path]::GetFullPath((Join-Path $projectRoot $sourcePath))
        if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) { $errors.Add("source.path does not exist: $sourcePath") }
    }
}
if ($piece.blueprint_path) {
    $manifestPath = Join-Path $projectRoot 'working\iostore-manifest\pakstore.json'
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        $errors.Add('blueprint_path requires a generated IoStore manifest')
    } else {
        $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $found = $false
        foreach ($entry in $manifest.oplog.entries) {
            if ([string]$entry.packagestoreentry.packagename -eq [string]$piece.blueprint_path) { $found = $true; break }
        }
        if (-not $found) { $errors.Add("blueprint_path not found in IoStore manifest: $($piece.blueprint_path)") }
    }
}
if ($null -ne $piece.dimensions) {
    foreach ($dimension in @('width', 'height', 'depth')) {
        if ($null -ne $piece.dimensions.$dimension -and [double]$piece.dimensions.$dimension -le 0) {
            $errors.Add("dimensions.$dimension must be greater than zero")
        }
    }
    if ($piece.dimensions.unit -and $piece.dimensions.unit -ne 'cm') { $errors.Add('dimensions.unit must be cm') }
}

if ($errors.Count -gt 0) {
    Write-Error (($errors | ForEach-Object { "- $_" }) -join [Environment]::NewLine)
    exit 2
}

[pscustomobject]@{
    Record = $recordPath
    Id = $piece.id
    Blueprint = $piece.blueprint_class
    Recipe = $piece.recipe_id
    Buildable = $piece.buildable
    Source = $piece.source.kind
    Status = 'OK'
} | Format-List
