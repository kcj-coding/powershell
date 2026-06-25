# command prompt to run
# powershell -noprofile -executionpolicy bypass -file "C:\Users\kelvi\Desktop\PowerShell\folder_and_file_dates1.ps1"

# Rename-Item -Path "c:\logfiles\daily_file.txt" -NewName "monday_file.txt"

# configure manually
$fileFolder = "C:\Users\kelvi\Desktop\date folder" # to store logs


$logFile = "log_tasks.txt"
$logFilePath = Join-Path -Path $fileFolder -ChildPath $logFile

#####################################################################

# check if log file exists
    if (Test-Path -Path $logFilePath -PathType Leaf) { # leaf means file container means folder
    # read file content if file exists
    Remove-Item -Path $logFilePath
}

# get date
$currentDateTime = Get-Date -Format "dd-MM-yyyy_HH:mm:ss" # "yyyy-MM-dd_HH:mm:ss"
$currentDate = Get-Date -Format "dd-MM-yyyy" # "yyyy-MM-dd"

############ create log file if all okay ##############
# add datetime to log file
#Add-Content -Path $logFilePath -Value "$currentDateTime"
"$currentDateTime" | Out-File -FilePath $logFilePath -Encoding UTF8
# add datetime to log file
#Add-Content -Path $logFilePath -Value "$currentDateTime"

"" | Out-File -FilePath $logFilePath -Append -Encoding UTF8
#######################################################################

# regex pattern
$pattern = "(\d+\-\d+\-\d+)"

# find matches
$files = Get-ChildItem -Path $fileFolder -Filter *.txt -Recurse| Where-Object{($_.FullName -match $pattern)} |
% {
# get date from file name
$matches = [regex]::Matches($_, $pattern, 'IgnoreCase') # also SingleLine

$date = $matches.Groups[1].Value.Trim()
write-host $date

$destination = Join-Path -Path $fileFolder -ChildPath $date

write-host $destination
write-host $_.FullName

# make folder if does not exist
if(-not (Test-Path $destination)) { mkdir $destination | out-null}

# move file into folder
#copy-item  $_.fullname ($_.fullname -replace $fileFolder, $destination) -Recurse -Force
Move-Item $_.fullname -Destination $destination # -WhatIf

}








