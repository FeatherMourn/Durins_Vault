[CmdletBinding()]
param(
    [ValidateSet('status', 'validate', 'plan', 'research')]
    [string]$Command = 'status',
    [string]$Profile = 'steam-local'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
    switch ($Command) {
        'status' {
            Write-Output "Durin's Vault"
            Write-Output "Repository: $root"
            Write-Output "Profile: $Profile"
            & powershell -ExecutionPolicy Bypass -File '.\tools\validate-project.ps1' -Profile $Profile
            if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        }
        'validate' {
            & powershell -ExecutionPolicy Bypass -File '.\tools\validate-all.ps1' -Profile $Profile
            exit $LASTEXITCODE
        }
        'plan' {
            & powershell -ExecutionPolicy Bypass -File '.\tools\plan-profile.ps1' `
                -ModsRoot '.\mods' `
                -JsonOutput '.\working\reports\profile-plan.json'
            exit $LASTEXITCODE
        }
        'research' {
            if (-not (Test-Path -LiteralPath '.\working\reports\runtime-inspection-catalog.json' -PathType Leaf)) {
                Write-Output 'No runtime inspection catalog is available yet. Run a native in-game inspection first.'
                exit 0
            }
            & powershell -ExecutionPolicy Bypass -File '.\tools\summarize-construction-properties.ps1'
            exit $LASTEXITCODE
        }
    }
}
finally { Pop-Location }
