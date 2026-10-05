[CmdletBinding()]
param(
    [string]$UE4SSSource = '',
    [string]$ProjectFile = ''
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($ProjectFile)) { $ProjectFile = Join-Path (Get-Location).Path 'durins-vault.project.json' }
$project = Get-Content -LiteralPath ([IO.Path]::GetFullPath($ProjectFile)) -Raw -Encoding UTF8 | ConvertFrom-Json
$source = if ($UE4SSSource) { [IO.Path]::GetFullPath($UE4SSSource) } else { $null }
$required = @(
    'include\DynamicOutput\Output.hpp',
    'include\Mod\CppUserModBase.hpp',
    'include\Unreal\UObjectGlobals.hpp',
    'include\Unreal\UObject.hpp'
)
$found = @()
if ($source) {
    foreach ($relative in $required) {
        $path = Join-Path $source $relative
        $found += [pscustomobject]@{ Header = $relative; Status = if (Test-Path -LiteralPath $path -PathType Leaf) { 'FOUND' } else { 'MISSING' }; Path = $path }
    }
}
$configured = [string]$project.tools.ue4ss_source
[pscustomobject]@{
    ConfiguredSource = if ($configured) { $configured } else { 'not configured' }
    CandidateSource = if ($source) { $source } else { 'not supplied' }
    RequiredHeaders = $required.Count
    FoundHeaders = @($found | Where-Object Status -eq 'FOUND').Count
    Status = if ($found.Count -gt 0 -and (@($found | Where-Object Status -eq 'MISSING').Count -eq 0)) { 'READY' } else { 'SOURCE_HEADERS_REQUIRED' }
} | Format-List
$found | Format-Table -AutoSize
if ($found.Count -eq 0 -or @($found | Where-Object Status -eq 'MISSING').Count -gt 0) { exit 2 }
