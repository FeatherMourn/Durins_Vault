[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ReferenceRoot,
    [string]$Output = '.\working\reports\native-source-state.json'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$ReferenceRoot = [IO.Path]::GetFullPath($ReferenceRoot)
if (-not (Test-Path -LiteralPath (Join-Path $ReferenceRoot '.git') -PathType Container)) {
    throw "Native reference is not a Git checkout: $ReferenceRoot"
}

$commit = (& git -C $ReferenceRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Unable to read native reference revision.' }
$status = @(& git -C $ReferenceRoot status --short -- 'MyCPPMods/MoriaCppMod/src')
$diffStat = (@(& git -C $ReferenceRoot diff --stat -- 'MyCPPMods/MoriaCppMod/src') -join "`n").Trim()
$tracked = @($status | ForEach-Object {
    if ($_ -match '^..\s+(.+)$') { $Matches[1] }
})

$record = [ordered]@{
    schema = 'durins-vault.native-source-state/v1'
    reference_root = $ReferenceRoot
    reference_commit = $commit
    source_scope = 'MyCPPMods/MoriaCppMod/src'
    dirty = ($tracked.Count -gt 0)
    dirty_files = $tracked
    diff_stat = $diffStat
    recorded_on = (Get-Date).ToUniversalTime().ToString('o')
}
$outputPath = if ([IO.Path]::IsPathRooted($Output)) { $Output } else { Join-Path $projectRoot $Output }
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $outputPath) | Out-Null
$record | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $outputPath -Encoding UTF8
$record | Format-List
