[CmdletBinding()]
param(
    [string]$Record = '.\data\building\crude-wall-3x4-a.json',
    [string]$Summary = '.\data\research\construction-datatable-export.json'
)

$ErrorActionPreference = 'Stop'
$piece = Get-Content -LiteralPath ([IO.Path]::GetFullPath($Record)) -Raw -Encoding UTF8 | ConvertFrom-Json
$table = Get-Content -LiteralPath ([IO.Path]::GetFullPath($Summary)) -Raw -Encoding UTF8 | ConvertFrom-Json
$row = $table.verified.sample_row
$errors = [System.Collections.Generic.List[string]]::new()
if ([string]$piece.recipe_id -ne [string]$row.id) { $errors.Add("recipe_id '$($piece.recipe_id)' does not match verified row '$($row.id)'") }
$expectedClass = ([string]$piece.blueprint_class)
if ([string]$row.actor -notmatch [regex]::Escape($expectedClass)) { $errors.Add("blueprint_class '$expectedClass' is not represented by the verified actor path '$($row.actor)'") }
if ($errors.Count -gt 0) { $errors | ForEach-Object { Write-Error $_ }; exit 2 }
[pscustomobject]@{ Record = $Record; DataTable = $Summary; RecipeId = $row.id; Actor = $row.actor; Status = 'OK' } | Format-List
