[CmdletBinding()]
param(
    [string]$ProjectFile = '',
    [string]$Output = 'working/reports/iostore-building-index.json'
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($ProjectFile)) { $ProjectFile = Join-Path (Get-Location).Path 'durins-vault.project.json' }
$projectPath = [IO.Path]::GetFullPath($ProjectFile)
$projectRoot = Split-Path -Parent $projectPath
$project = Get-Content -LiteralPath $projectPath -Raw -Encoding UTF8 | ConvertFrom-Json
$retoc = [IO.Path]::GetFullPath([string]$project.tools.retoc)
$pakRoot = [IO.Path]::GetFullPath(($project.game.install_roots[0] + '\Moria\Content\Paks'))
$utoc = Join-Path $pakRoot 'Moria-WindowsNoEditor.utoc'
if (-not (Test-Path -LiteralPath $retoc -PathType Leaf)) { throw "retoc not found: $retoc" }
if (-not (Test-Path -LiteralPath $utoc -PathType Leaf)) { throw "Main IoStore container not found: $utoc" }

$scratch = Join-Path $projectRoot 'working\iostore-manifest'
New-Item -ItemType Directory -Force -Path $scratch | Out-Null
$manifestPath = Join-Path $scratch 'pakstore.json'
Push-Location $scratch
try { & $retoc manifest $utoc | Out-Host } finally { Pop-Location }
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw 'retoc did not produce pakstore.json' }
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$pattern = '^/Game/Art/Assets/Blockout/SM_AR_(Floor|Foundation|Stairs|Wall)'
$assets = @($manifest.oplog.entries | ForEach-Object {
    $name = [string]$_.packagestoreentry.packagename
    if ($name -match $pattern) {
        [pscustomobject]@{
            path = $name
            files = @($_.packagedata | ForEach-Object { $_.filename })
        }
    }
} | Sort-Object path)
$report = [pscustomobject]@{
    schema = 'durins-vault.research-iostore-building/v1'
    source = 'Moria-WindowsNoEditor.utoc'
    retoc_version = (& $retoc --version).Trim()
    total_packages = @($manifest.oplog.entries).Count
    matched_packages = $assets.Count
    match_pattern = $pattern
    assets = $assets
}
$outputPath = [IO.Path]::GetFullPath((Join-Path $projectRoot $Output))
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $outputPath) | Out-Null
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $outputPath -Encoding UTF8
$report | Select-Object schema,retoc_version,total_packages,matched_packages,match_pattern | Format-List
