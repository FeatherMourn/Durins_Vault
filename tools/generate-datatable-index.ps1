[CmdletBinding()]
param(
    [string]$ProjectFile = '',
    [string]$Output = 'working/reports/iostore-datatable-index.json'
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($ProjectFile)) { $ProjectFile = Join-Path (Get-Location).Path 'durins-vault.project.json' }
$projectPath = [IO.Path]::GetFullPath($ProjectFile)
$projectRoot = Split-Path -Parent $projectPath
$project = Get-Content -LiteralPath $projectPath -Raw -Encoding UTF8 | ConvertFrom-Json
$retoc = [IO.Path]::GetFullPath([string]$project.tools.retoc)
$utoc = [IO.Path]::GetFullPath(($project.game.install_roots[0] + '\Moria\Content\Paks\Moria-WindowsNoEditor.utoc'))
$scratch = Join-Path $projectRoot 'working\iostore-manifest'
New-Item -ItemType Directory -Force -Path $scratch | Out-Null
Push-Location $scratch
try { & $retoc manifest $utoc | Out-Host } finally { Pop-Location }
$manifest = Get-Content -LiteralPath (Join-Path $scratch 'pakstore.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$assets = @($manifest.oplog.entries | ForEach-Object {
    $name = [string]$_.packagestoreentry.packagename
    if ($name -match '^/Game/.*/DT_[^/]+$') {
        [pscustomobject]@{ path = $name; files = @($_.packagedata | ForEach-Object { $_.filename }) }
    }
} | Sort-Object path)
$report = [pscustomobject]@{
    schema = 'durins-vault.research-iostore-datatables/v1'
    source = 'Moria-WindowsNoEditor.utoc'
    retoc_version = (& $retoc --version).Trim()
    total_packages = @($manifest.oplog.entries).Count
    matched_datatables = $assets.Count
    assets = $assets
}
$outputPath = [IO.Path]::GetFullPath((Join-Path $projectRoot $Output))
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $outputPath) | Out-Null
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $outputPath -Encoding UTF8
$report | Select-Object schema,retoc_version,total_packages,matched_datatables | Format-List
