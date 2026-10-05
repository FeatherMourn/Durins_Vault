[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Discovery
)
$ErrorActionPreference = 'Stop'
$path = [IO.Path]::GetFullPath($Discovery)
$record = Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json
$required = @('display_name','buildable','recipe_id','class','instance_name','level_path','captured_with','captured_on')
$missing = @($required | Where-Object { $null -eq $record.$_ -or ([string]$record.$_ -eq '' -and $_ -ne 'buildable') })
if ($missing.Count -gt 0) { Write-Error ('Missing discovery fields: ' + ($missing -join ', ')); exit 2 }
if ($record.level_path -notmatch '^/') { Write-Error 'level_path must be an Unreal object path'; exit 2 }
if ($record.captured_on -notmatch '^[0-9]{4}-[0-9]{2}-[0-9]{2}$') { Write-Error 'captured_on must be YYYY-MM-DD'; exit 2 }
[pscustomobject]@{ Discovery = $path; Class = $record.class; Recipe = $record.recipe_id; CapturedWith = $record.captured_with; Status = 'OK' } | Format-List
