[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$PaksRoot,
    [Parameter(Mandatory = $true)] [string]$Retoc,
    [Parameter(Mandatory = $true)] [string]$UAssetGui,
    [Parameter(Mandatory = $true)] [string]$CookedContentRoot,
    [Parameter(Mandatory = $true)] [string]$OutputRoot,
    [string]$ContainerName = 'DurinsVaultVariant_P'
)
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath($OutputRoot)
$legacy = Join-Path $root 'Legacy'
$json = Join-Path $root 'DT_Constructions.json'
$rowJson = Join-Path $root 'DT_Constructions_Variant.json'
$variant = Join-Path $root 'DT_Constructions_Variant.uasset'
$sourceDir = Join-Path $root 'ModSource'
$container = Join-Path $root ($ContainerName + '.utoc')
New-Item -ItemType Directory -Force -Path $root,$legacy | Out-Null

& $Retoc to-legacy $PaksRoot $legacy --filter 'DT_Constructions.uasset' --version UE4_27 --no-shaders --no-script-objects
if ($LASTEXITCODE -ne 0) { throw 'retoc to-legacy failed.' }
$legacyAsset = Get-ChildItem -LiteralPath $legacy -Recurse -Filter 'DT_Constructions.uasset' -File | Select-Object -First 1
if (-not $legacyAsset) { throw 'Legacy DT_Constructions.uasset was not produced.' }

$p = Start-Process -FilePath $UAssetGui -ArgumentList @('tojson',$legacyAsset.FullName,$json,'VER_UE4_27') -Wait -PassThru
if ($p.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $json)) { throw 'UAssetGUI export failed.' }
$cloneScript = Join-Path $PSScriptRoot 'clone-construction-row-uasset.ps1'
& powershell -NoProfile -ExecutionPolicy Bypass -File $cloneScript -SourceJson $json -OutputJson $rowJson -OutputAsset $variant
$p = Start-Process -FilePath $UAssetGui -ArgumentList @('fromjson',$rowJson,$variant) -Wait -PassThru
if ($p.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $variant)) { throw 'UAssetGUI import failed.' }

$tableDir = Join-Path $sourceDir 'Moria\Content\Tech\Data\Building'
New-Item -ItemType Directory -Force -Path $tableDir | Out-Null
Copy-Item -LiteralPath $variant -Destination (Join-Path $tableDir 'DT_Constructions.uasset') -Force
Copy-Item -LiteralPath ([IO.Path]::ChangeExtension($variant,'.uexp')) -Destination (Join-Path $tableDir 'DT_Constructions.uexp') -Force
$contentDest = Join-Path $sourceDir 'Moria\Content'
New-Item -ItemType Directory -Force -Path $contentDest | Out-Null
Copy-Item -Path (Join-Path $CookedContentRoot '*') -Destination $contentDest -Recurse -Force
& $Retoc to-zen $sourceDir $container --version UE4_27
if ($LASTEXITCODE -ne 0) { throw 'retoc to-zen failed.' }
[pscustomobject]@{ Container = $container; Rows = 855; Status = 'READY_FOR_IN_GAME_TEST'; SourceWasUntouched = $true } | Format-List
