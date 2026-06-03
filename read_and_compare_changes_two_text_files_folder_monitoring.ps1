# command prompt to run
# powershell -noprofile -executionpolicy bypass -file "C:\Users\kelvi\Desktop\PowerShell\read_and_compare_changes_two_text_files_folder_monitoring.ps1"

# Rename-Item -Path "c:\logfiles\daily_file.txt" -NewName "monday_file.txt"

# configure manually
$fileFolder = "C:\Users\kelvi\Desktop\tst"

$oldFiles = "old_files.txt"
$oldFilePath = Join-Path -Path $fileFolder -ChildPath $oldFiles

$newFiles = "new_files.txt"
$newFilePath = Join-Path -Path $fileFolder -ChildPath $newFiles

$logFile = "log_tasks.txt"
$logFilePath = Join-Path -Path $fileFolder -ChildPath $logFile

#####################################################################

# check if log file exists
    if (Test-Path -Path $logFilePath -PathType Leaf) { # leaf means file container means folder
    # read file content if file exists
    Remove-Item -Path $logFilePath
}

# check if old file exists
    if (-not (Test-Path -Path $oldFilePath -PathType Leaf)) { # leaf means file container means folder
   Write-Host "Required file $oldFiles missing. Exiting script..." -ForegroundColor Red
   exit
}

####################################################################

### directory to list files and folders ####
$dir = $fileFolder 

# get date
$currentDateTime = Get-Date -Format "dd-MM-yyyy_HH:mm:ss" # "yyyy-MM-dd_HH:mm:ss"
$currentDate = Get-Date -Format "dd-MM-yyyy" # "yyyy-MM-dd"

########## get folders and sizes of folders in folder #################
$results =@() # array
$fldrSize = "{0:N2} MB" -f ((Get-ChildItem $dir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB)

try {
Get-ChildItem -Directory $dir | ForEach-Object {
$size = (Get-ChildItem $_.FullName -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
$results += [PSCustomObject]@{
FolderName = $_.FullName
SizeMB = "{0:N2}" -f $size
}
} | Sort-Object SizeMB -Descending
} Catch {Write-Error $_}

####################################################################

# write res to log file

############ create log file if all okay ##############
# add datetime to log file
#Add-Content -Path $logFilePath -Value "$currentDateTime"
"$currentDateTime" | Out-File -FilePath $logFilePath -Encoding UTF8
"" | Out-File -FilePath $logFilePath -Append -Encoding UTF8
"The folder is $dir and the foldersize is $fldrSize" | Out-File -FilePath $logFilePath -Append -Encoding UTF8
"" | Out-File -FilePath $logFilePath -Append -Encoding UTF8
$results | Out-File -FilePath $logFilePath -Append -Encoding UTF8


# make a new file which contains the files in a folder

########## output new fie ####################
$folder     = (Get-Item $dir).Parent
$folderName = $folder.Name
$folderPath = $folder.FullName

$res = Get-ChildItem -Directory $dir -Recurse |
    Select-Object Fullname #Name, FullName #,
        #@{n='FolderName';e={$folderName}},
        #@{n='Folder';e={$folderPath}}

# write to csv
$res | Out-File -FilePath $newFilePath -Encoding UTF8

##############################################################

# if no old file found everything is new

try {

# check if what is in file a is in file b (if not these are new enrties)

$file2HashSet = [Linq.Enumerable]::ToHashSet(
  [string[]] (Get-Content -Path $oldFilePath),
  [StringComparer]::CurrentCultureIgnoreCase
)

$diff = Get-Content -Path $newFilePath | Where-Object {-not $file2HashSet.Contains($_)}

"Any new entries are below:" | Out-File -FilePath $logFilePath -Append -Encoding UTF8
"---------------------------------------" | Out-File -FilePath $logFilePath -Append -Encoding UTF8

if ($diff){

"These are new entries:" | Out-File -FilePath $logFilePath -Append -Encoding UTF8
$diff | Out-File -FilePath $logFilePath -Append -Encoding UTF8
"" | Out-File -FilePath $logFilePath -Append -Encoding UTF8
}

##############################################################

# check if what is in file b is in file a (if not these are removed entires)

$file1HashSet = [Linq.Enumerable]::ToHashSet(
  [string[]] (Get-Content -Path $newFilePath),
  [StringComparer]::CurrentCultureIgnoreCase
)

$diff2 = Get-Content -Path $oldFilePath | Where-Object {-not $file1HashSet.Contains($_)}

"Any old entries are below:" | Out-File -FilePath $logFilePath -Append -Encoding UTF8
"---------------------------------------" | Out-File -FilePath $logFilePath -Append -Encoding UTF8

if ($diff2){
"These are removed entries:" | Out-File -FilePath $logFilePath -Append -Encoding UTF8
$diff2 | Out-File -FilePath $logFilePath -Append -Encoding UTF8
"" | Out-File -FilePath $logFilePath -Append -Encoding UTF8
}

############################################################

# remove $oldFilePath
 if (Test-Path -Path $oldFilePath -PathType Leaf) { # leaf means file container means folder
    # read file content if file exists
    Remove-Item -Path $oldFilePath
}

# rename new file to old file
Rename-Item -Path $newFilePath -NewName $oldFilePath

# remove $newFilePath
 if (Test-Path -Path $newFilePath -PathType Leaf) { # leaf means file container means folder
    # read file content if file exists
    Remove-Item -Path $newFilePath
}

# Source - https://stackoverflow.com/a/61299576

} catch {
Write-Error $_
}