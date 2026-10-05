[CmdletBinding()]
param(
    [string]$Catalog = '.\data\research\building-datatables.json',
    [string]$Index = '.\working\reports\iostore-datatable-index.json'
)
$ErrorActionPreference = 'Stop'
$catalog = Get-Content -LiteralPath ([IO.Path]::GetFullPath($Catalog)) -Raw -Encoding UTF8 | ConvertFrom-Json
$index = Get-Content -LiteralPath ([IO.Path]::GetFullPath($Index)) -Raw -Encoding UTF8 | ConvertFrom-Json
$known = @{}
foreach ($asset in @($index.assets)) { $known[[string]$asset.path] = $true }
$missing = @($catalog.assets | Where-Object { -not $known.ContainsKey([string]$_.path) })
if ($missing.Count -gt 0) { Write-Error (($missing | ForEach-Object { "Missing DataTable from index: $($_.path)" }) -join [Environment]::NewLine); exit 2 }
$catalogCount = $catalog.assets.Length
$indexCount = $index.assets.Length
[pscustomobject]@{ CatalogAssets = $catalogCount; IndexedDataTables = $indexCount; Status = 'OK' } | Format-List
