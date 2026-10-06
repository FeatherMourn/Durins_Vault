[CmdletBinding()]
param(
    [string]$PlanPath,
    [string]$SummaryPath
)
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($PlanPath)) { $PlanPath = Join-Path $scriptRoot '..\data\building\crude-wall-variant-row.json' }
if ([string]::IsNullOrWhiteSpace($SummaryPath)) { $SummaryPath = Join-Path $scriptRoot '..\data\research\construction-datatable-export.json' }
$plan = Get-Content -Raw -LiteralPath $PlanPath | ConvertFrom-Json
$summary = Get-Content -Raw -LiteralPath $SummaryPath | ConvertFrom-Json
$errors = [System.Collections.Generic.List[string]]::new()
if ($plan.schema -ne 'durins-vault.construction-row-plan/v1') { $errors.Add('Unexpected row-plan schema') }
if ($plan.status -ne 'PLAN_ONLY') { $errors.Add('Row plan must remain PLAN_ONLY until full serialization is verified') }
if ($plan.row_struct -ne $summary.verified.row_struct) { $errors.Add('Row struct does not match verified DataTable struct') }
if ($plan.datatable -ne $summary.asset_path) { $errors.Add('DataTable path does not match verified export') }
if ($plan.clone_row -ne $summary.verified.sample_row.id) { $errors.Add('Clone row does not match verified source row') }
if ($plan.evidence.serialized_row_fields -ne $false) { $errors.Add('Serialized row fields must not be claimed yet') }
if ($plan.evidence.deployable -ne $false) { $errors.Add('Plan cannot claim deployable before cooked override testing') }
if ($plan.overrides.actor -notmatch 'BP_Crude_Wall_Variant_C$') { $errors.Add('Variant actor path does not target the cooked Blueprint class') }
if ($errors.Count) { $errors | ForEach-Object { Write-Error $_ }; exit 1 }
[pscustomobject]@{ Plan = $PlanPath; CloneRow = $plan.clone_row; NewRow = $plan.new_row; Status = 'OK'; Deployable = $plan.evidence.deployable } | Format-List
