[CmdletBinding()]
param(
    [string]$Catalog = '.\working\reports\runtime-inspection-catalog.json',
    [string]$Output = '.\working\reports\construction-property-index.json'
)

$ErrorActionPreference = 'Stop'
$catalogPath = [IO.Path]::GetFullPath($Catalog)
if (-not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) { throw "Inspection catalog not found: $catalogPath" }
$catalog = Get-Content -LiteralPath $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json
$groups = @{}
foreach ($record in $catalog.records) {
    $className = [string]$record.class_full_name
    if ([string]::IsNullOrWhiteSpace($className)) { continue }
    if (-not $groups.ContainsKey($className)) { $groups[$className] = @{} }
    foreach ($property in $record.properties) {
        $name = [string]$property.name
        if ([string]::IsNullOrWhiteSpace($name)) { continue }
        $key = "$name|$([int]$property.offset)"
        if (-not $groups[$className].ContainsKey($key)) {
            $groups[$className][$key] = [ordered]@{ name = $name; offset = [int]$property.offset; observations = 0; first_seen = [string]$record.timestamp; last_seen = [string]$record.timestamp }
        }
        $entry = $groups[$className][$key]
        $entry.observations++
        if ([string]$record.timestamp -lt [string]$entry.first_seen) { $entry.first_seen = [string]$record.timestamp }
        if ([string]$record.timestamp -gt [string]$entry.last_seen) { $entry.last_seen = [string]$record.timestamp }
    }
}
$classes = foreach ($group in ($groups.GetEnumerator() | Sort-Object Key)) {
    [ordered]@{ class_full_name = [string]$group.Key; properties = @($group.Value.GetEnumerator() | ForEach-Object { $_.Value } | Sort-Object name, offset) }
}
$report = [ordered]@{
    schema = 'durins-vault.construction-properties/v1'
    game = [string]$catalog.game
    source_catalog = $catalogPath
    evidence_policy = 'Observed names and offsets only; values and buildability require separate verified evidence.'
    classes = @($classes)
}
$outputPath = [IO.Path]::GetFullPath($Output)
New-Item -ItemType Directory -Path (Split-Path -Parent $outputPath) -Force | Out-Null
ConvertTo-Json -InputObject $report -Depth 8 | Set-Content -LiteralPath $outputPath -Encoding UTF8
[pscustomobject]@{ Output = $outputPath; Classes = @($classes).Count; Properties = @($classes | ForEach-Object { $_.properties }).Count; Status = 'OK' } | Format-List
