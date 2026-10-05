[CmdletBinding()]
param(
    [string]$Catalog = '.\data\building\blockout-asset-families.json',
    [string]$Index = '.\working\reports\iostore-building-index.json'
)

$ErrorActionPreference = 'Stop'
$catalogPath = [IO.Path]::GetFullPath($Catalog)
$indexPath = [IO.Path]::GetFullPath($Index)
if (-not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) { throw "Catalog not found: $catalogPath" }
if (-not (Test-Path -LiteralPath $indexPath -PathType Leaf)) { throw "IoStore index not found: $indexPath. Generate it first." }
$catalog = Get-Content -LiteralPath $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json
$index = Get-Content -LiteralPath $indexPath -Raw -Encoding UTF8 | ConvertFrom-Json
$indexPaths = @{}
foreach ($asset in @($index.assets)) { $indexPaths[[string]$asset.path] = $true }
$missing = @($catalog.assets | Where-Object { -not $indexPaths.ContainsKey([string]$_.path) })
if ($missing.Count -gt 0) {
    Write-Error (($missing | ForEach-Object { "Missing from IoStore index: $($_.path)" }) -join [Environment]::NewLine)
    exit 2
}
[pscustomobject]@{
    Catalog = $catalogPath
    IoStoreIndex = $indexPath
    CatalogAssets = @($catalog.assets).Count
    IndexedAssets = @($index.assets).Count
    Status = 'OK'
} | Format-List
