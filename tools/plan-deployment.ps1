[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Manifest,
    [string]$ProjectFile = '',
    [string]$Profile = '',
    [string]$JsonOutput = ''
)

$ErrorActionPreference = 'Stop'
$manifestPath = if ([IO.Path]::IsPathRooted($Manifest)) { $Manifest } else { [IO.Path]::GetFullPath($Manifest) }
$modRoot = Split-Path -Parent $manifestPath
$projectPath = if ($ProjectFile) { [IO.Path]::GetFullPath($ProjectFile) } else { Join-Path (Split-Path -Parent (Split-Path -Parent $modRoot)) 'durins-vault.project.json' }
$projectRoot = Split-Path -Parent $projectPath
$mod = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$project = Get-Content -LiteralPath $projectPath -Raw -Encoding UTF8 | ConvertFrom-Json
$profileName = if ($Profile) { $Profile } else { $project.game.test_profile }
$profile = $project.profiles.$profileName
if ($null -eq $profile) { throw "Profile '$profileName' is not defined." }

function Resolve-GameRoot {
    foreach ($candidate in $project.game.install_roots) {
        if (Test-Path -LiteralPath $candidate -PathType Container) { return [IO.Path]::GetFullPath($candidate) }
    }
    throw 'No configured game installation was found.'
}

function Resolve-ProjectPath([string]$Value) {
    if ([IO.Path]::IsPathRooted($Value) -or $Value -match '(^|[\\/])\.\.([\\/]|$)') { throw "Unsafe project path: $Value" }
    return [IO.Path]::GetFullPath((Join-Path $projectRoot $Value))
}

$gameRoot = Resolve-GameRoot
$plan = [System.Collections.Generic.List[object]]::new()
$layers = @('runtime', 'cooked_content', 'data_tables')
foreach ($layerName in $layers) {
    foreach ($artifact in @($mod.layers.$layerName)) {
        if ($null -eq $artifact) { continue }
        $source = Resolve-ProjectPath $artifact.source
        $destination = $artifact.destination.Replace('${game_root}', $gameRoot)
        if (-not [IO.Path]::IsPathRooted($destination)) {
            $destination = [IO.Path]::GetFullPath((Join-Path $gameRoot $destination))
        }
        $plan.Add([pscustomobject]@{
            Mod = $mod.id
            Layer = $layerName
            Source = $source
            SourceExists = Test-Path -LiteralPath $source -PathType Leaf
            Destination = $destination
            ExistingDestination = Test-Path -LiteralPath $destination
            LoadOrder = if ($null -ne $artifact.load_order) { [int]$artifact.load_order } else { 0 }
            Action = 'REVIEW_ONLY'
        })
    }
}
$plan = @($plan | Sort-Object LoadOrder, Layer, Destination)
if ($JsonOutput) {
    $outputPath = Resolve-ProjectPath $JsonOutput
    $outputDirectory = Split-Path -Parent $outputPath
    if (-not (Test-Path -LiteralPath $outputDirectory)) { New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null }
    ConvertTo-Json -InputObject @($plan) -Depth 6 | Set-Content -LiteralPath $outputPath -Encoding UTF8
}
$plan | Format-Table -AutoSize
if (@($plan | Where-Object { -not $_.SourceExists }).Count -gt 0) { exit 2 }
