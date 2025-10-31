function Test-NodeVersion(
    [Parameter(Mandatory=$true)]
    [string]$requiredVersion
) {
    $currentVersion = node --version
    $versionRegular = "*" + $requiredVersion + "*"
    if ($currentVersion -like $versionRegular) {
        $message = "Found required version of node " + $requiredVersion + " (" + $currentVersion + ")"
        Write-Host -ForegroundColor Green $message
    } else {
        $message =  "Install node version " + $requiredVersion + " from https://git-scm.com/downloads"
        Write-Host -ForegroundColor Yellow $message
    }
}

Export-ModuleMember -Function Test-NodeVersion