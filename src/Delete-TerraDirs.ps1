$dirs = gci -Recurse -Directory | ? {$_.Name -eq '.terraform' -or $_.Name -eq '.terragrunt-cache'}

Write-Host "Deleting $($dirs.Count) '.terraform' and '.terragrunt-cache' dir(s) recursively..." -ForegroundColor Green

$dirs | rm -Recurse