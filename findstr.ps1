# e.g. to run with command prompt
# powershell -noprofile -ExecutionPolicy Bypass -file "C:\Users\kelvi\Desktop\PowerShell\findstr.ps1"

# configure variables
$logFolder = "C:\Users\kelvi\Desktop"
$logFile = "find_string.txt"
$logFilePath = Join-Path -Path $logFolder -ChildPath $logFile

# get from user
$fldr = read-host "What is folder"
$fileType = read-host "`nWhat is filetype"
$paT = read-host "`nWhat is string"


#### clear console and begin ###
clear-host
echo "Starting checks for $paT in $fldr"

################################

$deleteLog = $logFilePath

# if output file exists remove it
if (Test-Path $deletelog) {
    Remove-Item $deleteLog
}

New-Item -Path $deleteLog -ItemType File
$logMessage = "Log entry created on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Content -Path $deleteLog -Value $logMessage

Add-Content -Path $deleteLog -Value "Searching for: $paT"
Add-Content -Path $deleteLog -Value "In folder: $fldr"
Add-Content -Path $deleteLog -Value "If there is no text below this line no match has been found"
Add-Content -Path $deleteLog -Value "==========================================================="

Get-ChildItem -Path $fldr -Filte "*.$fileType" -File -Recurse | 
Sort-Object LastWriteTime -Descending |
Where-Object { Select-String -Path $_.FullName -Pattern $paT -Quiet
Add-Content -Path $deleteLog -Value "FOUND match in $_"}