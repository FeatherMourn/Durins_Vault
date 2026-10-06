[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$SourceJson,
    [Parameter(Mandatory = $true)] [string]$OutputJson,
    [Parameter(Mandatory = $true)] [string]$OutputAsset
)
$asset = Get-Content -Raw -LiteralPath $SourceJson | ConvertFrom-Json
$table = $asset.Exports[0].Table.Data
$source = @($table | Where-Object { $_.Name -eq 'Crude_Wall' }) | Select-Object -First 1
if (-not $source) { throw 'Crude_Wall row was not found in the UAssetGUI JSON.' }
$clone = $source | ConvertTo-Json -Depth 40 | ConvertFrom-Json
$rowName = 'DurinsVault_Crude_Wall_Variant'
$actor = '/Game/Durins_Vault/Building/Blueprints/BP_Crude_Wall_Variant.BP_Crude_Wall_Variant_C'
$clone.Name = $rowName
foreach ($property in $clone.Value) {
    if ($property.Name -eq 'DisplayName') { $property.Value = "$rowName.Name" }
    elseif ($property.Name -eq 'Description') { $property.Value = "$rowName.Description" }
    elseif ($property.Name -eq 'Actor') { $property.Value.AssetPath.AssetName = $actor }
    elseif ($property.Name -eq 'BackwardCompatibilityActors') { $property.Value[0].Value[0].Value.AssetPath.AssetName = $actor }
}
$asset.Exports[0].Table.Data = @($table) + @($clone)
$requiredNames = @($rowName, "$rowName.Name", "$rowName.Description", $actor)
foreach ($name in $requiredNames) {
    if (@($asset.NameMap) -notcontains $name) { $asset.NameMap += $name }
}
$asset | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $OutputJson -Encoding UTF8
[pscustomobject]@{ OutputJson = $OutputJson; OutputAsset = $OutputAsset; OriginalRows = @($table).Count; NewRows = @($asset.Exports[0].Table.Data).Count; NewRow = $rowName; Actor = $actor; Status = 'READY_FOR_UASSETGUI_IMPORT' } | Format-List
