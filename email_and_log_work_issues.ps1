# e.g. to run with command prompt
# powershell -noprofile -ExecutionPolicy Bypass -file "C:\Users\kelvi\Desktop\PowerShell\email_and_log_work_issues.ps1"

# work issue email

# get date
$currentDateTime = Get-Date -Format "dd-MM-yyyy_HH:mm:ss" # "yyyy-MM-dd_HH:mm:ss"
$currentDate = Get-Date -Format "dd-MM-yyyy" # "yyyy-MM-dd"

# generate random reference number
function New-RandomString {
    param (
        [int]$length = 8 # Default length is 8 characters
    )

    # allowed characters A-Z, a-z, 0-9
    $chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefhijklmnopqrstuvwxyz0123456789'
    -join (1..$length | ForEach-Object { $chars[(Get-Random -Minimum 0 -Maximum $chars.Length)]})
}

# configure variables
$logFolder = "C:\Users\kelvi\Desktop"
$logFile = "log_tasks.txt"
$logFilePath = Join-Path -Path $logFolder -ChildPath $logFile

# capture from user
$tasK = read-host "What is the task"
$probLem = read-host "`nWhat is the problem"
$attemptS = read-host "`nWhat has been attempted to solve the problem"
$imPact = read-host "`nWhat is the impact of not progressing"
$stepS = read-host "`nWhat are the next steps"

#### clear console and begin ###
clear-host
echo "Starting email and log creation"

### log the details (append if log file already created)

try {
    # check if log file exists
    if (Test-Path -Path $logFilePath -PathType Leaf) { # leaf means file container means folder
    # read file content if file exists
    $fileContent = Get-Content -Path $logFilePath -ErrorAction Stop

    # generate a unique string
    do {
        $randomString = New-RandomString -Length 10
        $exists = Select-String -Path $logFilePath -Pattern "^\s$randomString\$" - Quiet
    } while ($exists)

    # check if the text already exists (case-insensitive) (only need to check e.g. 1) problem or task
    $wordPattern = "PROBLEM: $([regex]::Escape($probLem))|TASK: $([regex]::Escape($tasK))"# "PROBLEM: "+[regex]::Escale($probLem)
    $match = Select-String -Path $logFilePath -Pattern $wordPattern -SimpleMatch:$false
    if (-not $match) {
    # if ($fileContent -notcontains $probLem | $fileContent -notcontains $tasK) {
        Add-Content -Path $logFilePath -Value " "
        Add-Content -Path $logFilePath -Value "====== $currentDateTime ======"
        Add-Content -Path $logFilePath -Value "====== REFERENCE: $randomString ======"
        Add-Content -Path $logFilePath -Value "TASK: $tasK"
        Add-Content -Path $logFilePath -Value "PROBLEM: $probLem"
        Add-Content -Path $logFilePath -Value "ATEMPTS: $attemptS"
        Add-Content -Path $logFilePath -Value "IMPACT: $imPact"
        Add-Content -Path $logFilePath -Value "NEXt STEPS: $stepS"
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
        Add-Content -Path $logFilePath -Value "====== REFERENCE: $randomString ======"
        Add-Content -Path $logFilePath -Value "TASK: $tasK"
        Add-Content -Path $logFilePath -Value "PROBLEM: $probLem"
        Add-Content -Path $logFilePath -Value "ATEMPTS: $attemptS"
        Add-Content -Path $logFilePath -Value "IMPACT: $imPact"
        Add-Content -Path $logFilePath -Value "NEXt STEPS: $stepS"
        Add-Content -Path $logFilePath -Value "====== end ======"
        echo "File created and text added to file: $logFilePath"
        }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor -Red
    }

    # save draft email ######################

    # create outlook application com object
    $Outlook = New-Object -ComObject Outlook.Application

    # create a new mail item
    $Mail = $Outlook.CreateItem(0) # 0 corresponds to outlook mail item

    # set email properties
    $Mail.Subject = "Work issue - TASK: $task - REF: $randomString"
    $Mail.Body = " Hello ,
    I hope you're well.

    The problem encountered is: $probLem

    The attempts made so far are: $attemptS

    The impact of doing nothing will be: $imPact

    The next steps are: $stepS

    Best wishes,
    Kelvin"
    $Mail.To = "" 
    $Mail.CC = ""
    $Mail.BCC = ""

    # display the email
    $Mail.Display()

    # save the email
    #$Mail.Save()

    start-sleep -seconds 1

    echo "Log and created."
