# command prompt to run
# powershell -noprofile -executionpolicy bypass -file "C:\Users\kelvi\Desktop\PowerShell\list files in folders.ps1"

# Rename-Item -Path "c:\logfiles\daily_file.txt" -NewName "monday_file.txt"

# configure manually
$fileFolder = "C:\Users\kelvi\Desktop\tst" # to store logs
$folderToView = "C:\Users\kelvi" # to search for files and sizes

$newFiles = "new_files.txt"
$newFilePath = Join-Path -Path $fileFolder -ChildPath $newFiles

$logFile = "log_tasks.txt"
$logFilePath = Join-Path -Path $fileFolder -ChildPath $logFile

#####################################################################

$timer = [System.Diagnostics.Stopwatch]::StartNew()

# check if log file exists
    if (Test-Path -Path $logFilePath -PathType Leaf) { # leaf means file container means folder
    # read file content if file exists
    Remove-Item -Path $logFilePath
}

# check if new file exists
    if (Test-Path -Path $newFilePath -PathType Leaf) { # leaf means file container means folder
    # read file content if file exists
    Remove-Item -Path $newFilePath
}

####################################################################

### directory to list files and folders ####
$dir = $folderToView

# get date
$currentDateTime = Get-Date -Format "dd-MM-yyyy_HH:mm:ss" # "yyyy-MM-dd_HH:mm:ss"
$currentDate = Get-Date -Format "dd-MM-yyyy" # "yyyy-MM-dd"

# write res to log file

############ create log file if all okay ##############
# add datetime to log file
#Add-Content -Path $logFilePath -Value "$currentDateTime"
"$currentDateTime" | Out-File -FilePath $logFilePath -Encoding UTF8
"" | Out-File -FilePath $logFilePath -Append -Encoding UTF8
"The folder is $dir" | Out-File -FilePath $logFilePath -Append -Encoding UTF8
"" | Out-File -FilePath $logFilePath -Append -Encoding UTF8


# make a new file which contains the files in a folder

########## output new fie ####################
$folder     = (Get-Item $dir).Parent
$folderName = $folder.Name
$folderPath = $folder.FullName
#$files       = Get-ChildItem -Path $folderPath -Recurse

$res = Get-ChildItem -Path $dir -Recurse |
    Select-Object Fullname #Name, FullName #,
        #@{n='FolderName';e={$folderName}},
        #@{n='Folder';e={$folderPath}}

# write to csv
$res | Out-File -FilePath $newFilePath -Encoding UTF8


$timer.stop
Add-Content -Path $logFilePath -Value "Time to complete: $($timer.Elapsed.TotalSeconds) seconds"
