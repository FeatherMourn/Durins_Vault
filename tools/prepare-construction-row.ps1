[CmdletBinding()]
param(
    [string]$ExportPath = '.\working\authoring\asset-export-dt-constructions-imported.json',
    [string]$OutputPath = '.\working\authoring\construction-row-durins-vault-variant.json'
)
$export = Get-Content -Raw -LiteralPath $ExportPath | ConvertFrom-Json
$source = @($export.rows | Where-Object { $_.id -eq 'Crude_Wall' }) | Select-Object -First 1
if (-not $source) { throw 'The verified Crude_Wall source row was not found.' }
$row = $source | ConvertTo-Json -Depth 30 | ConvertFrom-Json
$row.id = 'DurinsVault_Crude_Wall_Variant'
$row.data.DisplayName.Key = 'DurinsVault_Crude_Wall_Variant.Name'
$row.data.DisplayName.SourceString = "Durin's Vault Wall Variant"
$row.data.DisplayName.LocalizedString = "Durin's Vault Wall Variant"
$row.data.Description.Key = 'DurinsVault_Crude_Wall_Variant.Description'
$row.data.Description.SourceString = 'A wall variant authored with Durin''s Vault.'
$row.data.Description.LocalizedString = 'A wall variant authored with Durin''s Vault.'
$actor = '/Game/Durins_Vault/Building/Blueprints/BP_Crude_Wall_Variant.BP_Crude_Wall_Variant_C'
$row.data.Actor.AssetPathName = $actor
$row.data.BackwardCompatibilityActors[0].AssetPathName = $actor
$row | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
[pscustomobject]@{ Output = $OutputPath; SourceRow = 'Crude_Wall'; NewRow = $row.id; Actor = $actor; Fields = $row.data.PSObject.Properties.Name.Count; Status = 'CANDIDATE_ONLY' } | Format-List
