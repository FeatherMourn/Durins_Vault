[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$ModsRoot,
    [string[]]$ModId,
    [string]$ProjectFile = '',
    [string]$JsonOutput = ''
)

$ErrorActionPreference = 'Stop'
function Resolve-AbsolutePath([string]$Value) {
    if ([IO.Path]::IsPathRooted($Value)) { return $Value }
    return [IO.Path]::GetFullPath($Value)
}
$root = Resolve-AbsolutePath $ModsRoot
$projectPath = if ($ProjectFile) { Resolve-AbsolutePath $ProjectFile } else { Join-Path (Split-Path -Parent $root) 'durins-vault.project.json' }
$projectRoot = Split-Path -Parent $projectPath
$project = Get-Content -LiteralPath $projectPath -Raw -Encoding UTF8 | ConvertFrom-Json
$gameRoot = @($project.game.install_roots | Where-Object { Test-Path -LiteralPath $_ -PathType Container } | Select-Object -First 1)
if (-not $gameRoot) { throw 'No configured game installation was found.' }
$gameRoot = Resolve-AbsolutePath $gameRoot

$records = @{}
foreach ($file in @(Get-ChildItem -LiteralPath $root -Filter mod.json -File -Recurse)) {
    $mod = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($records.ContainsKey($mod.id)) { throw "Duplicate mod id: $($mod.id)" }
    $records[$mod.id] = $mod
}
if ($records.Count -eq 0) { throw "No manifests found under: $root" }
$selected = if ($ModId -and $ModId.Count -gt 0) { @($ModId) } else { @($records.Keys) }
foreach ($id in $selected) { if (-not $records.ContainsKey($id)) { throw "Unknown mod id: $id" } }

$ordered = [System.Collections.Generic.List[string]]::new()
$visiting = @{}
function Add-Mod([string]$Id) {
    if ($visiting.ContainsKey($Id)) { throw "Dependency cycle detected at: $Id" }
    if ($ordered.Contains($Id)) { return }
    $visiting[$Id] = $true
    foreach ($dependency in @($records[$Id].requires)) {
        if (-not $records.ContainsKey($dependency.id)) { throw "Mod '$Id' requires unavailable mod '$($dependency.id)'" }
        Add-Mod $dependency.id
    }
    $visiting.Remove($Id)
    $ordered.Add($Id)
}
foreach ($id in $selected) { Add-Mod $id }

$plan = [System.Collections.Generic.List[object]]::new()
$destinationOwners = @{}
$order = 0
foreach ($id in $ordered) {
    $mod = $records[$id]
    foreach ($layerName in @('runtime', 'cooked_content', 'data_tables')) {
        foreach ($artifact in @($mod.layers.$layerName)) {
            if ($null -eq $artifact) { continue }
            $source = Resolve-AbsolutePath (Join-Path $projectRoot $artifact.source)
            $destination = [string]$artifact.destination
            $destination = $destination.Replace('${game_root}', $gameRoot)
            if (-not [IO.Path]::IsPathRooted($destination)) { $destination = Join-Path $gameRoot $destination }
            $destination = Resolve-AbsolutePath $destination
            $key = $destination.ToLowerInvariant()
            $collision = $destinationOwners[$key]
            $plan.Add([pscustomobject]@{
                Sequence = $order
                Mod = $id
                Layer = $layerName
                Source = $source
                SourceExists = Test-Path -LiteralPath $source -PathType Leaf
                Destination = $destination
                ExistingDestination = Test-Path -LiteralPath $destination
                Collision = if ($collision) { $collision } else { '' }
                Action = 'REVIEW_ONLY'
            })
            if (-not $destinationOwners.ContainsKey($key)) { $destinationOwners[$key] = $id }
            $order++
        }
    }
}
$result = @($plan)
if ($JsonOutput) {
    $outputCandidate = if ([IO.Path]::IsPathRooted($JsonOutput)) { $JsonOutput } else { Join-Path $projectRoot $JsonOutput }
    $outputPath = Resolve-AbsolutePath $outputCandidate
    New-Item -ItemType Directory -Path (Split-Path -Parent $outputPath) -Force | Out-Null
    ConvertTo-Json -InputObject $result -Depth 8 | Set-Content -LiteralPath $outputPath -Encoding UTF8
}
[pscustomobject]@{ Mods = ($ordered -join ', '); Artifacts = $result.Count; GameRoot = $gameRoot; Status = 'REVIEW_ONLY' } | Format-List
$result | Format-Table Sequence, Mod, Layer, SourceExists, Destination, Collision -AutoSize
if (@($result | Where-Object { -not $_.SourceExists -or $_.Collision }).Count -gt 0) { exit 2 }
