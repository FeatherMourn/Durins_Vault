[CmdletBinding()]
param(
    [ValidateSet('status', 'validate', 'plan')]
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
    }
}
finally { Pop-Location }
