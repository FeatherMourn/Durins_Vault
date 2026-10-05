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
& powershell -ExecutionPolicy Bypass -File '.\tools\validate-mod-set.ps1' -ModsRoot '.\mods'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$results += [pscustomobject]@{ Check = 'Mod set'; Status = 'OK'; ExitCode = 0 }
& powershell -ExecutionPolicy Bypass -File '.\tools\plan-profile.ps1' -ModsRoot '.\mods' -JsonOutput '.\working\reports\profile-plan.json'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$results += [pscustomobject]@{ Check = 'Profile deployment plan'; Status = 'OK'; ExitCode = 0 }
& powershell -ExecutionPolicy Bypass -File '.\tools\validate-discovery.ps1' -Discovery '.\data\discoveries\crude_wall_3x4_a.json'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$results += [pscustomobject]@{ Check = 'Native discovery record'; Status = 'OK'; ExitCode = 0 }
& powershell -ExecutionPolicy Bypass -File '.\tools\generate-iostore-building-index.ps1'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$results += [pscustomobject]@{ Check = 'IoStore building index'; Status = 'OK'; ExitCode = 0 }
& powershell -ExecutionPolicy Bypass -File '.\tools\validate-building-piece.ps1' -Record '.\data\building\crude-wall-3x4-a.json'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$results += [pscustomobject]@{ Check = 'Crude wall building record'; Status = 'OK'; ExitCode = 0 }
& powershell -ExecutionPolicy Bypass -File '.\tools\validate-building-assets.ps1'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$results += [pscustomobject]@{ Check = 'IoStore building asset catalog'; Status = 'OK'; ExitCode = 0 }
& powershell -ExecutionPolicy Bypass -File '.\tools\generate-datatable-index.ps1'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$results += [pscustomobject]@{ Check = 'IoStore DataTable index'; Status = 'OK'; ExitCode = 0 }
& powershell -ExecutionPolicy Bypass -File '.\tools\validate-building-datatables.ps1'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$results += [pscustomobject]@{ Check = 'Building DataTable catalog'; Status = 'OK'; ExitCode = 0 }

Write-Output ''
Write-Output 'Durin''s Vault validation summary'
$results | Format-Table -AutoSize
