# command prompt to run
# powershell -noprofile -executionpolicy bypass -file "C:\Users\kelvi\Desktop\PowerShell\compare_lines_txt_files1.ps1"

# read lines from two separate txt files and compare for any differences

param (
    #[Parameter(Mandatory = $true)]
    [string]$File1=" ",

    #[Parameter(Mandatory = $true)]
    [string]$File2=" ",

    #[Parameter(Mandatory = $true)]
    [string]$LogFile=" "
)

# configure manually
$fileFolder = "C:\Users\kelvi\Desktop\test"

$File1 = "a.txt"
$file1Path = Join-Path -Path $fileFolder -ChildPath $File1


$File2 = "b.txt"
$file2Path = Join-Path -Path $fileFolder -ChildPath $File2


$logFile = "log_tasks.txt"
$logFilePath = Join-Path -Path $fileFolder -ChildPath $logFile


# or read-host
#$folder = read-host "Enter folder"
#$File1 = read-host "Enter filename and extension of file1"
#$File2 = read-host "Enter filename and extension of file2"

#$logFile = "log_tasks.txt"
#$logFilePath = Join-Path -Path $folder -ChildPath $logFile

# remove .txt files in folder
#Get-ChildItem -Path $fileFolder -Filter *.txt -Recurse | Remove-Item


# get date
$currentDateTime = Get-Date -Format "dd-MM-yyyy_HH:mm:ss" # "yyyy-MM-dd_HH:mm:ss"
$currentDate = Get-Date -Format "dd-MM-yyyy" # "yyyy-MM-dd"

# check if log file exists
    if (Test-Path -Path $logFilePath -PathType Leaf) { # leaf means file container means folder
    # read file content if file exists
    Remove-Item -Path $logFilePath
}

# add datetime to log file
#Add-Content -Path $logFilePath -Value "$currentDateTime"
"$currentDateTime" | Out-File -FilePath $logFilePath -Encoding UTF8

try {
    if (-not (Test-Path $file1Path)) { throw "File not found: $file1Path" }
    if (-not (Test-Path $file2Path)) { throw "File not found: $file2Path" }

    # read files
    $lines1 = Get-Content -LiteralPath $file1Path
    $lines2 = Get-Content -LiteralPath $file2Path

    # determine longest file length
    $maxLines = [Math]::Max($lines1.Count, $lines2.Count)

    "Differences between $File1 and $File2" | Out-File -FilePath $logFilePath -Append -Encoding UTF8
    "----------------" | Out-File -FilePath $logFilePath -Append -Encoding UTF8

    $differencesFound = $false

    for ($i = 0; $i -lt $maxLines; $i++) {
        $lineNum = $i+1
        $text1 = if ($i -lt $lines1.Count) {$lines1[$i] } else { "<No line>" }
        $text2 = if ($i -lt $lines2.Count) {$lines2[$i] } else { "<No line>" }

        if ($text1 -ne $text2) {
            $differencesFound = $true
            "Line $lineNum - File 1: $text1" -join '' | Out-File -FilePath $logFilePath -Append -Encoding UTF8
            "Line $lineNum - File 2: $text2" -join '' | Out-File -FilePath $logFilePath -Append -Encoding UTF8
            "" -join '' | Out-File -FilePath $logFilePath -Append -Encoding UTF8
        }
    }

    if (-not $differencesFound) {
        "No differences found." -join '' | Out-File -FilePath $logFilePath -Append -Encoding UTF8
    }
    
    Write-Host "Comparison complete. Results saved to $logFile"
}
catch {
Write-Error $_
}