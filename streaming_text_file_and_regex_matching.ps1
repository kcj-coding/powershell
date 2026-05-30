# e.g. to run with command prompt
# powershell -noprofile -ExecutionPolicy Bypass -file "C:\Users\kelvi\Desktop\PowerShell\streaming_text_file_and_regex_matching.ps1"


# path to text file
$textFolder = "C:\Users\kelvi\Desktop"
$textFile = "New Text Document.txt"
$textFilePath = Join-Path -Path $textFolder -ChildPath $textFile

# path to  log file
$logFolder = "C:\Users\kelvi\Desktop"
$logFile = "log_spec_chars.txt"
$logFilePath = Join-Path -Path $logFolder -ChildPath $logFile

# create output folder if not exist
if (-not (Test-Path $logFolder)) {
    New-Item -ItemType Directory -Path $logFolder | Out-Null
}

# validate text file exists
if (-not (Test-Path $textFilePath)) {
        throw "Input text not found: $textFilePath"
    }

# check if log file exists - if so remove it so can rebuild
if (Test-Path $logFilePath) {
    Remove-Item $logFilePath
}

# get date
$currentDate = Get-Date -Format "dd-MM-yyyy" # "yyyy-MM-dd"

"-------------------------------------------------" | Out-File -FilePath $logFilePath -Encoding UTF8
$currentDate | Out-File -FilePath $logFilePath -Append -Encoding UTF8

# define regex pattern to search for e.g. special characters
#$pattern = "[^a-zA-Z0-9\s\-\&\+\;\?\=\/\.\(\)\*\,\%\'\""\$]"
$pattern = "[^a-zA-Z0-9]"
$regex = [regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::Compiled)

# read file as stream for quicker processing (not stored in memory)
try {
    $lineNumber = 0
    $matches = foreach ($line in [System.IO.File]::ReadLines($textFilePath)) {
    $lineNumber++
        if ($regex.IsMatch($line)) {
            $specialChars = ($line -split '').Where({ $_ -match $regex }) -join ''
            "Line $lineNumber $specialChars"
        }
    }

    # output results
    $matches | Out-File -FilePath $logFilePath -Append -Encoding UTF8
}
catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor -Red
        Write-Error "Error reading file: $_"
    }

