function Test-GitVersion{ 
    param (
        [Parameter(Mandatory)][string]$requiredVersion
    ) 
    
    $gitVersion = git --version
    $gitRegular = "*" + $requiredVersion + "*"
    if ($gitVersion -like $gitRegular) {
        $message = "Found required version of git " + $requiredVersion + " (" + $gitVersion + ")"
        Write-Host -ForegroundColor Green $message
    } else {
        $message =  "Install git version " + $requiredVersion + " from https://git-scm.com/downloads"
        Write-Host -ForegroundColor Yellow $message
    }
}

function Restore-Repositories {
    $currentLocation = Get-Location
    $repositoriesList = Join-Path $currentLocation "resources" "scripts" "repositories.json"
    if (!(Test-Path -Path $repositoriesList)) {
        Write-Host "Unable to locate repositories list"
        return
    }

    Get-Content -Path $repositoriesList | ConvertFrom-Json | ForEach-Object {
        $pathElements = $_.pathElements
        $targetFolder = Join-Path $currentLocation @pathElements
        $path = Join-Path  $currentLocation @pathElements ".git"
        if (Test-Path -Path $path) {
            Write-Host -ForegroundColor 7 -Message ("Updating " + $_.name + " repository")
            Set-Location $targetFolder
            git checkout main
            git pull >> $LogPath
            Set-Location $currentLocation
        } else {
            Write-Host -ForegroundColor 7 -Message ("Cloning " + $_.name + " repository")
            git clone $_.url $targetFolder >> $logPath
        }
    }  
}


Export-ModuleMember -Function Test-GitVersion
Export-ModuleMember -Function Restore-Repositories
