function Test-PowershellVersion(
    [Parameter(Mandatory=$true)]
    [string]$requiredVersion
) {
    if (!$PSVersionTable.PSVersion -eq $RequiredMajorVersion) {
        $temp = "" + $RequiredMajorVersion + "." + $RequiredMinorVersion + "." + $RequiredPatchVersion
        $message = "Install PowerShell " + $temp + " from https://github.com/PowerShell/powershell/releases"
        Write-Host $LogFile -ForegroundColor 4  -Message $message
    } else {
        $message = "Found PowerShell " + $PSVersionTable.PSEdition + " " + $PSVersionTable.PSVersion
        Write-Host -ForegroundColor 2  -Message $message
    }
}

Export-ModuleMember -Function Test-PowershellVersion