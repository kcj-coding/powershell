# e.g. to run with command prompt
# powershell -noprofile -ExecutionPolicy Bypass -file "C:\Users\kelvi\Desktop\PowerShell\log_tasks.ps1"

# work issue email

# get date
$currentDateTime = Get-Date -Format "dd-MM-yyyy_HH:mm:ss" # "yyyy-MM-dd_HH:mm:ss"
$currentDate = Get-Date -Format "dd-MM-yyyy" # "yyyy-MM-dd"

# just get date
$tryAgain = ((Get-Date) + (New-TimeSpan -Days 3)).ToString("dd-MM-yyyy")
$escalAte = ((Get-Date) + (New-TimeSpan -Days 5)).ToString("dd-MM-yyyy")

# configure variables
$logFolder = "C:\Users\kelvi\Desktop"
$logFile = "log_tasks.txt"
$logFilePath = Join-Path -Path $logFolder -ChildPath $logFile

# capture from user
$tasK = read-host "What is the task"
$probLem = read-host "`nWhat is the problem"

#### clear console and begin ###
clear-host
echo "Starting log creation"

### log the details (append if log file already created)

try {
    # check if log file exists
    if (Test-Path -Path $logFilePath -PathType Leaf) { # leaf means file container means folder
    # read file content if file exists
    $fileContent = Get-Content -Path $logFilePath -ErrorAction Stop

    # check if the text already exists (case-insensitive) (only need to check e.g. 1) problem or task
    $wordPattern = "PROBLEM: $([regex]::Escape($probLem))|TASK: $([regex]::Escape($tasK))"# "PROBLEM: "+[regex]::Escale($probLem)
    $match = Select-String -Path $logFilePath -Pattern $wordPattern -SimpleMatch:$false
    if (-not $match) {
    # if ($fileContent -notcontains $probLem | $fileContent -notcontains $tasK) {
        Add-Content -Path $logFilePath -Value " "
        Add-Content -Path $logFilePath -Value "====== $currentDateTime ======"
        Add-Content -Path $logFilePath -Value "====== TASK: $tasK ======"
        Add-Content -Path $logFilePath -Value "TASK: $tasK"
        Add-Content -Path $logFilePath -Value "PROBLEM: $probLem"
        Add-Content -Path $logFilePath -Value "FOLLOW UP: $tryAgain"
        Add-Content -Path $logFilePath -Value "ESCALATE: $escalAte"
        Add-Content -Path $logFilePath -Value "====== end ======"
        echo "Text appended to existing file: $logFilePath"
    }
    else {
        echo "Text already exists in file. No changes made."
        start-sleep -seconds 1
        exit 1
        }
    }
else {
        # create the file with text
        Add-Content -Path $logFilePath -Value "====== $currentDateTime ======"
        Add-Content -Path $logFilePath -Value "====== TASK: $tasK ======"
        Add-Content -Path $logFilePath -Value "TASK: $tasK"
        Add-Content -Path $logFilePath -Value "PROBLEM: $probLem"
        Add-Content -Path $logFilePath -Value "FOLLOW UP: $tryAgain"
        Add-Content -Path $logFilePath -Value "ESCALATE: $escalAte"
        Add-Content -Path $logFilePath -Value "====== end ======"
        echo "File created and text added to file: $logFilePath"
        }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor -Red
    }

    start-sleep -seconds 1

    echo "Log created."
