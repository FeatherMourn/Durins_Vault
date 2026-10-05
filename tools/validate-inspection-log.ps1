[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$Log
)

$ErrorActionPreference = 'Stop'
$logPath = [IO.Path]::GetFullPath($Log)
if (-not (Test-Path -LiteralPath $logPath -PathType Leaf)) { throw "Inspection log does not exist: $logPath" }
$errors = [System.Collections.Generic.List[string]]::new()
$records = [System.Collections.Generic.List[object]]::new()
$lineNumber = 0
foreach ($line in Get-Content -LiteralPath $logPath -Encoding UTF8) {
    $lineNumber++
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    try { $record = $line | ConvertFrom-Json }
    catch { $errors.Add("Line $lineNumber is not valid JSON: $($_.Exception.Message)"); continue }
    foreach ($field in @('timestamp', 'actor_full_name', 'class_full_name')) {
        if ([string]::IsNullOrWhiteSpace([string]$record.$field)) { $errors.Add("Line $lineNumber is missing '$field'") }
    }
    if ($record.timestamp -and $record.timestamp -notmatch '^\d{4}-\d{2}-\d{2}T.*Z$') { $errors.Add("Line $lineNumber has an invalid UTC timestamp") }
    $records.Add($record)
}
if ($errors.Count -gt 0) {
    Write-Error (($errors | ForEach-Object { "- $_" }) -join [Environment]::NewLine)
    exit 2
}
[pscustomobject]@{
    Log = $logPath
    Records = $records.Count
    DistinctClasses = @($records | Select-Object -ExpandProperty class_full_name -Unique).Count
    Status = 'OK'
} | Format-List
