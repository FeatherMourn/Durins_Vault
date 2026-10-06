[CmdletBinding()]
param(
    [string]$SourceJson = 'H:\DurinsVault_Work\RepeatTest2\DT_Constructions_Variant.json',
    [string]$OutputDirectory = '.\working\definitions\DurinsVaultWallVariant',
    [string]$RowName = 'DurinsVault_Crude_Wall_Variant'
)

$ErrorActionPreference = 'Stop'
$source = Get-Content -LiteralPath $SourceJson -Raw -Encoding UTF8 | ConvertFrom-Json
$row = $source.Exports | ForEach-Object { $_.Table.Data } | Where-Object { $_.Name -eq $RowName } | Select-Object -First 1
if ($null -eq $row) { throw "Row '$RowName' was not found in '$SourceJson'." }

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$valueJson = @{ Value = @($row.Value) } | ConvertTo-Json -Depth 100 -Compress
$escaped = '<![CDATA[' + $valueJson + ']]>'
$definition = @"
<?xml version="1.0" encoding="UTF-8"?>
<definition>
  <title>Durin's Vault Wall Variant</title>
  <author>Durin's Vault</author>
  <description>Adds the verified cooked wall variant to the live construction table.</description>
  <mod file="Moria\Content\Tech\Data\Building\DT_Constructions.json">
    <add_row name="$RowName">$escaped</add_row>
  </mod>
  <mod file="Moria\Content\Tech\Data\Building\DT_ConstructionRecipes.json">
    <add_row name="$RowName"><![CDATA[{"Value":[]}]]></add_row>
  </mod>
</definition>
"@
$defPath = Join-Path $OutputDirectory 'DT_Constructions_DurinsVaultWallVariant.def'
Set-Content -LiteralPath $defPath -Value $definition -Encoding UTF8
$manifest = @"
[ModInfo]
Title = Durin's Vault Wall Variant
Authors = Durin's Vault
Description = Adds the verified cooked wall variant to the construction table.

[Paths]
DurinsVaultWallVariant|DT_Constructions_DurinsVaultWallVariant.def = true

[Settings]
include_secrets = False
"@
$iniPath = Join-Path $OutputDirectory 'Durin''s Vault Wall Variant.ini'
Set-Content -LiteralPath $iniPath -Value $manifest -Encoding UTF8
[pscustomobject]@{ Definition = $defPath; Manifest = $iniPath; Row = $RowName; Status = 'GENERATED' } | Format-List
