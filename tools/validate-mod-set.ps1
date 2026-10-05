[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ModsRoot
)

$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath($ModsRoot)
if (-not (Test-Path -LiteralPath $root -PathType Container)) { throw "Mods root does not exist: $root" }
$manifests = @(Get-ChildItem -LiteralPath $root -Filter mod.json -File -Recurse)
$errors = [System.Collections.Generic.List[string]]::new()
$byId = @{}
$records = @{}
if ($manifests.Count -eq 0) { throw "No mod.json manifests found under: $root" }

foreach ($file in $manifests) {
    try { $mod = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8 | ConvertFrom-Json }
    catch { $errors.Add("Invalid JSON: $($file.FullName) - $($_.Exception.Message)"); continue }
    if ([string]::IsNullOrWhiteSpace([string]$mod.id)) { $errors.Add("Manifest is missing id: $($file.FullName)"); continue }
    if ($byId.ContainsKey($mod.id)) {
        $errors.Add("Duplicate mod id '$($mod.id)': $($byId[$mod.id]) and $($file.FullName)")
        continue
    }
    $byId[$mod.id] = $file.FullName
    $records[$mod.id] = $mod
}

foreach ($id in @($records.Keys)) {
    foreach ($dependency in @($records[$id].requires)) {
        if ($dependency.id -and -not $byId.ContainsKey($dependency.id)) {
            $errors.Add("Mod '$id' requires unavailable mod '$($dependency.id)'")
        }
    }
}

$visiting = @{}
$visited = @{}
function Visit([string]$Id, [string[]]$Chain) {
    if ($visiting.ContainsKey($Id)) {
        $errors.Add("Dependency cycle detected: $((@($Chain) + $Id) -join ' -> ')")
        return
    }
    if ($visited.ContainsKey($Id) -or -not $records.ContainsKey($Id)) { return }
    $visiting[$Id] = $true
    foreach ($dependency in @($records[$Id].requires)) {
        if ($dependency.id) { Visit $dependency.id (@($Chain) + $Id) }
    }
    $visiting.Remove($Id)
    $visited[$Id] = $true
}
foreach ($id in @($records.Keys)) { Visit $id @() }

if ($errors.Count -gt 0) {
    Write-Error (($errors | ForEach-Object { "- $_" }) -join [Environment]::NewLine)
    exit 2
}
[pscustomobject]@{
    ModsRoot = $root
    Manifests = $manifests.Count
    ModIds = (@($records.Keys) | Sort-Object) -join ', '
    Status = 'OK'
} | Format-List
