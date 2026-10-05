[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$Export,
    [string]$Index = '.\working\iostore-manifest\pakstore.json'
)

$ErrorActionPreference = 'Stop'
$exportPath = [IO.Path]::GetFullPath($Export)
if (-not (Test-Path -LiteralPath $exportPath -PathType Leaf)) { throw "Asset export not found: $exportPath" }
$item = Get-Content -LiteralPath $exportPath -Raw -Encoding UTF8 | ConvertFrom-Json
$errors = [System.Collections.Generic.List[string]]::new()
if ($item.schema -ne 'durins-vault.asset-export/v1') { $errors.Add('schema must be durins-vault.asset-export/v1') }
if ($item.game -ne 'return-to-moria') { $errors.Add('game must be return-to-moria') }
if ([string]$item.asset_path -notmatch '^/Game/') { $errors.Add('asset_path must begin with /Game/') }
if ($item.asset_kind -notin @('blueprint','datatable','static-mesh','material','texture','other')) { $errors.Add('asset_kind is invalid') }
if ([string]::IsNullOrWhiteSpace([string]$item.reader.name) -or [string]::IsNullOrWhiteSpace([string]$item.reader.version)) { $errors.Add('reader.name and reader.version are required') }
if ([string]::IsNullOrWhiteSpace([string]$item.source.container) -or [string]::IsNullOrWhiteSpace([string]$item.source.exported_on)) { $errors.Add('source.container and source.exported_on are required') }
if (Test-Path -LiteralPath $Index -PathType Leaf) {
    $manifest = Get-Content -LiteralPath $Index -Raw -Encoding UTF8 | ConvertFrom-Json
    $found = @($manifest.oplog.entries | Where-Object { [string]$_.packagestoreentry.packagename -eq [string]$item.asset_path }).Count -gt 0
    if (-not $found) { $errors.Add("asset_path is not present in the supplied IoStore index: $($item.asset_path)") }
}
if ($errors.Count -gt 0) { $errors | ForEach-Object { Write-Error $_ }; exit 2 }
[pscustomobject]@{ Export = $exportPath; AssetPath = $item.asset_path; AssetKind = $item.asset_kind; Status = 'OK' } | Format-List
