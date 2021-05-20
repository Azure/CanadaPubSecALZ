param(
  [Parameter(Mandatory=$true)][string]$filename,
  [Parameter(Mandatory=$true)][string]$varprefix
)
Write-Host "###### varprefix-key=value format (for yaml) ####"
$bicepfile = Get-Content $filename
$bicepfile | ForEach-Object {
    if ($_ -match "param\s(\w+).+'(.*)'"){
        $out = $varprefix+$matches[1]+": "+$matches[2]
        Write-Host ($out)
    }
} 
Write-Host "###### key=varprefix-key format (for az deployment in az devops) ####"
$bicepfile | ForEach-Object {
    if ($_ -match "param\s(\w+).+'(.*)'"){
        $out = $matches[1]+"=`'`$("+$varprefix+$matches[1]+")`' \"
        Write-Host ($out)
    }
} 