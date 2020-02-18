$ModulesPath = 'C:\code\infrastructure-modules'
#$ModulesPath = '/home/hemor/Code/infrastructure-modules'
$Tf012Branch = 'tf0_12'
$RegEx = '^\s*\{*\s*required_version\s*=\s*"(.+)"'

Push-Location $ModulesPath
$CurrentBranch = & git rev-parse --abbrev-ref HEAD

# Get current modules in master
git checkout master | Out-Null
$ModuleFolders = Get-ChildItem -Recurse -Filter *.tf | Where-Object { $_.Directory -notlike '*\.*' } | Select-Object -Expand Directory -Unique | ForEach-Object { $_.ToString().Replace("$ModulesPath", "") }

# Compare against TF 0.12 branch
git checkout $Tf012Branch
$ModuleStatus = ForEach ($Folder in $ModuleFolders) {

    $ModulePath = Join-Path $ModulesPath $Folder
    Remove-Variable TfVersion -ErrorAction SilentlyContinue
        
    If (Test-Path $ModulePath -PathType Container) {
        [string]$TfVersion = Get-ChildItem -Path $ModulePath -Filter *.tf | cat | Select-String -Pattern $RegEx | ForEach-Object { $_.matches.groups[1].value }
    }
    else {
        $TfVersion = "Not found in '$Tf012Branch'"
    }

    [PSCustomObject]@{
        ModulePath = $Folder
        TfVersion  = $TfVersion
        Upgraded   = [bool]($TfVersion -like '*0.12*' -or $TfVersion -like 'Not found*')
    }

}

$ModuleCount = $ModuleStatus.Count
$ModuleUpgradeCount = ($ModuleStatus | Where-Object Upgraded).Count
$UpgradeRelative = ($ModuleUpgradeCount / $ModuleCount).ToString('P')

$ModuleStatus | Out-Host
Write-Host "$ModuleUpgradeCount of $ModuleCount ($UpgradeRelative) modules upgraded" -ForegroundColor Green

git checkout $CurrentBranch | Out-Null
Pop-Location
