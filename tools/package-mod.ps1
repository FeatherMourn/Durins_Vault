[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$Manifest,
    [Parameter(Mandatory = $true)] [string]$Output
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Get-Location).Path
$manifestPath = [IO.Path]::GetFullPath($Manifest)
$modRoot = Split-Path -Parent $manifestPath
$mod = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
& powershell -ExecutionPolicy Bypass -File (Join-Path $projectRoot 'tools\validate-mod.ps1') -Manifest $manifestPath
if ($LASTEXITCODE -ne 0) { throw 'Manifest validation failed; package was not created.' }

$outputPath = [IO.Path]::GetFullPath($Output)
$stageRoot = Join-Path $projectRoot ("working\package-stage\" + $mod.id)
if (Test-Path -LiteralPath $stageRoot) { Remove-Item -LiteralPath $stageRoot -Recurse -Force }
New-Item -ItemType Directory -Path $stageRoot -Force | Out-Null
Copy-Item -LiteralPath $manifestPath -Destination (Join-Path $stageRoot 'mod.json')
$copied = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($layerName in @('runtime', 'cooked_content', 'data_tables')) {
    foreach ($artifact in @($mod.layers.$layerName)) {
        if ($null -eq $artifact) { continue }
        $source = [IO.Path]::GetFullPath((Join-Path $projectRoot $artifact.source))
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing declared artifact: $($artifact.source)" }
        $relative = $artifact.source.Replace('/', '\')
        $destination = Join-Path $stageRoot $relative
        $destinationKey = $destination.ToLowerInvariant()
        if ($copied.Contains($destinationKey)) { continue }
        New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
        Copy-Item -LiteralPath $source -Destination $destination
        $copied.Add($destinationKey) | Out-Null
    }
}
New-Item -ItemType Directory -Path (Split-Path -Parent $outputPath) -Force | Out-Null
if (Test-Path -LiteralPath $outputPath) { Remove-Item -LiteralPath $outputPath -Force }
Compress-Archive -LiteralPath $stageRoot -DestinationPath $outputPath -CompressionLevel Optimal
$expected = @('mod.json')
foreach ($layerName in @('runtime', 'cooked_content', 'data_tables')) {
    foreach ($artifact in @($mod.layers.$layerName)) {
        if ($artifact) { $expected += $artifact.source.Replace('/', '\') }
    }
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [IO.Compression.ZipFile]::OpenRead($outputPath)
try {
    $entries = @($archive.Entries | ForEach-Object { $_.FullName })
    foreach ($relative in $expected) {
        $entryName = ($mod.id + '/' + $relative).Replace('\', '/')
        if ($entries -notcontains $entryName) { throw "Package is missing declared entry: $relative" }
    }
} finally { $archive.Dispose() }
Remove-Item -LiteralPath $stageRoot -Recurse -Force
[pscustomobject]@{ Package = $outputPath; Mod = $mod.id; Artifacts = $copied.Count; Status = 'PACKAGED' } | Format-List
