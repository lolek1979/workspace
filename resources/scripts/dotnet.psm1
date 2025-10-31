function Test-NetVersion {
    $RequiredNetSdkVersion = (Get-Content -Raw -Path global.json | ConvertFrom-Json).Sdk.Version
 
    $NETSdkVersion = "*" + $RequiredNetSdkVersion + "*"
    $InstalledNETSDKs = dotnet --list-sdks
 
    if (!($InstalledNETSDKs -like $NETSdkVersion)) {
        $message = "Install .NET SDK " + $NETSdkVersion + " https://dotnet.microsoft.com/download"
        Write-Host -ForegroundColor Red $message
    } else {
        $message = "Found .NET SDK " + $NETSdkVersion
        Write-Host -ForegroundColor Green $message
    } 
}

Export-ModuleMember -Function Test-NetVersion
