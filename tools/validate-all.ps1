[CmdletBinding()]
param(
    [string]$Profile = 'steam-local'
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Get-Location).Path
$scriptRoot = Join-Path $projectRoot 'tools'
$results = @()
& powershell -ExecutionPolicy Bypass -File '.\tools\validate-project.ps1'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$results += [pscustomobject]@{ Check = 'Project environment'; Status = 'OK'; ExitCode = 0 }
& powershell -ExecutionPolicy Bypass -File '.\tools\validate-mod.ps1' -Manifest '.\mods\example-wall\mod.json'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$results += [pscustomobject]@{ Check = 'Example mod definition'; Status = 'OK'; ExitCode = 0 }
& powershell -ExecutionPolicy Bypass -File '.\tools\validate-building-piece.ps1' -Record '.\data\building\crude-wall-3x4-a.json'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$results += [pscustomobject]@{ Check = 'Crude wall building record'; Status = 'OK'; ExitCode = 0 }

Write-Output ''
Write-Output 'Durin''s Vault validation summary'
$results | Format-Table -AutoSize
