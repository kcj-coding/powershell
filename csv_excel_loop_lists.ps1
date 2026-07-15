# command prompt to run
# powershell -noprofile -executionpolicy bypass -file "C:\Users\kelvi\Desktop\PowerShell\csv_excel_loop_lists.ps1"

# Rename-Item -Path "c:\logfiles\daily_file.txt" -NewName "monday_file.txt"

# configure manually
$logFolder = "C:\Users\kelvi\Desktop\date folder" # to store logs and search for files
$logFile = "log_tasks.txt"

$num_range = 500
$splitter = 50 # split num_range by this number

$csvFolder = "C:\Users\kelvi\Desktop\date folder" # to store logs and search for files
$csvFile = "log_tasks.csv"
$colNum = 1 # starts from 0

#####################################################################

# function
function Get-ColumnData {
    param (
        [string]$Path,
        [int]$Start,
        [int]$End,
        [int]$colNum
    )

    $ext = [System.IO.Path]::GetExtension($Path).ToLower()

    if ($ext -eq ".csv") {
        $data = Import-Csv -Path $Path -Delimiter ','

    } elseif ($ext -eq ".xlsx") {
        if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
            throw "ImportExcel module not found. Install with: Install-Module ImportExcel"

        }
        Import-Module ImportExcel
        $data = Import-Excel -Path $Path

    } else {
        throw "Unsupported file type: ext"

    }

    # Get column name dynamically
    $colName = ($data | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name)[$colNum]
    if (-not $colName) {
        throw "File does not have a $colNum column."

    }

    # extract rows in range
    return $data | Select-Object -Skip ($Start-1) -First ($End - ($Start + 0)) -ExpandProperty $colName
}

#####################################################################

# clear console
clear-host
echo "Starting log creation"

#####################################################################

# get date
$currentDateTime = Get-Date -Format "dd-MM-yyyy_HH:mm:ss" # "yyyy-MM-dd_HH:mm:ss"
$currentDate = Get-Date -Format "dd-MM-yyyy" # "yyyy-MM-dd"

$logFilePath = Join-Path -Path $logFolder -ChildPath $logFile
$csvFilePath = Join-Path -Path $csvFolder -ChildPath $csvFile

$timer = [System.Diagnostics.Stopwatch]::StartNew()

# log details

try {

# make folder if does not exist
if (-not (Test-Path $logFolder)) { mkdir $logFolder | out-null}

# remove all .txt files in folder
 if (Test-Path $logFolder) {Get-ChildItem -Path $logFolder -Filter *.txt -Recurse | Remove-Item}

 $iters = $num_range/$splitter # make whole number

 # loop trhough iterations
 for ($i = 1; $i -lt $iters+1; $i++) {

    if ($i -eq 1) {$val = 1} else {$val = (($i-1) * $splitter)}

    # get min and max numbers
    $minVal = $val
    $maxVal = $i * $splitter

    # get data
    $values = Get-ColumnData -Path $csvFilePath -Start $minVal -End $maxVal -colNum $colNum

    $values = $values | ForEach-Object {"'$_',"}

    $filer = "$i $logFile"
    $codeFilePath = Join-Path -Path $logFolder -ChildPath $filer

    # write data to file
    Add-Content -Path $codeFilePath -Value "$values"

    #for ($j -eq $val; $j -lt $i*splitter; $j++) {
    #    Add-Content -Path $codeFilePath -Value "$j"

}
$timer.stop
"$currentDateTime" | Out-File -FilePath $logFilePath -Encoding UTF8
Add-Content -Path $logFilePath -Value ""
Add-Content -Path $logFilePath -Value "Time to complete: $($timer.Elapsed.TotalSeconds) seconds"
echo "Log created"
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

start-sleep -seconds 1
#pause