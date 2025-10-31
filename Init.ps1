param(
    [string]$environment = "both",
    [boolean]$restoreRepos = $false
)

Import-Module './resources/scripts/git.psm1'
Import-Module './resources/scripts/dotnet.psm1'
Import-Module './resources/scripts/node.psm1'
Import-Module './resources/scripts/pwsh.psm1'

# create directory for frameworks
if (!(Test-Path './domains')) {
    New-Item -ItemType Directory "domains"
} else {
    Write-Host "Folder domains already exists."
}

# create directory for domains
if (!(Test-Path './frameworks')) {
    New-Item -ItemType Directory "frameworks"
} else {
    Write-Host "Folder frameworks already exists."
}

# check prerequisites
Test-GitVersion '2.47'
Test-PowershellVersion "7.4.6"

if (($environment -eq "both") -or ($environment -eq "be")) {
    Write-Host "Checking backend developer prerequisites"
    Test-NetVersion
}

if (($environment -eq "both") -or ($environment -eq "fe")) {
    Write-Host "Checking frontend developer prerequisites"
    Test-NodeVersion '22.9.0'
}

if ($restoreRepos) {
    Write-Host "Restoring repositories"
    Restore-Repositories
}