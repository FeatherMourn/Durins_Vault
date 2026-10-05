[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$Log,
    [string]$Output = 'working\reports\runtime-inspection-catalog.json'
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Get-Location).Path
$logPath = [IO.Path]::GetFullPath($Log)
& powershell -ExecutionPolicy Bypass -File (Join-Path $projectRoot 'tools\validate-inspection-log.ps1') -Log $logPath
if ($LASTEXITCODE -ne 0) { throw 'Inspection log validation failed; no catalog was written.' }
$records = [System.Collections.Generic.List[object]]::new()
foreach ($line in Get-Content -LiteralPath $logPath -Encoding UTF8) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $hit = $line | ConvertFrom-Json
    $records.Add([ordered]@{
        actor_full_name = $hit.actor_full_name
        class_full_name = $hit.class_full_name
        component_full_name = $hit.component_full_name
        component_class_full_name = $hit.component_class_full_name
        timestamp = $hit.timestamp
        source = 'DurinsVaultInspectorNative'
    })
}
$catalog = [ordered]@{
    schema = 'durins-vault.runtime-inspection/v1'
    game = 'return-to-moria'
    source_log = $logPath
    records = @($records)
    note = 'Runtime evidence only; recipe, buildability, and asset references require separate verified inspection.'
}
$outputPath = [IO.Path]::GetFullPath((Join-Path $projectRoot $Output))
New-Item -ItemType Directory -Path (Split-Path -Parent $outputPath) -Force | Out-Null
ConvertTo-Json -InputObject $catalog -Depth 8 | Set-Content -LiteralPath $outputPath -Encoding UTF8
[pscustomobject]@{ Output = $outputPath; Records = $records.Count; Status = 'INGESTED' } | Format-List
