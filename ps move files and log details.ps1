# e.g. to run with command prompt
# powershell -noprofile -executionpolicy bypass -file "C:\Users\kelvi\Desktop\PowerShell\ps move files and log details.ps1"

#########################################################################################################

# Define source and destination folders
$sourceFolder = "C:\Path\To\Source"
$destinationFolder = "C:\Path\To\Destination"
$logFile = "C:\Path\To\Log\move_log.txt"

$NL = [System.Environment]::NewLine

############################# functions #################################################################

function Check-FolderPath {
    param (
        [Parameter(Mandatory=$true)]
        [string]$PathToCheck
    )

    # Use Test-Path to check if the path exists.
    # The result will be $True or $False.
    $pathExists = Test-Path -Path $PathToCheck
    
    if ($pathExists) {
        # Optional: further check if it is a container (directory) and not a file
        $isContainer = (Get-Item -Path $PathToCheck).PSIsContainer
        if ($isContainer) {
            Write-Host "Success: The folder path '$PathToCheck' exists." -ForegroundColor Green
            return $True
        } else {
            Write-Host "Error: The path '$PathToCheck' exists, but it is a file, not a folder." -ForegroundColor Red
            return $False
        }
    } else {
        Write-Host "Error: The folder path '$PathToCheck' does not exist." -ForegroundColor Red
        return $False
    }
}

# function not used

#########################################################################################################

# Display message to user
Write-Host "This PowerShell script will copy and move or simply just move files of a certain type and with certain content from one specify location to another. Unless specifying the file type extension, images or binary files can produce odd results with keyword(s) search"  `r`n # new line

# Get operation type (copy or move) - Check 1 or 2 as values otherwise loop to keep waiting until relevant response received
$response = $null
# Keep looping while the response is not 1 AND not 2
while ($response -ne "1" -and $response -ne "2") {
    $response = Read-Host -Prompt "Please enter 1 to copy files or 2 to move files"

    if ($response -ne "1" -and $response -ne "2") {
        Write-Host "$NL" # make new line
        Write-Host "Invalid entry. Please enter 1 or 2." -ForegroundColor Red
    }
    Write-Host "$NL" # make new line
    if ($response -eq "1"){Write-Host "You have chosen to copy files" -ForegroundColor Green}
    elseif ($response -eq "2") {Write-Host "You have chosen to move files" -ForegroundColor Green}
}

Write-Host "$NL" # make new line

# Query user what extension and keyword to search for and take response as values to use later on
$extension = Read-Host 'Define the file extension to filter files (set to $null or just click Enter key to ignore extension filter)' # ' to capture special characters and speech marks

Write-Host "$NL" # make new line

$keyword = Read-Host 'Define the keyword(s) to filter files and use comma to separate multiple keywords (set to $null or just click Enter key to ignore keyword filter)' # ' to capture special characters and speech marks

# Define the file extension and keyword to filter files
#$extension = ".txt"     # Set to $null or "" to ignore extension filter
#$keyword = "report"     # Set to $null or "" to ignore keyword filter

Write-Host "$NL" # make new line
# Get Source folder to take files from
$sourceFolder = $null#"C:/Folder/Source"
while ($null -eq $sourceFolder -or $sourceFolder -eq "" -or -not(Test-Path -Path $sourceFolder)){
$sourceFolder = Read-Host "Specify the source folder to take files from e.g. C:/Folder/Source"
if ($null -eq $sourceFolder -or $sourceFolder -eq "" -or !(Test-Path -Path $sourceFolder)) {
    echo "ERROR: Source folder '$sourceFolder' not found." -ForegroundColor Red
 }
}


Write-Host "$NL" # make new line
# Get Destination folder to take files from
$destinationFolder = $null#"C:/Folder/Destination"
while ($null -eq $destinationFolder -or $destinationFolder -eq "" -or -not(Test-Path -Path $destinationFolder)){
$destinationFolder = Read-Host "Specify the destination folder to send files to e.g. C:/Folder/Destination"
if ($null -eq $destinationFolder -or $destinationFolder -eq "" -or !(Test-Path -Path $destinationFolder)) {
    echo "ERROR: Destination folder '$destinationFolder' not found." -ForegroundColor Red
 }
}

############ checks folders and log file exist ############################################################

# Create or clear the log file
New-Item -ItemType File -Path $logFile -Force | Out-Null

# Check if source folder exists
if (!(Test-Path -Path $sourceFolder)) {
    $errorMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ERROR: Source folder '$sourceFolder' not found."
    Add-Content -Path $logFile -Value $errorMessage
    return
}

# Ensure destination folder exists
if (!(Test-Path -Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder
    $addedfolderMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') CREATED: Destination folder '$destinationFolder' did not exist."
}

################### copy or move files #########################################################################

# Get all files from the source folder
$files = Get-ChildItem -Path $sourceFolder -File

# Get count of files found and write to log
$filesCount = $files.Count
$filesCountMessage = "Files found in folder: $filesCount"
Add-Content -Path $logFile -Value $filesCountMessage

# Filter files based on extension and/or keyword
#$filesToCopy = $files | Where-Object {
#    ($null -eq $extension -or $extension -eq "" -or $_.Extension -eq $extension) -and
#    ($null -eq $keyword -or $keyword -eq "" -or Select-String -Pattern $keyword -SimpleMatch) # -or $_.Name -like "*$keyword*")
#}

# checking files to copy
$filesToCopy = $files | Where-Object {
    # 1. Check Extension (original logic)
    $extMatches = ($null -eq $extension -or $extension -eq "" -or $_.Extension -eq $extension) # -and

    # 2. Check Keywords: Only execute search logic if the keywords variable is not null/empty
    if ([string]::IsNullOrEmpty($keyword)) {
        # If keywords are null/empty, we assume this part of the AND logic passes (true)
        $keywordMatches = $true
    } else {
        # Keywords are present, so perform the content search
        $keywordsArray = $keyword.Split(',')
        
        # Use Select-String, explicitly passing the CURRENT item's FULL PATH
        # We wrap this in a boolean check ($null -ne ...) to return True if a match is found
        $keywordMatches = $null -ne (Select-String -Path $_.FullName -Pattern $keywordsArray -SimpleMatch -Quiet)# -ErrorAction Stop)

    }

# 3. Combine the results using the -and operator
    # The Where-Object block takes the final combined boolean result
    $extMatches -and $keywordMatches
}

# Get count of filtered files found and write to log
$filesFilterCount = if ($filesToCopy.Count -ne $null -and $filesToCopy.Count -ne 0) { $filesToCopy.Count } else { 0 }
$filesFilterCountMessage = "Filtered files found in folder: $filesFilterCount"
Add-Content -Path $logFile -Value $filesFilterCountMessage

########################## log files ##############################################################################

# Check of filesToCopy

foreach ($file in $filesToCopy) {
    $sourcePath = $file.FullName
    $destinationPath = Join-Path -Path $destinationFolder -ChildPath $file.Name
    $fileSize = [Math]::Round($file.Length / 1KB, 2)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    try {
        if ($response -eq "2") {
        	Move-Item -Path $sourcePath -Destination $destinationPath} # moves file
        elseif ($response -eq "1") {
        	Copy-Item -Path $sourcePath -Destination $destinationPath} # copies file
        else {
                Write-Host "Error" -ForegroundColor Red}
        $logEntry = "$timestamp - Moved '$($file.Name)' ($fileSize KB) to '$destinationFolder'"
    } catch {
        $logEntry = "$timestamp - FAILED to move '$($file.Name)': $_"
    }

    Add-Content -Path $logFile -Value $logEntry
}

##########################################################################################################

# write message to console
Write-Host "$NL" # make new line
if ($response -eq "1"){
echo "Copied this many files: $filesFilterCount"}
elseif ($response -eq "2"){
echo "Moved this many files: $filesFilterCount"}

# keep PowerShell script open
Write-Host "$NL" # make new line
Pause
# No Exit