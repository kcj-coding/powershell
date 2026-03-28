# https://learn.microsoft.com/en-us/answers/questions/597931/convert-xlsx-to-csv-using-powershell

# execute via command prompt
# powershell -noprofile -executionpolicy bypass -File "C:\Users\kelvi\Desktop\PowerShell\open and convert xls files to csv.ps1"

# param must be first statement in script everything else before it must be commented out

param(
    [string]$SourceFolder = "C:\InputExcels",       # Folder containing .xls* files
    [string]$DestinationFolder = "C:\OutputCSVs",   # Folder to save CSVs
    [string]$SheetName = "Sheet1",                  # Worksheet name to import
    [int]$EndColumn = 5                             # Last column number to include
)

# Ensure ImportExcel module is available
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Error "ImportExcel module not found. Install with: Install-Module ImportExcel"
    #exit
}

# Prompt user for values to be used
echo "Please specify the values to use below"

$SourceFolder = Read-Host "Input folder"
$DestinationFolder = Read-Host "Destination folder"
$SheetName = Read-Host "Sheet name"
$EndColumn = Read-Host "Number of columns"

# Create destination folder if it doesn't exist
if (-not (Test-Path $DestinationFolder)) {
    New-Item -ItemType Directory -Path $DestinationFolder | Out-Null
}

$LogFile = "move_log.txt"
$logFile = New-Item -ItemType File (Join-Path $DestinationFolder $LogFile)

# Process each Excel file and log details of what has happened
Get-ChildItem -Path $SourceFolder -Filter "*.xls*" | ForEach-Object {
    $excelFile = $_.FullName
    $baseName  = $_.BaseName
    $csvFile   = Join-Path $DestinationFolder "$baseName.csv"

    Write-Host "Processing $excelFile ..."`

    # Import the sheet
    $data = Import-Excel -Path $excelFile -WorksheetName $SheetName

    if ($null -eq $data) {
        Write-Warning "Sheet '$SheetName' not found in $excelFile"
        return
    }

    # Select only columns 1..EndColumn
    #$columns = $data.PSObject.Properties.Name[0..($EndColumn-1)]
    $columns = $data | Select-Object -Property ( ($data[0].PSObject.Properties.Name[0..($EndColumn-1)]))
    $trimmed = $columns #$data | Select-Object $columns

    # Export to CSV
    $trimmed | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8

    Write-Host "Saved $csvFile"

   # log successful processing
   $fileLogMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') SUCCESS: File '$excelFile' converted to '$baseName.csv'."
   Add-Content -Path $logFile -Value $fileLogMessage
}

# Prevent from closing
Pause
# No exit
