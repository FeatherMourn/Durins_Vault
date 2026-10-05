[CmdletBinding()]
param(
    [string]$Catalog = '.\working\reports\runtime-inspection-catalog.json',
    [string]$Output = '.\working\reports\construction-property-index.json'
)

$ErrorActionPreference = 'Stop'
$catalogPath = [IO.Path]::GetFullPath($Catalog)
if (-not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) { throw "Inspection catalog not found: $catalogPath" }
$jsonData = Get-Content -LiteralPath $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json
$records = @($jsonData.records)
$classNames = @($records | ForEach-Object { [string]$_.class_full_name } | Where-Object { $_ } | Sort-Object -Unique)
$classList = [System.Collections.Generic.List[object]]::new()
foreach ($className in $classNames) {
    $propertyRows = @{}
    foreach ($record in ($records | Where-Object { [string]$_.class_full_name -eq $className })) {
        foreach ($property in @($record.properties)) {
            $name = [string]$property.name
            if ([string]::IsNullOrWhiteSpace($name)) { continue }
            $key = "$name|$([int]$property.offset)"
            if (-not $propertyRows.ContainsKey($key)) { $propertyRows[$key] = [ordered]@{ name = $name; offset = [int]$property.offset; observations = 0; first_seen = [string]$record.timestamp; last_seen = [string]$record.timestamp } }
            $entry = $propertyRows[$key]
            $entry.observations++
            if ([string]$record.timestamp -lt [string]$entry.first_seen) { $entry.first_seen = [string]$record.timestamp }
            if ([string]$record.timestamp -gt [string]$entry.last_seen) { $entry.last_seen = [string]$record.timestamp }
        }
    }
    $classList.Add([ordered]@{ class_full_name = $className; properties = @($propertyRows.Values | Sort-Object name, offset) })
}
$report = [ordered]@{
    schema = 'durins-vault.construction-properties/v1'
    game = [string]$jsonData.game
    source_catalog = $catalogPath
    evidence_policy = 'Observed names and offsets only; values and buildability require separate verified evidence.'
    classes = @($classList)
}
$outputPath = [IO.Path]::GetFullPath($Output)
New-Item -ItemType Directory -Path (Split-Path -Parent $outputPath) -Force | Out-Null
ConvertTo-Json -InputObject $report -Depth 8 | Set-Content -LiteralPath $outputPath -Encoding UTF8
[pscustomobject]@{ Output = $outputPath; Classes = $classList.Count; Properties = @($classList | ForEach-Object { $_.properties }).Count; Status = 'OK' } | Format-List
